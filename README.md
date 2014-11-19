vim-go-ide
==========

IDE like setup for editing Go in Vim.
based on [hobeone](https://github.com/hobeone)'s generic [dotfiles](https://github.com/hobeone/dotfiles) set up.

Requirements:
- Go installed and $GOPATH set
- Vim >7.1 installed
- Debian/Ubuntu based system

Includes:
- [NERDTree](http://github.com/scrooloose/nerdtree.git) (file browser)
- [Pathogen](http://github.com/tpope/vim-pathogen.git) (plugin manager)
- [Syntastic](http://github.com/scrooloose/syntastic.git) (syntax checker)
- [Tagbar](https://github.com/majutsushi/tagbar.git) (tag manager)
- [Utilisnips](https://github.com/SirVer/ultisnips.git) (snippet engine)
- [vim-go](https://github.com/fatih/vim-go.git) (Go support in Vim)
- [vim-sensible](http://github.com/scrooloose/nerdtree.git) (Sensible Vim defaults)
- [vim-snippets](https://github.com/honza/vim-snippets.git) (snippet repo)
- [YouCompleteMe](https://github.com/Valloric/YouCompleteMe.git) (realtime auto completion)

Installation:

1. clone this repo
1. run ./install.sh -n (dry run)
  - check output, make sure it looks sensible
1. run ./install.sh

Usage:
* local untracked overrides for Vim go in ~/.vim/user.vim  (eg. work specific stuff on your work machine)
  * this file is ignored (see .gitignore).  track it in a separate branch if you need to.
* on file save
  * syntax checking (go, gotype, golint, govet)
  * automatically add missing imports
  * gofmt for style guide compliance
* key maps:
  * tab to complete with YouCompleteMe
  * snippets (completion menu with 'snip')
    * C-j to complete snippet with Utilisnips
    * C-j/k to jump forward/backward between fields in a snippet
  * F6 opens Tagbar
  * F7 opens NERDTree

Extending:
* add more dotfiles/dirs to $LINKS in install.sh (eg. bashrc tmux.conf) for auto linking
* add new Vim plugins
  1. git submodule add PATH-TO-REPO vim/bundle/REPO-NAME
  2. git commit -m "adding REPO-NAME"
