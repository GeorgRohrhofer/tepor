use crate::prelude::*;

#[cfg(feature = "logging")]
use std::{sync::Mutex, sync::OnceLock};

#[cfg(feature = "logging")]
pub(crate) static LOG_PATH: OnceLock<Box<str>> = OnceLock::new();

#[cfg(feature = "logging")]
pub(crate) static LOG_LEVEL: OnceLock<LogLevel> = OnceLock::new();

#[cfg(feature = "logging")]
pub(crate) static LOGS: Mutex<Vec<Box<str>>> = Mutex::new(vec![]);

#[cfg(feature = "logging")]
#[derive(Clone, Copy, Debug, PartialEq, Eq, clap::ValueEnum, Default, PartialOrd, Ord)]
pub(crate) enum LogLevel {
    Off,
    Trace,
    #[default]
    Info,
    Warning,
    Error,
}

#[cfg(feature = "logging")]
pub(crate) fn init(folder: Box<str>, level: LogLevel) {
    let _ = LOG_LEVEL.set(level);
    let _ = LOG_PATH.set(folder);

    let old_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |info| {
        // previous hook
        old_hook(info);

        // location
        let location = match info.location() {
            Some(loc) => format!("{loc}"),
            None => "<unknown location>".into(),
        };

        // thread name
        let thread = std::thread::current();
        let name = thread.name().unwrap_or("<unnamed>");

        // payload
        let payload = info
            .payload()
            .downcast_ref::<&str>()
            .copied()
            .or_else(|| info.payload().downcast_ref::<String>().map(|s| s.as_str()))
            .unwrap_or("<non-string panic payload>");

        // backtrace
        let backtrace = std::backtrace::Backtrace::force_capture();

        error!(
            "thread '{name}' panicked at {location}\nreason: {payload}\nbacktrace:\n{backtrace:#}"
        );

        // write log to file
        finish();
    }));
}

/// write the log to a file
#[cfg(feature = "logging")]
pub(crate) fn finish() {
    let Some(path) = LOG_PATH.get() else {
        return;
    };

    // create folder
    std::fs::create_dir_all(path.as_ref()).unwrap_or_else(|err| {
        exit_no_log!("could not create log folder at {path:?}: {err:?}");
    });

    // crate file
    let now = chrono::Utc::now();
    let now = now.to_string().replace(' ', "_");
    let path = format!("{path}/log_{now}.log");
    let mut file = std::fs::File::create_new(&path).unwrap_or_else(|err| {
        exit_no_log!("could not create log file at {path}: {err}");
    });

    // obtain log lines
    let lines = LOGS.lock().unwrap_or_else(|_| {
        exit_no_log!("cannot obtain log lines");
    });

    // write all the lines
    lines.iter().for_each(|line| {
        std::io::Write::write(&mut file, line.as_bytes()).unwrap_or_else(|err| {
            exit_no_log!("error while writing to log file: {err:#?}");
        });
    });
}

#[macro_export]
macro_rules! log {
    ($level:ident, $($msg:tt)+ ) => {
        #[cfg(feature = "logging")]
        'log: {
            use $crate::logging::LogLevel;
            let level = LogLevel::$level;
            let min = $crate::logging::LOG_LEVEL.get().copied().unwrap_or_default();
            if  min > level {
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
        crate::prelude::log!(Trace, $($msg)+ )
    }}
}

#[macro_export]
macro_rules! info {
    ( $($msg:tt)+ ) => {{
        crate::prelude::log!(Info, $($msg)+ )
    }}
}

#[macro_export]
macro_rules! warn {
    ( $($msg:tt)+ ) => {{
        crate::prelude::log!(Warning, $($msg)+ )
    }}
}

#[macro_export]
macro_rules! error {
    ( $($msg:tt)+ ) => {{
        crate::prelude::log!(Error, $($msg)+ )
    }}
}
