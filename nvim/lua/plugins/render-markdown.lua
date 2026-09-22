return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  opts = { enabled = false },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", ft = "markdown", desc = "Toggle Markdown Render" },
  },
}
