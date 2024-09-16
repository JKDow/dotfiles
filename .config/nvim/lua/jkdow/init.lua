require("jkdow.remap")
require("jkdow.set")
require("jkdow.lazy")

vim.schedule(function ()
    if vim.get_clients == nil then
        vim.lsp.get_clients = vim.lsp.get_active_clients
    end
end)
