// src/cli.rs
use std::path::PathBuf;

use clap::Parser;

use crate::Viewer;

#[derive(Debug, Parser)]
#[command(
    name = "hypr-binds-help",
    version,
    about = "Hyprland keybinds help menu generator"
)]
pub struct Cli {
    /// Path to the keybinds file (the sourced file, not necessarily hyprland.conf)
    #[arg(value_name = "PATH")]
    pub path: PathBuf,

    /// Where to show the output
    #[arg(long, default_value_t = Viewer::Auto)]
    pub viewer: Viewer,

    /// Title shown in the menu prompt
    #[arg(long, default_value = "Hyprland Keybinds")]
    pub prompt: String,

    /// Don’t sort, keep file order
    #[arg(long)]
    pub no_sort: bool,

    #[arg(long)]
    pub multiline: bool,

    #[arg(long)]
    pub width: Option<usize>,
}
