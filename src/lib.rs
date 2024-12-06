use arma_rs::{arma, Extension};

mod mesh;

#[arma]
pub fn init() -> Extension {
    Extension::build().group("mesh", mesh::group()).finish()
}
