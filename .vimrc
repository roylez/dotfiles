" Description: nvim runtime configure file
" vim: ft=vim foldmethod=marker

"---------------------vim/neovim only stuff------------------------------
if has('nvim')
    " support for cursor shapes
    let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
    let g:vim_home=$HOME.'/.config/nvim'
else
    set backspace=2
    set encoding=utf-8
    " keep record of editing information for cursor restore and more
    set viminfo='10,\"100,:20,%,n~/.viminfo
    let g:vim_home=$HOME.'/.vim'
endif
"------------------------------------------------------------------------
set background=dark
" support for truecolor
set termguicolors
set nocompatible
let mapleader=","    " this is used a lot in plugin settings

if filereadable( $HOME . '/.vimrc.plug' )
    source $HOME/.vimrc.plug
endif

" have to be after loadding pluggins 
filetype plugin indent on
syntax on

set mouse=""            " disable mouse
set history=50		" keep 50 lines of command line history

" do incremental searching
set incsearch hlsearch wrapscan
set ignorecase smartcase

" disable bell all together
set noeb vb t_vb=

set smartindent autoindent 
" replace <tab> with 2 blank space.
set expandtab smarttab shiftwidth=2 softtabstop=0 tabstop=8
set textwidth=80	" wrap text for 78 letters
" set relativenumber

set hidden              " hide instead of abandon buffer
map Q gq
set wrap
set whichwrap=b,s,<,>,[,],h,l
set linebreak           " no breakline in the middle of a word

if executable( 'par' )
    set formatprg=par\ req
else
    set formatprg=fmt
endif
set formatoptions+=mM     " default tcq, mM to help wrap chinese

set backup
if !isdirectory($HOME . "/.backup")
    call mkdir($HOME . "/.backup", "p")
endif
set backupdir=$HOME/.backup
set directory=$HOME/.backup     "swp

if !isdirectory($HOME . "/.vim/undo")
    call mkdir($HOME . "/.vim/undo", "p")
endif
set undodir=~/.vim/undo undofile undolevels=1000 undoreload=1000

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
set notitle             " do not set xterm dynamic title
"set number

set matchtime=5
set lazyredraw          " faster for macros
set ttyfast             " better for xterm

" make spell suggest faster
set spellsuggest=best
set spelllang=en_gb,cjk

set guioptions-=T
set guioptions-=r

let s:uname = system("uname")
if s:uname == "Darwin\n"
    "Mac options here
    set guifont=Monaco\ for\ Powerline:h14
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

" get rid of the delay while switching between normal mode and insert mode
set timeoutlen=1000 ttimeoutlen=0

"tags, use semicolon to seperate so that vim searches parent directories!
set tags=./.tags;

" 高亮当前位置
" set cursorline cursorcolumn

set noautochdir

"---------------------encoding detection--------------------------------
set fileencoding&
set fileencodings=ucs-bom,utf-8,enc-cn,cp936,gbk,latin1

"---------------------completion settings-------------------------------
"make completion menu usable even when some characters are typed.
set completeopt=longest,menuone
" set complete-=i
" set complete-=t
set complete+=kspell

"---------------------keyboard mappings---------------------------------
set winaltkeys=no

"move in insert mode
inoremap <m-h> <left>
inoremap <m-l> <Right>
inoremap <m-j> <C-o>gj
inoremap <m-k> <C-o>gk

" search for visual-mode selected text
vmap / y/<C-R>"<CR>

" tab navigation
nmap tp :tabprevious<cr>
nmap tn :tabnext<cr>
nmap to :tabnew<cr>
nmap tc :tabclose<cr>
nmap gf <C-W>gf

" clear search highlight with F5
nmap <F5>   :noh<cr><ESC>

" use <leader>y/p to interact with clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

"--------------------------file type settings---------------------------
"Python
autocmd FileType python set omnifunc=pythoncomplete#Complete

"ruby
"no folding for comment block and if/do blocks
let ruby_no_comment_fold=1
let ruby_fold=1
let ruby_operators=1
autocmd FileType ruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby let g:rubycomplete_classes_in_global = 1
autocmd BufRead,BufNewfile Vagrantfile set ft=ruby

"emails,
"delete old quotations, set spell and put cursor in the first line
autocmd FileType mail
            \|:silent setlocal fo+=aw       " http://wcm1.web.rice.edu/mutt-tips.html
            \|:silent set spell
            "\|:silent 0put=''
            \|:silent g/^.*>\sOn.*wrote:\s*$\|^>\s*>.*$/de
            \|:silent 1

"markdown
autocmd BufNewFile,BufRead *mkd,*.md,*.mdown set ft=markdown
autocmd FileType markdown set comments=n:> nu nospell textwidth=0 formatoptions=tcroqn2

"remind
autocmd BufNewFile,BufRead *.rem set ft=remind

"crontab hack for mac
autocmd BufEnter /private/tmp/crontab.* setl backupcopy=yes

"Auomatically add file head defined in ~/.vim/templates/
au BufNewFile * silent! exec ":0r " . g:vim_home . "/templates/" . &ft | normal G

"-------------------special settings------------------------------------
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
if exists('$TMUX')
    " tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
    let &t_SI .= "\<Esc>Ptmux;\<Esc>\<Esc>[5 q\<Esc>\\"
    let &t_SR .= "\<Esc>Ptmux;\<Esc>\<Esc>[4 q\<Esc>\\"
    let &t_EI .= "\<Esc>Ptmux;\<Esc>\<Esc>[2 q\<Esc>\\"
    autocmd VimLeave * silent !echo -ne "\033Ptmux;\033\033[5 q\033\\"
else
    let &t_SI .= "\<Esc>[5 q"
    let &t_SR .= "\<Esc>[4 q"
    let &t_EI .= "\<Esc>[2 q"
    autocmd VimLeave * silent !echo -ne "\033[5 q"
endif
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

