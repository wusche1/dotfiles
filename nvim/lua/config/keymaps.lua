-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>fy", function()
  local path = vim.fn.expand("%")
  vim.fn.system({ "tmux", "set-buffer", path })
  vim.fn.setreg("+", path)
  vim.notify(path)
end, { desc = "Copy relative path" })
