local C = require("oil_header.config")
local U = require("oil_header.utils")
local S = require("oil_header.state")
local R = require("oil_header.render")
local L = require("oil_header.lifecycle")
local Q = require("oil_header.quit")

local A = {}

function A.setup()
    -- Create header on first entry into Oil
    local function ensure_header_for_current_win()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        if U.is_oil_buf(buf) then
            vim.schedule(function()
                if U.is_oil_win(win) then
                    L.create_header(win)
                    R.update_header(win)
                end
            end)
        end
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = C.aug, pattern = "oil", callback = ensure_header_for_current_win,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
        group = C.aug, pattern = "*", callback = ensure_header_for_current_win,
    })
    pcall(vim.api.nvim_create_autocmd, "User", {
        group = C.aug, pattern = "OilEnter", callback = ensure_header_for_current_win,
    })

    -- Keep header fresh; bounce focus if it lands on header
    vim.api.nvim_create_autocmd({ "DirChanged", "WinResized", "WinEnter" }, {
        group = C.aug,
        callback = function()
            local cur = vim.api.nvim_get_current_win()
            local host = S.find_host_for_header_win(cur)
            if host and U.is_win(host) then
                vim.schedule(function()
                    if vim.api.nvim_get_current_win() == cur then
                        vim.api.nvim_set_current_win(host)
                    end
                end)
                return
            end
            if U.is_oil_win(cur) and S.header_for(cur) then
                R.update_header(cur)
            end
        end,
    })

    -- If a window stops showing Oil, remove its header
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = C.aug,
        pattern = "*",
        callback = function()
            local win = vim.api.nvim_get_current_win()
            if S.header_for(win) and not U.is_oil_win(win) then
                L.close_header_for(win)
            end
        end,
    })

    -- Intercept :q in Oil to preserve prompts / exit cleanly
    vim.api.nvim_create_autocmd("QuitPre", {
        group = C.aug,
        callback = function()
            local win = vim.api.nvim_get_current_win()
            local buf = vim.api.nvim_get_current_buf()
            if not U.is_oil_buf(buf) then return end
            if Q.switch_to_modified_buf_or_exit(win) then return end
        end,
    })

    -- Cleanup when either the Oil window or the header window closes
    vim.api.nvim_create_autocmd("WinClosed", {
        group = C.aug,
        callback = function(args)
            if vim.v.exiting ~= vim.NIL and tonumber(vim.v.exiting) ~= 0 then
                return
            end
            local closed = tonumber(args.match)

            -- Host closed -> close header (deferred)
            local hdr = S.header_for(closed)
            if hdr then
                S.clear_header(closed)
                if U.is_win(hdr) then
                    local buf = vim.api.nvim_win_get_buf(hdr)
                    vim.schedule(function()
                        if U.is_win(hdr) then pcall(vim.api.nvim_win_close, hdr, true) end
                        if U.is_buf(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
                    end)
                end
                return
            end

            -- Header closed -> untrack its host
            local host = S.find_host_for_header_win(closed)
            if host then S.clear_header(host) end
        end,
    })
end

return A
