return {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = {
        { "nvim-mini/mini.icons",            opts = {} },
        { "benomahony/oil-git.nvim",         opts = {} },
        { "JezerM/oil-lsp-diagnostics.nvim", opts = {} },
        {
            dir = vim.fn.stdpath("config") .. "/lua/oil_header",
            name = "oil-header",
            config = function()
                require("oil_header").setup()
            end,
        }
    },
    config = function()
        require('oil').setup {
            view_options = {
                show_hidden = false,
            },
            keymaps = {
                ["<C-p>"] = false,
                ["g."] = false,
                ["."] = { "actions.toggle_hidden", mode = "n" },
            },
            delete_to_trash = true,
        }

        vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory (Oil)" })
        vim.keymap.set("n", "<leader>pv", "<cmd>Oil<CR>", { desc = "Open parent directory (Oil)" })
    end,
}
