use std::{collections::HashMap, sync::RwLock};

use arma_rs::{Context, ContextState, Group};
use dashmap::DashMap;

use crate::{mesh::Networks, object::Objects, ConnectionInfo, Frequency, NetId, Radio};

pub fn group() -> Group {
    Group::new()
        .command("set", cmd_set)
        .command("connections", cmd_connections)
}

pub type Connection = (Frequency, Radio, ConnectionInfo);

pub struct RadioList(RwLock<Vec<(Radio, Frequency)>>);
pub struct Contacts {
    last: RwLock<HashMap<NetId, HashMap<(Radio, Radio), Connection>>>,
    current: DashMap<NetId, HashMap<(Radio, Radio), Connection>>,
}

impl Contacts {
    pub fn new() -> Self {
        Contacts {
            last: RwLock::new(HashMap::new()),
            current: DashMap::new(),
        }
    }

    pub fn player_radios(&self, radios: &[(Radio, Frequency)]) {
        for mut item in self.current.iter_mut() {
            let connections = item.value_mut();
            connections.retain(|(_, radio), (freq, _, _)| {
                radios.iter().any(|(r, f)| r == radio && f == freq)
            });
        }
    }

    pub fn remove_radio(&self, radio: &Radio) {
        for mut item in self.current.iter_mut() {
            let connections = item.value_mut();
            connections.retain(|_, (_, from, _)| from != radio);
        }
    }

    pub fn owner_switch(&self, radio: &Radio, net_id: &NetId) {
        for mut item in self.current.iter_mut() {
            if item.key() == net_id {
                continue;
            }
            let connections = item.value_mut();
            connections.retain(|_, (_, from, _)| from != radio);
        }
    }

    /// Save the current contacts to last
    /// Notifies if:
    /// - A new contact is added
    /// - A contact is removed
    pub fn apply_changes(&self, ctx: &Context) -> Result<(), String> {
        let mut new_contacts = HashMap::new();
        for item in self.current.iter() {
            let mut connections = item.value().clone();
            connections.retain(|_, info| info.2 .0 .0 != 0);
            if connections.is_empty() {
                continue;
            }
            new_contacts.insert(item.key().clone(), connections);
        }
        let mut last = self.last.write().unwrap();
        for (net_id, connections) in new_contacts.iter() {
            let count = connections.len();
            if count == 0 {
                continue;
            }
            if last.get(net_id).is_none() && *net_id != NetId::empty() {
                println!("New contact: {} -> {:?}", net_id.0, connections);
                if let Err(e) = ctx.callback_data("aid_contacts", "added", net_id.0.clone()) {
                    println!("Failed to send callback: {e}");
                }
            }
        }
        for (net_id, _) in last.iter() {
            if !new_contacts.contains_key(net_id) && *net_id != NetId::empty() {
                println!("Contact removed: {}", net_id.0);
                if let Err(e) = ctx.callback_data("aid_contacts", "removed", net_id.0.clone()) {
                    println!("Failed to send callback: {e}");
                }
            }
        }
        last.clear();
        for (net_id, connections) in new_contacts {
            if connections.is_empty() {
                continue;
            }
            last.insert(net_id.clone(), connections);
        }
        Ok(())
    }
}

/// Set the player's radios
fn cmd_set(ctx: Context, radios: Vec<(Radio, Frequency)>) -> Result<(), String> {
    let list = ctx.global().get::<RadioList>().unwrap_or_else(|| {
        println!("No radio list found, creating new one");
        ctx.global().set(RadioList(RwLock::new(Vec::new())));
        ctx.global().get::<RadioList>().unwrap()
    });
    if *list.0.read().unwrap() == radios {
        return Ok(());
    }
    println!("Set radios: {radios:?}");
    let mut list = list.0.write().unwrap();
    let contacts = ctx.global().get::<Contacts>().unwrap_or_else(|| {
        println!("No contacts found, creating new one");
        ctx.global().set(Contacts::new());
        ctx.global().get::<Contacts>().unwrap()
    });
    list.clear();
    contacts.player_radios(&radios);
    for (radio, freq) in radios {
        list.push((radio, freq));
    }
    Ok(())
}

/// Get a connected unit's radios
fn cmd_connections(ctx: Context, unit: NetId) -> Result<Vec<(Radio, Connection)>, String> {
    let contacts = ctx.global().get::<Contacts>().unwrap_or_else(|| {
        println!("No contacts found, creating new one");
        ctx.global().set(Contacts::new());
        ctx.global().get::<Contacts>().unwrap()
    });
    let last = contacts.last.read().unwrap();
    let Some(connections) = last.get(&unit) else {
        return Ok(Vec::new());
    };
    let mut radios = Vec::new();
    for (radio, info) in connections.iter() {
        radios.push((radio.clone(), info.clone()));
    }
    radios.sort_by(|a, b| a.0.cmp(&b.0));
    Ok(radios
        .into_iter()
        .map(|((_, radio), info)| (radio, info))
        .collect::<Vec<_>>())
}

pub fn process(ctx: &Context, networks: &Networks, from: Radio) -> Result<(), String> {
    let Some(list) = ctx.global().get::<RadioList>() else {
        return Ok(());
    };
    let list = list.0.read().unwrap();
    if list.is_empty() || list.iter().any(|(radio, _)| radio == &from) {
        return Ok(());
    }
    let contacts = ctx.global().get::<Contacts>().unwrap_or_else(|| {
        println!("No contacts found, creating new one");
        ctx.global().set(Contacts::new());
        ctx.global().get::<Contacts>().unwrap()
    });
    let owners = ctx.global().get::<Objects>().unwrap_or_else(|| {
        println!("No objects found, creating new one");
        ctx.global().set(Objects::new());
        ctx.global().get::<Objects>().unwrap()
    });
    for (radio, freq) in list.iter() {
        let Some(network) = networks.get(freq) else {
            println!("No network found for frequency {}", freq.0);
            continue;
        };
        let Some(owner) = owners.get_owner(&from) else {
            println!("No owner found for radio {}", from.0);
            if let Err(e) = ctx.callback_data("aid_network", "request_owner", from.0.clone()) {
                println!("Failed to send callback: {e}");
            } else {
                println!("Requested owner for radio {}", from.0);
            }
            continue;
        };
        if owner == NetId::empty() {
            println!("Empty owner, requesting owner");
            if let Err(e) = ctx.callback_data("aid_network", "request_owner", from.0.clone()) {
                println!("Failed to send callback: {e}");
            } else {
                println!("Requested owner for radio {}", from.0);
            }
        }
        let mut owner_contact = contacts.current.entry(owner).or_insert_with(HashMap::new);
        let info = network
            .read()
            .expect("not poisoned")
            .get_connection(&from, radio);
        if let Some(info) = info {
            if info.0 .0 == 0 {
                owner_contact.remove(&(from.clone(), radio.clone()));
            } else {
                owner_contact.insert(
                    (from.clone(), radio.clone()),
                    (freq.clone(), from.clone(), info),
                );
            }
        } else {
            owner_contact.remove(&(from.clone(), radio.clone()));
        }
    }
    contacts.apply_changes(ctx)
}
