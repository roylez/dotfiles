setlocal wrapmargin=0 wrap list linebreak nohlsearch spell
" http://wcm1.web.rice.edu/mutt-tips.html
setlocal fo+=aw

" delete old quotes and etc
silent g/^.*>\sOn.*wrote:\s*$\|^>\s*>.*$/de
