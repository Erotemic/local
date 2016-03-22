;===================================================================================================
;|||||||||||||||||||||||||||||| Middle Click to Close Window Code||||||||||||||||||||||||||||||||||||||||
;===================================================================================================

#NoEnv                           ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input                     ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%           ; Ensures a consistent starting directory.
#SingleInstance force

CoordMode, Mouse, Screen

GroupAdd, MS_Desktop, Program Manager ahk_class ProgMan
GroupAdd, MS_Desktop_TaskBar, ahk_group MS_Desktop

GroupAdd, MS_TaskBar, ahk_class Shell_TrayWnd
GroupAdd, MS_TaskBar, ahk_class UltraMonDeskTaskBar
GroupAdd, MS_Desktop_TaskBar, ahk_group MS_TaskBar

Return

; ================Close window with titlebar click============================
~MButton::


;  SetBatchLines, -1
;  CoordMode, Mouse, Screen
;  SetMouseDelay, -1 ; no pause after mouse clicks
;  SetKeyDelay, -1 ; no pause after keys sent
;  MouseGetPos, ClickX, ClickY, WindowUnderMouseID
;  WinActivate, ahk_id %WindowUnderMouseID%
;
;  ; WM_NCHITTEST
;  SendMessage, 0x84,, ( ClickY << 16 )|ClickX,, ahk_id %WindowUnderMouseID%
;  WM_NCHITTEST_Result =%ErrorLevel%
;
;; Title Bar click closes in below lines
;  If WM_NCHITTEST_Result in 2,3,8,9,20,21 ; in titlebar enclosed area - top of window
;    {
;    PostMessage, 0x112, 0xF060,,, ahk_id %WindowUnderMouseID% ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
;    }
;


;||||||||||||||||||||||||||||||||||||||||||Task Bar |||||||||||||||||||||||||||||||||||||||||||||||||||||


MouseGetPos, , , idWindow, , 2
WinGetClass, cWindow, ahk_id %idWindow%

If cWindow In Shell_TrayWnd,UltraMonDeskTaskBar
   {
   WinActivate, ahk_group MS_Desktop
   ;WinWaitActive, ahk_group MS_Desktop
   Click
   WinWaitNotActive, ahk_group MS_Desktop, , 0.3                              ;To avoid minimizing the Win
   If ErrorLevel = 0
   IfWinNotActive, ahk_group MS_Desktop_TaskBar                              ;check that neither MS_Desktop_TaskBar is active
      {
      WinActiveID := WinActive("A")
                                                                  ;GET Z ORDER NOW TO CHECK WIN DIDNT POP UP IF CLOSED
      If AltTabWinArray("AllwaysOnTop") Contains %WinActiveID%                  ;Not AllwaysOnTop
         {
         ;WinClose, ahk_id %WinActiveID%
         PostMessage, 0x112, 0xF060,,, ahk_id %WinActiveID%                     ;May Do it Faster
         
         WinWaitClose, ahk_id %WinActiveID%, , 0.3
         If ErrorLevel
            WinActivate, ahk_id %WinActiveID%                              ;DID not Close Probably needs to Save etc
         }
      Return
      }
   }


;||||||||||||||||||||||Double Click Middle Mouse to close window||||||||||||||||||||||||||||||||

;If (A_PriorHotkey != A_ThisHotkey OR A_TimeSincePriorHotkey > 150)
;      Return
;Sleep 250
;   WinClose A
;Return
return

;|||||||||||||||||||||Functions ||||||||||||||||||||||||||||||||


