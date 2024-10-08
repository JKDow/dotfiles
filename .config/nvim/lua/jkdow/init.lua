-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Load remaps and set options
require("jkdow.remap")
require("jkdow.set")

-- Load plugins
require("lazy").setup({
    spec = {
        -- import plugins
        { import = "jkdow.plugins" },
    },
    -- auto check plugin updates
    checker = { enabled = true },
})

-- Load autocommands
require("jkdow.autocmd")

-- Load colors
vim.cmd('colorscheme onedark')

