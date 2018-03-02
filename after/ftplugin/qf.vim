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
    let l:entry = s:qflist[a:linenr - 1]
    pclose

    if l:entry.valid
        execute 'pedit +' . l:entry.lnum . ' ' . bufname(l:entry.bufnr)

        " Jump to preview window
        wincmd p
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

        " Define a new sign for highlighting the line
        sign define QuickrPreviewLine text=>> linehl=Search texthl=ErrorMsg
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
    let l:entry = s:qflist[a:linenr - 1]
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
    let s:qflist = getqflist()

    if len(s:qflist) == 0
        let s:qflist = getloclist(0)
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
