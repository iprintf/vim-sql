# Kyo-Vim-SQL

    本插件功能是将mysql命令封装到vim编辑器中执行并分割窗口简单展示结果
    本插件只针对*.sql文件有效

### 安装

    本插件依赖mysql命令, 请自行安装

    如果使用插件管理器(vundle), 在vimrc增加以下配置

        Plugin 'iprintf/vim-sql'

    如果没有使用插件管理器(将本项目文件复制至vim对应目录)

        cp ftplugin/sql.vim ~/.vim/ftplugin/

### 配置

    本插件目前没有太多配置变量, 主要是mysql连接配置, 都有默认值, 根据环境设置
    将以下配置写入自己的.vimrc文件中

        配置远程MySQL服务器地址(默认配置为127.0.0.1)

            let g:kyo_sql_host = '127.0.0.1'

        配置远程MySQL服务器连接用户(默认配置为root)

            let g:kyo_sql_user = 'root'

        配置远程MySQL服务器连接密码(默认配置为123456)

            let g:kyo_sql_pwd = '123456'

        配置远程MySQL服务器连接端口(默认配置为3306)

            let g:kyo_sql_port = 3306

        配置远程MySQL服务器连接数据库(默认配置为mysql)

            let g:kyo_sql_db = 'mysql'

        配置执行SQL语句保存文件的路径(默认配置为临时文件)

            let g:kyo_sql_run_file = tempname()

        配置结果显示窗口开启追加模式(默认配置为0 关闭)

            let g:kyo_sql_append = 0

        配置打开空sql文档是否自动生成模板(默认配置为0 关闭)

            let g:kyo_sql_auto_template = 0

    本插件快捷键配置写死在插件文件中, 如果有需求可看代码自行配置

    vimrc文件的配置为全局配置, 每个sql文件可独立设置私有配置, 会覆盖全局配置

### 使用

    简单使用

        使用vim打开一个sql文件, 直接编写SQL代码, 在普通模式下输入`,sq`即可看到效果

    具体使用

        普通模式下输入

            ,Q      开/关结果展示窗口

            ,sq     执行sql文档所有SQL代码并且将结果显示在展示窗口

            ,sc     生成独立的私有配置模板

            ,st     生成计算执行时间代码

            F3      自动补全连接数据库的表名

            F5      自动补全连接服务器的数据库名

        可视模式下输入

            ,sq     执行文档所选中的SQL代码并且将结果显示在展示窗口

        编辑模式下输入

            ctrl + r m  执行文档所有SQL代码并且将结果显示在展示窗口

            kyomysql?   生成独立的私有配置模板

            kyotime?    生成计算执行时间代码

            F3      自动补全连接数据库的表名

            F5      自动补全连接服务器的数据库名

            S?      自动补全简单select关键词

            U?      自动补全简单update关键词

            D?      自动补全简单delete关键词

            I?      自动补全简单insert关键词

            select? 自动补全select语句语法模板

            create? 自动补全createt table语句语法模板

            还有些类似补全, 可自行测试, 语法并未所有补全, 后续继续会增加完善

