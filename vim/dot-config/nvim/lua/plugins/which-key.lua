return {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup {
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
    }

    vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y',  { silent = true, desc = 'Copy' })
    vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p',  { silent = true, desc = 'Paste' })
  end
}
