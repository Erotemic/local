" for loops and a few of the autocmd events don't exist in previous versions
if v:version < 700
  finish
endif

sign define EvenL linehl=EvenLbg

func! s:ColorAltLines()
  if exists('b:ALTLINES_disable') || exists('g:ALTLINES_disable')
    return
  elseif &buftype=="" && (!exists('b:ALTLINES_changedtick') || b:ALTLINES_changedtick != b:changedtick) && line('$') > 1
    let l:range = (exists('b:ALTLINES_quick') ? max([line('.')-100+line('.')%2, 2]).','.min([line('.')+100,line('$')]) : '2,'.line('$'))
    let l:starttime = localtime()
    if exists('b:ALTLINES_changedtick') " don't unplace signs if they've never been placed
      for id in eval('range('.l:range.',2)')
        exec 'sign unplace '.id.' buffer='.bufnr('%')
        if localtime()-l:starttime >= 10
          " force quick update next time and quit, it's taking way to long
          let b:ALTLINES_quick = 1
          return
        endif
      endfor
    endif
    let l:pos_sav = getpos('.')
    keepjumps exec l:range.'g#^#if line(".")%2==0 && localtime() - l:starttime < 16 | exec "sign place ".line(".")." line=".line(".")." name=EvenL buffer=".bufnr("%") | endif'
    call setpos('.',l:pos_sav)
    nohls
    if localtime() - l:starttime > 4
      let b:ALTLINES_quick = 1
    endif
    let b:ALTLINES_changedtick = b:changedtick
  endif
endfun

augroup ALT_LINES
  au!
  autocmd BufWinEnter,InsertLeave,CursorHold,CursorHoldI * call s:ColorAltLines()
augroup END
