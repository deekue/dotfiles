vim-go-ide
==========

IDE like setup for editing Go in Vim.

Requirements:
- Go installed and $GOPATH set
- Vim >7.1 installed

Installation:

1. clone this repo
1. run ./install.sh -n (dry run)
  - check output, make sure it looks sensible
1. run ./install.sh

Notes:
* local untracked overrides for Vim go in ~/.vim/user.vim  (think work specific stuff on your work machine)
* key maps:
  * tab to complete with YouCompleteMe
  * Snippets
    * C-j to complete snippets with Utilisnips
    * C-j/k to jump forward/backward
  * F6 opens Tagbar
  * F7 opens NERDTree

