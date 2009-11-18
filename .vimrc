"Author: Roy L Zuo (roylzuo at gmail dot com)
"Description: vim runtime configure file 
"source $VIMRUNTIME/vimrc_example.vim
" vim: ft=vim

set nocompatible	" not vi compatible
set mouse=""            " disable mouse
filetype plugin indent on 

set history=50		" keep 50 lines of command line history
" keep record of editing information for cursor restore and more
set viminfo='10,\"100,:20,%,n~/.viminfo 

" do incremental searching
set incsearch hlsearch wrapscan
set ignorecase smartcase

set showmatch		" show the matching brackets when typing

set showcmd		" display incomplete commands
set ruler		" show the cursor position all the time in statusline
set laststatus=2        " always display a nicer status bar
set statusline=%<%h%m%r\ %f%=[%{&filetype},%{&fileencoding},%{&fileformat}]%k\ %-14.(%l/%L,%c%V%)\ %P
set wildmenu		" show possible command when pressing <TAB>
set cmdheight=2
set notitle             " do not set xterm dynamic title
"set number

set matchtime=5		

set lazyredraw          " faster for macros

set guifont=Monaco\ 10

set smartindent autoindent
set expandtab
set shiftwidth=4
set softtabstop=4 	" replace <tab> with 4 blank space.
set textwidth=80	" wrap text for 78 letters
set smarttab

map Q gq
set wrap
set whichwrap=b,s,<,>,[,],h,l
set linebreak           " no breakline in the middle of a word

set formatprg=fmt
set formatoptions+=mM     " default tcq, mM to help wrap chinese

set backup
set backupdir=$HOME/.backup

set commentstring=#%s       " default comment style
set sps=best,10             " only show 10 best spell suggestions
set dictionary+=/usr/share/dict/words

set magic

" 输入:set list命令是应该显示些啥？
"set listchars=tab:>-,eol:<
set listchars=nbsp:¬,eol:¶,tab:>-,extends:»,precedes:«,trail:•

" 光标移动到buffer的顶部和底部时保持3行距离
set scrolloff=3

"dynamic cursor color for xterm
if &term =~ "xterm"
    :silent !echo -ne "\033]12;RoyalBlue1\007"
    let &t_SI = "\<esc>]12;green\007"
    let &t_EI = "\<esc>]12;RoyalBlue1\007"
    autocmd VimLeave * :!echo -ne "\033]12;green\007"
endif

let fortran_have_tabs=1	    " this line must be placed before syntax on
let fortran_fold=1

set foldenable
set foldmethod=syntax
set foldnestmax=1

set background=dark

syntax on 
"maybe necessary for urxvt, because vim use ^H for backspace, 
"but urxvt can use both ^H and ^?
"fixdel

"if has 256 colour, use a 256 colour theme
if $TERM =~ '^xterm' || $TERM =~ '^screen' || has("gui_running")
    if !has("gui_running")
        set t_Co=256
    endif
    "colorscheme inkpot
    "colorscheme leo
    colorscheme molokai
else
    colorscheme tango
endif

" 高亮当前行
"set cursorline
"set cursorcolumn
autocmd InsertLeave * set nocursorline
autocmd InsertEnter * set cursorline 

"---------------------encoding detection--------------------------------
"set encoding&		    " terminal charset: follows current locale
"set termencoding=
"set fileencodings-=latin1
"set fileencoding&          " auto-sensed charset of current buffer
"function GetEncoding(f)     "automatic update encoding
"let e = system('enca -L none -Pm "' . a:f . '"')
"let e = substitute(e, '/.*', '', '')
"if e =~ 'unknown'
"return 'utf-8'
"endif
"return e
"endfunc

"autocmd BufReadPre * 
"\exec "set fileencodings+=" . GetEncoding(expand('<afile>')) 

set encoding=utf-8
set fileencoding&
set fileencodings=ucs-bom,utf-8,enc-cn,cp936,gbk,latin1
"---------------------completion settings-------------------------------
"make completion menu usable even when some characters are typed.
set completeopt=longest,menuone
"inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<c-g>u\<cr>"
"inoremap <expr> <c-n> pumvisible() ? 
            "\"\<c-n>" : "\<c-n>\<c-r>=pumvisible() ? \"\\<down>\" : \"\\<cr>\""
"inoremap <expr> <m-;> pumvisible() ? 
            "\"\<c-n>" : "\<c-x>\<c-o>\<c-n>\<c-p>\<c-r>=pumvisible() ? 
            "\\"\\<down>\" : \"\\<cr>\""
"---------------------keyboard mappings---------------------------------
set winaltkeys=no

