;; MouseWheelEmulator.ahk

/*

MouseWheelEmulator
Created by Blahman (blah238 at gmail dot com)
v1.0
10/18/2009

Summary: This script combines the functionality of TheGood's AHKHID and ManaUser's MakeChord libraries to provide emulated middle-click and scroll wheel abilities to users of mice, trackpads and trackballs without a scroll wheel.

Features:
-Allows middle clicks and mouse wheel scrolling to be performed on hardware without a physical scroll wheel
-Freezes the mouse cursor in place during virtual mouse wheel scrolling
-Sends scroll wheel messages to window or control under cursor, not just the active window (in supported applications; see note about different scroll modes below)

Installation:
1) Download the AHKHID and MakeChord libraries and place the AHKHID.ahk and MakeChord.ahk files in the same folder as this script.
AHKHID: http://www.autohotkey.com/forum/topic41397.html
MakeChord (just the second half that starts with the MakeChord() function): http://www.autohotkey.com/forum/topic44399.html
2) Run this script.

Usage:
By default there are two ways to activate a middle click or scroll the virtual mouse wheel:
To perform middle-click:
Click the left and right mouse buttons simultaneously (often referred to as "chording").
-or-
Hold Alt and right click.

To scroll the virtual mouse wheel:
Click and hold the left and right mouse buttons simultaneously and move the mouse in the direction you wish to scroll.
-or-
Hold Alt, click and hold the right mouse button, and move the mouse in the direction you wish to scroll.

Note: If you need to terminate the script you can use Ctrl-Alt-Break.

About the different scroll modes:
There are several different ways that any given program may implement mouse scrolling. AHK has built-in WheelUp and WheelDown functions, but not all applications respond to them.
Some applications respond to WM_VSCROLL/WM_HSCROLL messages, while others respond to WM_MOUSEWHEEL/WM_HSCROLL messages.
If you find an application you use doesn't work with this script out of the box, you can probably fix it yourself by adding that application's process name to the conditional statements in the GetScrollMode() function.
The default scroll mode, 0, is AHK's built-in WheelUp and WheelDown commands. This does not support horizontal scrolling or scrolling the window or control under the cursor, while the other two modes do.
Some applications respond to more than one scroll mode, so you can try them all and decide which works best for you.
Finally, to further muddy the waters, some applications have frames within them that respond to scroll messages differently to the rest of the application. An example of this is the AHK help file, which uses the Internet Explorer_Server1 control to display HTML pages in one frame, and standard Windows controls to display the table of contents, index, etc. in another frame, and each responds to different scroll modes. I have tried to account for this in the GetScrollMode() function as well, but there may be other implementations I have not covered. You can use AHK's Window Spy to determine the name of the non-conforming control and write an exception for it, similar to the examples I have provided.

*/

;; Configuration

mouse_Threshold = 3 ; the number of pixels the mouse must move for a scroll tick to occur
MakeChord("LButton", "RButton", "scrollChord", 20) ; Chord to activate middle click or scrolling. See MakeChord.ahk for instructions
scroll_Hotkey = !RButton ; Hotkey to activate middle click or scrolling

;; End Configuration

#SingleInstance Force
#NoEnv
#Persistent
SendMode Input
Process, Priority, , Realtime
#Include %A_ScriptDir%\AHKHID.ahk

;Create GUI to receive messages
Gui, +LastFound
hGui := WinExist()

;Intercept WM_INPUT messages
OnMessage(0x00FF, "InputMsg")

SetDefaultMouseSpeed, 0
scrollMode = 0 ; 0 = MouseClick, WheelUp/WheelDown, 1 = WM_VSCROLL/WM_HSCROLL, 2 = WM_MOUSEWHEEL/WM_HSCROLL
CoordMode, Mouse, Screen


HotKey, %scroll_Hotkey%, scrollChord
HotKey, %scroll_Hotkey% Up, scrollChord_Up
return

