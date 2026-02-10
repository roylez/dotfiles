return {
  -- commenting
  {
    'echasnovski/mini.comment',
    opts = {
      mappings = {
        comment = '<leader>c',
        comment_line = '<leader>c',
        comment_visual = '<leader>c',
        text_object = '<leader>c'
      }
    }
  },

  -- jumping
  -- https://github.com/echasnovski/mini.nvim/discussions/1033
  {
    'echasnovski/mini.jump2d',
    lazy = false,
    config = function()
      require("mini.jump2d").setup({
        labels = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        view = {
          dim = true,
          n_steps_ahead = 2,
        },
        mappings = { start_jumping = "" }
      })

      vim.keymap.set(
        { "o", "x", "n" }, "<CR>",
        "<cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>",
        { desc = "Jump anywhere" }
      )

      -- Disable jump2d in quickfix buffers
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
          if vim.bo.buftype == "quickfix" then
            -- Override the global keymap in quickfix
            vim.keymap.set({ "n", "o", "x" }, "<CR>", "<CR>", { buffer = 0 })
          end
        end,
      })
    end
  },

  -- rooter
  {
    'echasnovski/mini.misc',
    config = function()
      require('mini.misc').setup()
      MiniMisc.setup_auto_root({".git", "Makefile"})
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

  -- icons
  {
    'echasnovski/mini.icons',
    opts = {
      lsp = {
        ripgrep = { glyph = '', hl = 'MiniIconsGreen'  }
      }
    },
  }

}
