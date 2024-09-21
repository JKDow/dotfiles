return {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'onsails/lspkind-nvim',
    },

    config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local lspkind = require('lspkind')

        -- require('luasnip/loaders/from_snipmate').lazy_load()

        local has_words_before = function()
            if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
            ---@diagnostic disable-next-line: deprecated
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
        end

        local source_map = {
            buffer = "Buffer",
            nvim_lsp = "LSP",
            nvim_lsp_signature_help = "Signature",
            luasnip = "LuaSnip",
            nvim_lua = "Lua",
            path = "Path",
            copilot = "Copilot",
        }

        local function ltrim(s)
            return s:match '^%s*(.*)'
        end

        vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#87d787" })

        cmp.setup({
            view = {},
            window = {
                completion = {
                    border = "rounded",
                    winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                    col_offset = -3,
                    side_padding = 1,
                },
                documentation = {
                    border = "rounded",
                },
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            formatting = {
                fields = {
                    "kind",
                    "abbr",
                    "menu"
                },
                format = lspkind.cmp_format({
                    mode = 'symbol',
                    maxwidth = 50,
                    ellipsis_char = '...',
                    show_labelDetails = false,
                    symbol_map = { Copilot = "" },
                    -- See: https://www.reddit.com/r/neovim/comments/103zetf/how_can_i_get_a_vscodelike_tailwind_css/
                    before = function(entry, vim_item)
                        -- Replace the 'menu' field with the kind and source
                        vim_item.menu = '  ' ..
                            vim_item.kind .. ' (' .. (source_map[entry.source.name] or entry.source.name) .. ')'
                        vim_item.menu_hl_group = 'SpecialComment'

                        vim_item.abbr = ltrim(vim_item.abbr)

                        if vim_item.kind == 'Color' and entry.completion_item.documentation then
                            local _, _, r, g, b = string.find(entry.completion_item.documentation,
                                '^rgb%((%d+), (%d+), (%d+)')
                            if r then
                                local color = string.format('%02x', r) ..
                                    string.format('%02x', g) .. string.format('%02x', b)
                                local group = 'Tw_' .. color
                                if vim.fn.hlID(group) < 1 then
                                    vim.api.nvim_set_hl(0, group, { fg = '#' .. color })
                                end
                                vim_item.kind_hl_group = group
                                return vim_item
                            end
                        end
                        return vim_item
                    end
                }),
            },
            mapping = {
                ["<Tab>"] = vim.schedule_wrap(function(fallback)
                    if cmp.visible() and has_words_before() then
                        cmp.confirm({ select = true })
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-p>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ['<CR>'] = cmp.mapping(function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({ select = true })
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-e>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'path' },
                { name = 'copilot' },
            },
            sorting = {
                priority_weight = 2,
                require("copilot_cmp.comparators").prioritize,
                cmp.config.compare.exact,
                cmp.config.compare.offset,
                cmp.config.compare.score,
                cmp.config.compare.recently_used,
                cmp.config.compare.locality,
                cmp.config.compare.kind,
                cmp.config.compare.sort_text,
                cmp.config.compare.length,
                cmp.config.compare.order,
            },
            experimental = {
                ghost_text = true,
            },
        })
    end
}
