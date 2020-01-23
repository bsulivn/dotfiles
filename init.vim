" PATH: ~/.config/nvim/
" TITLE: init.vim
" AUTHOR: Bob Sullivan @BobSulivn
" PURPOSE: Configuration/settings for neovim

" COLORS {{{
syntax on		" Enable syntax highlighting

" Fix issues with tmux and background color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" }}}

" SPACES AND TABS {{{
set expandtab		" Use space instead of tabs
filetype indent on
filetype plugin on
" }}}

" UI AND LAYOUT {{{
set number              " Hybrid line numbers
set relativenumber
set showcmd		" Show command in bottom bar
set cursorline	        " Highlight current line
" }}}

" FINDING FILES {{{
" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**            
set wildmenu             " Display all matching files when we tab complete
" }}}


""" CUSTOM PLUGINS
call plug#begin()
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'vim-pandoc/vim-pandoc'                    " Markdown file support
Plug 'vim-pandoc/vim-pandoc-syntax'
call plug#end()

""" ColorScheme
colorscheme dracula

" Allow pandoc to handle Markdown files
let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
