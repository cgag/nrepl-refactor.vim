nnoremap <silent> <Plug>UnthreadLast  :<C-U>set opfunc=<SID>unthread_last<CR>g@
xnoremap <silent> <Plug>UnthreadLast  :<C-U>call <SID>unthread_last(visualmode())<CR>
nnoremap <silent> <Plug>ThreadFirst   :<C-U>set opfunc=<SID>thread_first<CR>g@
xnoremap <silent> <Plug>ThreadFirst   :<C-U>call <SID>thread_first(visualmode())<CR>

nmap <buffer> cru <Plug>UnthreadLast
nmap <buffer> cruu <Plug>UnthreadLastab

function! s:refactor(type, op)
  let expr = s:opfunc(a:type)
  let newexpr = fireplace#message({"op": a:op, "code": expr})[0].value
  return s:replace(expr, newexpr)
endfunction

function! s:unthread_last(type)
  return s:refactor(a:type, "refactor.unthread-last")
endfunction

function! s:thread_first(type)
  return s:refactor(a:type, "refactor.thread-first")
endfunction

" direct rip from saint tpope's fireplace
function! s:opfunc(type) abort                                                  
  let sel_save = &selection                                                     
  let cb_save = &clipboard                                                      
  let reg_save = @@                                                             
  try                                                                           
    set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus           
    if a:type =~# '^.$'                                                         
      silent exe "normal! `<" . a:type . "`>y"                                  
    elseif a:type ==# 'line'                                                    
      silent exe "normal! '[V']y"                                               
    elseif a:type ==# 'block'                                                   
      silent exe "normal! `[\<C-V>`]y"                                          
    elseif a:type ==# 'outer'                                                   
      call searchpair('(','',')', 'Wbcr', g:fireplace#skip)                     
      silent exe "normal! vaby"                                                 
    else                                                                        
      silent exe "normal! `[v`]y"                                               
    endif                                                                       
    redraw                                                                      
    return @@                                                                   
  finally                                                                       
    let @@ = reg_save                                                           
    let &selection = sel_save                                                   
    let &clipboard = cb_save                                                    
  endtry                                                                        
endfunction

" basically ripped from ctford's fireplace refactoring PR
" https://github.com/tpope/vim-fireplace/pull/80
function! s:replace(expr, newexpr) abort
  let reg_save = @@
  try
    let @@ = matchstr(a:expr, '^\n\+').a:newexpr.matchstr(a:expr, '\n\+$')
    if @@ !~# '^\n*$'
      normal! gvp
    endif
  catch /^Clojure:/
    return ''
  finally
    let @@ = reg_save
  endtry
endfunction
