return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
            { 'simrat39/rust-tools.nvim' },
        },
        config = function()
            local lsp_zero = require("lsp-zero")
            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({ buffer = bufnr })
            end)

            local cmp = require('cmp')
            local cmp_action = require('lsp-zero').cmp_action()

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    -- `Enter` key to confirm completion
                    ['<CR>'] = cmp.mapping.confirm({ select = false }),

                    -- Ctrl+Space to trigger completion menu
                    ['<C-Space>'] = cmp.mapping.complete(),

                    -- Navigate between snippet placeholder
                    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

                    -- Scroll up and down in the completion documentation
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                })
            })

            local rust_tools = require('rust-tools')
            local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

            require('mason').setup({})
            require('mason-lspconfig').setup({
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        -- (Optional) configure lua language server
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                    rust_analyzer = function()
                        rust_tools.setup({
                            server = {
                                on_attach = function(client, bufnr)
                                    vim.keymap.set('n', 'K', rust_tools.hover_actions.hover_actions, { buffer = bufnr })
                                end
                            }
                        })
                        rust_tools.inlay_hints.enable()
                    end,
                    intelephense = function()
                        require('lspconfig').intelephense.setup({
                            commands = {
                                IntelephenseIndex = {
                                    function ()
                                        vim.lsp.buf.execute_command({ command = 'intelephense.index.workspace' })
                                    end
                                },
                            },
                            on_attach = function(client, bufnr)
                                lsp_zero.default_keymaps({ buffer = bufnr })
                            end,
                            filetypes = { "php", "blade" },
                            settings = {
                                intelephense = {
                                    files = {
                                        associations = { "*.php", "*.blade.php" },
                                    }
                                }
                            },
                            capabilities = capabilities,
                        })
                    end,
                }
            })
        end
    }
}
