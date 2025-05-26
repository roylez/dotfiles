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

  -- current word highlighting
  {
    'echasnovski/mini.cursorword',
    opts = {}
  },

  -- trail trim
  {
    'echasnovski/mini.trailspace',
    config = function()
      require('mini.trailspace').setup()
      vim.keymap.set('n', '<leader>T', MiniTrailspace.trim,  { silent = true, desc = 'Trailer Trim' })
      vim.api.nvim_create_autocmd({'BufWritePre'}, {
        callback = function(ev) MiniTrailspace.trim() end
      })
    end
  },

  -- indentation highlighting
  {
    'echasnovski/mini.indentscope',
    opts = { symbol = "·" }
  },

}
