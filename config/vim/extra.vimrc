" Colors
"
" Use 24-bit (true-color) mode in Vim when outside tmux
"
" NOTE: A longer if statement for Neovim is given e.g. in
"       https://github.com/joshdick/onedark.vim
"
if exists("+termguicolors")
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" set t_Co=256  " Use 256 (uncomment if supported in terminal)
syntax on

colorscheme one
set background=@background@

" Vim airline
let g:airline_powerline_fonts=1
let g:airline_theme='one'
set noshowmode " Disable the default statusline

" " Load colorscheme from a file so we can swap it
" let colorfile = expand("~/.vim/color.vim")
" if filereadable(colorfile)
"   exec "source" colorfile
" else
"   colorscheme delek
" endif

" Additional file type definitions
autocmd BufRead,BufNewFile *.zsh-theme set filetype=zsh
autocmd BufRead,BufNewFile .spacemacs set filetype=lisp

" Remove trailing whitespace on saving
autocmd BufWritePre * :%s/\s\+$//e

" Indentation per filetype
autocmd FileType python setlocal shiftwidth=4 tabstop=4
autocmd FileType c setlocal shiftwidth=2 tabstop=2
