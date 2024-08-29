return {
    {
        'joshdick/onedark.vim',
        name = "onedark",
        lazy = false,
        priority = 1000,
        config = function()
	        vim.cmd.colorscheme("onedark")
            -- ColorMyPencils()
        end
    },

    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            -- vim.cmd('colorscheme rose-pine')
        end
    },

    {
        'folke/tokyonight.nvim'
    }
}
