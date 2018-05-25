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
    " Ensure the qf/loc list is not empty
    if b:qflen == 0
        return
    endif
    " Close the preview window
    call ClosePreviewWindow()
    " Clear out any previous highlighting
    execute 'sign unplace 26'
    " Nothing else to do if the user has selected a same entry again
    if a:linenr == b:prvlinenr
        let b:prvlinenr = 0
        return
    endif
    let b:prvlinenr = a:linenr
    " Ensure the current entry is valid
    let l:entry = b:qflist[a:linenr - 1]
    if l:entry.valid
        " Determine if the preview window should open in a vertical/horizontal split
        let l:position = g:quickr_preview_position
        let l:axis = l:position ==? 'left' || l:position ==? 'right' ? 'vsplit' : 'split'
        let l:side = l:position ==? 'below' || l:position ==? 'right' ? 'belowright' : 'aboveleft'
        " Open the buffer in the preview window and jump to the line of interest
        execute l:side . ' ' . l:axis . ' +' . l:entry.lnum . ' ' . bufname(l:entry.bufnr)
        " Settings for preview window
        setlocal previewwindow
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
