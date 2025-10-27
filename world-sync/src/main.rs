pub(crate) mod cli;
pub(crate) mod logging;
pub(crate) mod prelude;
pub(crate) mod receive;
pub(crate) mod send;
pub(crate) mod utils;

use crate::prelude::*;

fn main() {
    // println!("cli: {:#?}", <cli::Cli as clap::Parser>::parse());

    let cli::Cli {
        mode,
        target,
        #[cfg(feature = "logging")]
        log_folder,
        #[cfg(feature = "logging")]
        log_level,
    } = clap::Parser::parse();

    #[cfg(feature = "logging")]
    logging::init(log_folder, log_level);

    match mode {
        cli::Mode::Send(args) => args.run(),
        cli::Mode::Receive(args) => args.run(),
    };

    #[cfg(feature = "logging")]
    logging::finish();
}
