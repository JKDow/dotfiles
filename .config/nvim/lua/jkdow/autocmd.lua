local autocmd = vim.api.nvim_create_autocmd

-- Set filetype to php for Intelephense
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.blade.php" },
    callback = function()
        vim.bo.filetype = "php"
    end
})

-- Force blade highlighting to work after file type change
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.blade.php" },
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        require('nvim-treesitter.highlight').attach(bufnr, 'blade')
    end
})

-- Set LSP keymaps
autocmd('lspAttach', {
    callback = function (event)
        local opts = { buffer = event.buf }
        -- Todo: Have this only apply to attached buffer
        vim.keymap.set('n', '<Leader>K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    end
})

-- Remove all trailing whitespace when saving a buffer
autocmd({"BufWritePre"}, {
    pattern = "*",
    callback = function ()
        local cur_pos = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", cur_pos)
    end
})
