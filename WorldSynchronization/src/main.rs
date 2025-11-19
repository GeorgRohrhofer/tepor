pub(crate) mod checkpoint;
pub(crate) mod cli;
pub(crate) mod file_visitor;
pub(crate) mod hash;
pub(crate) mod metadata;
#[cfg(all(feature = "logging", not(test)))]
pub(crate) mod logging;
pub(crate) mod prelude;
pub(crate) mod receive;
pub(crate) mod send;
pub(crate) mod utils;

use cli::{Cli, Mode};

fn main() {
    let Cli {
        mode,
        #[cfg(all(feature = "logging", not(test)))]
        log_folder,
        #[cfg(all(feature = "logging", not(test)))]
        log_level,
    } = clap::Parser::parse();

    #[cfg(all(feature = "logging", not(test)))]
    logging::init(log_folder, log_level);

    match mode {
        Mode::Send(args) => args.run(),
        Mode::Receive(args) => args.run(),
        Mode::CalculateHash(args) => args.run(),
        Mode::Checkpoint(args) => args.run(),
    };

    #[cfg(all(feature = "logging", not(test)))]
    logging::finish();
}
