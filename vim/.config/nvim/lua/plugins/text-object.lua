return {
  'kana/vim-textobj-user',

  -- dii / cii
  {
    'kana/vim-textobj-indent',
    dependencies = { 'kana/vim-textobj-user' },
  },

  -- dic / cic
  {
    'glts/vim-textobj-comment',
    dependencies = { 'kana/vim-textobj-user' },
  },

  {
    'amiralies/vim-textobj-elixir',
    ft = 'elixir',
    dependencies = { 'kana/vim-textobj-user' },
  },
}

