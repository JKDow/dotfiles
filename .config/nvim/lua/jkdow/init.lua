require("jkdow.remap")
require("jkdow.set")
require("jkdow.lazy")

vim.cmd('colorscheme onedark')

-- help window
vim.cmd [[
  hi HelpNormal guibg=#2E3440 guifg=#D8DEE9
  hi HelpBorder guifg=#81A1C1
]]

-- Function to open help in a floating window with an optional topic
function open_help_floating(topic)
  -- Close existing floating help window if any
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'help' then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Create a new buffer for help
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'help')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Define window dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  -- Define window position
  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2 - 1), -- Adjust for command line
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded", -- Options: "none", "single", "double", "rounded", "solid", "shadow"
  }

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Apply custom highlights
  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:HelpNormal,FloatBorder:HelpBorder")
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)

  -- Open help topic or general help
  if topic then
    vim.cmd('silent help ' .. topic)
  else
    vim.cmd('silent help')
  end
end
