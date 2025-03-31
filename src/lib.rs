use arma_rs::{arma, Extension, FromArma, FromArmaError, IntoArma};

mod mesh;
mod object;
mod player;

#[arma]
pub fn init() -> Extension {
    Extension::build()
        .group("mesh", mesh::group())
        .group("object", object::group())
        .group("player", player::group())
        .finish()
}

pub type Link = (Radio, Strength, f32);
pub type ConnectionInfo = (Strength, Vec<Link>);

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Radio(String);
impl FromArma for Radio {
    fn from_arma(arma: String) -> Result<Self, FromArmaError> {
        Ok(Radio(String::from_arma(arma)?.to_lowercase()))
    }
}
impl IntoArma for Radio {
    fn to_arma(&self) -> arma_rs::Value {
        self.0.to_arma()
    }
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct NetId(String);
impl NetId {
    pub fn empty() -> Self {
        NetId("".to_string())
    }
}
impl FromArma for NetId {
    fn from_arma(arma: String) -> Result<Self, FromArmaError> {
        Ok(NetId(String::from_arma(arma)?))
    }
}
impl IntoArma for NetId {
    fn to_arma(&self) -> arma_rs::Value {
        self.0.to_arma()
    }
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Frequency(String);
impl FromArma for Frequency {
    fn from_arma(arma: String) -> Result<Self, FromArmaError> {
        Ok(Frequency(arma.to_string()))
    }
}
impl IntoArma for Frequency {
    fn to_arma(&self) -> arma_rs::Value {
        arma_rs::Value::Number(self.0.parse::<f32>().unwrap_or(0.0).into())
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Strength(u8);
impl FromArma for Strength {
    fn from_arma(arma: String) -> Result<Self, FromArmaError> {
        let strength = arma.parse::<f32>().unwrap_or(0.0) * 255.0;
        Ok(Strength(strength.round() as u8))
    }
}
impl IntoArma for Strength {
    fn to_arma(&self) -> arma_rs::Value {
        arma_rs::Value::Number((self.0 as f64) / 255.0)
    }
}
