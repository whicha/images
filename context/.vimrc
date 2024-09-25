" 
" 编辑
"
" 使用 utf-8 编码 
set encoding=utf-8
" 打开语法高亮
syntax on
" 在底部显示，当前处于命令模式还是插入模式  
set showmode
" 命令模式下，在底部显示，当前键入的指令
set showcmd
" 按下回车键后，下一行的缩进会自动跟上一行的缩进保持一致
set autoindent
" 按下 Tab 键时，Vim 显示的空格数
set tabstop=2
" 由于 Tab 键在不同的编辑器缩进不一致，该设置自动将 Tab 转为空格
set expandtab
" Tab 转为多少个空格
set softtabstop=2
" 在文本上按下>>（增加一级缩进）、<<（取消一级缩进）或者==（取消全部缩进）时，每一级的字符数
set shiftwidth=2
"
" 外观
"
" 显示行号
set number
" 显示光标所在的当前行的行号，其他行都为相对于该行的相对行号
set relativenumber
" 光标所在的当前行高亮
set cursorline
" 自动折行，即太长的行分成几行显示
set wrap
" 只有遇到指定的符号（比如空格、连词号和其他标点符号），才发生折行。也就是说，不会在单词内部折行
set linebreak
" 指定折行处与编辑窗口的右边缘之间空出的字符数
set wrapmargin=2
"
" 搜索
"
" 光标遇到圆括号、方括号、大括号时，自动高亮对应的另一个圆括号、方括号和大括号
set showmatch
" 搜索时，高亮显示匹配结果
set hlsearch
" 输入搜索模式时，每输入一个字符，就自动跳到第一个匹配的结果
set incsearch
" 搜索时忽略大小写
set ignorecase
