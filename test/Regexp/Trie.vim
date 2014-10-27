let s:suite= themis#suite('Regexp.Trie')
let s:assert= themis#helper('assert')

function! s:suite.before_each()
    let s:RT= vital#of('vital').import('Regexp.Trie')
endfunction

function! s:suite.after_each()
    unlet! s:RT
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
    \]

    for data in data_set
        let regexp= s:RT.new()

        for pat in data.pat
            call regexp.add(pat)
        endfor

        call s:assert.equals(regexp.re(), data.re)
    endfor
endfunction
