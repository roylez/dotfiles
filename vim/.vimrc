" Description: nvim runtime configure file
" vim: ft=vim foldmethod=marker

" {{{ vim/neovim only stuff
if has('nvim')
  " support for cursor shapes
  " let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
else
  set backspace=2
  set encoding=utf-8
  " keep record of editing information for cursor restore and more
  set viminfo='10,\"100,:20,%,n~/.viminfo
endif

" use the same vim_home dir for vim and nvim, use the following in
" ~/.config/nvim/init.vim
"
"       set runtimepath^=~/.vim runtimepath+=~/.vim/after
"       let &packpath = &runtimepath
"       source ~/.vimrc
"
let g:vim_home=$HOME.'/.vim'
" }}}

set shellcmdflag=-c

" {{{ general settings
if has("gui_running")
  set background=dark
  "ensure gui vim gets the right PATH set
  " set shellcmdflag=-l\ -c
else
  set background=dark
  set notitle
endif

set notermguicolors
set nocompatible

if has("osx")
  if has("gui_macvim")
    set macmeta
  endif
  " include path for apple silicon homebrew
  let $PATH="/opt/homebrew/bin:" . $PATH
  " never have that python version mismatch problem again
  let &pythonthreehome=systemlist( '/usr/bin/python3 -c "import sys;print(sys.prefix)"' )[0]
  let &pythonthreedll= &pythonthreehome . '/Python3'
endif

" never use background color erase
let &t_ut=''

" system plugin files in voidlinux and archlinux
set runtimepath+=/usr/share/vim/vimfiles

" this is used a lot in plugin settings, and its default 1s timeout is too short
let mapleader="\<space>"
let maplocalleader="\<space>"
set timeoutlen=1000 ttimeoutlen=0

" selection to $ should not include eol character
set selection=exclusive

if filereadable( $HOME . '/.vimrc.plug' )
  source $HOME/.vimrc.plug
endif

" have to be after loadding pluggins
" filetype plugin indent on
syntax on

set mouse=""            " disable mouse
set history=50		" keep 50 lines of command line history

" do incremental searching
set incsearch hlsearch wrapscan
set ignorecase smartcase

" disable bell all together
set noeb vb t_vb=

" smartindent interferes with file type based indentation
set autoindent
set smartindent 
" replace <tab> with 2 blank space.
set expandtab shiftwidth=2 softtabstop=2 tabstop=8
set textwidth=100	" wrap text for 78 letters
" set relativenumber number

set hidden              " hide instead of abandon buffer
set wrap
map Q gq
set whichwrap=b,s,<,>,[,],h,l
set linebreak           " no breakline in the middle of a word
set wrapmargin=2

set formatprg=fmt
set formatoptions=croqnmB1

set backup
if !isdirectory($HOME . "/.backup")
    call mkdir($HOME . "/.backup", "p")
endif
set backupdir=$HOME/.backup
set directory=$HOME/.backup     "swp

" A hack so that vim does not break docker bind-mount
"https://github.com/moby/moby/issues/15793
set backupcopy=yes

if has("nvim")
  let vim_undo_dir = $HOME . "/.vim/nvim_undo"
else
  let vim_undo_dir = $HOME . "/.vim/undo"
endif
if !isdirectory(vim_undo_dir)
    call mkdir(vim_undo_dir, "p")
endif
let &undodir=vim_undo_dir
set undofile undolevels=1000 undoreload=1000

set commentstring=#%s       " default comment style
set sps=best,10             " only show 10 best spell suggestions
set dictionary+=/usr/share/dict/words

" make fuzzy find in :find command possible
set path+=**

set magic

set showmatch          " show the matching brackets when typing
" set ambiwidth=double     " set this if terminal has similar setting

set showcmd            " display incomplete commands
set ruler              " show the cursor position all the time in statusline
set laststatus=2        " always display a nicer status bar
set statusline=%<%h%m%r\ %f%=[%{&filetype},%{&fileencoding},%{&fileformat}]%k\ %-14.(%l/%L,%c%V%)\ %P
" set wildmenu         " show possible command when pressing <TAB>
set wildmode=longest:list,full
"set cmdheight=2
set matchtime=5
set lazyredraw          " faster for macros
set ttyfast             " better for xterm

