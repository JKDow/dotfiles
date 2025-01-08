local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("vue", {
    s("component", {
        t("<script setup>"),
        t({ "", "</script>", "" }),
        t({ "", "<template>", "" }),
        t({ "", "</template>" }),
    }),
})
