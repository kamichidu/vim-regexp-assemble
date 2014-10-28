let s:suite= themis#suite('Regexp.Lexer')
let s:assert= themis#helper('assert')
call themis#helper('command')

function! s:suite.before_each()
    let s:RL= vital#of('vital').import('Regexp.Lexer')
endfunction

function! s:suite.after_each()
    unlet! s:RL
endfunction

function! s:suite.__tokenize__()
    let tokenize_suite= themis#suite('tokenize')

    function! tokenize_suite.tokenize_some_patterns()
        let data_set= [
        \   {
        \       'pattern':   'hoge\b\%(hogehoge\)\|fuga',
        \       'tokenized': ['h', 'o', 'g', 'e', '\b', '\%(hogehoge\)', '\|', 'f', 'u', 'g', 'a'],
        \   },
        \   {
        \       'pattern':   '\%(hog\(eh\)oge\)',
        \       'tokenized': ['\%(hog\(eh\)oge\)'],
        \   },
        \   {
        \       'pattern':   '\(hogehoge\)',
        \       'tokenized': ['\(hogehoge\)'],
        \   },
        \   {
        \       'pattern':   '[abcd0-9]\+\w',
        \       'tokenized': ['[abcd0-9]\+', '\w'],
        \   },
        \   {
        \       'pattern':   '[^abcd0-9]\+\w',
        \       'tokenized': ['[^abcd0-9]\+', '\w'],
        \   },
        \   {
        \       'pattern':   'fun\%[ction]',
        \       'tokenized': ['f', 'u', 'n', '\%[ction]'],
        \   },
        \   {
        \       'pattern':   '\\\%(\w\+\|\d*\)',
        \       'tokenized': ['\\', '\%(\w\+\|\d*\)'],
        \   },
        \   {
        \       'pattern':   '^\w\+\|\d*$',
        \       'tokenized': ['^', '\w\+', '\|', '\d*', '$'],
        \   },
        \]

        for data in data_set
            call s:assert.equals(s:RL.tokenize(data.pattern), data.tokenized)
        endfor
    endfunction

    function! tokenize_suite.unbalanced_parentheses()
        let RL= s:RL
        Throws /^vital: Regexp\.Lexer:/ RL.tokenize('\%(hoge')
    endfunction
endfunction