" make spell suggest faster
set spellsuggest=best
set spelllang=en_gb,cjk

set guioptions=aAegk

if has("mac")
  set guifont=FantasqueSansMono_Nerd_Font_Mono:h18
  " 方正颜宋
  " set guifontwide=FZYanSongS-R-GB:h16
  set linespace=2
else
  set guifont=Monaco\ 10
  set guifontwide=WenQuanYi\ Micro\ Hei\ 12
endif

" 输入:set list命令是应该显示些啥？
set listchars=nbsp:¬,eol:¶,tab:>-,extends:»,precedes:«,trail:•

" 光标移动到buffer的顶部和底部时保持3行距离
set scrolloff=3

set foldenable foldnestmax=1 foldlevelstart=1
set foldmethod=marker   " fdm=syntax is very slow and makes trouble for neocomplete

" set colorcolumn=90

"tags, use semicolon to seperate so that vim searches parent directories!
set tags=./.tags

" 高亮当前位置
" set cursorline cursorcolumn

set noautochdir

" automatically reread file when changed elsewhere
set autoread

" encoding detection
set fileencoding&
set fileencodings=ucs-bom,utf-8,enc-cn,cp936,gbk,latin1
 
" completion settings
"make completion menu usable even when some characters are typed.
set completeopt=noselect,longest,menuone
" set complete-=i
" set complete-=t
set complete+=kspell

" }}}

" {{{ keyboard mappings
set winaltkeys=no

"move in insert mode
inoremap <m-h> <left>
inoremap <m-l> <Right>
inoremap <m-j> <C-o>gj
inoremap <m-k> <C-o>gk

" search for visual-mode selected text
vmap / y/<C-R>"<CR>

" tab navigation
if has("gui_running") "only in GUI as this may conflict with tmux window navigation
  nmap <F11> :tabprevious<CR>
  nmap <F12> :tabnext<CR>
  imap <F11> <ESC>:tabprevious<CR>
  imap <F12> <ESC>:tabnext<CR>
  nmap ZQ    :bd<CR>
  nmap ZZ    :w<CR>:bd<CR>
endif
nmap tp :tabprevious<CR>
nmap tn :tabnext<CR>
nmap to :tabnew<CR>
nmap tc :tabclose<CR>
nmap gf <C-W>gf

set pastetoggle=<F1>

" use <leader>y/p to interact with clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" use <leader>r to reload vim configuration
nmap <leader>r :source ~/.vimrc<CR>:echom "VIM configuration reloaded"<CR>
" }}}

" ruby
" no folding for comment block and if/do blocks
let ruby_no_comment_fold=1
let ruby_fold=1
let ruby_operators=1
autocmd BufRead,BufNewfile Vagrantfile set ft=ruby

"emails,
"delete old quotations, set spell and put cursor in the first line
autocmd FileType mail
            \|:silent setlocal fo+=aw       " http://wcm1.web.rice.edu/mutt-tips.html
            \|:silent set spell
            \|:silent g/^.*>\sOn.*wrote:\s*$\|^>\s*>.*$/de
            \|:silent 1

"markdown
autocmd FileType markdown set comments=n:> textwidth=0 wrapmargin=2 fo=croqnmB1

"crontab hack for mac
autocmd BufEnter /private/tmp/crontab.* setl backupcopy=yes

"Auomatically add file head defined in ~/.vim/templates/
autocmd BufNewFile * silent! exec ":0r " . g:vim_home . "/templates/" . &ft | normal G

" adhoc edits, files ending with "scratch"
"
" fallback to markdown file type if all ftdetect fails
autocmd BufRead,BufNewFile *.scratch setfiletype markdown.scratch
" do not wrap actual lines
autocmd BufRead,BufNewFile *.scratch setlocal list spell wrap textwidth=0 wrapmargin=5 noswapfile fo=roqnmB1
" paste to clipboard when saving. 
autocmd BufWritePost *.scratch if getfsize(expand(@%))>0 | silent :%y+ | endif
" delete tmp file when exiting
autocmd BufDelete,BufHidden,VimLeave *.scratch silent :!rm -f <afile>

command! -nargs=? PasteEdit :call <sid>new_vim_edit(<q-args>)
function! s:new_vim_edit(cmd)
  execute ":e " . a:cmd . ' /tmp/' . strftime('%Y%m%d.%H%M%S') . '.scratch'
