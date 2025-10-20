local M = {}

local map = {} -- [oil_winid] = header_winid

-- Utility helpers
local function is_valid_win(win)
    return win and vim.api.nvim_win_is_valid(win)
end

local function is_oil_win(win)
    if not is_valid_win(win) then return false end
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].filetype == "oil"
end

-- Build header content
local function build_lines()
    local ok, oil = pcall(require, "oil")
    local dir = (ok and oil.get_current_dir()) or vim.fn.getcwd()
    local path = vim.fn.fnamemodify(dir or "", ":~")
    return {
        " 󰉋  " .. path,
        " Move: m  Copy: y  Paste: p  Rename: r  Up: -  Open: <CR>",
        "",
    }
end

-- Style the header window to look seamless
local function style_header_win(hwin)
    local wo = vim.wo[hwin]
    wo.winfixheight = true
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = "no"
    wo.statuscolumn = ""
    wo.cursorline = false
    wo.foldcolumn = "0"
    wo.wrap = false
    wo.list = false
    wo.colorcolumn = ""
    wo.fillchars = "eob: " -- hide ~
    wo.winbar = ""       -- no winbar
    wo.statusline = " "  -- no local statusline
    wo.winhl = "Normal:OilHeader,EndOfBuffer:OilHeader"
    vim.cmd([[highlight default link OilHeader Normal]])
end

local function update_header_lines(hwin)
    if not is_valid_win(hwin) then return end
    local hbuf = vim.api.nvim_win_get_buf(hwin)
    if not vim.api.nvim_buf_is_valid(hbuf) then return end
    vim.bo[hbuf].modifiable = true
    vim.api.nvim_buf_set_lines(hbuf, 0, -1, false, build_lines())
    vim.bo[hbuf].modifiable = false
end

-- Create or refresh the header above a given Oil window
local function open_or_update_header(oil_win)
    if not is_oil_win(oil_win) then return end

    local hwin = map[oil_win]
    if is_valid_win(hwin) then
        update_header_lines(hwin)
        return
    end

    -- Create new header buffer
    local hbuf = vim.api.nvim_create_buf(false, true)
    vim.bo[hbuf].buftype = "nofile"
    vim.bo[hbuf].bufhidden = "wipe"
    vim.bo[hbuf].swapfile = false
    vim.bo[hbuf].modifiable = false
    vim.bo[hbuf].filetype = "oil-header"

    -- Split above the Oil window
    vim.api.nvim_set_current_win(oil_win)
    vim.cmd("noautocmd aboveleft split")
    hwin = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(hwin, hbuf)
    style_header_win(hwin)
    update_header_lines(hwin)
    pcall(vim.api.nvim_win_set_height, hwin, 3)

    -- Track relationship
    map[oil_win] = hwin
    vim.w[oil_win].oil_header_win = hwin
    vim.w[hwin].oil_parent_win = oil_win

    -- Return cursor focus back to Oil
    vim.api.nvim_set_current_win(oil_win)
end

local function close_header_for(oil_win)
    local hwin = map[oil_win]
    if is_valid_win(hwin) then
        pcall(vim.api.nvim_win_close, hwin, true)
    end
    map[oil_win] = nil
end

-- Prevent cursor focus in header
vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        local cur = vim.api.nvim_get_current_win()
        for oil_win, hwin in pairs(map) do
            if hwin == cur then
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(oil_win) then
                        pcall(vim.api.nvim_set_current_win, oil_win)
                    end
                end)
                return
            end
        end
    end,
})

-- Setup autocommands
function M.setup()
    -- Show header after Oil finishes drawing
    vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        callback = function()
            local win = vim.api.nvim_get_current_win()
            if is_oil_win(win) then
                vim.defer_fn(function()
                    open_or_update_header(win)
                end, 10)
            end
        end,
    })

    -- Ensure header exists when entering Oil again
    vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function(args)
            if vim.bo[args.buf].filetype == "oil" then
                open_or_update_header(vim.api.nvim_get_current_win())
            end
        end,
    })

    -- Refresh on resize or idle
    vim.api.nvim_create_autocmd({ "WinResized", "CursorHold" }, {
        callback = function()
            local win = vim.api.nvim_get_current_win()
            if is_oil_win(win) then
                local hwin = map[win]
                if is_valid_win(hwin) then
                    update_header_lines(hwin)
                    pcall(vim.api.nvim_win_set_height, hwin, 3)
                else
                    open_or_update_header(win)
                end
            end
        end,
    })

    -- Cleanup on exit
    vim.api.nvim_create_autocmd({ "BufWinLeave", "WinClosed" }, {
        callback = function(args)
            local closed = tonumber(args.match)
            for oil_win, hwin in pairs(map) do
                if closed == oil_win or closed == hwin then
                    close_header_for(oil_win)
                end
            end
        end,
    })
end

return M
