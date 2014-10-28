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
\}

function! s:new()
    return deepcopy(s:object)
endfunction

function! s:object.add(pattern)
    let ref= self.__trie
    for char in split(a:pattern, '\zs')
        if !has_key(ref, char)
            let ref[char]= {}
        endif
        let ref= ref[char]
    endfor
    " XXX: `ref' never contains this key
    let ref[s:terminal_key]= 1
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

function! s:object.re()
    return '\m\C' . s:_regexp(self.__trie)
endfunction

function! s:_regexp(trie)
    if get(a:trie, s:terminal_key, 0) && len(keys(a:trie)) == 1
        return 0
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
