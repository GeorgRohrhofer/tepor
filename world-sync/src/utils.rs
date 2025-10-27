use crate::prelude::*;

pub(crate) fn start_udp_connection(ip: &str, port: &str) -> Result<(), ()> {
    todo!()
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub(crate) enum ExitCode {
    #[default]
    Success = 0,
    GenericError,
}

#[macro_export]
macro_rules! exit {
    ($reason:ident) => {{
        let reason = $crate::prelude::ExitCode::$reason;
        let msg = format!("{reason:?}");
        $crate::exit!(@inner reason, msg);
    }};
    ($reason:ident, $($context:tt)+ ) => {{
        let reason = $crate::prelude::ExitCode::$reason;
        let msg = format!("{reason:?}: {}", format!( $($context)+ ));
        $crate::exit!(@inner reason, msg);
    }};
    (@inner $reason:ident, $msg:ident) => {{
        eprintln!("{}", $msg);
        $crate::error!("{}", $msg);
        $crate::logging::finish();
        std::process::exit($reason as i32);
    }};
}

#[macro_export]
macro_rules! exit_no_log {
    ( $($context:tt)* )=>{{
        eprintln!( $($context)* );
        std::process::exit($crate::utils::ExitCode::GenericError as i32);
    }}
}
