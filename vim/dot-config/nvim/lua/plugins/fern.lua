return {
  "lambdalisue/fern.vim",
  dependencies = {
    "lambdalisue/fern-hijack.vim",
    "lambdalisue/glyph-palette.vim",
    "TheLeoP/fern-renderer-web-devicons.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()

    vim.g["fern#renderer"] = "nvim-web-devicons"
    vim.g["glyph_palette#palette"] = require'fr-web-icons'.palette()

    -- Custom settings and mappings.
    vim.g["fern#disable_default_mappings"] = 1

    vim.cmd [[

    noremap <silent> <F4> :Fern . -drawer -reveal=% -toggle -width=35<CR><C-w>=
    noremap <silent> z=   :Fern . -drawer -reveal=%<CR>

    function! FernInit() abort
      nmap <buffer><expr>
        \ <Plug>(fern-my-open-expand-collapse)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open:select)",
        \   "\<Plug>(fern-action-expand)",
        \   "\<Plug>(fern-action-collapse)",
        \ )
      nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
      nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
      nmap <buffer> A <Plug>(fern-action-new-path)
      nmap <buffer> x <Plug>(fern-action-remove)
      nmap <buffer> m <Plug>(fern-action-move)
      nmap <buffer> M <Plug>(fern-action-rename)
      nmap <buffer> h <Plug>(fern-action-hidden:toggle)
      nmap <buffer> r <Plug>(fern-action-reload)
      nmap <buffer> F <Plug>(fern-action-mark:toggle)
      nmap <buffer> s <Plug>(fern-action-open:split)
      nmap <buffer> v <Plug>(fern-action-open:vsplit)
      nmap <buffer> p <Plug>(fern-action-focus:parent)
      nmap <buffer><nowait> < <Plug>(fern-action-leave)
      nmap <buffer><nowait> > <Plug>(fern-action-enter)
    endfunction

    augroup FernGroup
      autocmd!
      autocmd FileType fern call FernInit()
    augroup END

    ]]
  end,
}
