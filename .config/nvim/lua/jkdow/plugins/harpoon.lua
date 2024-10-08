return {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    name = 'harpoon',
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_ui_on_close = true,
            },
        })

        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end
            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        vim.keymap.set("n", "<leader>pe", function() toggle_telescope(harpoon:list()) end,
            { desc = "Open harpoon window" })
        for i = 1, 9 do
            vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end)
        end
    end
}
