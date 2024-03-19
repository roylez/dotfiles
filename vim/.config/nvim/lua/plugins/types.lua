return {

  { 'pearofducks/ansible-vim', ft = 'ansible' },

  { 'vim-crystal/vim-crystal', ft = 'crystal' },

  {
    'ledger/vim-ledger', ft = 'ledger',
    config = function()
      vim.cmd [[
        autocmd FileType ledger setlocal fdm=indent foldlevel=0 shiftwidth=4
        autocmd FileType ledger nnoremap j jzz
        autocmd FileType ledger nnoremap k kzz
        autocmd FileType ledger nnoremap G Gzz
      ]]
    end
  },

  {
    'elixir-editors/vim-elixir', ft = 'elixir',
    config = function()
      vim.cmd [[
        autocmd FileType elixir,eelixir setlocal shiftwidth=2
        autocmd BufNewFile,BufRead *.leex,*.heex setlocal ft=html.eelixir
      ]]
    end
  },
}
