pub(crate) mod cli;
pub(crate) mod logging;
pub(crate) mod prelude;
pub(crate) mod receive;
pub(crate) mod send;

use crate::prelude::*;

fn main() {
    println!("cli: {:#?}", <cli::Cli as clap::Parser>::parse());

    // let cli::Cli {
    //     mode,
    //     target,
    //     log_folder,
    // } = clap::Parser::parse();

    // match mode {
    //     cli::Mode::Send(args) => args.run(),
    //     cli::Mode::Receive(args) => args.run(),
    // };

    // #[cfg(feature = "logging")]
    // logging::finish();
}

fn start_udp_connection(ip: &str, port: &str) -> Result<(), ()> {
    todo!()
}
