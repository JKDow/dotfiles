return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        -- setup parser for blade (PHP LARAVEL)
        local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
        parser_config.blade = {
            install_info = {
                url = "https://github.com/EmranMR/tree-sitter-blade",
                files = { "src/parser.c" },
                branch = "main",
            },
            filetype = "blade"
        }

        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "c", "lua", "vimdoc", "rust", "php", "blade",
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            indent = { enable = true },

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "php", "markdown" },
            },
        })

        vim.api.nvim_exec([[
            augroup BladeFiletypeRelated
                au BufNewFile,BufRead *.blade.php set ft=blade
            augroup END
        ]], false)
    end
}
