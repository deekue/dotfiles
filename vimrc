
set   nocompatible
syntax on
filetype plugin indent on

let g:mapleader = "\<Space>"
let g:maplocalleader = ','

" keep undo files in one place
set undodir=~/.vim/undodir
set directory=~/.vim/swaps

" reasonable defaults for indentation
set autoindent nocindent nosmartindent

" tabs,space,indents
set tabstop=2
set shiftwidth=2
set smarttab
set expandtab
set textwidth=79

"==== Color schemes ===
set background=dark
set bg=dark
let g:solarized_termcolors=256
"let g:solarized_termcolors=16
colorscheme solarized
""if has('gui_running')
"  set guifont=terminus\ 12 linespace=0
"  set guioptions-=T
"  set bg=dark
"  set antialias
"else
"  set t_Co=256
"  set bg=dark
"endif

" More coding sytle colors - where was ExtraWhitespace defined?
"autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
"autocmd Syntax * syn match ExtraWhitespace /\s\+$/
"autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
"autocmd ColorScheme * highlight Tabs ctermbg=red guibg=red
"autocmd Syntax * syn match Tabs "\t"
"autocmd BufWinEnter * match Tabs "\t"

" improve readability of delimiters in Solarized - https://stackoverflow.com/a/69529920
highlight Delimiter cterm=bold ctermbg=none ctermfg=grey

" Bright red background for text matches
autocmd ColorScheme * highlight Search ctermbg=red ctermfg=white guifg=#FFFFFF guibg=#FF0000

" Override italics in gui colorschemes
autocmd ColorScheme * highlight Comment gui=NONE

" Force a black background in the colorschme
autocmd ColorScheme * highlight Normal guibg=black

"==== Key maps ====
set pastetoggle=<F2>
map <F3> mzgg=G'z<CR>

" spaces to tabs from:
" https://stackoverflow.com/questions/9104706/how-can-i-convert-spaces-to-tabs-in-vim-or-linux
nnoremap    <F4> :<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list? <CR>

" don't show help when F1 is pressed -- I press it too much by accident
map <F1> <ESC>
"map! <F1> <ESC>
inoremap <F1> <ESC>

"==== Markdown Stuff ===
augroup mkd
  autocmd BufRead *.md  set ai formatoptions=tcroqn2 comments=n:>
augroup END

"==== HTML Stuff ====
" Don't wrap html
autocmd BufWinEnter *.html set textwidth=0
autocmd BufWinEnter *.html set wrapmargin=0

"==== Go Stuff ====

" Go wants tabs so don't highlight or expand them,
"autocmd BufWinEnter *.go match Tabs "\t\+$"
autocmd BufWinEnter *.go set noexpandtab
autocmd BufWinEnter *.go set textwidth=0
autocmd BufWinEnter *.go set wrapmargin=0

" UltiSnips integration
"set omnifunc=syntaxcomplete#Complete
"let g:UltiSnipsSnippetDirectories=["UltiSnips","vim-snippets/UltiSnips"]
" Needed for YCM compat
"let g:UltiSnipsExpandTrigger="<c-j>"
"let g:UltiSnipsJumpForwardTrigger="<c-j>"
"let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" Force YCM to call out to the gocode omnifunc for everything.
"let g:ycm_semantic_triggers = {
"\  'go'  : [' '],
"\ }
"
"let g:go_fmt_command = "goimports"
"
"let g:syntastic_aggregate_errors = 1
"let g:syntastic_go_checkers = ['go', 'gotype', 'golint', 'govet']

"au Filetype go nnoremap <leader>v :sp <CR>:exe "GoDef" <CR>

" NERDTree key map
"nmap <F7> :NERDTreeToggle<CR>

" Tagbar/Go integration
"nmap <F6> :TagbarToggle<CR>
"let g:tagbar_type_go = {  
"    \ 'ctagstype' : 'go',
"    \ 'kinds'     : [
"        \ 'p:package',
"        \ 'i:imports:1',
"        \ 'c:constants',
"        \ 'v:variables',
"        \ 't:types',
"        \ 'n:interfaces',
"        \ 'w:fields',
"        \ 'e:embedded',
"        \ 'm:methods',
"        \ 'r:constructor',
"        \ 'f:functions'
"    \ ],
"    \ 'sro' : '.',
"    \ 'kind2scope' : {
"        \ 't' : 'ctype',
"        \ 'n' : 'ntype'
"    \ },
"    \ 'scope2kind' : {
"        \ 'ctype' : 't',
"        \ 'ntype' : 'n'
"    \ },
"    \ 'ctagsbin'  : 'gotags',
"    \ 'ctagsargs' : '-sort -silent'
"\ }
"
" Fugitive Conflict Resolution
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>

" vim-which-key
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader>      :<c-u>WhichKeyVisual '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual ','<CR>
let g:which_key_map = {}
let g:which_key_map['w'] = {
      \ 'name' : '+windows' ,
      \ 'w' : ['<C-W>w'     , 'other-window']          ,
      \ 'd' : ['<C-W>c'     , 'delete-window']         ,
      \ '-' : ['<C-W>s'     , 'split-window-below']    ,
      \ '|' : ['<C-W>v'     , 'split-window-right']    ,
      \ '2' : ['<C-W>v'     , 'layout-double-columns'] ,
      \ 'h' : ['<C-W>h'     , 'window-left']           ,
      \ 'j' : ['<C-W>j'     , 'window-below']          ,
      \ 'l' : ['<C-W>l'     , 'window-right']          ,
      \ 'k' : ['<C-W>k'     , 'window-up']             ,
      \ 'H' : ['<C-W>5<'    , 'expand-window-left']    ,
      \ 'J' : [':resize +5'  , 'expand-window-below']   ,
      \ 'L' : ['<C-W>5>'    , 'expand-window-right']   ,
      \ 'K' : [':resize -5'  , 'expand-window-up']      ,
      \ '=' : ['<C-W>='     , 'balance-window']        ,
      \ 's' : ['<C-W>s'     , 'split-window-below']    ,
      \ 'v' : ['<C-W>v'     , 'split-window-below']    ,
      \ '?' : ['Windows'    , 'fzf-window']            ,
      \ }
"call which_key#register('<Space>', "g:which_key_map")

" load local overrides
try
  source ~/.vim/user.vim
catch
  " no local overrides
endtry
