#[cfg(feature = "logging")]
use std::sync::Mutex;

#[cfg(feature = "logging")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, clap::ValueEnum, Default)]
pub(crate) enum LogLevel {
    Off,
    Trace,
    #[default]
    Info,
    Warning,
    Error,
}

// impl std::fmt::Display for LogLevel {
//     #[inline]
//     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
//         std::fmt::Debug::fmt(self, f)
//     }
// }

#[cfg(feature = "logging")]
static LOGS: Mutex<Vec<Box<str>>> = Mutex::new(vec![]);

#[macro_export]
macro_rules! log {
    ($level:ident, $($msg:tt)+ ) => {
        #[cfg(feature = "logging")]
        'log: {
            use crate::prelude::LogLevel;
            let level = LogLevel::$level;
            if level == LogLevel::Off {
                break 'log;
            }
        }
    };
}

/// write the log to a file
#[cfg(feature = "logging")]
pub(crate) fn finish() {
    let dir = "logs";
}
