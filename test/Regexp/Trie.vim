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

function! s:suite.makes_a_clone_of_itself()
    let orig= s:RT.new()

    call orig.add('hoge')

    let clone= orig.clone()

    call s:assert.equals(clone.re(), orig.re())

    call orig.anchor_word_begin(1)

    call s:assert.not_equals(clone.anchor_word_begin(), orig.anchor_word_begin())

    call s:assert.equals(orig.re(), '\m\C\<hoge')
    call s:assert.equals(clone.re(), '\m\Choge')
endfunction

function! s:suite.__add_func__()
    let add_func_suite= themis#suite('can add patterns by')

    function! add_func_suite.variadic_strings()
        let regexp= s:RT.new()

        call regexp.add('foo', 'bar', 'baz')

        call s:assert.equals(regexp.re(), '\m\C\%(ba[rz]\|foo\)')
    endfunction

    function! add_func_suite.list()
        let regexp= s:RT.new()

        call regexp.add(['foo', 'bar', 'baz'])

        call s:assert.equals(regexp.re(), '\m\C\%(ba[rz]\|foo\)')
    endfunction
endfunction

function! s:suite.__constructs_with_options__()
    let constructs_with_options_suite= themis#suite('can constructs with option')

    function! constructs_with_options_suite.anchor_word()
        let regexp= s:RT.new({
        \   'anchor_word': 1,
        \})

        call s:assert.true(regexp.anchor_word())
    endfunction

    function! constructs_with_options_suite.anchor_word_begin()
        let regexp= s:RT.new({
        \   'anchor_word_begin': 1,
        \})

        call s:assert.true(regexp.anchor_word_begin())
    endfunction

    function! constructs_with_options_suite.anchor_word_end()
        let regexp= s:RT.new({
        \   'anchor_word_end': 1,
        \})

        call s:assert.true(regexp.anchor_word_end())
    endfunction

    function! constructs_with_options_suite.anchor_line()
        let regexp= s:RT.new({
        \   'anchor_line': 1,
        \})

        call s:assert.true(regexp.anchor_line())
    endfunction

    function! constructs_with_options_suite.anchor_line_begin()
        let regexp= s:RT.new({
        \   'anchor_line_begin': 1,
        \})

        call s:assert.true(regexp.anchor_line_begin())
    endfunction

    function! constructs_with_options_suite.anchor_line_end()
        let regexp= s:RT.new({
        \   'anchor_line_end': 1,
        \})

        call s:assert.true(regexp.anchor_line_end())
    endfunction

    function! constructs_with_options_suite.ignorecase()
        let regexp= s:RT.new({
        \   'ignorecase': 1,
        \})

        call s:assert.true(regexp.ignorecase())
    endfunction

    function! constructs_with_options_suite.invalid_option()
        let regexp= s:RT.new({
        \   'Ignorecase': 1,
        \})

        call s:assert.false(regexp.ignorecase())
    endfunction
endfunction

function! s:suite.makes_trie_from_file()
    let regexp= s:RT.new()

    call regexp.add_file('./test/Regexp/keywords.txt')

    call s:assert.equals(regexp.re(), '\m\C\%(ba[rz]\|foo\)')
endfunction
