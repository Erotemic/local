; ; - comment
; # - window key
; ^ - control key
; ! - alt key


; Sending keystrokes and mouse clicks
; Send enter any text here or press buttons like {Enter} or {tab} or pase like this ^v


; Autoreplace
; ::btw::by the way
;Msgbox, Do you really want to reload this script?

{F1} - {F24}	Function keys. For example: {F12} is the F12 key.
{!}	!
{#}	#
{+}	+
{^}	^
{{}	{
{}}	}
{Enter}	ENTER key on the main keyboard
{Escape} or {Esc}	ESCAPE
{Space}	SPACE (this is only needed for spaces that appear either at the beginning or the end of the string to be sent -- ones in the middle can be literal spaces)
{Tab}	TAB
{Backspace} or {BS}	Backspace
{Delete} or {Del}	Delete
{Insert} or {Ins}	Insert
{Up}	Up-arrow key on main keyboard
{Down}	Down-arrow down key on main keyboard
{Left}	Left-arrow key on main keyboard
{Right}	Right-arrow key on main keyboard
{Home}	Home key on main keyboard
{End}	End key on main keyboard
{PgUp}	Page-up key on main keyboard
{PgDn}	Page-down key on main keyboard
 	 
{CapsLock}	CapsLock (using SetCapsLockState is more reliable on NT/2k/XP). Sending {CapsLock} might require SetStoreCapslockMode Off beforehand.
{ScrollLock}	ScrollLock (see also: SetScrollLockState)
{NumLock}	NumLock (see also: SetNumLockState)
 	 
{Control} or {Ctrl}	CONTROL (technical info: sends the neutral virtual key but the left scan code)
{LControl} or {LCtrl}	Left CONTROL key (technical info: same as CONTROL for Win9x, but on NT/2k/XP it sends the left virtual key rather than the neutral one)
{RControl} or {RCtrl}	Right CONTROL key
{Control Down} or {Ctrl Down}	Holds the CONTROL key down until {Ctrl Up} is sent. XP/2000/NT: To hold down the left or right key instead, use {RCtrl Down} and {RCtrl Up}.
 	 
{Alt}	ALT (technical info: sends the neutral virtual key but the left scan code)
{LAlt}	Left ALT key (technical info: same as ALT for Win9x, but on NT/2k/XP it sends the left virtual key rather than the neutral one)
{RAlt}	Right ALT key (or AltGr, depending on keyboard layout)
{Alt Down}	Holds the ALT key down until {Alt Up} is sent. XP/2000/NT: To hold down the left or right key instead, use {RAlt Down} and {RAlt Up}.
 	 
{Shift}	 SHIFT (technical info: sends the neutral virtual key but the left scan code)
{LShift}	Left SHIFT key (technical info: same as SHIFT for Win9x, but on NT/2k/XP it sends the left virtual key rather than the neutral one)
{RShift}	Right SHIFT key
{Shift Down}	Holds the SHIFT key down until {Shift Up} is sent. XP/2000/NT: To hold down the left or right key instead, use {RShift Down} and {RShift Up}.
 	 
{LWin}	Left Windows key
{RWin}	Right Windows key
{LWin Down}	Holds the left Windows key down until {LWin Up} is sent
{RWin Down}	Holds the right Windows key down until {RWin Up} is sent
 	 
{AppsKey}	Windows App key (invokes the right-click or context menu)
{Sleep}	Computer SLEEP key.
{ASC nnnnn}	
Sends an ALT+nnnnn keypad combination, which can be used to generate special characters that don't exist on the keyboard. To generate ASCII characters, specify a number between 1 and 255. To generate ANSI characters (standard in most languages), specify a number between 128 and 255, but precede it with a leading zero, e.g. {Asc 0133}.

To generate Unicode characters, specify a number between 256 and 65535 (without a leading zero). However, this is not supported by all applications. Therefore, for greater compatibility and easier sending of long Unicode strings, use "Transform Unicode".

{vkXX}
{scYYY}
{vkXXscYYY}

Sends a keystroke that has virtual key XX and scan code YYY. For example: Send {vkFFsc159}. If the sc or vk portion is omitted, the most appropriate value is sent in its place.

The values for XX and YYY are hexadecimal and can usually be determined from the main window's View->Key history menu item. See also: Special Keys

 	 
{Numpad0} - {Numpad9}	Numpad digit keys (as seen when Numlock is ON). For example: {Numpad5} is the digit 5.
{NumpadDot}	Numpad Period (as seen when Numlock is ON).
{NumpadEnter}	Enter key on keypad
{NumpadMult}	Numpad Multiply
{NumpadDiv}	Numpad Divide
{NumpadAdd}	Numpad Add
{NumpadSub}	Numpad Subtract
 	 
{NumpadDel}	Delete key on keypad (this key and the following Numpad keys are used when Numlock is OFF)
{NumpadIns}	Insert key on keypad
{NumpadClear}	Clear key on keypad (usually the '5' key when Numlock is OFF).
{NumpadUp}	Up-arrow key on keypad
{NumpadDown}	Down-arrow key on keypad
{NumpadLeft}	Left-arrow key on keypad
{NumpadRight}	Right-arrow key on keypad
{NumpadHome}	Home key on keypad
{NumpadEnd}	End key on keypad
{NumpadPgUp}	Page-up key on keypad
{NumpadPgDn}	Page-down key on keypad
 	 
{Browser_Back}	2000/XP/Vista+: Select the browser "back" button
{Browser_Forward}	2000/XP/Vista+: Select the browser "forward" button
{Browser_Refresh}	2000/XP/Vista+: Select the browser "refresh" button
{Browser_Stop}	2000/XP/Vista+: Select the browser "stop" button
{Browser_Search}	2000/XP/Vista+: Select the browser "search" button
{Browser_Favorites}	2000/XP/Vista+: Select the browser "favorites" button
{Browser_Home}	2000/XP/Vista+: Launch the browser and go to the home page
{Volume_Mute}	2000/XP/Vista+: Mute/unmute the master volume. Usually equivalent to SoundSet, +1, , mute
{Volume_Down}	2000/XP/Vista+: Reduce the master volume. Usually equivalent to SoundSet -5
{Volume_Up}	2000/XP/Vista+: Increase the master volume. Usually equivalent to SoundSet +5
{Media_Next}	2000/XP/Vista+: Select next track in media player
{Media_Prev}	2000/XP/Vista+: Select previous track in media player
{Media_Stop}	2000/XP/Vista+: Stop media player
{Media_Play_Pause}	2000/XP/Vista+: Play/pause media player
{Launch_Mail}	2000/XP/Vista+: Launch the email application
{Launch_Media}	2000/XP/Vista+: Launch media player
{Launch_App1}	2000/XP/Vista+: Launch user app1
{Launch_App2}	2000/XP/Vista+: Launch user app2
 	 
{PrintScreen}	Print Screen
{CtrlBreak}	Ctrl+break
{Pause}	Pause
 	 
{Click [Options]}
[v1.0.43+]	Sends a mouse click using the same options available in the Click command. For example, {Click} would click the left mouse button once at the mouse cursor's current position, and {Click 100, 200} would click at coordinates 100, 200 (based on CoordMode). To move the mouse without clicking, specify 0 after the coordinates; for example: {Click 100, 200, 0}. The delay between mouse clicks is determined by SetMouseDelay (not SetKeyDelay).
{WheelDown}, {WheelUp}, {WheelLeft}, {WheelRight}, {LButton}, {RButton}, {MButton}, {XButton1}, {XButton2}	Sends a mouse button event at the cursor's current position (to have control over position and other options, use {Click} above). The delay between mouse clicks is determined by SetMouseDelay. WheelLeft/Right require v1.0.48+, but have no effect on operating systems older than Windows Vista.
{Blind}	
When {Blind} is the first item in the string, the program avoids releasing Alt/Control/Shift/Win if they started out in the down position. For example, the hotkey +s::Send {Blind}abc would send ABC rather than abc because the user is holding down the Shift key.

{Blind} also causes SetStoreCapslockMode to be ignored; that is, the state of Capslock is not changed. Finally, {Blind} omits the extra Control keystrokes that would otherwise be sent; such keystrokes prevent: 1) Start Menu appearance during LWin/RWin keystrokes; 2) menu bar activation during Alt keystrokes.

Blind-mode is used internally when remapping a key. For example, the remapping a::b would produce: 1) "b" when you type "a"; 2) uppercase B when you type uppercase A; and 3) Control-B when you type Control-A.

{Blind} is not supported by SendRaw and ControlSendRaw. Furthermore, it is not completely supported by SendPlay, especially when dealing with the modifier keys (Control, Alt, Shift, and Win).

{Raw}
[v1.0.43+]	Sends the keystrokes exactly as they appear rather than translating {Enter} to an ENTER keystroke, ^c to Control-C, etc. Although the string {Raw} need not occur at the beginning of the string, once specified, it stays in effect for the remainder of the string.

