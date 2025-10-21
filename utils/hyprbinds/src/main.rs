// src/main.rs
use anyhow::{Context, Result};
use clap::Parser;
use hyprbinds::{
    display_rows, parse_keybinds, render_markup, run_dmenu, Cli, ResolvedViewer
};
use std::{cmp::Ordering, fs};

fn main() -> Result<()> {
    let cli = Cli::parse();
    let text = fs::read_to_string(&cli.path)
        .with_context(|| format!("Failed to read {}", cli.path.display()))?;
    let (vars, entries) = parse_keybinds(&text)?;

    let mut rows = display_rows(&vars, &entries);

    if !cli.no_sort {
        rows.sort_by(|a, b| {
            let scope_a = a.scope.as_deref().unwrap_or("");
            let scope_b = b.scope.as_deref().unwrap_or("");
            match scope_a.cmp(scope_b) {
                Ordering::Equal => match a.action.cmp(&b.action) {
                    Ordering::Equal => a.keys.cmp(&b.keys),
                    o => o,
                },
                o => o,
            }
        });
    }

    let output = render_markup(&rows, cli.multiline);

    match ResolvedViewer::from(cli.viewer) {
        ResolvedViewer::Wofi => run_dmenu("wofi", &cli.prompt, &output, cli.multiline, cli.width)?,
        ResolvedViewer::Rofi => run_dmenu("rofi", &cli.prompt, &output, false, None)?,
        ResolvedViewer::Stdout => {
            print!("{output}");
        }
    }

    Ok(())
}
