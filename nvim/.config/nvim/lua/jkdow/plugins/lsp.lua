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
        require('mason-lspconfig').setup({
            automatic_installation = true,
            ensure_installed = {
                "lua_ls",
                "intelephense",
                "vue_ls",
                "vtsls",
            },
            automatic_enable = {
                exclude = { 'vue_ls' },
            },
        })

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
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<leader>rs', vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
            -- Use prettier (via null-ls) if available, otherwise fall back to the first available formatter
            vim.keymap.set("n", "<leader>f", function()
                vim.lsp.buf.format({
                    async = false,
                    filter = function(client)
                        -- Prefer null-ls (Prettier)
                        if client.name == "null-ls" then
                            return true
                        end
                        -- If no null-ls client is attached, fall back to the first that supports formatting
                        local clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
                        local has_null_ls = vim.iter(clients):any(function(c) return c.name == "null-ls" end)
                        return not has_null_ls
                    end,
                })
            end, opts)
        end

        vim.lsp.config('lua_ls', {
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    }
                }
            },
            on_attach = attach_keymaps,
        })

        vim.lsp.config('jsonls', {
            capabilities = capabilities,
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                },
            },
            on_attach = attach_keymaps,
        })

        vim.lsp.config('intelephense', {
            filetypes = { "php" },
            capabilities = capabilities,
            settings = {
                intelephense = {
                    stubs = {
                        "wordpress", "woocommerce", "wp-cli", "wp-cli-commands",
                        "apache", "bcmath", "bz2", "calendar", "Core", "ctype", "curl", "date",
                        "dba", "dom", "enchant", "exif", "FFI", "fileinfo", "filter", "ftp",
                        "gd", "gettext", "gmp", "hash", "iconv", "imap", "intl", "json",
                        "ldap", "libxml", "mbstring", "mcrypt", "mysqli", "openssl",
                        "pcntl", "pcre", "PDO", "pdo_mysql", "pdo_sqlite", "Phar",
                        "posix", "random", "readline", "Reflection", "session", "shmop",
                        "SimpleXML", "soap", "sockets", "sodium", "SPL", "sqlite3", "standard",
                        "superglobals", "sysvsem", "sysvshm", "tokenizer", "xml",
                        "xmlreader", "xmlwriter", "xsl", "Zend OPcache", "zip", "zlib"
                    },
                    files = {
                        maxSize = 5000000,
                    }
                }
            },
            on_attach = attach_keymaps,
        })

        local vue_path = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server"
        local vue_plugin_path = vue_path .. "/node_modules/@vue/language-server"
        local vue_plugin = {
            name = "@vue/typescript-plugin",
            location = vue_plugin_path,
            languages = { "vue" },
            configNamespace = "typescript",
        }
        vim.lsp.config('vtsls', {
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
            settings = {
                vtsls = {
                    tsserver = { globalPlugins = { vue_plugin } }
                }
            },
            on_attach = attach_keymaps,
            capabilities = capabilities,
        })

        vim.lsp.enable('vue_ls')

        vim.lsp.config('slint_lsp', {
            capabilities = capabilities,
            on_attach = attach_keymaps,
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

        local null_ls = require("null-ls")

        null_ls.setup({
            sources = {
                -- Prefer prettierd; falls back to prettier if you also enable the line below
                null_ls.builtins.formatting.prettierd.with({
                    prefer_local = "node_modules/.bin",
                    -- Only use project-local prettier (avoids global mismatches)
                    env = { PRETTIERD_LOCAL_PRETTIER_ONLY = "1" },
                }),

                -- Optional fallback if prettierd isn’t installed/available:
                null_ls.builtins.formatting.prettier.with({
                    prefer_local = "node_modules/.bin",
                }),
            },
        })
    end
}
