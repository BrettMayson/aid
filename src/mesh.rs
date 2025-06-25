use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::sync::RwLock;
use std::time::SystemTime;

use arma_rs::Context;
use arma_rs::ContextState;
use arma_rs::Group;
use dashmap::DashMap;

use crate::ConnectionInfo;
use crate::Frequency;
use crate::Link;
use crate::Radio;
use crate::Strength;

pub fn group() -> Group {
    Group::new()
        .command("set", cmd_set)
        .command("get", cmd_get)
        .command("remove", cmd_remove)
        .command("clear", cmd_clear)
}

fn cmd_set(
    ctx: Context,
    from: Radio,
    to: Radio,
    freq: Frequency,
    strength: Strength,
    db: f32,
) -> Result<(), String> {
    let networks = ctx.global().get::<Networks>().unwrap_or_else(|| {
        println!("No networks found, creating new one");
        ctx.global().set(Networks::new());
        ctx.global().get::<Networks>().unwrap()
    });
    // remove `from` from all networks, except the one we are adding to
    for network in networks.networks.iter_mut() {
        if network.key() != &freq {
            network
                .write()
                .expect("not poisoned")
                .remove_radio(from.clone());
        }
    }
    let network = networks
        .networks
        .entry(freq)
        .or_insert_with(|| RwLock::new(MeshNetwork::new()));

    network
        .write()
        .expect("not poisoned")
        .add_connection(from.clone(), to, strength, db);

    drop(network);

    crate::player::process(&ctx, networks, from)?;

    Ok(())
}

// Returns
// - the minimum strength along the path
// - the minimum decibels along the path
// - a list of nodes along the path with their strength
fn cmd_get(
    ctx: Context,
    from: Radio,
    to: Radio,
    freq: Frequency,
) -> Result<(Strength, f32, Vec<Link>), String> {
    let networks = ctx.global().get::<Networks>().unwrap_or_else(|| {
        println!("No networks found, creating new one");
        ctx.global().set(Networks::new());
        ctx.global().get::<Networks>().unwrap()
    });
    let network = networks
        .networks
        .get(&freq)
        .ok_or_else(|| format!("Frequency not found: `{:?}`", freq))?;
    let network = network.read().expect("not poisoned");
    let (strength, path) = network
        .get_connection(&from, &to)
        .ok_or_else(|| "No path found".to_string())?;
    let min_db = path
        .iter()
        .map(|(_, _, db)| *db)
        .fold(f32::INFINITY, f32::min);
    Ok((strength, min_db, path))
}

fn cmd_remove(ctx: Context, radio: Radio) -> Result<(), String> {
    let networks = ctx.global().get::<Networks>().unwrap_or_else(|| {
        println!("No networks found, creating new one");
        ctx.global().set(Networks::new());
        ctx.global().get::<Networks>().unwrap()
    });
    for network in networks.networks.iter_mut() {
        network
            .write()
            .expect("not poisoned")
            .remove_radio(radio.clone());
    }
    crate::player::process(&ctx, networks, radio)?;
    Ok(())
}

fn cmd_clear(ctx: Context) -> Result<(), String> {
    let networks = ctx.global().get::<Networks>().unwrap_or_else(|| {
        println!("No networks found, creating new one");
        ctx.global().set(Networks::new());
        ctx.global().get::<Networks>().unwrap()
    });
    for network in networks.networks.iter_mut() {
        network.write().expect("not poisoned").connections.clear();
    }
    Ok(())
}

pub struct Networks {
    networks: DashMap<Frequency, RwLock<MeshNetwork>>,
}

impl Networks {
    /// Create a new Networks instance
    pub fn new() -> Self {
        Networks {
            networks: DashMap::new(),
        }
    }

    pub fn get<'a>(
        &'a self,
        key: &Frequency,
    ) -> Option<dashmap::mapref::one::Ref<'a, Frequency, std::sync::RwLock<MeshNetwork>>> {
        self.networks.get(key)
    }
}

pub struct MeshNetwork {
    pub connections: HashMap<Radio, HashMap<Radio, (Strength, f32, SystemTime)>>, // (strength, decibels, time)
}

impl MeshNetwork {
    /// Create a new MeshNetwork
    pub fn new() -> Self {
        MeshNetwork {
            connections: HashMap::new(),
        }
    }

    /// Add a connection between two nodes with given strength and decibels
    pub fn add_connection(
        &mut self,
        node_a: Radio,
        node_b: Radio,
        strength: Strength,
        decibels: f32,
    ) {
        self.connections
            .entry(node_a)
            .or_default()
            .insert(node_b, (strength, decibels, SystemTime::now()));
    }

    /// Get the best path between two nodes based on highest minimum strength
    pub fn get_connection(&self, start: &Radio, end: &Radio) -> Option<ConnectionInfo> {
        if !self.connections.contains_key(start) || !self.connections.contains_key(end) {
            return None; // One or both nodes are not in the network
        }

        // Use a max-heap to prioritize paths with higher minimum strength
        let mut heap = BinaryHeap::new();
        let mut best_strengths = HashMap::new();
        let mut predecessors = HashMap::new();

        for node in self.connections.keys() {
            best_strengths.insert(node, 0); // 0 strength means no connection
        }
        best_strengths.insert(start, 255); // Full strength at the start
        heap.push((255, start)); // Max-heap, so we push with positive values

        while let Some((current_min_strength, current_node)) = heap.pop() {
            if current_node == end {
                break;
            }

            if current_min_strength < *best_strengths.get(current_node).unwrap_or(&0) {
                continue;
            }

            if let Some(neighbors) = self.connections.get(current_node) {
                for (neighbor, &(strength, _, time)) in neighbors {
                    // If the connection is older than 30 seconds, ignore it
                    if time.elapsed().unwrap().as_secs() > 30 {
                        continue;
                    }

                    // Apply the connection cost
                    let strength = strength.0;
                    let hop_strength = strength.saturating_sub(10);

                    // Compute the minimum strength along the path
                    let new_strength = current_min_strength.min(hop_strength);

                    if new_strength > *best_strengths.get(neighbor).unwrap_or(&0) {
                        best_strengths.insert(neighbor, new_strength);
                        predecessors.insert(neighbor.clone(), current_node.clone());
                        heap.push((new_strength, neighbor));
                    }
                }
            }
        }

        // If the end node is not reachable
        if best_strengths.get(&end).unwrap_or(&0) == &0 {
            return None;
        }

        // Reconstruct the path
        let mut path = Vec::new();
        let mut min_strength = best_strengths[&end];
        let mut current_node = end;

        while let Some(predecessor) = predecessors.get(current_node) {
            let (strength, decibels, _) = self.connections[predecessor][current_node];
            path.push((current_node.clone(), strength, decibels));
            min_strength = min_strength.min(strength.0);
            current_node = predecessor;
        }

        path.push((start.clone(), Strength(255), 0.0)); // Decibels are not meaningful for the start
        path.reverse();
        Some((Strength(min_strength), path))
    }

    pub fn remove_radio(&mut self, radio: Radio) {
        self.connections.remove(&radio);
        for neighbors in self.connections.values_mut() {
            neighbors.remove(&radio);
        }
    }
}