AltTabWinArray(Include="NotExcluded",Exclude="Hidden Disable AllwaysOnTop TaskBar Desktop ChildWin NoTitle Custom1",Options="",Alert="")
{
Global                                                      ;VARS TO BE SEEN OUTSIDE THIS FUNCTION
WS_EX_CONTROLPARENT =0x10000
WS_EX_APPWINDOW =0x40000
WS_EX_TOOLWINDOW =0x80
WS_DISABLED =0x8000000
WS_POPUP =0x80000000

;Blank VARS
AltTab_Win_Count = 0
AltTab_Win_ID_List =

Loop
   {
   Sleep -1
   If    AltTab_Win_ID_%A_Index% =
      Break
   AltTab_Win_ID_%A_Index% =
   AltTab_Win_Class_%A_Index% =
   AltTab_Win_Title_%A_Index% =
   }

Prev_DetectHiddenWin := A_DetectHiddenWindows                        ;SAVE CUURENT STATUS

If Include not Contains Hidden
   DetectHiddenWindows, Off
Else
   DetectHiddenWindows, On

WinGet, Window_List, List                                       ; Gather a list of Visible or Not Visible running programs

Loop, %Window_List%
   {
   wid := Window_List%A_Index%
   
   If Include not Contains Disable
      {
      WinGet, Style, Style, ahk_id %wid%
      If (Style & WS_DISABLED)
         Continue
      }
   
   If Include not Contains AllwaysOnTop
      {
      WinGet, ExStyle, ExStyle, ahk_id %wid%
      If (ExStyle & 0x8)                                          ; skip Allways on top wins
         Continue
      }

   WinGetTitle, wid_Title, ahk_id %wid%
   
   If Include not Contains ChildWin
      {
      Parent := Decimal_to_Hex( DllCall( "GetParent", "uint", wid ) )
      WinGetClass, Win_Class, ahk_id %wid%
      
      If Exclude Contains TaskBar
      If Win_Class = ProgMan
      If wid_Title = Program Manager
         Continue

      If Exclude Contains Desktop
      If Win_Class = Shell_TrayWnd
      If wid_Title =
         Continue
      
      WinGet, Style_parent, Style, ahk_id %Parent%

      If ((ExStyle & WS_EX_TOOLWINDOW)
         or ((ExStyle & ws_ex_controlparent) and ! (Style & WS_POPUP) and !(Win_Class ="#32770") and ! (ExStyle & WS_EX_APPWINDOW))       ; pspad child window excluded
         or ((Style & WS_POPUP) and (Parent) and ((Style_parent & WS_DISABLED) =0)))                                        ; notepad find window excluded ; note - some windows result in blank value so must test for zero instead of using NOT operator!
         continue
      }
   
   If Include not Contains NoTitle
   If (! (wid_Title))                                           ; skip unimportant windows ; ! wid_Title or Disabled
      {
      If Win_Class <> Shell_TrayWnd                              ;TASKBAR WAS EXCLUDED BEFORE
         Continue
      }
    
   ;ADD WINS TITLES AND CLASSES TO EXCLUDE
   If Include not Contains Custom1
      {
      If (wid_Title = "Norton 360") && (Win_Class = "SymHTMLDialog")
         Continue
      }
   
;   If (wid_Title = "TITLE_TO_EXCLUDE") && (Win_Class = "CLASS_TO_EXCLUDE")
;      Continue
    
                                             ;ADD CURRENT WINDOW TO LIST
   AltTab_Win_Count ++
   AltTab_Win_ID_%AltTab_Win_Count% := wid
   AltTab_Win_Class_%AltTab_Win_Count% := Win_Class
   AltTab_Win_Title_%AltTab_Win_Count% := wid_Title
   
   If AltTab_Win_ID_List =
      AltTab_Win_ID_List = %wid%
   Else
      AltTab_Win_ID_List = %AltTab_Win_ID_List%,%wid%

   ;FOR TESTING
   ;      If TXT =                                                ;FOR TESTING
   ;         TXT = %wid% - %Win_Class% - %wid_Title%                        ;FOR TESTING
   ;      Else                                                   ;FOR TESTING
   ;         TXT = %TXT%`n%wid% - %Win_Class% - %wid_Title%                  ;FOR TESTING
   }
   
;ToolTip, % AltTab_Win_Count " Alt-Tab Windows `n" TXT                  ;FOR TESTING
;TXT =                                                       ;FOR TESTING

                                                   ;Restore Status
If Prev_DetectHiddenWin in On,Off
   DetectHiddenWindows, %Prev_DetectHiddenWin%

Return AltTab_Win_ID_List
}
   
Decimal_to_Hex(var)            ;USED TO GET PARENT WIN
{
SetFormat, integer, hex
var += 0
SetFormat, integer, d
Return var
}

