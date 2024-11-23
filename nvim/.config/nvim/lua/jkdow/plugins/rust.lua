return {
    'mrcjkb/rustaceanvim',
    version = '5.7.0',
    ft = "rust",
    dependencies = {
        {
            "chrisgrieser/nvim-lsp-endhints",
            opts = {},
        },
    },
    config = function()
        require("lsp-endhints").setup {
            icons = {
                type = "󰜁 ",
                parameter = "󰏪 ",
                offspec = " ", -- hint kind not defined in official LSP spec
                unknown = " ", -- hint kind is nil
            },
            label = {
                padding = 1,
                marginLeft = 0,
                bracketedParameters = true,
            },
            autoEnableHints = false,
        }
        vim.g.rustaceanvim = {
            tools = {
                code_actions = {
                    ui_select_fallback = true,
                },
                float_win_config = {
                    border = "rounded",
                    borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
                },
            },
            server = {
                on_attach = function(_, bufnr)
                    require("lsp-endhints").enable()

                    local opts = { buffer = bufnr }

                    -- Set LSP keymaps
                    vim.keymap.set('n', 'K',
                        function() vim.cmd.RustLsp { 'hover', 'actions' } end, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', '<Leader>d',
                        function() vim.cmd.RustLsp({ 'renderDiagnostic', 'current' }) end, opts)
                    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
                    vim.keymap.set('n', '<leader>ca',
                        function() vim.cmd.RustLsp('codeAction') end, opts)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
                    vim.keymap.set("n", "<leader>.t",
                        function() vim.cmd.RustLsp('openCargo') end, opts)
                    vim.keymap.set('n', '<leader>rs', vim.lsp.buf.rename, opts)
                end
            },
            dap = {}, -- Debug addapter protocol
        }
    end
}
