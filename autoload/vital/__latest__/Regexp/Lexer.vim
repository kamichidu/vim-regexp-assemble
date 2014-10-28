let s:save_cpo= &cpo
set cpo&vim

function! s:_vital_loaded(V)
endfunction

function! s:_vital_depends()
    return []
endfunction

let s:multi= join([
\   '\*',
\   '\\+',
\   '\\=',
\   '\\?',
\   '\\{\d\+,\d\+}',
\   '\\{\d\+}',
\   '\\{\d\+,}',
\   '\\{,\d\+}',
\   '\\{}',
\   '\\{-\d\+,\d\+}',
\   '\\{-\d\+}',
\   '\\{-\d\+,}',
\   '\\{-,\d\+}',
\   '\\{-}',
\   '\\@>',
\   '\\@=',
\   '\\@!',
\   '\\@<=',
\   '\\@<!',
\], '\|')
let s:atom= join([
\   '\^',
\   '\\^',
\   '\\_^',
\   '\$',
\   '\\$',
\   '\\_$',
\   '\.',
\   '\\_\.',
\   '\\<',
\   '\\>',
\   '\\zs',
\   '\\ze',
\   '\\%\^',
\   '\\%\$',
\   '\\%V',
\   '\\%#',
\   '\\%''m',
\   '\\%\d\+l',
\   '\\%\d\+c',
\   '\\%\d\+v',
\], '\|')
let s:char= join([
\   '\\\\',
\   '\\i',
\   '\\I',
\   '\\k',
\   '\\K',
\   '\\f',
\   '\\F',
\   '\\p',
\   '\\P',
\   '\\s',
\   '\\S',
\   '\\d',
\   '\\D',
\   '\\x',
\   '\\X',
\   '\\o',
\   '\\O',
\   '\\w',
\   '\\W',
\   '\\h',
\   '\\H',
\   '\\a',
\   '\\A',
\   '\\l',
\   '\\L',
\   '\\u',
\   '\\U',
\   '\\e',
\   '\\t',
\   '\\r',
\   '\\b',
\   '\\n',
\   '\~',
\   '\\[1-9]',
\   '\\z[1-9]',
\   '\[\%([^]]\|\\\@<=\]\)\+\]',
\   '\\%\[\%([^]]\|\\\@<=\]\)\+\]',
\   '\\[cC]',
\   '\\Z',
\   '\\[mM]',
\   '\\[vV]',
\   '\\%=[0-2]',
\   '\\%d\d\+',
\   '\\%x\x\+',
\   '\\%o\o\+',
\   '\\%u\x\+',
\   '\\%U\x\+',
\   '\\%C',
\   '\\|',
\   '\\%(',
\   '\\(',
\   '\\)',
\   '.',
\], '\|')
let s:default_lexer= '\%(' . s:atom . '\|' . s:char . '\)\%(' . s:multi . '\)\?'

function! s:tokenize(pattern)
    let lexer= '\m\C\%(' . s:default_lexer . '\)'
    let p= 0
    let path= []
    while 1
        let token= matchstr(a:pattern, lexer, p)
        let token_length= strlen(token)

        if empty(token)
            " not matched
            break
        elseif token =~# '\m\\%\?('
            " tokenize parentheses
            let nest= 0
            let next_token= token
            while 1
                let p+= strlen(next_token)
                let next_token= matchstr(a:pattern, lexer, p)
                if next_token =~# '\m\\)'
                    if nest == 0
                        let p+= strlen(next_token)
                        let token.= next_token
                        break
                    else
                        let nest-= 1
                    endif
                elseif next_token =~# '\m\\%\?('
                    let nest+= 1
                elseif empty(next_token)
                    throw 'vital: Regexp.Lexer: Detected unbalanced parentheses.'
                endif
                let token.= next_token
            endwhile
            let path+= [token]
        else
            " single token
            let p+= token_length
            let path+= [token]
        endif
    endwhile
    return path
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
