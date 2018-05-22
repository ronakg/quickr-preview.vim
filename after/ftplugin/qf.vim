" quick-preview.vim:  Quickly preview quickfix results without opening files
" Maintainer:         Ronak Gandhi <https://github.com/ronakg>
" Version:            1.0
" Website:            https://github.com/ronakg/quickr-preview.vim

" ClosePreviewWindow() {{
"
" This function closes the preview window while ensuring that the
" quickfix/location window maintain the correct size. This should
" be called while in the quickfix/location window.
"
function! ClosePreviewWindow()
    let l:orig_win_height = winheight(0)
    pclose
    execute 'resize' l:orig_win_height
endfunction
" }}

" QFList() {{
"
" Operate on an entry in quickfix list
"       linenr is current line number in the quickfix window
"
function! QFList(linenr)
    if b:qflen == 0
        return
    endif

    call ClosePreviewWindow()

    " Clear out any previous highlighting
    execute 'sign unplace 26'

    if a:linenr == b:prvlinenr
        let b:prvlinenr = 0
        return
    endif

    let b:prvlinenr = a:linenr
    let l:entry = b:qflist[a:linenr - 1]

    if l:entry.valid
        let l:position = g:quickr_preview_position

        let l:axis = l:position ==? 'left' || l:position ==? 'right' ? 'vsplit' : 'split'
        let l:side = l:position ==? 'below' || l:position ==? 'right' ? 'belowright' : 'aboveleft'

        execute l:side . ' ' . l:axis . ' +' . l:entry.lnum . ' ' . bufname(l:entry.bufnr)

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
    call ClosePreviewWindow()

    " Clear out any previous highlighting
    execute 'sign unplace 26'

    " Check whether buffer is already open outside the preview window, if
    " not then delete it to clear out all local settings (i.e. noswapfile)
    if index(s:buflist, l:entry.bufnr) == -1 && bufexists(l:entry.bufnr)
        execute 'silent! bd '.l:entry.bufnr
    endif

    call add(s:buflist, l:entry.bufnr)
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

    for l:bufnum in range(1, bufnr('$'))
        if buflisted(l:bufnum)
            call add(s:buflist, l:bufnum)
        endif
    endfor
endfunction
" }}

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
