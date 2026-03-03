return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            win = {
              list = {
                keys = {
                  ["<CR>"] = { "select_and_next", mode = { "n", "x" } },
                  ["<Tab>"] = "confirm",
                },
              },
            },
          },
          files = { hidden = true },
        },
      },
    },
  },
}

