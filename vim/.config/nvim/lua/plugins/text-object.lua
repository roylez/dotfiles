return {

  'kana/vim-textobj-user',

  {
    'kana/vim-textobj-indent',
    dependencies = { 'kana/vim-textobj-user' }
  },

  {
    'andyl/vim-textobj-elixir',
    ft = 'elixir',
    dependencies = { 'kana/vim-textobj-user' }
  },

}

