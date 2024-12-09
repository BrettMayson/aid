use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::sync::RwLock;
use std::time::SystemTime;

use arma_rs::{Context, ContextState, Group};
use dashmap::DashMap;

pub fn group() -> Group {
    Group::new()
        .command("set", cmd_set)
        .command("get", cmd_get)
}

fn cmd_set(
    ctx: Context,
    from: String,
    to: String,
    freq: String,
    strength: f32,
    db: f32,
) -> Result<(), String> {
    let from = from.to_lowercase();
    let to = to.to_lowercase();
    let freq = freq.to_lowercase();
    if ctx.group().get::<Networks>().is_none() {
        ctx.group().set(Networks {
            networks: DashMap::new(),
        });
    }
    let Some(networks) = ctx.group().get::<Networks>() else {
        return Err("Mesh network not initialized".to_string());
    };
    // remove `from` from all networks, except the one we are adding to
    for network in networks.networks.iter_mut() {
        if network.key() != &freq {
            network
                .write()
                .expect("not poisoned")
                .connections
                .remove(&from);
        }
    }
    let network = networks
        .networks
        .entry(freq)
        .or_insert_with(|| RwLock::new(MeshNetwork::new()));
    // map strength 0-1 to 0-255
    let strength = (strength * 255.0).round() as u8;
    network
        .write()
        .expect("not poisoned")
        .add_connection(&from, &to, strength, db);
    Ok(())
}

// Returns
// - the minimum strength along the path
// - the minimum decibels along the path
// - a list of nodes along the path with their strength
fn cmd_get(
    ctx: Context,
    from: String,
    to: String,
    freq: String,
) -> Result<(f32, f32, Vec<(String, f32, f32)>), String> {
    let from = from.to_lowercase();
    let to = to.to_lowercase();
    let freq = freq.to_lowercase();
    if ctx.group().get::<Networks>().is_none() {
        ctx.group().set(Networks {
            networks: DashMap::new(),
        });
    }
    let Some(networks) = ctx.group().get::<Networks>() else {
        return Err("Mesh network not initialized".to_string());
    };
    let network = networks
        .networks
        .get(&freq)
        .ok_or_else(|| "Frequency not found".to_string())?;
    let network = network.read().expect("not poisoned");
    let (strength, path) = network
        .get_connection(&from, &to)
        .ok_or_else(|| "No path found".to_string())?;
    let min_strength = strength as f32 / 255.0;
    let min_db = path
        .iter()
        .map(|(_, _, db)| *db)
        .fold(f32::INFINITY, f32::min);
    let path = path
        .into_iter()
        .map(|(node, strength, db)| (node, strength as f32 / 255.0, db))
        .collect();
    Ok((min_strength, min_db, path))
}

struct Networks {
    /// A map of networks, one per frequency
    networks: DashMap<String, RwLock<MeshNetwork>>,
}

pub struct MeshNetwork {
    connections: HashMap<String, HashMap<String, (u8, f32, SystemTime)>>, // (strength, decibels, time)
}

impl MeshNetwork {
    // Create a new MeshNetwork
    pub fn new() -> Self {
        MeshNetwork {
            connections: HashMap::new(),
        }
    }

    // Add a connection between two nodes with given strength and decibels
    pub fn add_connection(&mut self, node_a: &str, node_b: &str, strength: u8, decibels: f32) {
        self.connections
            .entry(node_a.to_string())
            .or_default()
            .insert(node_b.to_string(), (strength, decibels, SystemTime::now()));
    }

    // Get the best path between two nodes based on highest minimum strength
    pub fn get_connection(&self, start: &str, end: &str) -> Option<(u8, Vec<(String, u8, f32)>)> {
        if !self.connections.contains_key(start) || !self.connections.contains_key(end) {
            return None; // One or both nodes are not in the network
        }

        // Use a max-heap to prioritize paths with higher minimum strength
        let mut heap = BinaryHeap::new();
        let mut best_strengths = HashMap::new();
        let mut predecessors = HashMap::new();

        for node in self.connections.keys() {
            best_strengths.insert(node.clone(), 0); // 0 strength means no connection
        }
        best_strengths.insert(start.to_string(), 255); // Full strength at the start
        heap.push((255, start.to_string())); // Max-heap, so we push with positive values

        while let Some((current_min_strength, current_node)) = heap.pop() {
            if current_node == end {
                break;
            }

            if current_min_strength < *best_strengths.get(&current_node).unwrap_or(&0) {
                continue;
            }

            if let Some(neighbors) = self.connections.get(&current_node) {
                for (neighbor, &(strength, _, time)) in neighbors {
                    // If the connection is older than 20 seconds, ignore it
                    if time.elapsed().unwrap().as_secs() > 20 {
                        continue;
                    }
                    // Compute the minimum strength along the path
                    let new_strength = current_min_strength.min(strength);
                    if new_strength > *best_strengths.get(neighbor).unwrap_or(&0) {
                        best_strengths.insert(neighbor.clone(), new_strength);
                        predecessors.insert(neighbor.clone(), current_node.clone());
                        heap.push((new_strength, neighbor.clone()));
                    }
                }
            }
        }

        // If the end node is not reachable
        if best_strengths.get(end).unwrap_or(&0) == &0 {
            return None;
        }

        // Reconstruct the path
        let mut path = Vec::new();
        let mut current_node = end.to_string();
        let mut min_strength = best_strengths[end];

        while let Some(predecessor) = predecessors.get(&current_node) {
            let (strength, decibels, _) = self.connections[predecessor][&current_node];
            path.push((current_node.clone(), strength, decibels));
            min_strength = min_strength.min(strength);
            current_node = predecessor.clone();
        }

        path.push((start.to_string(), 255, 0.0)); // Decibels are not meaningful for the start
        path.reverse();
        Some((min_strength, path))
    }
}
