// src/utils.rs
use regex::Regex;
use std::collections::BTreeMap;

pub fn normalize_mods(mods: &str) -> String {
    // Input like: "$mainMod SHIFT" or "CTRL ALT"
    let tokens: Vec<String> = mods
        .split_whitespace()
        .map(|t| {
            let t = t.trim().to_uppercase();
            match t.as_str() {
                "CONTROL" => "CTRL".into(),
                "SUPER" => "SUPER".into(),
                "ALTGR" => "ALTGR".into(),
                "SHIFT" => "SHIFT".into(),
                "CTRL" => "CTRL".into(),
                "ALT" => "ALT".into(),
                _ => t,
            }
        })
        .collect();
    tokens.join("+")
}

pub fn pretty_key(k: &str) -> String {
    let k = k.trim();
    // mouse buttons
    if let Some(rest) = k.strip_prefix("mouse:") {
        return match rest {
            "272" => "LMB".into(),
            "273" => "RMB".into(),
            "274" => "MMB".into(),
            _ => format!("BTN{rest}"),
        };
    }
    match k {
        "left" => "←".into(),
        "right" => "→".into(),
        "up" => "↑".into(),
        "down" => "↓".into(),
        "PRINT" | "Print" => "PrintScreen".into(),
        "semicolon" => ";".into(),
        "apostrophe" => "'".into(),
        "quote" => "\"".into(),
        "comma" => ",".into(),
        "period" => ".".into(),
        "slash" => "/".into(),
        "backslash" => "\\".into(),
        "minus" => "-".into(),
        "equal" => "=".into(),
        other => other.to_string(),
    }
}

/// Expand $VARS that exactly match `$[A-Za-z0-9_]+` tokens separated by whitespace.
pub fn expand_vars_tokenwise(s: &str, vars: &BTreeMap<String, String>) -> String {
    s.split_whitespace()
        .map(|t| {
            if t.starts_with('$') {
                vars.get(t).cloned().unwrap_or_else(|| t.to_string())
            } else {
                t.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join(" ")
}

/// Expand $vars anywhere in the string using regex `$[A-Za-z0-9_]+`.
pub fn expand_vars_generic(s: &str, vars: &BTreeMap<String, String>) -> String {
    static VAR_RE_SRC: &str = r"\$[A-Za-z0-9_]+";
    let re = Regex::new(VAR_RE_SRC).unwrap();
    re.replace_all(s, |caps: &regex::Captures| {
        let m = caps.get(0).unwrap().as_str();
        vars.get(m).cloned().unwrap_or_else(|| m.to_string())
    })
    .into_owned()
}

pub fn pad(s: &str, n: usize) -> String {
    let len = s.chars().count();
    if len >= n {
        s.to_string()
    } else {
        format!("{s}{}", " ".repeat(n - len))
    }
}
