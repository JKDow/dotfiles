return {
    "goolord/alpha-nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local theme = require("alpha.themes.startify")
        theme.file_icons.provider = "devicons"
        require("alpha").setup(
            theme.config
        )
    end,
}
