// src/lib.rs
mod cli;
mod utils;
mod viewer;

use anyhow::Result;
use std::{
    collections::BTreeMap,
    io::Write,
    process::{Command, Stdio},
};
use utils::*;

pub use cli::Cli;
use regex::Regex;
pub use viewer::*;

#[derive(Debug, Clone)]
pub struct Entry {
    pub keys: String,
    pub action: String,
    pub args: String,
    pub scope: Option<String>, // submap name
    pub kind: String,          // bind / bindl / bindel / bindm
}

#[derive(Debug, Clone)]
pub struct ParsedBind {
    kind: String,
    mods: String,
    key: String,
    action: String,
    args: String,
    scope: Option<String>,
}

pub fn run_dmenu(
    bin: &str,
    prompt: &str,
    input: &str,
    allow_markup: bool,
    width: Option<usize>,
) -> Result<()> {
    let mut cmd = if bin == "wofi" {
        let mut c = Command::new("wofi");
        if allow_markup {
            c.arg("--allow-markup");
        }
        if let Some(w) = width {
            c.args(["--width", &w.to_string()]);
        }
        c.args(["--show", "dmenu", "--prompt", prompt]);
        c
    } else {
        // rofi
        let mut c = Command::new("rofi");
        c.args(["-dmenu", "-p", prompt]);
        c
    };
    let mut child = cmd.stdin(Stdio::piped()).stdout(Stdio::null()).spawn()?;
    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(input.as_bytes())?;
    }
    let _ = child.wait()?;
    Ok(())
}

