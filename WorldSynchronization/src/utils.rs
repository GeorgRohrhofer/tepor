#[allow(unused_imports)]
use crate::prelude::*;

#[macro_export]
macro_rules! exit {
    ( $($msg:tt)+ ) => {{
        $crate::error!( $($msg)+ );
        $crate::exit_no_log!( $($msg)+ );
    }};
}

#[macro_export]
macro_rules! exit_no_log {
    ( $($context:tt)* )=>{{
        eprintln!( $($context)* );
        #[cfg(all(feature = "logging", not(test)))]
        $crate::logging::finish();
        std::process::exit(1);
    }}
}

#[macro_export]
macro_rules! log {
    (Off, $($rest:tt)+ )=>{
        compile_error!("`Off` is not a valid log level");
    };
    ($level:ident, $($msg:tt)+ ) => {
        #[cfg(all(feature = "logging", not(test)))]
        {
            use $crate::logging::LogLevel;
            let level = LogLevel::$level;
            let min = $crate::logging::LOG_LEVEL.get().copied().unwrap_or_default();
            if  min <= level {
                $crate::logging::log_msg(level, format!( $($msg)+ ));
            }
        }
    };
}

#[macro_export]
macro_rules! trace {
    ( $($msg:tt)+ ) => {{
        $crate::prelude::log!(Trace, $($msg)+ )
    }}
}

#[macro_export]
macro_rules! info {
    ( $($msg:tt)+ ) => {{
        $crate::prelude::log!(Info, $($msg)+ )
    }}
}

#[macro_export]
macro_rules! warn {
    ( $($msg:tt)+ ) => {{
        $crate::prelude::log!(Warning, $($msg)+ )
    }}
}

#[macro_export]
macro_rules! error {
    ( $($msg:tt)+ ) => {{
        $crate::prelude::log!(Error, $($msg)+ )
    }}
}
