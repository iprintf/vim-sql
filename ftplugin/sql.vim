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

let s:title = '-MySQL-'

" 生成私有配置
function! KyoMySQLGenConfig()
  let s = "-- Kyo MySQL IDE\n
\\n
\/* Kyo MySQL IDE Config\n
\@Host ".g:kyo_sql_host."\n
\@User ".g:kyo_sql_user."\n
\@Password ".g:kyo_sql_pwd."\n
\@Port ".g:kyo_sql_port."\n
\@DataBase ".g:kyo_sql_db."\n
\KYO MySQL IDE Config */"
  call append(line('.'), split(s, '\n'))
  return ''
endfunction

" 根据内容给全局配置变量赋值
function! s:assignConfig(config)
  try
    let [name, value] = split(a:config)
  catch /.*/
    return
  endtry

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

" 解析本文私有配置
function! s:parseConfig(content)
  let re = '\ *kyo\ *mysql\ *ide\ *config\ *'
  let config = []
  if type(a:content) == 3
    let start = match(a:content, '\c\/\*'.re)
    let end = match(a:content, '\c'.re.'\*\/')
    if start != -1 && end != -1
      let config = a:content[start + 1 : end - 1]
      unlet a:content[start : end]
    endif
  else
    let start = search('\/\*'.re, 'n') + 1
    let end = search(re.'\*\/', 'n') - 1
    let config = getline(start, end)
  endif
  for x in config
    call s:assignConfig(x)
  endfor
  return a:content
endfunction

" 清除列表中空行和SQL注释行
function! s:clearComment(content_list)
  let newlist = []
  for s in a:content_list
    if strlen(s) > 0 && stridx(s, '-- ') == -1
      call add(newlist, s)
    endif
  endfor
  return join(newlist)
endfunction

function! s:createDisplayWin()
  " silent exec 'botright 15 split '.s:title
  silent exec 'botright split  '.s:title
  setlocal buflisted
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nowrap
endfunction

" 跳转到显示窗口
function! s:gotoDisplayWin()
  if len(bufname(s:title)) == 0
    call s:createDisplayWin()
  elseif bufname('%') != s:title
    if bufwinnr(bufname(s:title)) == -1
      silent exec 'ba'
    endif
    silent exec 'wincmd w'
  endif
endfunction

" 解析配置执行mysql命令并且分割窗口显示
function! KyoMySQLCmdView(isVisual)
  if bufname('%') == s:title
    silent exec 'wincmd w'
  endif

  let content_list = s:parseConfig(getline(1, line('$')))
  if a:isVisual
    let content_list = GetVisualSelection()
  endif
  let content = s:clearComment(content_list)

  call s:gotoDisplayWin()
  setlocal modifiable
  silent exec 'normal ggVGx'
  let cmd = "mysql -h".g:kyo_sql_host." -P".g:kyo_sql_port
  let cmd .= " -u".g:kyo_sql_user." -p".g:kyo_sql_pwd." ".g:kyo_sql_db
  let cmd .= " -t <<< '".content."'"
  " call append(line('$'), cmd)
  silent exec ':r! '.cmd
  setlocal nomodifiable
  silent exec 'wincmd w'
endfunction

" 关闭和开启显示窗口
function! KyoMySQLWindowToggle()
  if len(bufname(s:title)) == 0
    call s:createDisplayWin()
  elseif bufwinnr(bufname(s:title)) == -1
    silent exec ':ba'
  else
    if bufname('%') != s:title
      silent exec 'wincmd w'
    endif
    close
  endif
endfunction

" 执行mysql命令并且返回结果
function! s:mysqlExec(sql, fmt)
  if len(a:sql) == 0
    return ''
  endif
  call s:parseConfig(0)
  let cmd = "mysql -h".g:kyo_sql_host." -P".g:kyo_sql_port
  let cmd .= " -u".g:kyo_sql_user." -p".g:kyo_sql_pwd." ".g:kyo_sql_db
  if a:fmt
    let cmd .= " -t "
  endif
  let cmd .= " <<< '".a:sql."'"
  return system(cmd)
endfunction

function! KyoCompleteDatabase(findstart, base)
  let list = split(s:mysqlExec('show databases', 0), '\n')
  return KyoComplete(a:findstart, a:base, list[1:])
endfunction

function! KyoCompleteTable(findstart, base)
  let list = split(s:mysqlExec('show tables', 0), '\n')
  return KyoComplete(a:findstart, a:base, list[1:])
endfunction

function! TriggerComplete(name)
  if a:name == 'table'
    setlocal completefunc=KyoCompleteTable
  elseif a:name == 'db'
    setlocal completefunc=KyoCompleteDatabase
  endif
  return "\<C-X>\<C-U>"
endfunction

" 运行mysql命令并且弹出选择框选择
function! ListData(cmd)
  let out = s:mysqlExec(a:cmd, 0)
  let list = split(out, '\n')
  call complete(col('.'), list[1:])
  return ''
endfunction

autocmd QuitPre *.sql exec ':wqall!'

nnoremap ,Q :call KyoMySQLWindowToggle()<CR><CR>

