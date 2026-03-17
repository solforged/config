{
  keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
      options.desc = "Toggle explorer";
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree focus<CR>";
      options.desc = "Focus explorer";
    }
    {
      mode = "n";
      key = "<leader>fe";
      action = "<cmd>Neotree reveal<CR>";
      options.desc = "Reveal current file";
    }
  ];

  plugins.neo-tree.enable = true;
}
