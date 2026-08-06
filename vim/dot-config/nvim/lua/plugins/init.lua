return {
  {
    'levouh/tint.nvim',
    opts = {}
  },

  'mg979/vim-visual-multi',

  {
    'tpope/vim-surround',
    config = function()
      vim.cmd [[
        autocmd FileType markdown,vimwiki let b:surround_{char2nr('i')} = "*\r*"
        autocmd FileType markdown,vimwiki let b:surround_{char2nr('b')} = "**\r**"
        autocmd FileType markdown,vimwiki let b:surround_{char2nr('c')} = "``` \1language: \1\r```"
      ]]
    end
  },

  'tpope/vim-endwise',

  'tpope/vim-repeat',

  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', desc="Align" },
      { '<leader>a',  '<Plug>(EasyAlign)', mode='x', desc="Align" }
    }
  },

  'lewis6991/gitsigns.nvim',

  {
    "knubie/vim-kitty-navigator",
    build = "cp ./*.py ~/.config/kitty/",
    enabled = function()
      return vim.fn.executable("kitty") == 1 and vim.fn.executable("kitten") == 1
    end
  }
}
