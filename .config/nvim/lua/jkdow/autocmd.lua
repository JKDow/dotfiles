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

-- Remove all trailing whitespace when saving a buffer
autocmd({ "BufWritePre" }, {
    pattern = "*",
    callback = function()
        local cur_pos = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", cur_pos)
    end
})
