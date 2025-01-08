return {
  'echasnovski/mini.nvim',
  config = function()

    require('mini.diff').setup()

    -- commenting
    require('mini.comment').setup({
      mappings = {
        comment = 'gc',
        comment_line = '<F9>',
        comment_visual = '<F9>',
        text_object = 'gc'
      }
    })

    -- auto change root directory
    require('mini.misc').setup()
    MiniMisc.setup_auto_root({".git", "mix.exs", "Makefile"})

  end
}
