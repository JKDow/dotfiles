return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require('telescope').setup({})

        local builtin = require('telescope.builtin')
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        local function custom_help_picker()
            builtin.help_tags({
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        if selection == nil then
                            return
                        end
                        actions.close(prompt_bufnr)
                        open_help_floating(selection.display)
                    end)
                    return true
                end,
            })
        end

        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>re', builtin.oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader>?', builtin.keymaps, { desc = 'Open list of keymaps to search' })
        vim.keymap.set('n', '<leader>h', function() custom_help_picker() end, { noremap = true, silent = true })

    end
}
