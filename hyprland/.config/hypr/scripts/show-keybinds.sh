#!/usr/bin/env bash
set -euo pipefail

# Point this at your sourced binds file
CONF="${1:-$HOME/.config/hypr/keybinds.conf}"

# Pick a viewer
if command -v wofi >/dev/null 2>&1; then
  VIEWER_CMD=('sh' '-lc' "wofi --show dmenu --prompt 'Hyprland Keybinds'")
elif command -v rofi >/dev/null 2>&1; then
  VIEWER_CMD=('sh' '-lc' "rofi -dmenu -p 'Hyprland Keybinds'")
else
  VIEWER_CMD=('cat')
fi

# NOTE: Requires gawk for asort(). Most systems have /usr/bin/awk -> gawk.
awk '
  function trim(s){ sub(/^[ \t\r\n]+/,"",s); sub(/[ \t\r\n]+$/,"",s); return s }
  function rstrip_comment(s,   i){ i=index(s,"#"); return i?substr(s,1,i-1):s }

  function split_commas(s, arr,   t,i,c,part){
    # split on commas with tolerant spacing
    c=0; t=s
    while ((i = index(t, ",")) > 0) {
      part = trim(substr(t,1,i-1))
      arr[++c]=part
      t = substr(t, i+1)
    }
    t=trim(t); if(t!="") arr[++c]=t
    return c
  }

  # replacer to expand $vars: gsub(/\$NAME/, repl_var, token)
  function repl_var(v,   k){ k=v; return (k in varmap) ? varmap[k] : k }

  function normmods(s,   out,i,n,mods,part){
    s=trim(s); if(s=="") return ""
    n=split(s,mods,/ +/)
    out=""
    for(i=1;i<=n;i++){
      part = mods[i]
      # expand variables in the modifier token
      gsub(/\$[A-Za-z0-9_]+/, repl_var, part)
      # normalize canonical names
      gsub(/^CONTROL$/,"CTRL",part)
      gsub(/^ALTGR$/,"ALTGR",part)
      gsub(/^SUPER$/,"SUPER",part)
      out = (out=="" ? part : out "+" part)
    }
    return out
  }

  function pretty_key(k){
    # prettify common keys/punctuation/mouse buttons
    if (k=="left") return "←"
    if (k=="right") return "→"
    if (k=="up") return "↑"
    if (k=="down") return "↓"
    if (k=="PRINT" || k=="Print") return "PrintScreen"
    if (k=="semicolon" || k==";") return ";"
    if (k=="apostrophe") return "\x27"
    if (k=="quote") return "\""
    if (k=="comma") return ","
    if (k=="period") return "."
    if (k=="slash") return "/"
    if (k=="backslash") return "\\"
    if (k=="minus") return "-"
    if (k=="equal") return "="
    if (k ~ /^mouse:[0-9]+$/) {
      sub(/^mouse:/,"",k)
      if (k==272) return "LMB"
      if (k==273) return "RMB"
      if (k==274) return "MMB"
      return "BTN" k
    }
    return k
  }

  function pad(s,n){ l=length(s); return (l<n) ? s sprintf("%" (n-l) "s","") : s }

  BEGIN{
    entryc=0; submap="";
    dq = sprintf("%c",34)  # double-quote character
  }

  {
    raw=$0
    line=trim(raw)
    if(line=="" || substr(line,1,1)=="#") next

    nohash = rstrip_comment(line)

    # Track submaps
    if (match(nohash, /^[ \t]*submap[ \t]*=[ \t]*/)) {
      sm = trim(substr(nohash, RSTART+RLENGTH))
      submap = (sm=="reset") ? "" : sm
      next
    }

    # Variables like: $mainMod = SUPER or $menu = "wofi --show drun"
    if (match(nohash, /^[ \t]*\$[A-Za-z0-9_]+[ \t]*=/)) {
      var = trim(substr(nohash, 1, index(nohash,"=")-1))
      gsub(/[ \t]/,"",var) # keep leading $
      val = trim(substr(nohash, index(nohash,"=")+1))
      # strip optional surrounding quotes safely
      if (substr(val,1,1)==dq && substr(val,length(val),1)==dq) {
        val = substr(val, 2, length(val)-2)
      }
      varmap[var]=val
      bare=var; sub(/^\$/,"",bare)
      varmap["$" bare]=val
      next
    }

    # Binds: bind / bindl / bindel / bindm
    if (match(nohash, /^[ \t]*bind(m|l|el)?[ \t]*=/)) {
      type = substr(nohash, RSTART, RLENGTH)
      rest = trim(substr(nohash, RSTART+RLENGTH))
      if (substr(rest,1,1)==",") rest=trim(substr(rest,2))

      c = split_commas(rest, parts)
      if (c < 3) next

      mods = parts[1]
      key  = parts[2]
      act  = parts[3]
      args = ""
      for (i=4;i<=c;i++) {
        args = (args=="" ? parts[i] : args ", " parts[i])
      }

      # Expand variables that appear inside args too (nice for $terminal/$menu)
      # We only expand standalone $vars; leave quoted arg text intact otherwise.
      for (v in varmap) {
        gsub("\\$" substr(v,2) "([^A-Za-z0-9_]|$)", varmap[v] "\\1", args)
      }

      # Expand vars in modifiers; prettify key
      nmods = normmods(mods)
      kdisp = (nmods!="" ? nmods "+" pretty_key(key) : pretty_key(key))

      entryc++
      entries_key[entryc]=kdisp
      entries_act[entryc]=act
      entries_args[entryc]=(args=="" ? "—" : args)
      entries_scope[entryc]=(submap=="" ? "" : "submap:" submap)
      entries_type[entryc]=type

      w_keys = (length(kdisp)>w_keys? length(kdisp):w_keys)
      w_act  = (length(act)>w_act? length(act):w_act)
      next
    }
  }

  END{
    if (entryc==0) {
      print "No keybinds found in " ENVIRON["CONF"]; exit 0
    }

    title="Hyprland Keybinds"
    print title
    print "────────────────────────────────────────────────────────────────────────"

    # sort by scope → action → keys
    for (i=1;i<=entryc;i++){
      sortk = entries_scope[i] "\034" entries_act[i] "\034" entries_key[i] "\034" i
      idx[i]=sortk
    }
    asort(idx)

    hk = (w_keys<12?12:w_keys)
    ha = (w_act<12?12:w_act)

    print pad("Keys", hk) "  " pad("Action", ha) "  Args / Details  [Scope]"
    print pad("----", hk) "  " pad("------", ha) "  -------------  -------"

    for (j=1;j<=entryc;j++){
      sk = idx[j]
      split(sk, p, /\034/)
      i = p[4]+0
      k  = entries_key[i]
      a  = entries_act[i]
      ar = entries_args[i]
      sc = entries_scope[i]
      print pad(k, hk) "  " pad(a, ha) "  " ar "  " (sc==""?"":"[" sc "]")
    }
  }
' "$CONF" | "${VIEWER_CMD[@]}"

