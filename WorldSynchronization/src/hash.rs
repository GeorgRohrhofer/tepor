use crate::{file_visitor::visit_files_or_err, prelude::*};
use std::{
    fs::OpenOptions,
    hash::{DefaultHasher, Hash, Hasher},
    io::{BufReader, Read},
};

/// Calculates the hash of a directory.
/// if any error is encountered, this function returns an Err
pub(crate) fn calculate_hash(path: impl AsRef<Path>) -> std::io::Result<u64> {
    let mut out = Ok(());
    let mut hash = DefaultHasher::new();
    let buf = &mut [0; 8];

    // collect all paths
    let mut all = vec![];
    visit_files_or_err(
        path,
        |path| {
            all.push(path);
            true
        },
        |_path, err| {
            error!("Error obtaining file {_path:?}: {err}");
            out = Err(err);
            false
        },
    )?;

    out?;

    // calculate hash
    all.sort();
    for path in all {
        let path = path.as_path();

        // open the file to read it
        let mut file = match OpenOptions::new().read(true).open(path) {
            Ok(file) => BufReader::new(file),
            Err(err) => {
                error!("Cannot open file {path:?}: {err}");
                return Err(err);
            }
        };

        // read the bytes from the file
        loop {
            match file.read(buf) {
                Ok(0) => break,
                Ok(_) => {
                    #[cfg(target_endian = "little")]
                    let data = u64::from_le_bytes(*buf);
                    #[cfg(target_endian = "big")]
                    let data = u64::from_be_bytes(*buf);

                    data.hash(&mut hash);
                    *buf = [0; 8];
                }
                Err(err) => {
                    error!("Error while reading bytes from {path:?}: {err}");
                    return Err(err);
                }
            }
        }
    }

    Ok(hash.finish())
}

impl crate::cli::CalcHashArgs {
    pub(crate) fn run(self) {
        let Self { directory } = self;
        match calculate_hash(directory.as_ref()) {
            Ok(hash) => println!("{hash}"),
            Err(_err) => {
                error!("could not calculate hash for {directory}: {_err}")
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn calc_hash() {
        let exp: u64 = 7376138373308570751;
        let hash = calculate_hash("test_files/calc_hash").unwrap();
        assert_eq!(exp, hash)
    }
}
