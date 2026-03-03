return {
  "swaits/zellij-nav.nvim",
  event = "VeryLazy",
  cond = function()
    return vim.env.ZELLIJ ~= nil
  end,
  keys = {
    { "<C-h>", "<cmd>ZellijNavigateLeft<CR>", mode = { "n", "t" }, silent = true, desc = "Navigate left" },
    { "<C-j>", "<cmd>ZellijNavigateDown<CR>", mode = { "n", "t" }, silent = true, desc = "Navigate down" },
    { "<C-k>", "<cmd>ZellijNavigateUp<CR>", mode = { "n", "t" }, silent = true, desc = "Navigate up" },
    { "<C-l>", "<cmd>ZellijNavigateRight<CR>", mode = { "n", "t" }, silent = true, desc = "Navigate right" },
  },
  opts = {},
}
