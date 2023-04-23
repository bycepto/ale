" Author: bycepto - https://github.com/bycepto

function! ale_linters#elixir#gradient#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " lib/filename.ex:106: Undefined remote type Module.t/0
    " let l:patterns = ['\v(.+):(\d+): (.+)$', '\v.+$']
    let l:patterns = ['\v(.+):(\d+): (.+)$']
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:patterns)
        " if len(l:match) == 1 && !empty(l:output)
        "     let l:output[-1].detail .= "\n\n" . l:match[0]
        "
        "     continue
        " endif

        let l:fpath = l:match[1]

        " HACK: check if the error is found in a file that in a subpath of the
        " current buffer. At minimum this should be a right substring match.

        if stridx(bufname(a:buffer), l:fpath) >= 0
            let l:num = l:match[2]
            let l:text = l:match[3]

            call add(l:output, {
            \   'bufnr': a:buffer,
            \   'lnum': l:num,
            \   'col': 0,
            \   'type': 'E',
            \   'text': l:text,
            \   'detail': l:text,
            \})
        endif
    endfor

    return l:output
endfunction

function! ale_linters#elixir#gradient#GetCommand(buffer) abort
    return 'mix help gradient && '
    \ . 'mix gradient --no-fancy --no-colors --fmt-location brief'
endfunction

call ale#linter#Define('elixir', {
\   'name': 'gradient',
\   'executable': 'mix',
\   'cwd': function('ale#handlers#elixir#FindMixUmbrellaRoot'),
\   'command': function('ale_linters#elixir#gradient#GetCommand'),
\   'callback': 'ale_linters#elixir#gradient#Handle',
\})
