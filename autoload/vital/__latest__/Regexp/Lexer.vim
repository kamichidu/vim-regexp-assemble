let s:save_cpo= &cpo
set cpo&vim

function! s:_vital_loaded(V)
endfunction

function! s:_vital_depends()
    return []
endfunction

"
" lexer member function
"
function! s:next_token() dict
    " (atom | char) multi?
    while self.__c !=# ''
        if self.__c ==# '\'
            call self.consume()
            if self.__c ==# '+'
                return {'type': 'multi', 'text': '\+'}
            elseif self.__c ==# '='
                return {'type': 'multi', 'text': '\='}
            elseif self.__c ==# '?'
                return {'type': 'multi', 'text': '\?'}
            elseif self.__c ==# '{'
                call self.consume()
                if self.__c =~# '^\d$'
                elseif self.__c ==# ','
                elseif self.__c ==# '-'
                    call self.consume()
                    if self.__c ==# '^\d$'
                        call self.consume()
                    elseif self.__c ==# ','
                        " \{-,m}
                        return self.ZERO_TO_M()
                    elseif self.__c ==# '}'
                        return {'type': 'multi', 'text': '\{-}'}
                    else
                        throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
                    endif
                elseif self.__c ==# '}'
                    return {'type': 'multi', 'text': '\{}'}
                else
                    throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
                endif
            elseif self.__c ==# '@'
                call self.consume()
                if self.__c ==# '>'
                    " \@>
                    " TODO
                elseif self.__c ==# '='
                    " \@=
                    " TODO
                elseif self.__c ==# '!'
                    " \@!
                    " TODO
                elseif self.__c ==# '<'
                    call self.consume()
                    if self.__c ==# '='
                        " \@<=
                        " TODO
                    elseif self.__c ==# '!'
                        " \@<!
                        " TODO
                    else
                        throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
                    endif
                else
                    throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
                endif
            elseif self.__c ==# '^'
                return {'type': 'char', 'text': '\^'}
            elseif self.__c ==# '_'
            elseif self.__c ==# '$'
                return {'type': 'char', 'text': '\$'}
            elseif self.__c ==# '<'
                return {'type': 'char', 'text': '\<'}
            elseif self.__c ==# '>'
                return {'type': 'char', 'text': '\>'}
            elseif self.__c ==# 'z'
                call self.consume()
                if self.__c ==# 's'
                    " \zs
                    return {'type': 'char', 'text': '\zs'}
                elseif self.__c ==# 'e'
                    " \ze
                    return {'type': 'char', 'text': '\ze'}
                elseif self.__c =~# '^[1-9]$'
                    " \z1
                    return {'type': 'char', 'text': '\z' . self.__c}
                else
                    throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
                endif
            elseif self.__c ==# '%'
                call self.consume()
                if self.__c ==# '^'
                elseif self.__c ==# '$'
                elseif self.__c ==# 'V'
                elseif self.__c ==# '#'
                    " \%# or \%#=1
                elseif self.__c ==# "'"
                    " \%'m mark
                elseif self.__c =~# '^\d$'
                    " \%23l or \%23c or \%23v
                elseif self.__c ==# '['
                else
                    throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
                endif
            elseif self.__c =~# '^[iIkKfFpPsSdDxXoOwWhHaAlLuU]$'
                return {'type': 'char', 'text': '\' . self.__c}
            elseif self.__c =~# '^[etrbn]$'
                return {'type': 'char', 'text': '\' . self.__c}
            elseif self.__c =~# '^[1-9]$'
                return {'type': 'char', 'text': '\' . self.__c}
            elseif self.__c =~# '^[cCZmMvV]$'
                return {'type': 'char', 'text': '\' . self.__c}
            elseif self.__c ==# '\'
                return {'type': 'char', 'text': '\\'}
            else
                throw printf("Regexp.Lexer: Illegal character `%s'", self.__c)
            endif
        elseif self.__c ==# '*'
            return {'type': 'multi', 'text': '*'}
        elseif self.__c ==# '^'
            return {'type': 'multi', 'text': '*'}
        elseif self.__c ==# '$'
            return {'type': 'multi', 'text': '*'}
        elseif self.__c ==# '.'
            return {'type': 'multi', 'text': '*'}
        elseif self.__c ==# '~'
            return {'type': 'atom', 'text': '~'}
        elseif self.__c ==# '['
            " TODO
        else
            return {'type': 'char', 'text': self.__c}
        endif
    endwhile
    return {'type': 'eof', 'text': ''}
endfunction

function! s:consume() dict
    let self.__p+= 1
    if self.__p >= len(self.__input)
        let self.__c= s:EOF
    else
        let self.__c= self.__input[self.__p]
    endif
endfunction

function! s:token_name(x) dict
    " TODO
endfunction

function! s:match(x) dict
    if self.__c ==# a:x
        call self.consume()
    else
        throw printf("Regexp.Lexer: Expecting `%s' found `%s'.", a:x, self.__c)
    endif
endfunction

let s:lexer= {
\   'next_token': function('s:next_token'),
\   'consume': function('s:consume'),
\   'token_name': function('s:token_name'),
\   'match': function('s:match'),
\}

function! s:new(pattern)
    let lexer= deepcopy(s:lexer)
endfunction

" token
" ---
" type: number
" text: string

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

    if a:pattern =~# '\\%#=[0-2]'
        let path+= [matchstr(a:pattern, '\\%#=[0-2]')]
        let p+= 5
    endif

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
