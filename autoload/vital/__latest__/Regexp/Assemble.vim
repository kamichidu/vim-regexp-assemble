let s:save_cpo= &cpo
set cpo&vim

function! s:_vital_loaded(V)
    let s:RL= a:V.import('Regexp.Lexer')
    let s:L= a:V.import('Data.List')
endfunction

function! s:_vital_depends()
    return ['Regexp.Lexer', 'Data.List']
endfunction

let s:terminal_key= '__terminal__'

let s:object= {
\   '__path': [],
\}

function! s:new()
    return deepcopy(s:object)
endfunction

function! s:object.add(...)
    if a:0 == 0
        throw 'vital: Regexp.Assemble: Arguments are required'
    endif

    if type(a:1) == type([])
        let patterns= a:1
    else
        let patterns= a:000
    endif

    for pattern in patterns
        let self.__path= s:_add(self, self.__path, s:RL.tokenize(pattern))
    endfor
    return self
endfunction

function! s:object.re()
    if has_key(self, '__re')
        return self.__re
    endif

    " let self.__re= join([
    " \   '\m',
    " \   (self.ignorecase() ? '\c' : '\C'),
    " \   (self.anchor_line_begin() ? '^' : ''),
    " \   (self.anchor_word_begin() ? '\<' : ''),
    " \   s:_regexp(self.__trie, 1),
    " \   (self.anchor_word_end() ? '\>' : ''),
    " \   (self.anchor_line_end() ? '$' : ''),
    " \], '')
    let self.__re= join([
    \   '\m',
    \   '\C',
    \   s:_regexp(self.__path, 1),
    \], '')
    return self.__re
endfunction

function! s:_add(self, path, tokens)
    if has_key(a:self, '__re') | unlet a:self.__re | endif
    let tokens= copy(a:tokens)

    " at first time
    if empty(a:path)
        if empty(tokens) || (len(tokens) == 1 && tokens[0] ==# '')
            let node= {}
            let node[s:terminal_key]= 1
            return [node]
        else
            return tokens
        endif
    endif
    if empty(tokens)
        if type(a:path[0]) != type({})
            let node= {}
            let node[s:terminal_key]= 1
            let node[a:path[0]]= a:path
            return [node]
        else
            let node= a:path[0]
            let node[s:terminal_key]= 1
            return a:path
        endif
    endif

    let path= a:path
    let offset= 0
    while !empty(tokens)
        let token= s:L.shift(tokens)

        if type(token) == type({})
            let path= a:self._insert_node(path, offset, token, tokens)
            break
        endif
        if type(path[offset]) == type({})
            let node= path[offset]
            if has_key(node, token)
                if offset < len(path) - 1
                    let new= {}
                    let new[token]= [token] + tokens
                    let new[a:self._re_path(a:self, [node])]= path[offset : (len(path) - 1)]
                    let path= s:_splice(path, offset, len(path) - offset, new)
                    break
                else
                    let path= node[token]
                    let offset= 0
                    continue
                endif
            else
                if offset == len(path) - 1
                    let node[token]= [token] + tokens
                else
                    let new= {}
                    let new[a:self._node_key(token)]= [token] + tokens
                    let new[a:self._node_key(node)]= path[offset : (len(path) - 1)]
                    let path= s:_splice(path, offset, len(path) - offset, new)
                endif
                break
            endif
        endif

        if offset >= len(path)
            let node= {}
            let node[token]= [token] + tokens
            let node[s:terminal_key]= 1
            call s:L.push(path, node)
            break
        elseif token !=# path[offset]
            let node= {}
            if token !=# ''
                let node[a:self._node_key()]= [token] + tokens
            else
                let node[s:terminal_key]= 1
            endif
            let path= s:_splice(path, offset, len(path) - offset, node)
            break
        elseif !empty(tokens)
            if offset + 1 < len(path)
                let offset+= 1
                if type(path[offset]) == type({})
                    let node= {}
                    let node[s:terminal_key]= 1
                    let path[offset]= node
                else
                    let node= {}
                    let node[path[offset]]= path[offset : (len(path) - 1)]
                    let node[s:terminal_key]= 1
                    let path= s:_splice(path, offset, len(path) - offset, node)
                endif
            endif
            break
        endif
        let offset+= 1
    endwhile

    return path
endfunction

function! s:_splice(list, from, to, val)
    let [left, right]= [a:list[ : a:from], a:list[a:to : ]]
    return left + [a:val] + right
endfunction

function! s:_regexp(path, ...)
    let wanted_empty_regexp= get(a:000, 0, 0)

    if get(a:path, s:terminal_key, 0) && len(keys(a:path)) == 1
        return wanted_empty_regexp ? '\%(\)' : 0
    endif

    let [alt, cc]= [[], []]
    let q= 0
    for char in sort(keys(a:path))
        " escape regex character when 'magic'
        let qchar= char
        if type(a:path[char]) == type({})
            let recurse= s:_regexp(a:path[char])
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