endfunction

" }}}

" {{{ big files?
let g:LargeFile = 0.3	"in megabyte
augroup LargeFile
    au!
    au BufReadPre *
        \let f=expand("<afile>")
        \|if getfsize(f) >= g:LargeFile*1023*1024 || getfsize(f) <= -2
            \|let b:eikeep = &ei
            \|let b:ulkeep = &ul
            \|let b:bhkeep = &bh
            \|let b:fdmkeep= &fdm
            \|let b:swfkeep= &swf
            \|set ei=FileType
            \|setlocal noswf bh=unload fdm=manual
            \|let f=escape(substitute(f,'\','/','g'),' ')
            \|exe "au LargeFile BufEnter ".f." set ul=-1"
            \|exe "au LargeFile BufLeave ".f." let &ul=".b:ulkeep."|set ei=".b:eikeep
            \|exe "au LargeFile BufUnload ".f." au! LargeFile * ". f
            \|echomsg "***note*** handling a large file"
        \|endif
    au BufReadPost *
        \if &ch < 2 && getfsize(expand("<afile>")) >= g:LargeFile*1024*1024
            \|echomsg "***note*** handling a large file"
        \|endif
augroup END
" }}}

" {{{ restore views
set viewoptions=cursor,folds,slash,unix
augroup vimrc
    autocmd BufWritePost *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      mkview!
    \|  endif
    autocmd BufRead *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      silent! loadview
    \|  endif
augroup END
" }}}

" {{{ Changing cursor shape per mode
" NOTE does not work over ssh
" 1 or 0 -> blinking block
" 2 -> solid block
" 3 -> blinking underscore
" 4 -> solid underscore
" 5 -> blinking bar (xterm)
" 6 -> steady bar (xterm)
" if exists('$TMUX')
"     " tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
"     let &t_SI .= "\<Esc>Ptmux;\<Esc>\<Esc>[5 q\<Esc>\\"
"     let &t_SR .= "\<Esc>Ptmux;\<Esc>\<Esc>[4 q\<Esc>\\"
"     let &t_EI .= "\<Esc>Ptmux;\<Esc>\<Esc>[2 q\<Esc>\\"
"     autocmd VimLeave * silent !echo -ne "\033Ptmux;\033\033[2 q\033\\"
" else
"     let &t_SI .= "\<Esc>[5 q"
"     let &t_SR .= "\<Esc>[4 q"
"     let &t_EI .= "\<Esc>[2 q"
"     autocmd VimLeave * silent !echo -ne "\033[2 q"
" endif
" }}}

" visual p does not replace paste buffer {{{ "
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()
" }}} visual p does not replace paste buffer "

" Highlight keywords like TODO BUG HACK INFO and etc {{{ "
autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\)')
autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\)')
" }}} Highlight keywords like TODO BUG HACK INFO and etc "

" bracketed-paste, never set paste again {{{
if exists("g:loaded_bracketed_paste")
  finish
endif
let g:loaded_bracketed_paste = 1

let &t_ti .= "\<Esc>[?2004h"
let &t_te = "\e[?2004l" . &t_te

function! XTermPasteBegin(ret)
  set pastetoggle=<f29>
  set paste
  return a:ret
endfunction

execute "set <f28>=\<Esc>[200~"
execute "set <f29>=\<Esc>[201~"
map <expr> <f28> XTermPasteBegin("i")
imap <expr> <f28> XTermPasteBegin("")
vmap <expr> <f28> XTermPasteBegin("c")
cmap <f28> <nop>
cmap <f29> <nop>
"}}}

" quickfix/location list height auto adjustment {{{
au FileType qf call AdjustWindowHeight(3, 10)
function! AdjustWindowHeight(minheight, maxheight)
  let l = 1
  let n_lines = 0
  let w_width = winwidth(0)
  while l <= line('$')
    " number to float for division
    let l_len = strlen(getline(l)) + 0.0
    let line_width = l_len/w_width
    let n_lines += float2nr(ceil(line_width))
    let l += 1
    endw
    exe max([min([n_lines, a:maxheight]), a:minheight]) . "wincmd _"
  endfunction
" }}}
