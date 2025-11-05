pub(crate) mod cli;
pub(crate) mod file_visitor;
#[cfg(all(feature = "logging", not(test)))]
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
        #[cfg(all(feature = "logging", not(test)))]
        log_folder,
        #[cfg(all(feature = "logging", not(test)))]
        log_level,
    } = clap::Parser::parse();

    #[cfg(all(feature = "logging", not(test)))]
    logging::init(log_folder, log_level);

    info!("binding udp socket to {target:?}");
    let socket = UdpSocket::bind(target.as_ref()).unwrap_or_else(|err| {
        exit!("cannot bind udp socket: {err:#?}");
    });

    match mode {
        cli::Mode::Send(args) => args.run(),
        cli::Mode::Receive(args) => args.run(),
    };

    #[cfg(all(feature = "logging", not(test)))]
    logging::finish();
}
