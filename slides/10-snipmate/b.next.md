
```vim
Bundle "msanders/snipmate.vim"
au FileType perl call ExtractSnipsFile(
            \      expand('<sfile>:h') . '/snippets', 'perl'
            \    )
```
