local U = require("oil_header.utils")
local S = require("oil_header.state")
local R = require("oil_header.render")
local C = require("oil_header.config")

local L = {}

local function make_header_buf()
    local buf              = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype    = "nofile"
    vim.bo[buf].bufhidden  = "wipe"
    vim.bo[buf].swapfile   = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype   = "oil_header"
    vim.bo[buf].buflisted  = false
    return buf
end

function L.create_header(oil_win)
    local existing = S.header_for(oil_win)
    if existing and U.is_win(existing) then
        R.update_header(oil_win)
        return existing
    end

    local hdr_buf = make_header_buf()

    local saved = vim.api.nvim_get_current_win()
    if U.is_win(oil_win) then vim.api.nvim_set_current_win(oil_win) end
    vim.cmd("aboveleft 5split")
    local hdr_win = vim.api.nvim_get_current_win()
    if U.is_win(saved) then vim.api.nvim_set_current_win(saved) end

    vim.api.nvim_win_set_buf(hdr_win, hdr_buf)
    vim.wo[hdr_win].winfixheight   = true
    vim.wo[hdr_win].number         = false
    vim.wo[hdr_win].relativenumber = false
    vim.wo[hdr_win].signcolumn     = "no"
    vim.wo[hdr_win].foldcolumn     = "0"
    vim.wo[hdr_win].list           = false
    vim.wo[hdr_win].cursorline     = false
    vim.wo[hdr_win].cursorcolumn   = false
    vim.wo[hdr_win].wrap           = false
    vim.wo[hdr_win].statuscolumn   = ""
    vim.wo[hdr_win].winbar         = ""
    vim.wo[hdr_win].statusline     = " "

    vim.wo[hdr_win].winhl          = C.opts.winhl or ""

    S.set_header(oil_win, hdr_win)
    R.update_header(oil_win)

    vim.schedule(function()
        if U.is_win(oil_win) then vim.api.nvim_set_current_win(oil_win) end
    end)

    return hdr_win
end

function L.close_header_for(oil_win)
    local hdr_win = S.header_for(oil_win)
    S.clear_header(oil_win)
    if U.is_win(hdr_win) then
        local buf = vim.api.nvim_win_get_buf(hdr_win)
        pcall(vim.api.nvim_win_close, hdr_win, true)
        if U.is_buf(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
    end
end

return L
