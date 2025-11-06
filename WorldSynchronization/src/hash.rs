use crate::{file_visitor::visit_files_or_err, prelude::*};
use std::{
    fs::OpenOptions,
    hash::{DefaultHasher, Hash, Hasher},
    io::{BufReader, Read},
};

/// Calculates the hash of a directory.
/// if any error is encountered, this function returns an Err
pub(crate) fn calculate_hash(path: impl AsRef<Path>) -> std::io::Result<u64> {
    let mut out1 = Ok(());
    let mut out2 = Ok(());
    let mut hash = DefaultHasher::new();
    let buf = &mut [0; 8];

    visit_files_or_err(
        path,
        |path| {
            // open the file to read it
            let mut file = match OpenOptions::new().read(true).open(path) {
                Ok(file) => BufReader::new(file),
                Err(err) => {
                    error!("Cannot open file {path:?}: {err}");
                    out1 = Err(err);
                    return false;
                }
            };

            // read the bytes and hash them
            loop {
                match file.read(buf) {
                    Ok(0) => return true,
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
                        out1 = Err(err);
                        return false;
                    }
                }
            }
        },
        |_path, err| {
            error!("Error obtaining file {_path:?}: {err}");
            out2 = Err(err);
            false
        },
    )?;

    out1?;
    out2?;
    Ok(hash.finish())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn calc_hash() {
        let exp: u64 = 8800404550835207352;
        let hash = calculate_hash("test_files/calc_hash").unwrap();
        assert_eq!(exp, hash)
    }
}
