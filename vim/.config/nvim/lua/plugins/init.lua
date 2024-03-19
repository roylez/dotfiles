return {
  "folke/which-key.nvim",

  {
    'levouh/tint.nvim', 
    config = function()
      require("tint").setup()
    end
  },

  'mg979/vim-visual-multi',

  { 'csexton/trailertrash.vim', event = "BufWritePre" },

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

}
