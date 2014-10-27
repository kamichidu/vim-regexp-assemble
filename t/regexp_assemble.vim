let s:suite= themis#suite('regexp_assemble')
let s:assert= themis#helper('assert')

function! s:suite.before_each()
    let s:rasm= regexp_assemble#new()
endfunction

function! s:suite.after_each()
    unlet! s:rasm
endfunction

function! s:suite.never_matches()
    call s:assert.equals(s:rasm.re(), '\m^\>')
endfunction

function! s:suite.__constants__()
    let constants_suite= themis#suite('constants')

    function! constants_suite.makes_trie()
        call s:rasm.add('public')
        call s:rasm.add('protected')
        call s:rasm.add('private')

        call s:assert.equals(s:rasm.re(), '\m\C\%(p\%(r\%(ivate\|otected\)\|ublic\)\)')
    endfunction

    function! constants_suite.makes_trie2()
        call s:rasm.add(range(0, 25))

        call s:assert.equals(s:rasm.re(), '\m\C\%(1\%(0\d\?\|1\d\?\|2\d\?\|3\d\?\|4\d\?\|5\d\?\|6\d\?\|7\d\?\|8\d\?\|9\d\?\)\?\|2\%([6789]\|5[012345]\?\|0\d\?\|1\d\?\|2\d\?\|3\d\?\|4\d\?\)\?\|3\d\?\|4\d\?\|5\d\?\|6\d\?\|7\d\?\|8\d\?\|9\d\?\|0\)')
    endfunction

    function! constants_suite.test()
        call s:rasm.add(range(-30, 30))
        let pattern= s:rasm.re()
        call s:assert.equals(filter(range(-300, 300), 'v:val =~# "^" . pattern . "$"'), range(-30, 30))
    endfunction
endfunction

function! s:suite.__lexer__()
    let lexer_suite= themis#suite('lexer')

    function! lexer_suite.lexes_constants()
        let pattern= 'hoge\b\%(hogehoge\)\|fuga'
        let expected= ['h', 'o', 'g', 'e', '\b', '\%(hogehoge\)', '\|', 'f', 'u', 'g', 'a']
        call s:assert.equals(regexp_assemble#lex(pattern), expected)
    endfunction

    function! lexer_suite.lexes_nested_parentheses()
        let pattern= '\%(hog\(eh\)oge\)'
        let expected= ['\%(hog\(eh\)oge\)']
        call s:assert.equals(regexp_assemble#lex(pattern), expected)
    endfunction

    function! lexer_suite.lexes_parenthese()
        let pattern= '\(hogehoge\)'
        let expected= ['\(hogehoge\)']
        call s:assert.equals(regexp_assemble#lex(pattern), expected)
    endfunction
endfunction