nnoremap ,sq :call KyoMySQLCmdView(0)<CR><CR>
vnoremap ,sq :call KyoMySQLCmdView(1)<CR><CR>
inoremap <C-R>m <ESC>:call KyoMySQLCmdView(0)<CR>i

nnoremap ,sc :call KyoMySQLGenConfig()<CR><CR>
ab kyomysql? <C-R>=KyoMySQLGenConfig()<CR>

nnoremap <F5> i<C-R>=TriggerComplete('db')<CR>
inoremap <F5> <C-R>=TriggerComplete('db')<CR>
nnoremap <F3> i<C-R>=TriggerComplete('table')<CR>
inoremap <F3> <C-R>=TriggerComplete('table')<CR>

ab S? SELECT FROM WHERE
ab U? UPDATE FROM WHERE
ab D? DELETE FROM WHERE
ab I? INSERT INTO () VALUES ()

let s:sql_if = "IF () THEN\n
\\n
\ELSEIF () THEN\n
\\n
\ELSE\n
\\n
\END IF"

let s:sql_case = "CASE \n
\WHEN THEN\n
\\n
\ELSE\n
\\n
\END CASE"

let s:sql_loop = "kyo: LOOP\n
\   IF 条件表达式 THEN\n
\       LEAVE kyo;\n
\   END IF;\n
\END LOOP kyo;"

let s:sql_repeat = "kyo: REPEAT\n
\\n
\UNTIL 条件表达式 END REPEAT kyo;"

let s:sql_while = "kyo: WHILE 条件表达式 DO\n
\\n
\END WHILE kyo;"

let s:sql_declare = "-- 定义fetch取数据的临时变量\n
\DECLARE cur_name VARCHAR(255);\n
\-- 定义游标结束标识符\n
\DECLARE done INT DEFAULT 0;\n
\-- 定义游标及对应的查询语句\n
\DECLARE o CURSOR for SELECT name FROM student;\n
\-- 定义异常处理, 发生02000异常将done置1(即Fetch语句引用游标位置为最后一行之后)\n
\DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;\n
\\n
\-- 打开游标\n
\OPEN o;\n
\\n
\-- 循环遍历游标对应的查询数据\n
\read_loop: LOOP\n
\    -- 获取游标当前位置数据, into后面对应游标查询语句的列名, 但不能与列名命名相同, 否则获取数据失败\n
\    FETCH o INTO cur_name;\n
\    -- 因为定义了异常处理, 游标位置到最后会将done置True, 为真则退出循环\n
\    IF done THEN\n
\        LEAVE read_loop;\n
\    END IF;\n
\    -- 对获取游标当前位置数据进行操作(insert update delete select)\n
\    SELECT cur_name;\n
\END LOOP;\n
\\n
\-- 关闭游标\n
\CLOSE o;"

let s:create = "CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name (\n
\   id INT PRIMARY KEY AUTO_INCREMENT,\n
\) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;"

let s:func = "DELIMITER $$\n
\CREATE FUNCTION func_name(a TINYINT) RETURNS VARCHAR(12)\n
\BEGIN\n
\\n
\END$$\n
\DELIMITER ;"

let s:procedure = "DELIMITER $$\n
\CREATE PROCEDURE pro_name(IN a INT(11), OUT b INT(11), INOUT c INT(11))\n
\BEGIN\n
\\n
\END$$\n
\DELIMITER ;"

let s:select = "SELECT\n
\    [ALL | DISTINCT | DISTINCTROW ]\n
\      [HIGH_PRIORITY]\n
\      [STRAIGHT_JOIN]\n
\    select_expr [, select_expr ...]\n
\    [FROM table_references\n
\    [WHERE where_condition]\n
\    [GROUP BY {col_name | expr | position}\n
\      [ASC | DESC], ... [WITH ROLLUP]]\n
\    [HAVING where_condition]\n
\    [ORDER BY {col_name | expr | position}\n
\      [ASC | DESC], ...]\n
\    [LIMIT {[offset,] row_count | row_count OFFSET offset}]"

function! KyoSQLAbbr(content)
  try
    let v = eval('s:'.a:content)
  catch /.*/
    return ''
  endtry
  call append(line('.'), split(v, '\n'))
  return ''
endfunction

ab select? <C-R>=KyoSQLAbbr('select')<CR>
ab create? <C-R>=KyoSQLAbbr('create')<CR>
ab func? <C-R>=KyoSQLAbbr('func')<CR>
ab proc? <C-R>=KyoSQLAbbr('procedure')<CR>
ab declare? <C-R>=KyoSQLAbbr('sql_declare')<CR>
ab if? <C-R>=KyoSQLAbbr('sql_if')<CR>
ab case? <C-R>=KyoSQLAbbr('sql_case')<CR>
ab while? <C-R>=KyoSQLAbbr('sql_while')<CR>
ab repeat? <C-R>=KyoSQLAbbr('sql_repeat')<CR>
ab loop? <C-R>=KyoSQLAbbr('sql_loop')<CR>

" vim:set sw=2:
