return {
    "rcarriga/nvim-notify",
    version = "3.14.*",
    config = function()
        local notify = require("notify")
        -- For transparency
        -- notify.setup({ background_colour = "#000000" })
        notify.setup({
            stages = "static",
        })
        -- reset vim notify function with the notify one
        vim.notify = notify
    end
}
