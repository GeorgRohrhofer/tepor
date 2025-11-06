#![allow(dead_code)]

use crate::prelude::*;
use std::{sync::Mutex, sync::OnceLock};

pub(crate) static LOG_LEVEL: OnceLock<LogLevel> = OnceLock::new();
static LOG_PATH: OnceLock<Box<str>> = OnceLock::new();
static LOGS: Mutex<Vec<Box<str>>> = Mutex::new(vec![]);

#[derive(Clone, Copy, Debug, PartialEq, Eq, clap::ValueEnum, Default, PartialOrd, Ord)]
pub(crate) enum LogLevel {
    Trace,
    #[default]
    Info,
    Warning,
    Error,
    Off,
}

/// write to the log file, with the specified log level
pub(crate) fn log_msg(level: LogLevel, msg: impl Into<Box<str>>) {
    let Ok(mut lock) = LOGS.lock() else {
        eprintln!("cannot aquire log");
        return;
    };

    // split log into its lines
    let msg = msg.into();
    let mut lines = msg.lines();

    // push header with time
    let now = ::chrono::Utc::now();
    if let Some(first) = lines.next() {
        lock.push(format!("{now} [{level:8?}] {first}\n").into());
    }

    // push rest of the lines
    while let Some(next) = lines.next() {
        lock.push(format!("\t{next}\n").into())
    }
}

/// initialize the logging process
/// this function is expected to always be called once, even if logging is off
pub(crate) fn init(folder: Box<str>, level: LogLevel) {
    let _ = LOG_LEVEL.set(level);
    let _ = LOG_PATH.set(folder);

    let old_hook = std::panic::take_hook();
    #[allow(unused_variables)]
    std::panic::set_hook(Box::new(move |info| {
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

        // previous hook
        old_hook(info);
    }));
}

/// finish the log process by saving the file
/// this function is expected to always be called once, even if logging is off
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
