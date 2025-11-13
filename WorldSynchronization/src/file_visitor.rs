//! visit all files in a directory

use crate::prelude::*;
use std::{fs::read_dir, path::PathBuf};

/// either unwrap the `$in` value, or calls `$on_err` with the error value
macro_rules! tri {
    ($on_err:expr, $path:expr, $in:expr) => {
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
/// `on_iter`: visitor of file entries
/// and returns true if you wanna keep iterating, or false if youre done
///
/// Returns the error for loading the initial folder
/// all subsequent errors will be logged as a warning
///
/// for specific error behaviour, use [`list_files_or_err`]
pub(crate) fn visit_files(
    path: impl AsRef<Path>,
    on_iter: impl FnMut(PathBuf) -> bool,
) -> std::io::Result<()> {
    visit_files_or_err(path, on_iter, |_path, _err| {
        warn!("File iter error at {_path:?}: {_err}");
        true
    })
}

/// visit all files in a directory.
/// recursively visits sub-folders, but other file system features (like sym links), cause an [`std::io::ErrorKind::Unsupported`] error
///
/// `on_iter`: visitor of file entries
/// `on_err`: visitor for errors, take in the relevant path, and a [`std::io::Error`]
/// both visitors return true if you wanna keep iterating, or false if youre done
///
/// Returns the error for loading the initial folder, but Ok even if `on_err` stops the iteration
///
/// for a version that just logs all errors, use [`list_files`]
pub(crate) fn visit_files_or_err(
    path: impl AsRef<Path>,
    mut on_iter: impl FnMut(PathBuf) -> bool,
    mut on_err: impl FnMut(PathBuf, std::io::Error) -> bool,
) -> std::io::Result<()> {
    let path = PathBuf::from(path.as_ref());
    trace!("visiting files at {path:?}");
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
        let entry = tri!(on_err, folder_path.clone(), entry);
        let path = entry.path();

        // got a file
        if path.is_file() {
            trace!("visit file {path:?}");
            if on_iter(path) {
                continue;
            } else {
                return Ok(());
            }
        }

        // iterate over sub-directories
        if path.is_dir() {
            // ignore the info folder
            if path.ends_with(INFO_DIR) {
                continue;
            }

            trace!("visit directory {path:?}");
            let read = tri!(on_err, path, read_dir(path.as_path()));
            stack.push((read, path));
            continue;
        }

        // unsupported object
        let err = std::io::Error::from(std::io::ErrorKind::Unsupported);
        tri!(on_err, path, Err(err));
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::OsString;

    macro_rules! run_test {
        ($path:literal => $($exp:literal),+ $(,)? ) => {{
            let mut exp = vec![ $(OsString::from(concat!($path, $exp))),+ ];
            visit_files_or_err(
                $path,
                |path| {
                    if let Some(idx) = exp.iter().position(|item| path.as_os_str() == item) {
                        exp.swap_remove(idx);
                        true
                    } else {
                        panic!("did not expect path {path:?}");
                    }
                },
                |path, err| panic!("{path:?} caused err: {err}"),
            )
            .expect("could not load test folder");

            assert!(exp.is_empty(), "not all files were visited");
        }};
    }

    #[test]
    /// check visiting files recursively works
    fn visit_all() {
        run_test!("test_files/visit_all" =>
            "/info.md",
            "/sub-dir/file",
            "/sub-dir-2/.hidden",
        );
    }

    #[test]
    fn ignore_info_folder() {
        run_test!("test_files/ignore_info_folder" =>
            "/info.md",
        );
    }
}
