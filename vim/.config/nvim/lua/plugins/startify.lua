return {
  'mhinz/vim-startify',
  enabled = vim.fn.has("mac") == 1,
  dependencies = { 'roylez/zwiki' },
  config = function()
    vim.cmd [[
    autocmd User Startified setlocal cursorline

    let g:startify_files_number = 5
    let g:startify_enable_special = 0
    let g:startify_session_persistence = 1
    let g:startify_session_before_save = [ 'silent! tabdo NERDTreeClose' ]
    let g:startify_lists = [
    \ { 'type': 'commands',  'header': ['      COMMANDS'] },
    \ { 'type': 'sessions',  'header': ['      SESSIONS' ] },
    \ { 'type': 'files',     'header': ['      RECENT' ] },
    \ { 'type': 'bookmarks', 'header': ['      BOOKMARKS'] } ]
    let g:startify_bookmarks = [
    \ { 't': '~/TODO.taskpaper' },
    \ { 'd': '~/wiki/TODO.md' },
    \ { 'c': '~/.config/nvim/init.lua' },
    \ { 's': '~/.zshrc' } ]
    let g:startify_commands = [
    \ { 'b': ['BLANK',      'PasteEdit'            ]},
    \ { 'B': ['CLIPBOARD',  'PasteEdit +norm\ "+P' ]},
    \ { 'z': ['Zettel',     'ZwikiNew +norm\ G"+p'  ]} ]

    let g:startify_custom_header = "startify#center(split(system('bat --decorations=always --style=grid ~/wiki/TODO.md'), '\n'))"
    ]]
  end
}
