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
    ($level:ident, $($msg:tt)+ ) => {
        #[cfg(all(feature = "logging", not(test)))]
        'log: {
            use $crate::logging::LogLevel;
            let level = LogLevel::$level;
            let min = $crate::logging::LOG_LEVEL.get().copied().unwrap_or_default();
            if  min > level|| min == LogLevel::Off {
                break 'log;
            }


            if let Ok(mut lock) = $crate::logging::LOGS.lock() {
                let msg = format!( $($msg)+ );
                let now = ::chrono::Utc::now();
                let mut lines = msg.lines();
                if let Some(first) = lines.next() {
                    lock.push(format!("{now} [{level:8?}] {first}\n").into());
                }

                while let Some(next) = lines.next(){
                    lock.push(format!("\t{next}\n").into())
                }
            } else {
                eprintln!("cannot aquire log");
                break 'log;
            };
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
