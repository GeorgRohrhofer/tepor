//! metadata about a world save

use crate::prelude::*;
use std::io::{Read, Write};

#[derive(Serialize, Deserialize, Debug)]
/// metadata about a world save
pub(crate) struct RepositoryInfo {
    world_name: Box<str>,
    current_save_version: usize,
    // TODO add checkpoints, hashes + time
}

const PATH: &str = concat!(info_dir!(), "/info.toml");

impl RepositoryInfo {
    #[inline]
    pub(crate) fn load() -> Result<Self, SaveError> {
        Self::load_from(PATH)
    }

    #[inline]
    pub(crate) fn load_from(path: impl AsRef<Path>) -> Result<Self, SaveError> {
        let mut content = std::fs::OpenOptions::new().read(true).open(path)?;
        let buf = &mut String::new();
        content.read_to_string(buf)?;
        let val = toml::from_str(buf)?;
        Ok(val)
    }

    #[inline]
    pub(crate) fn save(&self) -> Result<(), SaveError> {
        self.save_to(PATH)
    }

    #[inline]
    pub(crate) fn save_to(&self, path: impl AsRef<Path>) -> Result<(), SaveError> {
        let ser = toml::to_string(self)?;
        let mut file = std::fs::OpenOptions::new()
            .write(true)
            .create(true)
            .open(path)?;

        file.write(ser.as_bytes())?;

        Ok(())
    }
}
