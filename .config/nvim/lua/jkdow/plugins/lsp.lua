--[[
-- Automatically setup neovim LSP
--]]
return {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
        'williamboman/mason.nvim',           -- Handle automatic installation of LSP
        'williamboman/mason-lspconfig.nvim', -- Handle automatic setup of LSP
        'b0o/schemastore.nvim',              -- JSON Parser to work with LSP
        "nvimtools/none-ls.nvim",            -- Replacemet for Null-ls. Handles non-LSP sources integrating into LSP
        "jay-babu/mason-null-ls.nvim",       -- Let Mason handle installation for None-LS
    },
    config = function()
        require('mason').setup()

        local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require('mason-lspconfig').setup({
            automatic_installation = true,
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "intelephense",
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
                ["intelephense"] = function()
                    require('lspconfig').intelephense.setup({
                        filetypes = { "php", "blade" },
                        capabilities = capabilities,
                        settings = {
                            files = {
                                associations = { "*.blade.php", "php" }
                            },
                        },
                    })
                end
            },
        })

        -- show diagnostic source for errors (which LSP it is from)
        vim.diagnostic.config({
            float = {
                source = true
            },
        })

        require("mason-null-ls").setup({
            ensure_installed = {},
            automatic_installation = true,
            handlers = {},
        })
        --[[
        require('null-ls').setup({
            -- anything not supported by mason
            sources = {},
        })
        --]]
    end
}
