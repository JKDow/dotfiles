return {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'b0o/schemastore.nvim',
    },
    config = function()
        require('mason').setup()

        local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require('mason-lspconfig').setup({
            automatic_installation = true,
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities
                    })
                end,
                ["jsonls"] = function()
                    require('lspconfig').jsonls.setup({
                        capabilities = capabilities,
                        settings = {
                            json = {
                                schemas = require('schemastore').json.schemas(),
                            },
                        },
                    })
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            },
        })

        -- Todo: Have this only apply to attached buffer
        vim.keymap.set('n', '<Leader>K', function() vim.lsp.buf.hover() end)
        vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end)
        vim.keymap.set('n', '<Leader>d', function() vim.diagnostic.open_float() end)
        vim.keymap.set('n', '<F3>', function() vim.lsp.buf.format() end)

        -- show diagnostic source for errors (which LSP it is from)
        vim.diagnostic.config({
            float = {
                source = true
            },
        })
    end
}
