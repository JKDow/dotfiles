return {
    "zbirenbaum/copilot.lua",
    name = 'copilot',
    cmd = "Copilot",
    dependencies = {
        "zbirenbaum/copilot-cmp",
    },
    event = "InsertEnter",
    config = function()
        require("copilot_cmp").setup()
        require("copilot").setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
        })
        vim.keymap.set('n', '<leader>ai', require('copilot.suggestion').toggle_auto_trigger)
    end,
}
