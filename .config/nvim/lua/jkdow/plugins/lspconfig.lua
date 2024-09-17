return {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'b0o/schemastore.nvim',
    },
    config = function ()
        require('mason').setup()
        require('mason-lspconfig').setup({
            automatic_installation = true,
        })

        local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require('lspconfig').intelephense.setup({
            capabilities = capabilities,
        })
        -- require('lspconfig').tailwind.setup({})

        -- JSON LSP
        require('lspconfig').jsonls.setup({
            capabilities = capabilities,
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                },
            },
        })

        -- Todo: Have this only apply to attached buffer 
        vim.keymap.set('n', '<Leader>K', function() vim.lsp.buf.hover() end)
        vim.keymap.set('n', 'gd', function () vim.lsp.buf.definition() end)
        vim.keymap.set('n', '<Leader>d', function() vim.diagnostic.open_float() end)

        -- show diagnostic source for errors (which LSP it is from)
        vim.diagnostic.config({
            float = {
                source = true
            },
        })

    end
}
