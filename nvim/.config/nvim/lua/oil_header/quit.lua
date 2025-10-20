local U = require("oil_header.utils")
local S = require("oil_header.state")
local L = require("oil_header.lifecycle")
local C = require("oil_header.config")

local Q = {}

-- When :q in Oil:
-- - if any modified listed buffers exist, switch to one and let default E37/E162 prompt happen
-- - else if this is the only real window, quit the editor immediately
function Q.switch_to_modified_buf_or_exit(current_oil_win)
    if U.count_real_wins() > 1 then
        return false -- let normal :q close the split
    end

    local modbuf = U.find_modified_listed_buf()
    if modbuf then
        L.close_header_for(current_oil_win)
        pcall(vim.api.nvim_set_current_buf, modbuf)
        return true
    end

    -- No modified buffers: exit editor cleanly
    S.clear_all() -- avoid teardown races
    local cmd = C.opts.force_quit and "qall!" or "qall"
    pcall(vim.cmd, cmd)
    return true
end

return Q
