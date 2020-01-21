""" Filetype Plugin
filetype plugin on

""" Syntax Highlighting
syntax on

""" Fix issues with tmux and background color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

""" Line Numbers
set number

" FINDING FILES
" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab complete
set wildmenu

""" CUSTOM PLUGINS
call plug#begin()
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

""" ColorScheme
colorscheme dracula
