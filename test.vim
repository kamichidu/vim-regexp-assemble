let s:bench= benchmark#new('checking speed')
let s:nums= range(-10000, 10000)

let s:trivial_pattern= '^' . join(range(0, 255), '\|') . '$'

let s:rasm= regexp_assemble#new()

call s:rasm.add(range(0, 255))

let s:assemble_pattern= s:rasm.re()

function! s:bench.trivial()
    call filter(copy(s:nums), 'v:val =~# s:trivial_pattern')
endfunction

function! s:bench.assemble()
    call filter(copy(s:nums), 'v:val =~# s:assemble_pattern')
endfunction

call s:bench.run()
