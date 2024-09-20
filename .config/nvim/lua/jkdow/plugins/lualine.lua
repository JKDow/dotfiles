---@diagnostic disable: duplicate-index
return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        'arkav/lualine-lsp-progress',
        { "letieu/harpoon-lualine",    dependencies = { 'harpoon' } },
        'AndreM222/copilot-lualine',
    },
    opts = {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {
                statusline = {},
                winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            globalstatus = false,
            refresh = {
                statusline = 1000,
                tabline = 1000,
                winbar = 1000,
            }
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = {
                {
                    'harpoon2',
                    indicators = { "j", "k", "l", ";" },
                    active_indicators = { "J", "K", "L", ":" },
                    color_active = { fg = "#87d787" },
                    _separator = " ",
                    no_harpoon = "Harpoon not loaded",
                },
                {
                    'lsp_progress',
                    display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' } },
                    separators = {
                        component = ' ',
                        progress = ' | ',
                        message = { pre = '(', post = ')' },
                        percentage = { pre = '', post = '%% ' },
                        title = { pre = '', post = ': ' },
                        lsp_client_name = { pre = '[', post = ']' },
                        spinner = { pre = '', post = '' },
                        message = { commenced = 'In Progress', completed = 'Completed' },
                    },
                    display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' } },
                    timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
                    spinner_symbols = { '🌑 ', '🌒 ', '🌓 ', '🌔 ', '🌕 ', '🌖 ', '🌗 ', '🌘 ' },
                },
            },
            lualine_x = {
                'copilot',
                'encoding',
                'fileformat',
                'filetype'
            },
            lualine_y = {
                {
                    require("lazy.status").updates,
                    cond = require("lazy.status").has_updates,
                    color = { fg = "#ff9e64" },
                },
                'filename',
            },
            lualine_z = { 'progress', 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
    },
}
