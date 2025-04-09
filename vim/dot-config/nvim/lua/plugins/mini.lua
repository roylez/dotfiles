return {
  -- commenting
  {
    'echasnovski/mini.comment',
    opts = {
      mappings = {
        comment = 'gc',
        comment_line = '<F9>',
        comment_visual = '<F9>',
        text_object = 'gc'
      }
    }
  },

  -- rooter
  {
    'echasnovski/mini.misc',
    config = function()
      require('mini.misc').setup()
      MiniMisc.setup_auto_root({".git", "mix.exs", "Makefile"})
    end
  },

  -- arround text objects
  {
    'echasnovski/mini.ai'
  },
}
