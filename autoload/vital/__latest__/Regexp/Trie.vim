let s:save_cpo= &cpo
set cpo&vim

function! s:_vital_loaded(V)
endfunction

function! s:_vital_depends()
    return []
endfunction

" XXX: Be careful, this pattern must not be a regex pattern
let s:terminal_key= '__terminal__'

let s:object= {
\   '__trie': {},
\   '__ignorecase': 0,
\   '__anchor_word_begin': 0,
\   '__anchor_word_end': 0,
\   '__anchor_line_begin': 0,
\   '__anchor_line_end': 0,
\}

function! s:new(...)
    let opts= deepcopy(get(a:000, 0, {}))
    let object= deepcopy(s:object)

    for opt in keys(opts)
        if has_key(object, opt) && type(object[opt]) == type(function('tr'))
            call object[opt](opts[opt])
        endif
    endfor

    return object
endfunction

function! s:object.add(...)
    if a:0 == 0
        throw 'vital: Regexp.Trie: Arguments are required'
    endif

    if type(a:1) == type([])
        let patterns= a:1
    else
        let patterns= a:000
    endif

    for pattern in patterns
        call self._add(pattern)
    endfor
    return self
endfunction

function! s:object.add_file(filename)
    if !filereadable(a:filename)
        throw printf("vital: Regexp.Trie: No such file `%s'", a:filename)
    endif

    for pattern in readfile(a:filename)
        call self.add(pattern)
    endfor
    return self
endfunction

function! s:object.ignorecase(...)
    if a:0 == 0
        return self.__ignorecase
    else
        let self.__ignorecase= a:1
        if has_key(self, '__re') | unlet self.__re | endif
    endif
    return self
endfunction

function! s:object.anchor_word(...)
    if a:0 == 0
        return self.anchor_word_begin() && self.anchor_word_end()
    else
        call self.anchor_word_begin(a:1)
        call self.anchor_word_end(a:1)
    endif
    return self
endfunction

function! s:object.anchor_word_begin(...)
    if a:0 == 0
        return self.__anchor_word_begin
    else
        let self.__anchor_word_begin= a:1
        if has_key(self, '__re') | unlet self.__re | endif
    endif
    return self
endfunction

function! s:object.anchor_word_end(...)
    if a:0 == 0
        return self.__anchor_word_end
    else
        let self.__anchor_word_end= a:1
        if has_key(self, '__re') | unlet self.__re | endif
    endif
    return self
endfunction

function! s:object.anchor_line(...)
    if a:0 == 0
        return self.anchor_line_begin() && self.anchor_line_end()
    else
        call self.anchor_line_begin(a:1)
        call self.anchor_line_end(a:1)
        if has_key(self, '__re') | unlet self.__re | endif
    endif
    return self
endfunction

function! s:object.anchor_line_begin(...)
    if a:0 == 0
        return self.__anchor_line_begin
    else
        let self.__anchor_line_begin= a:1
        if has_key(self, '__re') | unlet self.__re | endif
    endif
    return self
endfunction

function! s:object.anchor_line_end(...)
    if a:0 == 0
        return self.__anchor_line_end
    else
        let self.__anchor_line_end= a:1
        if has_key(self, '__re') | unlet self.__re | endif
    endif
    return self
endfunction

function! s:object.re()
    if has_key(self, '__re')
        return self.__re
    endif

    let self.__re= join([
    \   '\m',
    \   (self.ignorecase() ? '\c' : '\C'),
    \   (self.anchor_line_begin() ? '^' : ''),
    \   (self.anchor_word_begin() ? '\<' : ''),
    \   s:_regexp(self.__trie, 1),
    \   (self.anchor_word_end() ? '\>' : ''),
    \   (self.anchor_line_end() ? '$' : ''),
    \], '')
    return self.__re
endfunction

function! s:object.clone()
    return deepcopy(self)
endfunction

function! s:object._add(pattern)
    let ref= self.__trie
    for char in split(a:pattern, '\zs')
        if !has_key(ref, char)
            let ref[char]= {}
        endif
        let ref= ref[char]
    endfor
    " XXX: `ref' never contains this key
    let ref[s:terminal_key]= 1
    if has_key(self, '__re') | unlet self.__re | endif
endfunction

function! s:_regexp(trie, ...)
    let wanted_empty_regexp= get(a:000, 0, 0)

    if get(a:trie, s:terminal_key, 0) && len(keys(a:trie)) == 1
        return wanted_empty_regexp ? '\%(\)' : 0
    endif

    let [alt, cc]= [[], []]
    let q= 0
    for char in sort(keys(a:trie))
        " escape regex character when 'magic'
        let qchar= escape(char, '.\$^~*[')
        if type(a:trie[char]) == type({})
            let recurse= s:_regexp(a:trie[char])
            if type(recurse) == type('')
                let alt+= [qchar . recurse]
            else
                let cc+= [qchar]
            endif
        else
            let q= 1
        endif
    endfor

    let cconly= empty(alt)
    if !empty(cc)
        if len(cc) == 1
            let alt+= [cc[0]]
        else
            let alt+= ['[' . join(cc, '') . ']']
        endif
    endif
    if len(alt) == 1
        let result= alt[0]
    else
        let result= '\%(' . join(alt, '\|') . '\)'
    endif
    if q
        if cconly
            let result.= '\?'
        else
            let result= '\%(' . result . '\)\?'
        endif
    endif
    return result
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
