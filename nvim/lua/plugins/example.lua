-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
return {
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    }
  },
  { "hrsh7th/nvim-cmp", enabled = false },
  
  { "saghen/blink.cmp", enabled = false },
}
