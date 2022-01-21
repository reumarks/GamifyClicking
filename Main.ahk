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
CoordMode Mouse, Screen
CoordMode, Pixel, Screen 
SetBatchLines -1
OnExit GuiClose

var := "https://raw.githubusercontent.com/reumarks/GamifyClicking/main/crosshair.png"

zoom = 4
gamestate := -1
Rx := A_ScreenWidth/2
Ry := A_ScreenHeight/2
Zx := Rx/zoom
Zy := Ry/zoom

width := 200
height := 200
crosshairX := 0
crosshairY := 0
crosshairSX := 30
crosshairSY := 30

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
Gui,3: -caption +toolwindow +alwaysontop
Gui,3: color, ffffff
Gui,3: margin, 0, 0
Gui,3: Add, ActiveX, x-70 y-35 w200 h200 vWB, shell explorer
wb.Navigate("about:blank")
html := "<html>`n<title>name</title>`n<body>`n<center>`n<img src=""" var """ >`n</center>`n</body>`n</html>"
wb.document.write(html)
sysget, var_, monitorworkarea
Gui,3: +LastFound
Gui,3: show, x0 y0 w0 h0, dodger
winset, transcolor, ffffff, dodger

Gui, 3: Hide
Gui, 2: Hide 
Gui, Hide 

hdd_frame := DllCall("GetDC", UInt, PrintSourceID)
hdc_frame := DllCall("GetDC", UInt, MagnifierID)
DllCall( "gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 3 )

loop, {
    if(gamestate = 0){
        DllCall("ShowCursor", "Int", 0)
        MouseGetPos x, y
        Gui, Show 
        Gui, 2:Show
        xz := In(x-Zx-6,0,A_ScreenWidth-2*Zx)
        yz := In(y-Zy-6,0,A_ScreenHeight-2*Zy)
        DllCall("gdi32.dll\StretchBlt", UInt,hdc_frame, Int,0, Int,0, Int,2*Rx, Int,2*Ry, UInt,hdd_frame, UInt,xz, UInt,yz, Int,2*Zx, Int,2*Zy, UInt,0xCC0020)
        WinSet Transparent, 255, Magnifier
        crosshairX := 0
        crosshairY := 0
        gamestate := 1
    }else if(gamestate = 1){
        if(crosshairY + 64 > A_ScreenHeight){
            crosshairSY *= -1
        }
        if(crosshairY < 0){
            crosshairSY *= -1
        }
        crosshairY += crosshairSY
        sleep 10
        Gui, 3: show, x%crosshairX% y%crosshairY% w100 h100, dodger
    }else if(gamestate = 2){
        if(crosshairX + 64 > A_ScreenWidth){
            crosshairSX *= -1
        }
        if(crosshairX < 0){
            crosshairSX *= -1
        }
        crosshairX += crosshairSX
        sleep 10
        Gui, 3: show, x%crosshairX% y%crosshairY% w100 h100, dodger
    }else if(gamestate = 3){
        WinSet Transparent, 0, Magnifier
        Gui, 3:Hide 
        Gui, 2:Hide 
        Gui, Hide 
        clickPointX := In(x-Zx-6,0,A_ScreenWidth-2*Zx) + (crosshairX + 32) / zoom
        clickPointY := In(y-Zy-6,0,A_ScreenHeight-2*Zy) + (crosshairY + 32) / zoom
        Send {Click %clickPointX% %clickPointY%}
        gamestate := -1
        DllCall("ShowCursor", "Int", 1)
    }
}

LButton::
RButton::
    gamestate++
return

#ESC::
GuiClose:
   DllCall("ShowCursor", "Int", 1)
   DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
   DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
ExitApp

In(x,a,b) {
   IfLess x,%a%, Return a
   IfLess b,%x%, Return b
   Return x
}