pub fn parse_keybinds(text: &str) -> Result<(BTreeMap<String, String>, Vec<ParsedBind>)> {
    let mut vars: BTreeMap<String, String> = BTreeMap::new();
    let mut entries: Vec<ParsedBind> = Vec::new();
    let mut current_submap: Option<String> = None;

    let re_var = Regex::new(r#"^\s*(\$\w+)\s*=\s*(?:"([^"]*)"|([^\#]+?))\s*(?:\#.*)?$"#).unwrap();
    // Examples:
    // bind = $mainMod, T, exec, kitty
    // bindl = , XF86AudioNext, exec, playerctl next
    // bindm = $mainMod, mouse:272, movewindow
    let re_bind = Regex::new(r#"^\s*(bind(?:m|l|el)?)\s*=\s*(.+?)\s*(?:\#.*)?$"#).unwrap();
    let re_submap = Regex::new(r#"^\s*submap\s*=\s*([^\#]+?)\s*(?:\#.*)?$"#).unwrap();

    for raw in text.lines() {
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }

        if let Some(cap) = re_submap.captures(line) {
            let name = cap[1].trim();
            if name.eq_ignore_ascii_case("reset") {
                current_submap = None;
            } else {
                current_submap = Some(name.to_string());
            }
            continue;
        }

        if let Some(cap) = re_var.captures(line) {
            let key = cap[1].to_string(); // with leading $
            let val = cap
                .get(2)
                .map(|m| m.as_str().to_string())
                .or_else(|| cap.get(3).map(|m| m.as_str().trim().to_string()))
                .unwrap_or_default();
            vars.insert(key.clone(), val.clone());

            // also allow referencing without the $ internally, if desired
            let bare = key.trim_start_matches('$').to_string();
            vars.insert(format!("${bare}"), val);
            continue;
        }

        if let Some(cap) = re_bind.captures(line) {
            let kind = cap[1].to_string();
            let rest = cap[2].to_string();

            // split by commas (tolerant)
            let parts: Vec<String> = rest.split(',').map(|s| s.trim().to_string()).collect();

            if parts.len() < 3 {
                continue;
            }
            let mods = parts.first().cloned().unwrap_or_default();
            let key = parts.get(1).cloned().unwrap_or_default();
            let action = parts.get(2).cloned().unwrap_or_default();
            let args = if parts.len() > 3 {
                parts[3..].join(", ")
            } else {
                String::new()
            };

            entries.push(ParsedBind {
                kind,
                mods,
                key,
                action,
                args,
                scope: current_submap.clone(),
            });
            continue;
        }
    }

    Ok((vars, entries))
}

pub fn display_rows(vars: &BTreeMap<String, String>, parsed: &[ParsedBind]) -> Vec<Entry> {
    let mut rows = Vec::with_capacity(parsed.len());
    for p in parsed {
        let mods_disp = normalize_mods(&expand_vars_tokenwise(&p.mods, vars));
        let key_disp = pretty_key(&p.key);
        let keys = if mods_disp.is_empty() {
            key_disp
        } else {
            format!("{mods_disp}+{key_disp}")
        };

        let action = p.action.clone();
        let args = expand_vars_generic(&p.args, vars);
        let scope = p.scope.clone();

        rows.push(Entry {
            keys,
            action,
            args: if args.trim().is_empty() {
                "—".into()
            } else {
                args
            },
            scope,
            kind: p.kind.clone(),
        });
    }
    rows
}

pub fn render_markup(rows: &[Entry], multiline: bool) -> String {
    // widths for the first line (keys + action)
    let mut w_keys = 12usize;
    let mut w_action = 12usize;
    for r in rows {
        w_keys = w_keys.max(r.keys.chars().count());
        w_action = w_action.max(r.action.chars().count());
    }

    // Build a stable ordered list of scope groups, preserving the order
    // that rows appear in after your sort. None comes first, then each
    // Some(scope) the first time it’s seen.
    let mut order: Vec<Option<String>> = Vec::new();
    let mut seen = std::collections::BTreeSet::<String>::new();
    for r in rows {
        match &r.scope {
            None => {
                if !order.iter().any(|s| s.is_none()) {
                    order.push(None);
                }
            }
            Some(s) => {
                if seen.insert(s.clone()) {
                    order.push(Some(s.clone()));
                }
            }
        }
    }

    let mut out = String::new();

    // Header
    if multiline {
        out.push_str("<b>Hyprland Keybinds</b>\n");
    } else {
        out.push_str("Hyprland Keybinds\n");
        out.push_str("────────────────────────────────────────────────────────────────────────\n");
        out.push_str(&format!(
            "{}  {}  {}  {}\n",
            pad("Keys", w_keys),
            pad("Action", w_action),
            "Args / Details",
            "[Scope]"
        ));
        out.push_str(&format!(
            "{}  {}  {}  {}\n",
            pad("----", w_keys),
            pad("------", w_action),
            "-------------",
            "-------"
        ));
    }

    // Helper to transform the "submap" opener into a nicer description
    let humanize = |action: &str, args: &str| -> (String, String) {
        if action.eq_ignore_ascii_case("submap") && !args.trim().is_empty() {
            // Action becomes a friendly label; keep the submenu name in args
            return ("Open submenu".to_string(), args.to_string());
        }
        (action.to_string(), args.to_string())
    };

    // Render by groups
    for scope in order {
        let in_submenu = scope.is_some();

        // Submenu header
        if let Some(s) = &scope {
            if multiline {
                out.push_str(&format!("<small><b>⟪ Submenu: {s} ⟫</b></small>\n"));
            } else {
                out.push_str(&format!(
                    "── Submenu: {s} ─────────────────────────────────────────────\n"
                ));
            }
        }

        // Render rows that belong to this group
        for r in rows.iter().filter(|r| r.scope == scope) {
            let (action, mut args) = humanize(&r.action, &r.args);

            // Prefix submenu entries with an arrow for visual nesting
            let keys_disp = match &scope {
                Some(s) => format!("{}  {}", s, r.keys),
                None => r.keys.clone(),
            };

            if multiline {
                // Line 1: keys + action
                out.push_str(&format!(
                    "<tt>{}</tt>  <b>{}</b>\n",
                    pad(&keys_disp, w_keys + if in_submenu { 2 } else { 0 }),
                    pad(&action, w_action)
                ));

                // Line 2: details (args + [scope])
                // We omit [scope] here since it's obvious under the submenu header.
                if args.trim().is_empty() {
                    args = "—".into();
                }
                out.push_str(&format!("<small>{args}</small>\n"));
            } else {
                // Single-line table
                let scope_disp = match (&scope, action.as_str()) {
                    // Don’t repeat [scope] for submenu items; the group header shows it
                    (Some(_), _) => "".to_string(),
                    (None, _) => "".to_string(),
                };
                if args.trim().is_empty() {
                    args = "—".into();
                }
                out.push_str(&format!(
                    "{}  {}  {}  {}\n",
                    pad(&keys_disp, w_keys + if in_submenu { 2 } else { 0 }),
                    pad(&action, w_action),
                    args,
                    scope_disp
                ));
            }
        }

        // Visual spacing between groups
        if multiline {
            out.push('\n');
        }
    }

    out
}
