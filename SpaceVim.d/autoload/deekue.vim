function! deekue#before() abort
    let g:pydocstring_doq_path = '/usr/local/bin/doq'

    let g:github_dashboard = { 'username': 'dq-dd', 'password': $VIM_GITA_GITHUB_TOKEN }
    let g:gista#client#default_username = 'dq-dd'
endfunction

function! deekue#after() abort
  " for tpope/vim-projectionist
  nnoremap <silent> ga :<C-u>A<CR>
endfunction
