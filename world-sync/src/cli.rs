use clap::{Args, Parser, Subcommand};

#[cfg(all(feature = "logging", not(test)))]
use crate::logging::LogLevel;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub(crate) struct Cli {
    #[arg(long = "target", short = 't')]
    /// the target ip address and its port
    /// example: `127.0.0.1:2000`
    pub(crate) target: Box<str>,

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
    Send(SendArgs),
    Receive(ReceiveArgs),
}

#[derive(Debug, Args)]
pub(crate) struct SendArgs {
    #[arg(long, short = 'f')]
    file: Box<str>,
    #[arg(long, short = 's')]
    hash: Box<str>,
}

#[derive(Debug, Args)]
pub(crate) struct ReceiveArgs {}
