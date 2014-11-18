" load pathogen first
runtime bundle/vim-pathogen.git/autoload/pathogen.vim
execute pathogen#infect()

set   nocompatible
syntax on
filetype plugin indent on

" keep undo files in one place
set undodir=~/.vim/undodir

" Go wants tabs so don't highlight or expand them,
"autocmd BufWinEnter *.go match Tabs "\t\+$"
autocmd BufWinEnter *.go set noexpandtab
autocmd BufWinEnter *.go set textwidth=0
autocmd BufWinEnter *.go set wrapmargin=0

" UltiSnips integration
set omnifunc=syntaxcomplete#Complete
let g:UltiSnipsSnippetDirectories=["UltiSnips","vim-snippets/UltiSnips"]
" Needed for YCM compat
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" Force YCM to call out to the gocode omnifunc for everything.
let g:ycm_semantic_triggers = {
\  'go'  : [' '],
\ }

let g:go_fmt_command = "goimports"

let g:syntastic_aggregate_errors = 1
let g:syntastic_go_checkers = ['go', 'gotype', 'golint', 'govet']

au Filetype go nnoremap <leader>v :sp <CR>:exe "GoDef" <CR>

" NERDTree key map
nmap <F7> :NERDTreeToggle<CR>

" Tagbar/Go integration
nmap <F6> :TagbarToggle<CR>
let g:tagbar_type_go = {  
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

" load local overrides
source ~/.vim/user.vim
