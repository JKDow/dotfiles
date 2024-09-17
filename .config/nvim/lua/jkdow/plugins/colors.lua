return {
    --[[
    {
        'navarasu/onedark.nvim',
        name = "onedark",
        lazy = false,
        priority = 1000,
        config = function()
            require('onedark').setup {
                style = 'dark',
            }
            require('onedark').load()
        end
    },
    --]]
    --[[
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        lazy = false,
        priority = 1000,
        config = function()
           vim.cmd('colorscheme rose-pine')
        end
    },
    --]]
    --[[
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        opts = {},
    }
    --]]
    {
        "olimorris/onedarkpro.nvim",
        lazy = false,
        priority = 1000,
    }
}
