" Vim filetype plugin
" Language: SQL
" Maintainer: kyo

if !executable('mysql')
  finish
endif

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

unlet! b:did_ftplugin

if !exists('g:kyo_sql_host')
  let g:kyo_sql_host = '127.0.0.1'
endif

if !exists('g:kyo_sql_port')
  let g:kyo_sql_port = '3306'
endif

if !exists('g:kyo_sql_user')
  let g:kyo_sql_user = 'root'
endif

if !exists('g:kyo_sql_pwd')
  let g:kyo_sql_pwd = '123321'
endif

if !exists('g:kyo_sql_db')
  let g:kyo_sql_db = 'mysql'
endif

" 根据列表内容给全局配置变量赋值
function! s:assignConfig(config)
  let [name, value] = split(a:config)
  if name == "@Host"
    let g:kyo_sql_host = value
  elseif name == "@User"
    let g:kyo_sql_user = value
  elseif name == "@Port"
    let g:kyo_sql_port = value
  elseif name == "@Password"
    let g:kyo_sql_pwd = value
  elseif name == "@Database"
    let g:kyo_sql_db = value
  endif
endfunction


