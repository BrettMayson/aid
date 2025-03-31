use arma_rs::{Context, ContextState, Group};
use dashmap::DashMap;

use crate::{player::Contacts, NetId, Radio};

pub fn group() -> Group {
    Group::new()
        .command("set", cmd_set)
        .command("get", cmd_get)
        .command("remove", cmd_remove)
        .command("clear", cmd_clear)
}

fn cmd_set(ctx: Context, radio: Radio, net_id: NetId) -> Result<(), String> {
    let objects = ctx.global().get::<Objects>().unwrap_or_else(|| {
        println!("No objects found, creating new one");
        ctx.global().set(Objects::new());
        ctx.global().get::<Objects>().unwrap()
    });
    println!("Set owner: {} -> {}", radio.0, net_id.0);
    let contacts = ctx.global().get::<Contacts>().unwrap_or_else(|| {
        println!("No contacts found, creating new one");
        ctx.global().set(Contacts::new());
        ctx.global().get::<Contacts>().unwrap()
    });
    contacts.owner_switch(&radio, &net_id);
    objects.set_owner(radio, net_id);
    Ok(())
}

fn cmd_get(ctx: Context, radio: Radio) -> Result<NetId, String> {
    let objects = ctx.global().get::<Objects>().unwrap_or_else(|| {
        println!("No objects found, creating new one");
        ctx.global().set(Objects::new());
        ctx.global().get::<Objects>().unwrap()
    });
    if let Some(net_id) = objects.get_owner(&radio) {
        Ok(net_id)
    } else {
        Err("No owner found".to_string())
    }
}

fn cmd_remove(ctx: Context, radio: Radio) -> Result<(), String> {
    let objects = ctx.global().get::<Objects>().unwrap_or_else(|| {
        println!("No objects found, creating new one");
        ctx.global().set(Objects::new());
        ctx.global().get::<Objects>().unwrap()
    });
    println!("Remove radio: {}", radio.0);
    objects.remove_radio(radio);
    Ok(())
}

fn cmd_clear(ctx: Context) -> Result<(), String> {
    let objects = ctx.global().get::<Objects>().unwrap_or_else(|| {
        println!("No objects found, creating new one");
        ctx.global().set(Objects::new());
        ctx.global().get::<Objects>().unwrap()
    });
    objects.objects.clear();
    Ok(())
}

pub struct Objects {
    pub objects: DashMap<Radio, NetId>,
}

impl Objects {
    pub fn new() -> Self {
        Self {
            objects: DashMap::new(),
        }
    }

    pub fn set_owner(&self, radio: Radio, net_id: NetId) {
        self.objects.insert(radio, net_id);
    }

    pub fn get_owner(&self, radio: &Radio) -> Option<NetId> {
        self.objects.get(radio).map(|v| v.clone())
    }

    pub fn remove_radio(&self, radio: Radio) {
        self.objects.remove(&radio);
    }
}
