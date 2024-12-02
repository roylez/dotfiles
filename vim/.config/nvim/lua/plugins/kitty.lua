

return
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
      require('kitty-scrollback').setup({
        ksb_builtin_get_text_all = {
          visual_selection_highlight_mode = 'kitty',
        }
      })
    end,
  }