scrollChord:
mouse_Moved = n
BlockInput, MouseMove
MouseGetPos, m_x, m_y, winID, control
WinGet, procName, ProcessName, ahk_id %winID%
hw_m_target := DllCall( "WindowFromPoint", "int", m_x, "int", m_y )
GetScrollMode()
HID_Register(1, 2, hGui, RIDEV_INPUTSINK)
return

scrollChord_Up:
ToolTip
BlockInput, MouseMoveOff
HID_Register(1,2,0,RIDEV_REMOVE)
if mouse_Moved = n
    MouseClick, Middle
return

InputMsg(wParam, lParam) {
    local x, y
    Critical
    
    x := HID_GetInputInfo(lParam, II_MSE_LASTX)
    y := HID_GetInputInfo(lParam, II_MSE_LASTY)
    If ((Abs(x) > 0.0) or (Abs(y) > 0.0))
       mouse_Moved = y
    if y > %mouse_Threshold%
    {
        ScrollDown()
    }
    else if y < -%mouse_Threshold%
        ScrollUp()
    if x > %mouse_Threshold%
    {
        ScrollRight()
    }
    else if x < -%mouse_Threshold%
        ScrollLeft()
    ;ToolTip, % "dX = " . x . "  " . "dY = " . y . a_tab . winID . a_tab . control . a_tab . procName . a_tab . hw_m_target . a_tab . scrollMode
    ;; Uncomment the above line for handy debug info shown while scrolling
}

GetScrollMode()
{
    global
    local ctl_x, ctl_y, ctl_w, ctl_h, ctl_hwnd, win_x, win_y
    if (procName = "hh.exe" or procName = "iexplore.exe" or procName = "dexplore.exe" or procName = "OUTLOOK.EXE")
    {
        scrollMode = 1
        WinGetPos, win_x, win_y, , , ahk_id %WinID%
        ControlGetPos, ctl_x, ctl_y, ctl_w, ctl_h, Internet Explorer_Server1, ahk_id %WinID%
        if (((m_x >= win_x + ctl_x) and (m_x <= win_x + ctl_x + ctl_w)) and ((m_y >= win_y + ctl_y) and (m_y <= win_y + ctl_y + ctl_h)))
            control = Internet Explorer_Server1
        else
            {
                ControlGetPos, ctl_x, ctl_y, ctl_w, ctl_h, NETUIHWND1, ahk_id %WinID%
                if (((m_x >= win_x + ctl_x) and (m_x <= win_x + ctl_x + ctl_w)) and ((m_y >= win_y + ctl_y) and (m_y <= win_y + ctl_y + ctl_h)))
                    scrollMode = 2
            }
    }
    else if (procName = "firefox.exe" or procName = "notepad.exe" or procName = "explorer.exe" or procName = "EXCEL.exe")
        scrollMode = 2
    else
        scrollMode = 0
    return
}

ScrollDown()
{
    global
    if (scrollMode = 0)
        MouseClick, WheelDown
    else if (scrollMode = 1)
        PostMessage, 0x115, 1, 0, %control%, ahk_id %winID%
    else
    {
       ; WM_MOUSEWHEEL
       ;   WHEEL_DELTA = 120
       PostMessage, 0x20A, -120 << 16, ( m_y << 16 )|m_x,, ahk_id %hw_m_target%
    }
}

ScrollUp()
{
    global
    if (scrollMode = 0)
        MouseClick, WheelUp
    else if (scrollMode = 1)
    {
       PostMessage, 0x115, 0, 0, %control%, ahk_id %winID%
    }
    else if (scrollMode = 2)
    {
       ; WM_MOUSEWHEEL
       ;   WHEEL_DELTA = 120
       PostMessage, 0x20A, 120 << 16, ( m_y << 16 )|m_x,, ahk_id %hw_m_target%
    }
}

ScrollRight()
{
    global
    if (scrollMode <> 0)
        loop, 2
            SendMessage, 0x114, 1, 0, %control%, ahk_id %winID%
}

ScrollLeft()
{
    global
    if (scrollMode <> 0)
        loop, 2
            SendMessage, 0x114, 0, 0, %control%, ahk_id %winID%
}

^!CtrlBreak::ExitApp

#Include %A_ScriptDir%\MakeChord.ahk
