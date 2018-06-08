" quick-preview.vim:  Quickly preview quickfix results without opening files
" Maintainer:         Ronak Gandhi <https://github.com/ronakg>
" Version:            1.0
" Website:            https://github.com/ronakg/quickr-preview.vim

" OpenPreviewWindow() {{
"
" This function opens the specified buffer within the preview window
" while ensuring that the preview window maintains the correct size
" and position.
"
function! OpenPreviewWindow(bufname, linenr)
    let l:size = (g:quickr_preview_position =~? '\(left\|right\)') ? winwidth(0)/2 : (&lines-winheight(0))/2
    let l:orig_preview_height = &previewheight
    execute 'set previewheight='.l:size
    execute g:quickr_preview_pedit_cmd.' +'.a:linenr.' '.a:bufname
    execute 'set previewheight='.l:orig_preview_height
endfunction
" }}

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

" GetPreviewWindow() {{
"
" This function will return the window ID of the preview window;
" if no preview window is currently open it will return zero.
"
function! GetPreviewWindow()
    for l:winnr in range(1, winnr('$'))
        if getwinvar(l:winnr, '&previewwindow')
            return l:winnr
        endif
    endfor
    return 0
endfunction
" }}

" QFList() {{
"
" Operate on an entry in quickfix list
"       linenr is current line number in the quickfix window
"
function! QFList(linenr)
    " Ensure the qf/loc list is not empty
    if b:qflen == 0
        return
    endif
    " Clear out any previous highlighting
    execute 'sign unplace 26'
    " Close the preview window if the user has selected a same entry again
    if a:linenr == b:prvlinenr
        call ClosePreviewWindow()
        let b:prvlinenr = 0
        return
    endif
    let b:prvlinenr = a:linenr
    " Ensure the current entry is valid
    let l:entry = b:qflist[a:linenr - 1]
    if !l:entry.valid
        return
    endif
    " Check if the buffer of interest is already opened in the preview window
    if GetPreviewWindow() && l:entry.bufnr == b:prvbufnr
        " Go to preview window
        set eventignore+=all
        wincmd P
        " Jump to the line of interest
        execute l:entry.lnum.' | normal! zz'
        " Highlight the line of interest
        execute 'sign place 26 name=QuickrPreviewLine line=' . l:entry.lnum . ' buffer=' . l:entry.bufnr
        " Go back to qf/loc window
        wincmd p
        set eventignore-=all
    else
        " Open the buffer in the preview window and jump to the line of interest
        call OpenPreviewWindow(bufname(l:entry.bufnr), l:entry.lnum)
        " Go to preview window
        set eventignore+=all
        wincmd P
        " Settings for preview window
        setlocal number
        setlocal norelativenumber
        " Don't mark the buffer unlisted etc. if it existed before quickfix was populated
        if index(s:buflist, l:entry.bufnr) == -1
            setlocal nobuflisted        " don't list this buffer
            setlocal noswapfile         " don't create swap file for this buffer
            setlocal readonly           " make this buffer readonly
            setlocal nofoldenable       " disable folding
        endif
        " Highlight the line of interest
        execute 'sign place 26 name=QuickrPreviewLine line=' . l:entry.lnum . ' buffer=' . l:entry.bufnr
        " Go back to qf/loc window
        wincmd p
        set eventignore-=all
    endif
    let b:prvbufnr = l:entry.bufnr
endfunction
" }}

" HandleEnterQuickfix() {{
"
" When Enter is pressed, add the result buffer to s:buflist
" and close the preview window
function! HandleEnterQuickfix(linenr)
    " Ensure the qf/loc list is not empty
    if b:qflen == 0
        return
    endif
    let l:entry = b:qflist[a:linenr - 1]
    " Close the preview window
    call ClosePreviewWindow()
    " Clear out any previous highlighting
    execute 'sign unplace 26'
    " Check whether buffer is already open outside the preview window, if
    " not then delete it to clear out all local settings (i.e. noswapfile)
    if index(s:buflist, l:entry.bufnr) == -1 && bufexists(l:entry.bufnr)
        execute 'silent! bd '.l:entry.bufnr
    endif
    " Add the buffer to the list of 'already opened' buffers
    call add(s:buflist, l:entry.bufnr)
endfunction
" }}

" GenerateBufferList() {{
"
" Generate list of buffers
" Append already listed buffer to s:buflist
"
function! GenerateBufferList()
    " Initialize default values
    let s:buflist = []
    let b:prvlinenr = 0
    let b:prvbufnr = 0
    " Grab the location list
    let b:qflist = getloclist(0)
    let b:qflen = len(b:qflist)
    " If the location list is empty, then grab the qiuckfix list
    if b:qflen == 0
        let b:qflist = getqflist()
        let b:qflen = len(b:qflist)
    endif
    " Create a list of 'already opened' buffers
    for l:bufnum in range(1, bufnr('$'))
        if buflisted(l:bufnum)
            call add(s:buflist, l:bufnum)
        endif
    endfor
endfunction
" }}

" Mappings {{
nnoremap <silent> <buffer> <plug>(quickr_preview) :call QFList(line("."))<CR>
if g:quickr_preview_keymaps
    nmap <leader><space> <plug>(quickr_preview)
endif
nnoremap <buffer> <cr> :call HandleEnterQuickfix(line("."))<CR><CR>
" }}

call GenerateBufferList()
