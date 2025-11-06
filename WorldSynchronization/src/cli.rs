use clap::{Args, Parser, Subcommand, ValueEnum};

#[cfg(all(feature = "logging", not(test)))]
use crate::logging::LogLevel;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub(crate) struct Cli {
    #[cfg(all(feature = "logging", not(test)))]
    #[arg(long, default_value = "logs")]
    pub(crate) log_folder: Box<str>,

    #[cfg(all(feature = "logging", not(test)))]
    #[arg(long, short = 'l', default_value = "info")]
    pub(crate) log_level: LogLevel,

    #[command(subcommand)]
    pub(crate) mode: Mode,
}

#[derive(Subcommand, Debug)]
pub(crate) enum Mode {
    #[command(visible_alias = "calc-hash")]
    CalculateHash(CalcHashArgs),
    Send(SendArgs),
    #[command(visible_alias = "rec")]
    Receive(ReceiveArgs),
}

#[derive(Debug, Args)]
/// Send the contents of a Directory to a target
pub(crate) struct SendArgs {
    #[arg(long = "target", short = 't')]
    /// the target ip address and its port
    /// example: `127.0.0.1:2000`
    pub(crate) target: Box<str>,

    #[arg(long, short = 'd')]
    /// the directory that should be processed
    pub(crate) directory: Box<str>,

    #[arg(long, short = 'h')]
    /// The hash of the target directory
    /// if no hash is provided, it will calculated that on its own
    pub(crate) with_hash: Option<u64>,
}

#[derive(Debug, Args)]
/// Receive the contents of a directory from a target
pub(crate) struct ReceiveArgs {
    #[arg(long = "target", short = 't')]
    /// the target ip address and its port
    /// example: `127.0.0.1:2000`
    pub(crate) target: Box<str>,
}

#[derive(Debug, Args)]
/// Calculate the Hash of a directory
pub(crate) struct CalcHashArgs {
    /// the directory that should be processed
    pub(crate) directory: Box<str>,
}