"ascii art escape sequence for /etc/motd, ssh banner and etc
imap ,e   <C-V><C-[>[

"move among windows
"nmap h   <C-W>h
"nmap i   <C-W>i
"nmap j   <C-W>j
"nmap k   <C-W>k

"move in insert mode
inoremap <m-h> <left>
inoremap <m-l> <Right>
inoremap <m-j> <C-o>gj
inoremap <m-k> <C-o>gk

" search for visual-mode selected text
vmap / y/<C-R>"<CR>

" taglist.vim
let g:Tlist_GainFocus_On_ToggleOpen=1
let g:Tlist_Exit_OnlyWindow=1
"let g:Tlist_Use_Right_Window=1
let g:Tlist_Show_One_File=1
let g:Tlist_Enable_Fold_Column=0
let g:Tlist_Auto_Update=1
nmap <F2>   :TlistToggle<CR>

"Make and make test
nmap <F5>   :w<CR>:make<CR>
nmap <F6>   :make test<CR>

" NERO_comment.vim
let g:NERDShutUp=1
nmap <F9>   ,c<SPACE>
vmap <F9>   ,c<SPACE>

" tab navigation
nmap tp :tabprevious<cr> 
nmap tn :tabnext<cr>    
nmap to :tabnew<cr>
nmap tc :tabclose<cr>
nmap gf <C-W>gf

"Auomatically add file head. NERO_commenter.vim needed.
function! AutoHead()        
    let fl = line(".") 
    if getline(fl) !~ "^$"
        let fl += 1
    endif 
    let ll = fl+2
    call setline(fl,"Author: Roy L Zuo (roylzuo at gmail dot com)")
    "call append(fl,"Last Change: ")
    call append(fl,"Description: ")
    call append(fl+1,"")
    execute fl . ','. ll .'call NERDComment(0,"toggle")'
endfunc
nmap ,h :call AutoHead()<cr>

let g:timestamp_regexp = '\v\C%(<Last %([cC]hanged?|[Mm]odified):\s+)@<=.*$'

"--------------------------file type settings---------------------------
"tags
"use semicolon to seperate so that vim searches parent directories!
set tags=tags;

"Python
"autocmd Filetype python setlocal omnifunc=pythoncomplete#Complete
autocmd BufNewFile *.py 
            \0put=\"#!/usr/bin/env python\<nl># -*- coding: UTF-8 -*-\<nl>\" 
            \|call AutoHead()
autocmd FileType python set omnifunc=pythoncomplete#Complete

"ruby
autocmd BufNewFile *.rb 0put=\"#!/usr/bin/env ruby\<nl># coding: utf-8\<nl>\" |call AutoHead()
"autocmd FileType ruby set omnifunc=rubycomplete#Complete

"C/C++
autocmd FileType cpp setlocal nofoldenable
            \|nmap ,a :A<CR>      
autocmd FileType c setlocal cindent

"Fortran
"autocmd FileType fortran let b:fortran_free_source = 1

"Txt, set syntax file and spell check
"autocmd BufRead,BufNewFile *.txt set filetype=txt 
"autocmd BufRead *.txt setlocal spell spelllang=en_gb

"Tex ''spelllang=en_gb 
"let g:tex_flavor="context"
autocmd FileType tex,plaintex,context
            \|silent set spell
            \|nmap <buffer> <F8> gwap	

" shell script
autocmd BufNewFile *.sh 0put=\"#!/bin/bash\<nl># vim:fdm=marker\<nl>\" |call AutoHead()

"Gnuplot
autocmd BufNewFile *.gpi 0put='#!/usr/bin/gnuplot -persist' |call AutoHead()

"emails, 
"delete old quotations, set spell and put cursor in the first line
autocmd FileType mail 
            \|:silent set spell
            "\|:silent 0put=''
            "\|:silent 0put=''
            \|:silent g/^.*>\sOn.*wrote:\s*$\|^>\s*>.*$/de
            "\|:silent %s/^\s*>\s*--\_.\{-\}\_^\s*\_$//ge
            \|:silent 1

"openGL shading language (glsl)
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl

"cuda
au BufNewFile,BufRead *.cu set ft=cuda |setlocal cindent

"markdown
autocmd BufNewFile,BufRead *.mkd,*.mdown  set ft=mkd comments=n:> nu spell

"RestructuredText 
autocmd BufNewFile,BufRead *.rst  set ft=rest ai formatoptions=tcroqn2

"viki
autocmd BufNewFile,BufRead *.viki set ft=viki

"fcron
autocmd BufNewFile,BufRead /tmp/fcr-* set ft=crontab
"-------------------special settings------------------------------------
"big files?
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

"Restore cursor to file position in previous editing session
autocmd BufReadPost * 
    \if line("'\"") > 0 && line("'\"") <= line("$") 
        \|exe "normal g`\"" 
    \|endif

"warn long lines
"au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>' . &textwidth . 'v.\+', -1)
