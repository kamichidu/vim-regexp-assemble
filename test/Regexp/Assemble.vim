let s:suite= themis#suite('Regexp.Assemble')
let s:assert= themis#helper('assert')

function! s:suite.before_each()
    let s:RA= vital#of('vital').import('Regexp.Assemble')
endfunction

function! s:suite.after_each()
    unlet! s:RA
endfunction

function! s:suite.makes_trie()
    let data_set= [
    \   {
    \       'pat': [],
    \       're':  '\m\C\%(\)',
    \   },
    \   {
    \       'pat': ['public', 'protected', 'private'],
    \       're': '\m\Cp\%(r\%(ivate\|otected\)\|ublic\)',
    \   },
    \   {
    \       'pat': ['foo', 'bar', 'baz'],
    \       're': '\m\C\%(ba[rz]\|foo\)',
    \   },
    \   {
    \       'pat': ['[abcd]', '\.', 'a*', '^~$'],
    \       're':  '\m\C\%([abcd]\|^~$\|a*\|\.\)',
    \   },
    \   {
    \       'pat': [10, 0],
    \       're':  '\m\C\%(10\?\)',
    \   },
    \   {
    \       'pat': [''],
    \       're':  '\m\C\%(\)',
    \   },
    \]

    for data in data_set
        let regexp= s:RA.new()

        for pat in data.pat
            call regexp.add(pat)
        endfor

        call s:assert.same(regexp.re(), data.re)
    endfor
endfunction
