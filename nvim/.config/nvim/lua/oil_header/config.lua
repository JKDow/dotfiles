local M = {}

M.opts = {
    winhl = nil,     -- e.g. "Normal:NormalFloat,EndOfBuffer:NormalFloat"
    force_quit = false -- use :qall! when exiting via Oil-only flow
}

M.aug = vim.api.nvim_create_augroup("OilHeader", { clear = true })

function M.apply(opts)
    if opts then
        M.opts = vim.tbl_extend("force", M.opts, opts)
    end
end

return M
