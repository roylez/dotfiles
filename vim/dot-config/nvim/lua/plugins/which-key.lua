return {
  "folke/which-key.nvim",
  lazy = false,
  opts = {
    preset = "helix",
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "->", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },
    layout = {
      height = { min = 3, max = 25 },
      spacing = 3,
      align = 'center'
    },
    win = {
      border = 'single'
    }
  },
  keys = {
    { '<leader>y', '"+y',  desc = 'Copy',  silent = true, mode = {'n', 'v'} },
    { '<leader>p', '"+p',  desc = 'Paste', silent = true, mode = {'n', 'v'} },
  }
}
