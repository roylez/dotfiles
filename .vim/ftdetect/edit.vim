au BufRead,BufNewFile *.vim-edit setlocal filetype=vim-edit
" do not wrap actual lines
au FileType vim-edit setlocal spell textwidth=0
" copy from clipboard when entering
au BufNewFile   *.vim-edit normal "+P
" paste to clipboard when saving
au BufWritePost *.vim-edit if getfsize(expand(@%))>0 | silent :%y+ | endif
" delete tmp file when exiting
au BufDelete,BufHidden,VimLeave *.vim-edit silent :!rm -f <afile>
