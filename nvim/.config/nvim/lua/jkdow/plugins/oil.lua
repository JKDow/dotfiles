return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        view_options = {
            show_hidden = true,
        },
        keymaps = {
            ["<C-p>"] = false,
        }
    },
    keys = {
        { "-",          "<cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
        { "<leader>pv", "<cmd>Oil<CR>", desc = "File explorer" },
    },
    -- Optional dependencies
    dependencies = {
        { "nvim-mini/mini.icons", opts = {} },
        {
            dir = vim.fn.stdpath("config") .. "/lua/oil_header", -- if you drop it in your config
            name = "oil-header",
            config = function()
                require("oil_header").setup()
            end,
        }
    },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
}
