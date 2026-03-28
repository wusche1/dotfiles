-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>fy", function()
  local path = vim.fn.expand("%")
  vim.fn.system({ "tmux", "set-buffer", path })
  vim.fn.setreg("+", path)
  vim.notify(path)
end, { desc = "Copy relative path" })

vim.keymap.set("n", "<leader>pp", function()
  local path
  if vim.bo.filetype:find("^snacks") then
    local pickers = Snacks.picker.get()
    for _, picker in ipairs(pickers) do
      local item = picker:current()
      if item then
        path = Snacks.picker.util.path(item)
        if path then break end
      end
    end
  end
  if not path or path == "" then
    path = vim.api.nvim_buf_get_name(0)
  end
  if path and path ~= "" then
    vim.fn.system({ "open", path })
  end
end, { desc = "Open file externally" })
