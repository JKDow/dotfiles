// src/viewer.rs
use clap::ValueEnum;

#[derive(Debug, Clone, ValueEnum)]
pub enum Viewer {
    Auto,
    Wofi,
    Rofi,
    None,
}

#[derive(Debug)]
pub enum ResolvedViewer {
    Wofi,
    Rofi,
    Stdout,
}

impl std::fmt::Display for Viewer {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Auto => write!(f, "Auto"),
            Self::Wofi => write!(f, "Wofi"),
            Self::Rofi => write!(f, "Rofi"),
            Self::None => write!(f, "None"),
        }
    }
}

impl From<Viewer> for ResolvedViewer {
    fn from(value: Viewer) -> Self {
        match value {
            Viewer::Wofi => ResolvedViewer::Wofi,
            Viewer::Rofi => ResolvedViewer::Rofi,
            Viewer::None => ResolvedViewer::Stdout,
            Viewer::Auto => {
                if which::which("wofi").is_ok() {
                    ResolvedViewer::Wofi
                } else if which::which("rofi").is_ok() {
                    ResolvedViewer::Rofi
                } else {
                    ResolvedViewer::Stdout
                }
            }
        }
    }
}
