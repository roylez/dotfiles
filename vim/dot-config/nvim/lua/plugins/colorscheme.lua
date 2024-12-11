return {
  'lifepillar/vim-gruvbox8',
  priority = 9000,
  lazy = false,
  config = function()
    vim.cmd [[
      let g:gruvbox_material_enable_italic = 1

      if $TERM =~ '^\(xterm\|screen\|tmux\)' || $TERM =~ '256color$' || has("gui_running")
          colorscheme gruvbox8
      else
          colorscheme koehler
      endif
    ]]
  end
}
