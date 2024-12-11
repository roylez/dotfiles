return {
  'vim-airline/vim-airline',
  config = function()
    vim.cmd [[
      set noshowmode
      let g:airline_mode_map = {
          \ '__' : '-',
          \ 'n'  : 'N',
          \ 'i'  : 'INSERT',
          \ 'R'  : 'REPLACE',
          \ 'c'  : 'C',
          \ 'v'  : 'V',
          \ 'V'  : 'VL',
          \ '' : 'VB',
          \ 's'  : 'S',
          \ 'S'  : 'S',
          \ '' : 'S',
          \ }
      let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
      let g:airline_section_x='%l,%c%V %3p%%'
      let g:airline_section_z='%{&filetype}'
      let g:airline_section_error=''
      let g:airline_section_warning=''
      let g:airline_theme='dark'
      let g:airline#extensions#hunks#enabled = 0
    ]]
  end
}
