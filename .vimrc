" Description: vim runtime configure file
" vim: ft=vim foldmethod=marker

set nocompatible	    " not vi compatible
let mapleader="\<Space>"    " this is used a lot in plugin settings

if filereadable( $HOME . '/.vimrc.plug'  )
    source  $HOME/.vimrc.plug
endif

filetype plugin indent on
syntax on

set mouse=""            " disable mouse
set history=50		" keep 50 lines of command line history
" keep record of editing information for cursor restore and more
set viminfo='10,\"100,:20,%,n~/.viminfo

" do incremental searching
set incsearch hlsearch wrapscan
set ignorecase smartcase

set showmatch		" show the matching brackets when typing
" set ambiwidth=double     " set this if terminal has similar setting

set showcmd		" display incomplete commands
set ruler		" show the cursor position all the time in statusline
set laststatus=2        " always display a nicer status bar
set statusline=%<%h%m%r\ %f%=[%{&filetype},%{&fileencoding},%{&fileformat}]%k\ %-14.(%l/%L,%c%V%)\ %P
" set wildmenu		" show possible command when pressing <TAB>
set wildmode=longest:list,full
"set cmdheight=2
set notitle             " do not set xterm dynamic title
"set number

set matchtime=5
set lazyredraw          " faster for macros
set ttyfast             " better for xterm

set guioptions-=T
set guioptions-=r
let s:uname = system("uname")
if s:uname == "Darwin\n"
    "Mac options here
    set guifont=Monaco\ for\ Powerline:h14
    set lines=50
    set columns=90
else
    set guifont=Monaco\ 10
    set guifontwide=WenQuanYi\ Micro\ Hei\ 12
endif

set smartindent autoindent expandtab smarttab
set shiftwidth=4
set softtabstop=4 	" replace <tab> with 4 blank space.
set textwidth=80	" wrap text for 78 letters

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

if version >= 703
    if !isdirectory($HOME . "/.vim/undo")
        call mkdir($HOME . "/.vim/undo", "p")
    endif
    set undodir=~/.vim/undo undofile undolevels=1000 undoreload=1000
endif

set commentstring=#%s       " default comment style
set sps=best,10             " only show 10 best spell suggestions
set dictionary+=/usr/share/dict/words

set magic

" 输入:set list命令是应该显示些啥？
"set listchars=tab:>-,eol:<
set listchars=nbsp:¬,eol:¶,tab:>-,extends:»,precedes:«,trail:•

" 光标移动到buffer的顶部和底部时保持3行距离
set scrolloff=3

set foldenable foldmethod=syntax foldnestmax=1 foldlevelstart=1

set background=dark
set cc=90

"maybe necessary for urxvt, because vim use ^H for backspace,
"but urxvt can use both ^H and ^?
"fixdel
set backspace=2

"tags, use semicolon to seperate so that vim searches parent directories!
set tags=./.tags;

" 高亮当前行
"set cursorline
"set cursorcolumn
autocmd InsertLeave * set nocursorline
autocmd InsertEnter * set cursorline

" remove all trailing white spaces
autocmd BufWritePre * :%s/\s\+$//e

"---------------------encoding detection--------------------------------
set encoding=utf-8
set fileencoding&
set fileencodings=ucs-bom,utf-8,enc-cn,cp936,gbk,latin1

"---------------------completion settings-------------------------------
"make completion menu usable even when some characters are typed.
set completeopt=longest,menuone
set complete-=i
set complete-=t

"---------------------keyboard mappings---------------------------------
set winaltkeys=no

"ascii art escape sequence for /etc/motd, ssh banner and etc
imap ,e   <C-V><C-[>[

"insert time stamp
imap <F8> <C-R>=strftime("%Y-%m-%d %H:%M")<CR>

"move among windows
nmap <C-h>   <C-W>h
nmap <C-l>  <C-W>l
nmap <C-j>   <C-W>j
nmap <C-k>   <C-W>k

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
autocmd FileType ruby set shiftwidth=2 softtabstop=2
autocmd BufRead,BufNewfile Vagrantfile set ft=ruby

" scss
autocmd FileType scss,sass setl shiftwidth=2 softtabstop=2

"C/C++
autocmd FileType cpp setl nofoldenable
            \|nmap ,a :A<CR>
autocmd FileType c setl cindent

"Txt, set syntax file and spell check
"autocmd BufRead,BufNewFile *.txt set filetype=txt
"autocmd BufRead *.txt setlocal spell spelllang=en_gb

"Tex ''spelllang=en_gb
"let g:tex_flavor="context"
autocmd FileType tex,plaintex,context
            \|silent set spell
            \|nmap <buffer> <F8> gwap

"emails,
"delete old quotations, set spell and put cursor in the first line
autocmd FileType mail
            \|:silent setlocal fo+=aw       " http://wcm1.web.rice.edu/mutt-tips.html
            \|:silent set spell
            "\|:silent 0put=''
            \|:silent g/^.*>\sOn.*wrote:\s*$\|^>\s*>.*$/de
            \|:silent 1

"cuda
au BufNewFile,BufRead *.cu set ft=cuda |setlocal cindent

"markdown
autocmd BufNewFile,BufRead *mkd,*.md,*.mdown set ft=markdown
autocmd FileType markdown set comments=n:> nu nospell textwidth=0 formatoptions=tcroqn2

"yaml
autocmd FileType yaml set softtabstop=2 shiftwidth=2 noautoindent nosmartindent

"coffee
autocmd FileType coffee set softtabstop=2 shiftwidth=2

"viki
autocmd BufNewFile,BufRead *.viki set ft=viki

"fcron
autocmd BufNewFile,BufRead /tmp/fcr-* set ft=crontab

"pentadactyl/vimperator
autocmd BufNewFile,BufRead /tmp/pentadactyl*.tmp set textwidth=9999
autocmd BufNewFile,BufRead *.vimperatorrc set ft=vimperator

"bbcode
autocmd BufNewFile,BufRead /tmp/*forum.ubuntu.org.cn* set ft=bbcode

"remind
autocmd BufNewFile,BufRead *.rem set ft=remind

"crontab hack for mac
autocmd BufEnter /private/tmp/crontab.* setl backupcopy=yes

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

" {{{ dynamic cursor color for xterm \033=>\e  007=>\a (BEL)
if &term =~ "xterm"
    :silent !echo -ne "\e]12;IndianRed2\007"
    let &t_SI = "\e]12;RoyalBlue1\007"
    let &t_EI = "\e]12;IndianRed2\007"
    autocmd VimLeave * :!echo -ne "\e]12;green\007"
"elseif &term =~ "screen"    " screen in urxvt or xterm
    ":silent !echo -ne "\eP\e]12;IndianRed2\007\e\\"
    "let &t_SI = "\eP\e]12;RoyalBlue1\007\e\\"
    "let &t_EI = "\eP\e]12;IndianRed2\007\e\\"
    "autocmd VimLeave * :!echo -ne "\eP\e]12;green\007\e\\"
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
