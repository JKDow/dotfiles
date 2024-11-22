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

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded", -- You can also use "single", "double", "shadow", or any custom style
        })

        -- Set LSP keymaps
        local attach_keymaps = function(_, bufnr)
            local opts = { buffer = bufnr }
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<leader>rs', vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        end

        require('mason-lspconfig').setup({
            automatic_installation = true,
            ensure_installed = {
                "lua_ls",
                "intelephense",
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = attach_keymaps,
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
                        on_attach = attach_keymaps,
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
                        },
                        on_attach = attach_keymaps,
                    }
                end,
                ["intelephense"] = function()
                    require('lspconfig').intelephense.setup({
                        filetypes = { "php" },
                        capabilities = capabilities,
                        settings = {
                            files = {
                                -- associations = { "php" }
                            },
                        },
                        on_attach = attach_keymaps,
                    })
                end,
                ['rust_analyzer'] = function()
                    -- Rust setup is handled elsewhere
                end,
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
