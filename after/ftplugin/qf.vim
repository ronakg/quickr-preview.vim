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

" GetValidEntry() {{
"
" This function returns a dictionary containing a valid qf/loc entry
" for the specified line number; where the line number is the current
" line in the qf/loc window. If no valid entry is found, then an empty
" dictionary is returned.
"
function! GetValidEntry(linenr)
    " Ensure this function is run within a qf/loc list
    if &filetype !=# 'qf'
        return {}
    endif
    " Ensure the cached qf/loc list is configured
    if !exists('b:qflen') || !exists('b:qflist')
        return {}
    endif
    " Ensure the entry exist within the qf/loc list
    if a:linenr > b:qflen
        return {}
    endif
    " Ensure the current entry is valid
    if !b:qflist[a:linenr-1].valid
        return {}
    endif
    " Ensure the file actually exists
    if !filereadable(bufname(b:qflist[a:linenr-1].bufnr))
        return {}
    endif
    " Return the valid entry
    return b:qflist[a:linenr-1]
endfunction
" }}

" QFList() {{
"
" Operate on an entry in quickfix list
"       linenr is current line number in the quickfix window
"
function! QFList(linenr)
    " Get the current entry and ensure it is valid
    let l:entry = GetValidEntry(a:linenr)
    if empty(l:entry)
        return
    endif
    " Close the preview window if the user has selected a same entry again
    if a:linenr == b:prvlinenr
        call ClosePreviewWindow()
        let b:prvlinenr = 0
        return
    endif
    let b:prvlinenr = a:linenr
    " Check if the buffer of interest is already opened in the preview window
    if GetPreviewWindow() && l:entry.bufnr == b:prvbufnr
        " Go to preview window
        set eventignore+=all
        wincmd P
        " Jump to the line of interest
        execute l:entry.lnum.' | normal! zz'
        " Highlight the line of interest
        execute 'match '.g:quickr_preview_line_hl.' /\%'.l:entry.lnum.'l^\s*\zs.\{-}\ze\s*$/'
        " Go back to qf/loc window
        wincmd p
        set eventignore-=all
    else
        " Note if the buffer of interest is already listed
        let l:alreadylisted = buflisted(l:entry.bufnr)
        " Open the buffer in the preview window and jump to the line of interest
        call OpenPreviewWindow(bufname(l:entry.bufnr), l:entry.lnum)
        " Go to preview window
        set eventignore+=all
        wincmd P
        " Settings for preview window
        setlocal number
        setlocal norelativenumber
        " Don't mark the buffer unlisted etc. if it existed before quickfix was populated
        if !l:alreadylisted
            setlocal nobuflisted        " don't list this buffer
            setlocal noswapfile         " don't create swap file for this buffer
            setlocal readonly           " make this buffer readonly
            setlocal nofoldenable       " disable folding
            setlocal bufhidden=delete   " clear out settings when buffer is hidden
        endif
        " Highlight the line of interest
        execute 'match '.g:quickr_preview_line_hl.' /\%'.l:entry.lnum.'l^\s*\zs.\{-}\ze\s*$/'
        " Go back to qf/loc window
        wincmd p
        set eventignore-=all
    endif
    let b:prvbufnr = l:entry.bufnr
endfunction
" }}

" HandleEnterQuickfix() {{
"
" When Enter is pressed close the preview window
"
function! HandleEnterQuickfix(linenr)
    " Get the current entry and ensure it is valid
    let l:entry = GetValidEntry(a:linenr)
    if empty(l:entry)
        return
    endif
    " Close the preview window
    call ClosePreviewWindow()
endfunction
" }}

" InitializeQuickrPreview() {{
"
" This function initializes the local (buffer) variables required
" by quickr-preview. This should be called each time a new qf/loc
" buffer is created.
"
function! InitializeQuickrPreview()
    " Initialize default values
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
endfunction
" }}

" Mappings {{
nnoremap <silent> <buffer> <plug>(quickr_preview) :call QFList(line("."))<CR>
if g:quickr_preview_keymaps
    nmap <leader><space> <plug>(quickr_preview)
endif
nnoremap <buffer> <cr> :call HandleEnterQuickfix(line("."))<CR><CR>
" }}

call InitializeQuickrPreview()

