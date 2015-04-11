" configure various preliminary settings
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" manage plugins by naming them each here,
" starting with Vundle itself
Plugin 'gmarik/Vundle.vim'
Plugin 'another/plugin'
" view plugin specifications on GitHub

" post-plugin cleanup
call vundle#end()
filetype plugin indent on
