set   all&
" reasonable defaults for indentation
set autoindent nocindent nosmartindent

set textwidth=79
set tabstop=2
set softtabstop=2


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
"       compatible:  Let Vim behave like Vi?  Hell, no!
set   nocompatible
"
"       comments default: sr:/*,mb:*,el:*/,://,b:#,:%,:XCOMM,n:>,fb:-
set   comments=b:#,:%,fb:-,n:>,n:)

"
"       errorbells: damn this beep!  ;-)
set   noerrorbells


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
"set number
"
"
"       report: show a report when N lines were changed.
"               report=0 thus means "show all changes"!
set   report=0
"
"       ruler:       show cursor position?  Yep!
set   ruler

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
"       title:
set title

"       visualbell:
set   visualbell


"set   highlight=8r,db,es,hs,mb,Mr,nu,rs,sr,tb,vr,ws


" allows files to be open in invisible buffers
set hidden

" make backspace "more powerful"
set backspace=indent,eol,start

" keep undo files in one place
set undodir=~/.vim/undodir

"
" ===================================================================
" AutoCommands
" ===================================================================
"
" More coding sytle colors

autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd Syntax * syn match Tabs "\t" containedin=ALL
autocmd ColorScheme * highlight Tabs ctermbg=red guibg=red

" Bright red background for text matches
autocmd ColorScheme * highlight Search guifg=#FFFFFF guibg=#FF0000

" Override italics in gui colorschemes
autocmd ColorScheme * highlight Comment gui=NONE

" Force a black background in the colorschme
autocmd ColorScheme * highlight Normal guibg=black

call pathogen#infect()
syntax on
filetype on
filetype plugin on
filetype indent on
let g:solarized_termtrans=1
call togglebg#map("<F5>")

let g:solarized_termcolors = 256
"let g:solarized_visibility = "high"
"let g:solarized_contrast = "high"


if has("gui_running")
  set guifont=terminus\ 12 linespace=0
  "set guifont=Source\ Code\ Pro\ 11 linespace=-2
  " no toolbar
  set guioptions-=T
  set bg=dark
  set antialias
  colorscheme vividchalk
else
  set t_Co=256
  set bg=dark
  colorscheme vividchalk
endif


set modeline modelines=3

" don't show help when F1 is pressed -- I press it too much by accident
map <F1> <ESC>
"map! <F1> <ESC>
inoremap <F1> <ESC>

highlight Cursor ctermfg=white  ctermbg=black

augroup mkd
  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:>
augroup END



" Reopen files at the last seen line
:au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

" Wrapping and tabs.
autocmd BufRead *.py set tw=78 ts=2 sw=2 sta et sts=2 ai

" More syntax highlighting.
let python_highlight_all = 1

" Smart indenting
autocmd BufRead *.py set indentexpr=GetGooglePythonIndent(v:lnum)

" Auto completion via ctrl-space (instead of the nasty ctrl-x ctrl-o)
set omnifunc=pythoncomplete#Complete
inoremap <Nul> <C-x><C-o>

" http://code.google.com/p/google-styleguide/source/browse/trunk/google_python_style.vim

let s:maxoff = 50 " maximum number of lines to look backwards.

function GetGooglePythonIndent(lnum)

  " Indent inside parens.
  " Align with the open paren unless it is at the end of the line.
  " E.g.
  "   open_paren_not_at_EOL(100,
  "                         (200,
  "                          300),
  "                         400)
  "   open_paren_at_EOL(
  "       100, 200, 300, 400)
  call cursor(a:lnum, 1)
  let [par_line, par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
        \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
        \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
        \ . " =~ '\\(Comment\\|String\\)$'")
  if par_line > 0
    call cursor(par_line, 1)
    if par_col != col("$") - 1
      return par_col
    endif
  endif

  " Delegate the rest to the original function.
  return GetPythonIndent(a:lnum)

endfunction

let pyindent_nested_paren="&sw*2"
let pyindent_open_paren="&sw*2"

autocmd BufRead *.py  set formatoptions=ctrq

" Enable spell checking, even in program source files. Hit <F4> to highlight
" highlight spelling errors. Hit it again to turn highlighting off.
"
" And, if you cannot remember the keybindings, and/or too lazy to type
"
"     :help spell

" and read the manual, here is a brief reminder:
" ]s Next misspelled word
" [s Previous misspelled word
" z= Make suggestions for current word
" zg Add to good words list
"
if has("spell")
  setlocal spell spelllang=en_us  " American English spelling.

  " Toggle spelling with F4 key.
  map <F4> :set spell!<CR><Bar>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

  " z= for suggestions

  " Change the default highlighting colors and terminal attributes
  highlight SpellBad cterm=underline ctermfg=yellow ctermbg=gray

  " Limit list of suggestions to the top 10 items
  set sps=best,10

  "Turn spelling off by default for English UK.
  "Center is correctly spelled. Centre is not, and
  "shows with spell local colors. Misspelled words
  "show like soo.
  set nospell
endif

source ~/.vim/user.vim
