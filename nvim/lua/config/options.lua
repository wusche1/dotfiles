-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
vim.cmd("set nospell")
vim.o.exrc = true
vim.o.secure = false

-- Over SSH, LazyVim leaves clipboard unset; sync yanks to the local machine via
-- OSC 52 (copy-only: OSC 52 paste would require querying the terminal, so p
-- falls back to the last yank instead of the remote reading the Mac clipboard)
vim.opt.clipboard = "unnamedplus"
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "osc52-copy-only",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
