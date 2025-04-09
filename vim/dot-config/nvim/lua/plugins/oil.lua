return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-",  "<cmd>Oil --float<CR>", { desc = "Explore parent dir" } },
  },
  opts = {
    default_file_explorer = true,
    keymaps = {
      ["q"] = { "actions.close", mode = "n" },
    }
  },
}
