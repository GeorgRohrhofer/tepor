//! visit all files in a directory

use crate::prelude::*;
use std::{
    fs::{Metadata, read_dir},
    path::{Path, PathBuf},
};

/// either unwrap the `$in` value, or calls `$on_err` with the error value
macro_rules! tri {
    ($on_err:ident, $path:ident, $in:expr) => {
        match $in {
            Ok(k) => k,
            Err(err) => {
                if ($on_err)($path, err) {
                    continue;
                } else {
                    return Ok(());
                }
            }
        }
    };
}

/// visit all files in a directory.
/// recursively visits sub-folders, but other file system features (like sym links), cause an [`std::io::ErrorKind::Unsupported`] error
///
/// `on_iter`: visitor of file entries, with their path and meta data,
/// and returns true if you wanna keep iterating, or false if youre done
///
/// Returns the error for loading the initial folder
/// all subsequent errors will be logged as a warning
///
/// for specific error behaviour, use [`list_files_or_err`]
pub(crate) fn visit_files(
    path: impl AsRef<Path>,
    on_iter: impl FnMut(&Path, Metadata) -> bool,
) -> std::io::Result<()> {
    visit_files_or_err(path, on_iter, |_path, _err| {
        warn!("File iter error at {_path:?}: {_err}");
        true
    })
}

/// visit all files in a directory.
/// recursively visits sub-folders, but other file system features (like sym links), cause an [`std::io::ErrorKind::Unsupported`] error
///
/// `on_iter`: visitor of file entries, with their path and meta data
/// `on_err`: visitor for errors, take in the relevant path, and a [`std::io::Error`]
/// both visitors return true if you wanna keep iterating, or false if youre done
///
/// Returns the error for loading the initial folder, but Ok even if `on_err` stops the iteration
///
/// for a version that just logs all errors, use [`list_files`]
pub(crate) fn visit_files_or_err(
    path: impl AsRef<Path>,
    mut on_iter: impl FnMut(&Path, Metadata) -> bool,
    mut on_err: impl FnMut(&Path, std::io::Error) -> bool,
) -> std::io::Result<()> {
    let path = PathBuf::from(path.as_ref());
    let read = read_dir(&path)?;
    let mut stack = vec![(read, path)];

    // recursively iterate over all elements in the directory
    while let Some((top, folder_path)) = stack.last_mut() {
        // get next dir entry
        let Some(entry) = top.next() else {
            // dir contains no more entries
            stack.pop();
            continue;
        };

        // unpack the path entry
        let entry = tri!(on_err, folder_path, entry);
        let path = entry.path();
        let path_ref = path.as_path();

        // got a file
        if path.is_file() {
            let meta = tri!(on_err, path_ref, path.metadata());
            if on_iter(path_ref, meta) {
                continue;
            } else {
                return Ok(());
            }
        }

        // iterate over sub-directories
        if path.is_dir() {
            let read = tri!(on_err, path_ref, read_dir(path_ref));
            stack.push((read, path));
            continue;
        }

        // unsupported object
        let err = std::io::Error::from(std::io::ErrorKind::Unsupported);
        tri!(on_err, path_ref, Err(err));
    }

    Ok(())
}
