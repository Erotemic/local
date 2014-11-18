;----------------------------------------
; Hold Caps Lock to Scroll with Trackball

;CoordMode, Mouse, Screen

;*CapsLock:: 
    ;MouseGetPos, xposinit, yposinit
    ;xposlast := xposinit
    ;yposlast := yposinit

    ;;SystemCursor("Off")

    ;SetTimer, ButtonHold, 10
    ;KeyWait, CapsLock
    ;SetTimer, ButtonHold, off

    ;MouseMove, xposinit, yposinit, 0
    ;;SystemCursor("On")

    ;Return

    ;ButtonHold:
        ;MouseGetPos, xpos, ypos

        ;if (ypos > yposlast) {
            ;MouseClick, WheelDown
        ;} else if (ypos < yposlast) {
            ;MouseClick, WheelUp
        ;}

        ;MouseMove, xposlast, yposlast, 0
;;*RButton:: 



;    MouseGetPos, xposinit, yposinit
;    xposlast := xposinit
;    yposlast := yposinit
;
;    ;SystemCursor("Off")
;
;    SetTimer, ButtonHold, 10
;    KeyWait, RButton
;    SetTimer, ButtonHold, off
;
;    MouseMove, xposinit, yposinit, 0
;    ;SystemCursor("On")
;
;    Return
;
;    ButtonHold:
;        MouseGetPos, xpos, ypos
;
;        if (ypos > yposlast) {
;            MouseClick, WheelDown
;        } else if (ypos < yposlast) {
;            MouseClick, WheelUp
;        }
;
;        MouseMove, xposlast, yposlast, 0
;;----------------------------------------
