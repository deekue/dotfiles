function! deekue#before() abort
  let g:pydocstring_doq_path = '/usr/local/bin/doq'

  let g:github_dashboard = { 'username': 'dq-dd', 'password': $VIM_GITA_GITHUB_TOKEN }
  let g:gista#client#default_username = 'dq-dd'

  let g:neoformat_enabled_javascript = ['npxprettier']

  if has('nvim')
    call SpaceVim#custom#SPCGroupName(['z'], '+ZkGroup')
    call SpaceVim#custom#SPC('nore', ['z', 'n'], ":ZkNew { title = vim.fn.input('Title: ') }", 'Create a new note after asking for its title', 1)
    call SpaceVim#custom#SPC('nore', ['z', 'o'], ":ZkNotes { sort = { 'modified' } }<CR>", 'Open notes', 1)
    call SpaceVim#custom#SPC('nore', ['z', 't'], ':ZkTags<CR>', 'Open notes associated with the selected tags', 1)
    call SpaceVim#custom#SPC('nore', ['z', 'f'], ":ZkNotes { sort = { 'modified' }, match = vim.fn.input('Search: ') }<CR>", 'Search for the notes matching a given query.', 1)
    call SpaceVim#custom#SPC('nore', ['z', 'v'], ":'<,'>ZkMatch<CR>", 'Search for the notes matching the current visual selection.', 1)
  endif

endfunction

function! deekue#after() abort
  " for tpope/vim-projectionist
  nnoremap <silent> ga :<C-u>A<CR>

  if has('nvim')
    " zk-nvim
    lua << EOF
require("zk").setup({
 -- can be "telescope", "fzf" or "select" (`vim.ui.select`)
 -- it's recommended to use "telescope" or "fzf"
 picker = "fzf",

 lsp = {
   -- `config` is passed to `vim.lsp.start_client(config)`
   config = {
     cmd = { "zk", "lsp" },
     name = "zk",
     -- on_attach = ...
     -- etc, see `:h vim.lsp.start_client()`
   },

   -- automatically attach buffers in a zk notebook that match the given filetypes
   auto_attach = {
     enabled = true,
     filetypes = { "markdown" },
   },
 },
})
EOF
  endif

endfunction
