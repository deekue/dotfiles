
set   all&
set   autoindent
set   smartindent
highlight SpecialKey ctermfg=DarkGray

"ignore case in searches
set ignorecase

"       autowrite: Automatically save modifications to files
"       when you use critical (rxternal) commands.
set   autowrite
"
"       backup:  backups are for wimps  ;-)
"  set   backup
set nobackup
" write a backup file before overwriting a file
set nowb
" keep a backup after overwriting a file
set nobk
"
"       background:  Are we using a "light" or "dark" background?
set   background=dark
"
"       compatible:  Let Vim behave like Vi?  Hell, no!
set   nocompatible
"
"       comments default: sr:/*,mb:*,el:*/,://,b:#,:%,:XCOMM,n:>,fb:-
set   comments=b:#,:%,fb:-,n:>,n:)

"
"       errorbells: damn this beep!  ;-)
set   noerrorbells

set   expandtab
"
"       formatoptions:  Options for the "text format" command ("gq")
"                       I need all those options (but 'o')!
"set   formatoptions=cqrt
"
"       helpheight: zero disables this.
set   helpheight=0
"
"       hlsearch :  highlight search - show the current search pattern
"       This is a nice feature sometimes - but it sure can get in the
"       way sometimes when you edit.
set   hlsearch
"       laststatus:  show status line?  Yes, always!
"       laststatus:  Even for only one buffer.
set   laststatus=2
"
"       magic:  Use 'magic' patterns  (extended regular expressions)
"       in search patterns?  Certainly!  (I just *love* "\s\+"!)
"set   magic
"
"set nonumber
"
"
"       report: show a report when N lines were changed.
"               report=0 thus means "show all changes"!
set   report=0
"
"       ruler:       show cursor position?  Yep!
set   ruler
"
"
"       shiftwidth:  Number of spaces to use for each
"                    insertion of (auto)indent.
set   shiftwidth=2
"
"       shortmess:   Kind of messages to show.   Abbreviate them all!
"          New since vim-5.0v: flag 'I' to suppress "intro message".
set   shortmess=tI
"
"       showcmd:     Show current uncompleted command?  Absolutely!
set   showcmd
"
"       showmatch:   Show the matching bracket for the last ')'?
set   showmatch
"
"       showmode:    Show the current mode?  YEEEEEEEEESSSSSSSSSSS!
set   showmode
"
"       startofline:  no:  do not jump to first character with page
"       commands, ie keep the cursor in the current column.
set nostartofline
"
set   splitbelow
"
set   tabstop=2
"       title:
set title
"       visualbell:
set   visualbell

set   highlight=8r,db,es,hs,mb,Mr,nu,rs,sr,tb,vr,ws


"
" ===================================================================
" AutoCommands
" ===================================================================
"

call pathogen#infect()
syntax on
filetype on
filetype plugin on
filetype indent on

if has("gui")
    "  set guifont=Andale\ Mono/12/-1/5/48/0/0/0/1/0
    "  set guifont=-xos4-Terminus-Medium-R-Normal--14-140-72-72-C-80-ISO8859-1
    set gfn=terminus\ 12
endif
if ! has("gui_running")
    set t_Co=256
endif
" set background=light gives a different style, feel free to choose between them.
set background=dark
colors molokai

set modeline modelines=3

" don't show help when F1 is pressed -- I press it too much by accident
map <F1> <ESC>
"map! <F1> <ESC>
inoremap <F1> <ESC>

highlight Cursor ctermfg=white  ctermbg=black

augroup mkd
  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:>
augroup END

syntax match Tabs "\t" containedin=ALL
syntax match LineEndWS "\s\+$" containedin=ALL
highlight Tabs term=standout cterm=standout gui=standout
highlight link LineEndWS Error

:au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

" enables extra vim features (which break strict compatibility with vi)
set nocompatible

" allows files to be open in invisible buffers
set hidden

" show trailing spaces in yellow (or red, for users with dark backgrounds).
" "set nolist" to disable this.
" this only works if syntax highlighting is enabled.
set list
set listchars=tab:\ \ ,trail:\ ,extends:?,precedes:?
if &background == "dark"
  highlight SpecialKey ctermbg=Red guibg=Red
else
  highlight SpecialKey ctermbg=Yellow guibg=Yellow
end
" if you would like to make tabs and trailing spaces visible without syntax
" highlighting, use this:
"   set listchars=tab:?\ ,trail:\?,extends:?,precedes:?

" make backspace "more powerful"
set backspace=indent,eol,start


" don't outdent hashes
inoremap # #








" Wrapping and tabs.
autocmd BufRead *.py set tw=78 ts=4 sw=4 sta et sts=4 ai

" More syntax highlighting.
let python_highlight_all = 1

" Smart indenting
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

" Auto completion via ctrl-space (instead of the nasty ctrl-x ctrl-o)
set omnifunc=pythoncomplete#Complete
inoremap <Nul> <C-x><C-o>

" Wrap at 72 chars for comments.
set formatoptions=cq textwidth=72 foldignore= wildignore+=*.py[co]

" Highlight end of line whitespace.
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/
