return {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup {
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "->", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      layout = {
        height = { min = 3, max = 25 },
        spacing = 3,
        align = 'center'
      }
    }
  end
}
