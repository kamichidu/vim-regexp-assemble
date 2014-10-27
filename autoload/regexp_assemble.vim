let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('vital')
let s:S= s:V.import('Data.String')
unlet s:V

let s:always_fail= '\m^\>'

let s:rasm= {
\   '__patterns': [],
\}

function! s:rasm.add(...)
    if a:0 == 0
        return
    endif

    if a:0 == 1 && type(a:1) == type([])
        let patterns= a:1
    else
        let patterns= a:000
    endif

    let self.__patterns+= copy(patterns)
endfunction

function! s:rasm.add_file(filename)
    let self.__patterns+= readfile(a:filename)
endfunction

function! s:rasm.re()
    if empty(self.__patterns)
        return s:always_fail
    endif

    let trie= s:build_trie(self.__patterns)
    return s:assemble(trie)
endfunction

function! regexp_assemble#new()
    return deepcopy(s:rasm)
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
\   '\\_x',
\   '\\e',
\   '\\t',
\   '\\r',
\   '\\b',
\   '\\n',
\   '\~',
\   '\\[1-9]',
\   '\\z[1-9]',
\   '\[\%([^]]\|\\\@<=\]\)\]',
\   '\\|',
\   '\\%(',
\   '\\(',
\   '\\)',
\   '.',
\], '\|')
let s:default_lexer= '\%(' . s:atom . '\|' . s:char . '\)\%(' . s:multi . '\)\?'

function! regexp_assemble#lex(pattern)
    let lexer= '\m\C\%(' . s:default_lexer . '\)'
    let p= 0
    let path= []
    while 1
        let token= matchstr(a:pattern, lexer, p)
        let token_length= strlen(token)

        if empty(token)
            break
        elseif token =~# '\m\\%\?('
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
                endif
                let token.= next_token
            endwhile
            let path+= [token]
        else
            let p+= token_length
            let path+= [token]
        endif
    endwhile
    return path
endfunction

function! s:build_trie(texts, ...)
    let nested= get(a:000, 0, 0)
    let groups= s:split_by_common_head(a:texts)

    let trie= {
    \   'prefix': '',
    \   'is_leaf': empty(groups),
    \   'children': [],
    \}
    for group in groups
        if len(group) == 1
            let trie.children+= [{
            \   'prefix': group[0],
            \   'is_leaf': 1,
            \   'children': [],
            \}]
        else
            let prefix= s:S.common_head(group)
            let plen= strlen(prefix)

            let trie.children+= [{
            \   'prefix': prefix,
            \   'is_leaf': 0,
            \   'children': s:build_trie(map(copy(group), 'strpart(v:val, plen)'), 1),
            \}]
        endif
    endfor

    if nested
        return trie.children
    else
        return trie
    endif
endfunction

function! s:split_by_common_head(texts)
    if empty(a:texts)
        return []
    endif

    let texts= sort(copy(a:texts))

    let prefix= strpart(texts[0], 0, 1)
    let splitten= []
    let buffer= []
    for text in texts
        let c= strpart(text, 0, 1)
        if c ==# prefix
            let buffer+= [text]
        else
            let prefix= c
            let splitten+= [buffer]
            let buffer= [text]
        endif
    endfor
    let splitten+= [buffer]

    return splitten
endfunction

"
" trie
" ---
" prefix: '',
" is_leaf: 0,
" children:
"   - prefix: ''
"     is_leaf: 0
"     children: []
"
function! s:assemble(trie, ...)
    let nested= get(a:000, 0, 0)
    let pat= []

    if !nested
        let pat+= ['\m\C']
    endif

    if a:trie.is_leaf
        return a:trie.prefix
    endif

    let pat+= ['\%(']
    let alternatives= []
    for child in a:trie.children
        if child.is_leaf
            let alternatives+= [child.prefix]
        else
            let alternatives+= [child.prefix . s:assemble(child, 1)]
        endif
    endfor
    let pat+= [join(alternatives, '\|')]
    let pat+= ['\)']

    return join(pat, '')
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
