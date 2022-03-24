function! deekue#before() abort
    let g:pydocstring_doq_path = '/usr/local/bin/doq'

    let g:github_dashboard = { 'username': 'dq-dd', 'password': $VIM_GITA_GITHUB_TOKEN }
    let g:gista#client#default_username = 'dq-dd'

endfunction

function! deekue#after() abort
  " for tpope/vim-projectionist
  nnoremap <silent> ga :<C-u>A<CR>

  " zk-nvim
  lua require("zk").setup()
endfunction


""    lua << EOF
""require("zk").setup()
""EOF
" require("zk").setup({
"   -- can be "telescope", "fzf" or "select" (`vim.ui.select`)
"   -- it's recommended to use "telescope" or "fzf"
"   picker = "select",
" 
"   lsp = {
"     -- `config` is passed to `vim.lsp.start_client(config)`
"     config = {
"       cmd = { "zk", "lsp" },
"       name = "zk",
"       -- on_attach = ...
"       -- etc, see `:h vim.lsp.start_client()`
"     },
" 
"     -- automatically attach buffers in a zk notebook that match the given filetypes
"     auto_attach = {
"       enabled = true,
"       filetypes = { "markdown" },
"     },
"   },
" })
