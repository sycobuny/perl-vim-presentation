" ===== MISCELLANEOUS SETTINGS =====
" no backups or swap files
set nowb
set noswapfile

" we'll assume we like syntax highlighting until proven otherwise
syntax enable
hi NonText ctermfg=black

" give us a gutter to warn us of approaching boundaries, or highlight
" over-long lines, whichever this version of vim supports
set textwidth=78

hi Comment term=reverse ctermfg=2 ctermbg=3

au FileType *        set foldcolumn=0
au FileType markdown set foldcolumn=2

au FileType *        hi ColorColumn term=reverse ctermbg=1
au FileType *        hi FoldColumn  term=standout ctermfg=14 ctermbg=242
au FileType markdown hi ColorColumn ctermbg=black
au FileType markdown hi FoldColumn  ctermbg=black



" ===== SOME AWESOME PLUGINS =====
" required settings for vundle
set      nocompatible
filetype off
set      rtp+=~/.vim/bundle/vundle
call     vundle#rc(expand('<sfile>:h') . '/.vim/bundle')
" have vundle manage vundle
Bundle "gmarik/vundle"

" PLUGIN - vim-markdown
Bundle "tpope/vim-markdown"
let g:markdown_fenced_languages = ['pod', 'perl', 'vim']

" PLUGIN - Syntastic
Bundle "scrooloose/syntastic"

" PLUGIN - SyntaxRange
Bundle "SyntaxRange"
au FileType vim call SyntaxRange#Include(
            \     'perl <<', '.', 'perl'
            \   )
au FileType sql call SyntaxRange#Include(
            \     '  AS \$PERL\$', '  \$PERL\$;', 'perl'
            \   )

" PLUGIN - snipMate
Bundle "msanders/snipmate.vim"
au FileType snippet set noexpandtab
au FileType perl call ExtractSnipsFile(
            \      expand('<sfile>:h') . '/snippets', 'perl'
            \    )




" turn filetype detection back on
filetype plugin indent on

" map a command to switch syntax highlighting on and off easily, in case the
" screen we're demoing on isn't amenable to it.
function! ToggleHighlighting()
    if exists('g:syntax_on')
        syntax off
    else
        syntax enable
    endif
endfunction

if expand('<sfile>:h') ==# $HOME
    let mapleader = ';'

    nmap <Leader>TS :call ToggleHighlighting()<enter>
    imap <Leader>TS <Esc>:call ToggleHighlighting()<enter>a
    xmap <Leader>TS :call ToggleHighlighting()<enter>gv
    smap <Leader>TS <C-v>:call ToggleHighlighting()<enter>gv<C-g>
endif
