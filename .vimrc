" CHANGE CURSOR SHAPE BASED ON MODE (For Windows Terminal)
let &t_SI.="\e[5 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

" BASIC SETUP
set nocompatible

" show line numbers
set number

" enable syntax and plugins (for netrw)
set t_Co=16
packadd! dracula
colorscheme dracula
syntax enable
filetype plugin on

" FINDING FILES
" Search down into subfolders
" Provides tab-completion for all file-related tasks 
set path+=**

" Display all matching files when we tab complete
set wildmenu

