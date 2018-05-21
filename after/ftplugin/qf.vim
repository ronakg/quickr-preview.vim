" quick-preview.vim:  Quickly preview quickfix results without opening files
" Maintainer:         Ronak Gandhi <https://github.com/ronakg>
" Version:            1.0
" Website:            https://github.com/ronakg/quickr-preview.vim

" QFList() {{
"
" Operate on an entry in quickfix list
"       linenr is current line number in the quickfix window
"
function! QFList(linenr)
    if b:qflen == 0
        return
    endif

    pclose

    if a:linenr == b:prvlinenr
        let b:prvlinenr = 0
        return
    endif

    let b:prvlinenr = a:linenr
    let l:entry = b:qflist[a:linenr - 1]

    if l:entry.valid
        let position = g:quickr_preview_position

        let axis = position == 'left' || position == 'right' ? 'vsplit' : 'split'
        let side = position == 'below' || position == 'right' ? 'belowright' : 'aboveleft'

        execute side . ' ' . axis . ' +' . l:entry.lnum . ' ' . bufname(l:entry.bufnr)

        " Settings for preview window
        setlocal previewwindow
        setlocal number
        setlocal norelativenumber

        " Don't mark the buffer unlisted etc. if it existed before quickfix
        " was populated
        if index(s:buflist, l:entry.bufnr) == -1
            setlocal nobuflisted        " don't list this buffer
            setlocal noswapfile         " don't create swap file for this buffer
            setlocal readonly           " make this buffer readonly
            setlocal nofoldenable       " disable folding
        endif

        " Highlight the current line
        execute 'sign unplace 26'
        execute 'sign place 26 name=QuickrPreviewLine line=' . l:entry.lnum . ' buffer=' . l:entry.bufnr

        " Go back to quickfix window
        wincmd p
    endif
endfunction
" }}

" HandleEnterQuickfix() {{
"
" When Enter is pressed, add the result buffer to s:buflist
" and close the preview window
function! HandleEnterQuickfix(linenr)
    if b:qflen == 0
        return
    endif

    let l:entry = b:qflist[a:linenr - 1]
    call add(s:buflist, l:entry.bufnr)
    pclose
endfunction
" }}

" GenerateBufferList() {{
"
" Generate list of buffers
" Append already listed buffer to s:buflist
"
function! GenerateBufferList()
    let s:buflist = []
    let b:prvlinenr = 0
    let b:qflist = getloclist(0)
    let b:qflen = len(b:qflist)

    if b:qflen == 0
        let b:qflist = getqflist()
        let b:qflen = len(b:qflist)
    endif

    for bufnum in range(1, bufnr('$'))
        if buflisted(bufnum)
            call add(s:buflist, bufnum)
        endif
    endfor
endfunction
" }}

" Options {{
if !exists("g:quickr_preview_keymaps")
    let g:quickr_preview_keymaps = 1
endif

" Setup <plug> {{
nnoremap <silent> <buffer> <plug>(quickr_preview) :call QFList(line("."))<CR>
" }}

" Default key maps {{
if g:quickr_preview_keymaps
    nmap <leader><space> <plug>(quickr_preview)
endif

nnoremap <buffer> <cr> :call HandleEnterQuickfix(line("."))<CR><CR>
" }}

call GenerateBufferList()
