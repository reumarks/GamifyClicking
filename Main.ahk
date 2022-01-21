#NoEnv
#KeyHistory 0
#Persistent
#SingleInstance force
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, 0
SetControlDelay, 0
SendMode Input
CoordMode, Pixel, Screen 
CoordMode Mouse, Screen
SetBatchLines -1
OnExit GuiClose

zoom = 3
gamestate := 0
Screen_X = %A_ScreenWidth%
Screen_Y = %A_ScreenHeight%
Rx := Screen_X/2
Ry := Screen_Y/2
Zx := Rx/zoom
Zy := Ry/zoom

Gui +AlwaysOnTop +Resize +ToolWindow
Gui Show, % "w" 2*Rx " h" 2*Ry " x0 y0", Magnifier
WinSet Transparent, 0, Magnifier
WinGet MagnifierID, id,  Magnifier
WinGet PrintSourceID, ID
WinMove, Magnifier,, 0,0
WinSet, Style, -0xC00000, Magnifier
WinSet, Style, -0x40000 , Magnifier
WinSet, AlwaysOnTop , On, Magnifier 
WinSet, ExStyle, +0x20, Magnifier
WinMaximize, Magnifier
Gui, 2:Hide 
Gui, Hide 

hdd_frame := DllCall("GetDC", UInt, PrintSourceID)
hdc_frame := DllCall("GetDC", UInt, MagnifierID)
DllCall( "gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 3 )

LButton::
RButton::
    if(gamestate = 0){
        Gui, Show 
        Gui, 2:Show 
        WinSet Transparent, 0, Magnifier
        MouseGetPos x, y
        xz := In(x-Zx-6,0,A_ScreenWidth-2*Zx)
        yz := In(y-Zy-6,0,A_ScreenHeight-2*Zy)
        DllCall("gdi32.dll\StretchBlt", UInt,hdc_frame, Int,0, Int,0, Int,2*Rx, Int,2*Ry, UInt,hdd_frame, UInt,xz, UInt,yz, Int,2*Zx, Int,2*Zy, UInt,0xCC0020)
        WinSet Transparent, 255, Magnifier
        gamestate ++
    }else if(gamestate = 1){
        Gui, 2:Hide 
        Gui, Hide 
        gamestate := 0
    }
Return

ESC::
GuiClose:
   DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
   DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
ExitApp

In(x,a,b) {
   IfLess x,%a%, Return a
   IfLess b,%x%, Return b
   Return x
}