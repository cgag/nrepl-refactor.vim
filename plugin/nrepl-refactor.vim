nnoremap <silent> <Plug>UnthreadLast  :<C-U>set opfunc=<SID>unthread_last<CR>g@
xnoremap <silent> <Plug>UnthreadLast  :<C-U>call <SID>unthread_last(visualmode())<CR>

nnoremap <silent> <Plug>ThreadFirst   :<C-U>set opfunc=<SID>thread_first<CR>g@
xnoremap <silent> <Plug>ThreadFirst   :<C-U>call <SID>thread_first(visualmode())<CR>

nnoremap <silent> <Plug>ThreadLast   :<C-U>set opfunc=<SID>thread_last<CR>g@
xnoremap <silent> <Plug>ThreadLast   :<C-U>call <SID>thread_last(visualmode())<CR>

nnoremap <silent> <Plug>CyclePrivacy   :<C-U>set opfunc=<SID>cycle_privacy<CR>g@
xnoremap <silent> <Plug>CyclePrivacy   :<C-U>call <SID>cycle_privacy(visualmode())<CR>

nnoremap <silent> <Plug>CycleCollection   :<C-U>set opfunc=<SID>cycle_collection<CR>g@
xnoremap <silent> <Plug>CycleCollection   :<C-U>call <SID>cycle_collection(visualmode())<CR>

nnoremap <silent> <Plug>CycleStrKeyword   :<C-U>set opfunc=<SID>cycle_str_keyword<CR>g@
xnoremap <silent> <Plug>CycleStrKeyword   :<C-U>call <SID>cycle_str_keyword(visualmode())<CR>

nmap cru <Plug>UnthreadLast
nmap cruu <Plug>UnthreadLastab

nmap crf <Plug>ThreadFirst
nmap crff <Plug>ThreadFirstab

nmap  crl <Plug>ThreadLast
nmap  crll <Plug>ThreadLastab

nmap  crp <Plug>CyclePrivacy
nmap  crpp <Plug>CyclePrivacyab

nmap  crc <Plug>CycleCollection
nmap  crcc <Plug>CycleCollectionab 

nmap  crk  <Plug>CycleStrKeyword
nmap  crkk <Plug>CycleStrKeywordab



"nmap <buffer> crt <Plug>Thread
"nmap <buffer> crtt <Plug>FireplaceThreadab

function! s:refactor(type, refactor)
  let expr = s:opfunc(a:type)
  let newexpr = fireplace#message({"op": "nrepl.refactor",
        \ "refactor": a:refactor,
        \ "code": expr})[0].value
  return s:replace(expr, newexpr)
endfunction

function! s:unthread_last(type)
  return s:refactor(a:type, "unthread-last")
endfunction

function! s:thread_first(type)
  return s:refactor(a:type, "thread-first")
endfunction

function! s:thread_last(type)
  return s:refactor(a:type, "thread-last")
endfunction

function! s:cycle_privacy(type)
  return s:refactor(a:type, "cycle-privacy")
endfunction

function! s:cycle_collection(type)
  return s:refactor(a:type, "cycle-collection-type")
endfunction

function! s:cycle_str_keyword(type)
  return s:refactor(a:type, "cycle-str-keyword")
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
