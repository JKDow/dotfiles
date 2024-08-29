
function ColorMyPencils(color)
    -- color = color or "rose-pine"
    -- color = color or "tokyonight"
    color = color or "onedark"
	vim.cmd.colorscheme(color)
end 

return {
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    },

    {
        'folke/tokyonight.nvim'
    },

    {
        'joshdick/onedark.vim',
        name = "onedark",
        config = function()
            ColorMyPencils()
        end
    }
}
