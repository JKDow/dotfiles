-- Set filetype to php for Intelephense, but keep Tree-sitter working for Blade
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.blade.php" },
    callback = function()
        vim.bo.filetype = "php"
    end
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.blade.php" },
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        require('nvim-treesitter.highlight').attach(bufnr, 'blade')
    end
})
