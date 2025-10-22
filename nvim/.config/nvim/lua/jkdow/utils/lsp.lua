-- jkdow/utils/lsp.lua
local util = require("lspconfig.util")

-- Prefer the *nearest* Node project; fall back to git
local function node_root(fname)
    return util.root_pattern(
            ".nvim-root", -- optional marker you can add to /admin
            "package.json",
            "pnpm-workspace.yaml",
            "yarn.lock",
            "tsconfig.json",
            "jsconfig.json",
            ".nvmrc"
        )(fname)
        or util.find_node_modules_ancestor(fname)
        or util.find_git_ancestor(fname)
end

return node_root
