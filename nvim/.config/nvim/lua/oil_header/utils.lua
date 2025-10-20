local U = {}

function U.is_win(win) return win and vim.api.nvim_win_is_valid(win) end

function U.is_buf(buf) return buf and vim.api.nvim_buf_is_valid(buf) end

function U.is_oil_buf(buf)
    return U.is_buf(buf) and vim.bo[buf].filetype == "oil"
end

function U.is_oil_win(win)
    return U.is_win(win) and U.is_oil_buf(vim.api.nvim_win_get_buf(win))
end

function U.is_float(win)
    if not U.is_win(win) then return false end
    local cfg = vim.api.nvim_win_get_config(win)
    return cfg and cfg.relative ~= ""
end

function U.is_header_win(win)
    if not U.is_win(win) then return false end
    local buf = vim.api.nvim_win_get_buf(win)
    return U.is_buf(buf) and vim.bo[buf].filetype == "oil_header"
end

function U.count_real_wins()
    local n = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if U.is_win(w) and not U.is_float(w) and not U.is_header_win(w) then
            n = n + 1
        end
    end
    return n
end

function U.find_modified_listed_buf()
    for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if info.changed == 1 then
            local ft = vim.bo[info.bufnr].filetype
            if ft ~= "oil" and ft ~= "oil_header" then
                return info.bufnr
            end
        end
    end
    return nil
end

return U
