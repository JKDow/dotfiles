local U = require("oil_header.utils")
local S = require("oil_header.state")
-- local C = require("oil_header.config")

local R = {}

local function shorten_path(dir, max_len)
    if not dir or dir == "" then return "" end
    dir = dir:gsub(vim.fn.getenv("HOME") or "", "~"):gsub("//+", "/")
    local segs = {}
    for s in dir:gmatch("[^/]+") do table.insert(segs, s) end
    if #segs == 0 then return dir end
    for i = 2, #segs - 1 do
        local seg = segs[i]
        if #seg > 1 then segs[i] = seg:sub(1, 1) end
    end
    local out = table.concat(segs, "/")
    if dir:sub(1, 1) == "/" then out = "/" .. out end
    if max_len and #out > max_len then
        out = "…" .. out:sub(#out - max_len + 2)
    end
    return out
end

local function rule(width) return string.rep("─", math.max(0, width)) end

local function chunk(key, label) return key .. ":" .. label end

local function join_chunks(chunks, max_width)
    local sep = "  •  "
    local line = table.concat(chunks, sep)
    if max_width and #line > max_width then
        line = table.concat(chunks, "  ")
        if #line > max_width then
            line = line:sub(1, math.max(0, max_width - 1)) .. "…"
        end
    end
    return line
end

local function header_lines(dir, width)
    dir = dir or ""
    width = math.max(20, width or 80)

    local title = "  󰉋  " .. shorten_path(dir, math.floor(width * 0.85))

    local g1 = join_chunks({
        chunk("⏎", "Open"),
        chunk("-", "Parent Dir"),
        chunk("y", "Copy"),
        chunk("p", "Paste"),
    }, width)

    local g2 = join_chunks({
        chunk("o", "New Line"),
        chunk("dd", "Trash"),
    }, width)

    local g3 = join_chunks({
        chunk("C-p", "Search Git Files"),
        chunk("<leader>pf", "Search All Files"),
        chunk("<leader>?", "Search Keybinds"),
    }, width)

    local spacer = "   "
    local line0 = rule(width)
    local line1 = title
    local line2 = rule(width)
    local line3 = spacer .. g1
    local merged = spacer .. g2 .. spacer .. g3
    if #merged > width then merged = merged:sub(1, width - 1) .. "…" end
    local line4 = merged

    return { line0, line1, line2, line3, line4 }
end

local function highlight_header(buf, lines)
    if not U.is_buf(buf) then return end
    local ns = vim.api.nvim_create_namespace("OilHeaderHL")
    local function try_set(name, def) pcall(vim.api.nvim_set_hl, 0, name, def) end

    try_set("OilHeaderTitle", { bold = true })
    try_set("OilHeaderKey", { bold = true })
    try_set("OilHeaderHint", { fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg })
    try_set("OilHeaderRule", { fg = vim.api.nvim_get_hl(0, { name = "NonText" }).fg })

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, ns, "OilHeaderRule", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, ns, "OilHeaderTitle", 1, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, ns, "OilHeaderRule", 2, 0, -1)

    local function hl_keys_on_line(idx)
        local s = lines[idx + 1]
        local i = 1
        while i <= #s do
            local colon = s:find(":", i, true)
            if not colon then break end
            local key_start = i
            local key_end   = colon - 1
            while key_start <= key_end and s:sub(key_start, key_start):match("[%s•]") do
                key_start = key_start + 1
            end
            if key_end >= key_start then
                vim.api.nvim_buf_add_highlight(buf, ns, "OilHeaderKey", idx, key_start - 1, key_end)
                local lbl_end = s:find("  •  ", colon + 1, true) or (#s + 1)
                vim.api.nvim_buf_add_highlight(buf, ns, "OilHeaderHint", idx, colon - 1, lbl_end - 1)
            end
            local next_sep = s:find("  •  ", colon + 1, true)
            i = (next_sep and next_sep + 5) or (#s + 1)
        end
    end

    hl_keys_on_line(3)
    hl_keys_on_line(4)
    vim.api.nvim_buf_add_highlight(buf, ns, "OilHeaderRule", 5, 0, -1)
end

function R.update_header(oil_win)
    local hdr_win = S.header_for(oil_win)
    if not U.is_win(hdr_win) then return end
    local hdr_buf              = vim.api.nvim_win_get_buf(hdr_win)
    local width                = vim.api.nvim_win_get_width(hdr_win)

    local ok, oil              = pcall(require, "oil")
    local dir                  = ok and (oil.get_current_dir() or "") or ""

    local lines                = header_lines(dir, width)

    vim.bo[hdr_buf].modifiable = true
    vim.api.nvim_buf_set_lines(hdr_buf, 0, -1, false, lines)
    vim.bo[hdr_buf].modifiable = false

    highlight_header(hdr_buf, lines)
end

R.header_lines = header_lines -- export for testing/tweaks if you want

return R
