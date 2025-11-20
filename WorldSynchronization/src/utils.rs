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

fn start_connection(target: impl AsRef<str> + std::fmt::Debug) {
    todo!()
    // info!("binding udp socket to {target:?}");
    // let socket = UdpSocket::bind(target.as_ref()).unwrap_or_else(|err| {
    //     exit!("cannot bind udp socket: {err:#?}");
    // });

    // socked
}

/// implement `From` for every branch arm
/// # Example
/// ```rust
/// enum Value {
///     Number(u32),
///     String(String),
/// }
///
/// impl_enum_from!(Value with
///     u32 as Number,
///     String,
/// );
/// ```
#[macro_export]
macro_rules! impl_enum_from {
    ($name:ident with ) => {};
    ($name:ident with $label:ident, $($rest:tt)* ) => {
        $crate::impl_enum_from!($name with $label as $label, $($rest)* );
    };
    ($name:ident with $from:ty as $label:ident, $($rest:tt)* ) => {
        $crate::impl_enum_from!($name with $($rest)* );
        impl From<$from> for $name {
            #[inline]
            fn from(value: $from) -> Self {
                Self::$label(value)
            }
        }
    };
}

/// contains info about the error of loading from or saving to a toml file
pub(crate) enum SaveError {
    IO(std::io::Error),
    TomlSer(toml::ser::Error),
    TomlDes(toml::de::Error),
}

impl_enum_from!(SaveError with
    std::io::Error as IO,
    toml::ser::Error as TomlSer,
    toml::de::Error as TomlDes,
);

#[macro_export]
/// the info directory, useful for `concat!` calls
macro_rules! info_dir {
    () => {
        ".world-sync"
    };
}
/// the directory at which metadata is stored
pub(crate) const INFO_DIR: &str = info_dir!();
