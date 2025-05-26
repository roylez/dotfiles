return {
  {
    'levouh/tint.nvim',
    config = function()
      require("tint").setup()
    end
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

  'tpope/vim-fugitive',

  'tpope/vim-endwise',

  'tpope/vim-repeat',

  {
    'junegunn/vim-easy-align',
    config = function()
      vim.keymap.set({'n'}, 'ga',      '<Plug>(EasyAlign)')
      vim.keymap.set({'v'}, '<Enter>', '<Plug>(EasyAlign)')
    end
  },

}
