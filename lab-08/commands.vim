" Run real Vim commands without an interactive terminal, saving each stage.
set nocompatible
set noswapfile
execute "normal! isome text\<CR>more text\<CR>even more text\<Esc>"
write
write! /tmp/lab8/01-insert.txt
" Batch-mode commands otherwise share one undo block in this script.
let &undolevels = &undolevels

normal! ggjdd
write
write! /tmp/lab8/02-delete-line.txt

undo
write
write! /tmp/lab8/03-undo.txt

%s/text/line/g
write
write! /tmp/lab8/04-replace.txt

%d
write
write! /tmp/lab8/05-clear.txt

execute "normal! iFinal line\<Esc>"
wq
