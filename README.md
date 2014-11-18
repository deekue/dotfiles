vim-go-ide
==========

IDE like setup for editing Go in Vim.

Requirements:
- Go installed and $GOPATH set
- Vim >7.1 installed

Installion:
1. clone this repo
2. run ./install.sh -n (dry run)
2. check output, make sure it looks sensible
2. run ./install.sh

Notes:
* local untracked overrides for Vim go in ~/.vim/user.vim  (think work specific stuff on your work machine)
* key maps:
  * tab to complete with YouCompleteMe
  * Snippets
    * C-j to complete snippets with Utilisnips
    * C-j/k to jump forward/backward
  * F6 opens Tagbar
  * F7 opens NERDTree

