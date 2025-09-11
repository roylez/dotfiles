return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = { "echasnovski/mini.icons" },
  enabled = function()
    local ft = vim.o.filetype
    return ft ~= 'markdown.scratch' and ft ~= 'mail'
  end,
  keys = {
    { "-",  "<cmd>Oil --float<CR>", { desc = "Explore parent dir" } },
  },
  opts = {
    default_file_explorer = true,
    keymaps = {
      ["q"]           = { "actions.close",  mode = "n" },
      ["<Backspace>"] = { "actions.parent", mode = "n" },
    }
  },
}
