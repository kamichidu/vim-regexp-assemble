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
    \   {
    \       'pat': ['[abcd]', '\.', 'a*', '^~$'],
    \       're':  '\m\C\%(\[abcd]\|\\\.\|\^\~\$\|a\*\)',
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

function! s:suite.makes_ignorecase_trie()
    let regexp= s:RT.new()

    call regexp.ignorecase(1)

    call regexp.add('insert')
    call regexp.add('select')

    call s:assert.equals(regexp.re(), '\m\c\%(insert\|select\)')
endfunction

function! s:suite.__makes_trie_with_anchor__()
    let anchor_suite= themis#suite('makes trie with')

    function! anchor_suite.anchor_word()
        let regexp= s:RT.new()

        call regexp.anchor_word(1)

        call regexp.add('hoge')

        call s:assert.equals(regexp.re(), '\m\C\<hoge\>')
    endfunction

    function! anchor_suite.anchor_word_begin()
        let regexp= s:RT.new()

        call regexp.anchor_word_begin(1)

        call regexp.add('hoge')

        call s:assert.equals(regexp.re(), '\m\C\<hoge')
    endfunction

    function! anchor_suite.anchor_word_end()
        let regexp= s:RT.new()

        call regexp.anchor_word_end(1)

        call regexp.add('hoge')

        call s:assert.equals(regexp.re(), '\m\Choge\>')
    endfunction

    function! anchor_suite.anchor_line()
        let regexp= s:RT.new()

        call regexp.anchor_line(1)

        call regexp.add('hoge')

        call s:assert.equals(regexp.re(), '\m\C^hoge$')
    endfunction

    function! anchor_suite.anchor_line_begin()
        let regexp= s:RT.new()

        call regexp.anchor_line_begin(1)

        call regexp.add('hoge')

        call s:assert.equals(regexp.re(), '\m\C^hoge')
    endfunction

    function! anchor_suite.anchor_line_end()
        let regexp= s:RT.new()

        call regexp.anchor_line_end(1)

        call regexp.add('hoge')

        call s:assert.equals(regexp.re(), '\m\Choge$')
    endfunction
endfunction
