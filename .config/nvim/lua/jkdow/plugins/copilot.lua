return {
    "zbirenbaum/copilot.lua",
    name = 'copilot',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({})
        vim.keymap.set('n', '<leader>ai', require('copilot.suggestion').toggle_auto_trigger)
    end,
}
