; =========================
; Hotkey Definitions
; =========================

RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 1
; Regwrite HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer r

vSelWindow := -1
; 1. Navigate visible windows with Win + [h/j/k/l]
#j::Navigate("down")
#k::Navigate("up")
#h::Navigate("left")
#l::Navigate("right")

; 2. Increase/decrease window size with Win+Shift+[h/j/k/l]
#+l::Resize("increaseWidth")
#+k::Resize("decreaseHeight")
#+h::Resize("decreaseWidth")
#+j::Resize("increaseHeight")

; 3. Minimize window with Win + m
#m::WinMinimize, A

; 4. Close window with Win + w
#w::WinClose, A

; 5. Move window to screen edge with Win+Alt+[h/j/k/l]
#^h::MoveEdge("left")
#^l::MoveEdge("right")
#^k::MoveEdge("up")
#^j::MoveEdge("down")

; #o::OpenAndPlaceWindow()

; =========================
; Function Definitions
; =========================

visible(winTitle) {
    WinGet, thisStyle, Style, %winTitle%
    ; MsgBox, the style is %thisStyle%
    Transform, visible, BitAnd, %thisStyle%, 0x10000000 ; 0x10000000 is WS_VISIBLE.
    Return visible
}

Navigate(direction) {
    ; Get current active window
    WinGet, currID, ID, A
    WinGetPos, x0, y0, w0, h0, ahk_id %currID%
    cx0 := x0 + w0/2
    cy0 := y0 + h0/2
    MsgBox, the cx0 is %cx0% and the cy0 is %cy0%
    candidateId := ""
    minDist := 1e9
    ; Loop through all top-level windows
    WinGet, winCount, List
    Loop, %winCount% {
        ; this_id := WinExist("ahk_id " . WinGetTitle("ahk_id " . WinExist("ahk_id " . A_Index)))
        this_id := winCount%A_Index%
        ; Skip current window
        if (this_id = currID)
            continue

        ; WinGet, Style, Style, ahk_id %this_id%
        ; if !(Style & 0x10000000)  ; WS_VISIBLE
        ;     continue
        ; WinGet, MinMax, MinMax, ahk_id %this_id%
        ; if (MinMax = -1 or MinMax = 0)  ; minimized
        ;     continue

        if not visible("ahk_id " . this_id)
            continue

        ; Get position and center of candidate window
        WinGetPos, x, y, w, h, ahk_id %this_id%
        cx := x + w/2
        cy := y + h/2

        ; Filter based on direction

        if (direction = "left" && cx >= cx0)
            continue
        if (direction = "right" && cx <= cx0)
            continue
        if (direction = "up" && cy >= cy0)
            continue
        if (direction = "down" && cy <= cy0)
            continue

        dy := cy - cy0
        dist := Sqrt(dx*dx + dy*dy)

        dx := cx - cx0
        if (dist < minDist) {
            minDist := dist
            candidateId := this_id
        }
    }

    if candidateId
        WinActivate, ahk_id %candidateId%
}

Resize(which) {
    WinGet, id, ID, A
    WinGetPos, x, y, w, h, ahk_id %id%
    step := 20  ; pixel adjustment step

    if (which = "increaseWidth")
        w += step
    else if (which = "decreaseWidth")
        w := (w > step ? w - step : w)
    else if (which = "increaseHeight")
        h += step
    else if (which = "decreaseHeight")
        h := (h > step ? h - step : h)

    WinMove, ahk_id %id%, , x, y, w, h
}

GetResizeAnchor(direction){
    if (direction == "left") {
        anchor := 1
    } else if( direction == "right") {
        anchor := 2
    } else if (direction == "up") {
        anchor := 1
    } else if (direction == "down") {
        anchor := 4
    }
    return anchor
}
GetBorderString(left, down, right, up) {
    borderString := ""
    if (left)
        borderString .= "left "
    if (down)
        borderString .= "down "
    if (right)
        borderString .= "right "
    if (up)
        borderString .= "up "
    return borderString
}

MoveEdge(direction) {

    WinGet, winid, ID, A
    WinGet, MinMax, MinMax, ahk_id %winid%
    isMaximized := (MinMax == 1)
    if (isMaximized) {
        WinRestore, ahk_id %id%
    }



    WinGetPos,,,,t_h, ahk_class Shell_TrayWnd
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight 
    halfWidth := screenWidth / 2
    halfHeight := ( screenHeight  ) / 2
    padx := 4 ;left ? -x : w - screenWidth
    gpadx := 8
    pady := 4 ; up ? -y : h - screenHeight 
    gpady := 8

    compArray := []
    oppArray := []
    orientation := getNeighbours(winid, compArray, oppArray)

    WinGetPos, x, y, w, h, ahk_id %winid%
    endx := x + w 
    endy := y + h

    w := "abc"
    h := "abc"

    left := false, down := false, right := false, up := false
    count := get_border_count(winid, left, down, right, up)

    ;diff_padding_x := left  ? -1 * (padx + x ): 0
    ;diff_padding_y := up  ? -1 * (pady + y ): 0
    ;if ( left ) { 
        ;diff := -1 * ( padx + x )
        ;x := left ? -1 * padx : x
        ;endx :=  endx + diff
    ;}

    x := left ? -1 * padx : x
    y := up ? -1 * pady : y
    endx := right ? screenWidth + padx : endx
    endy := down ? screenHeight + pady : endy



    ;nw := w > screenWidth ? screenWidth : (w > halfWidth ? halfWidth : w)
    ;th := h > screenHeight ? screenHeight : (h > halfHeight ? halfHeight : h)



    vertical := direction == "up" || direction == "down"
    horizontal := direction == "left" || direction == "right"
    anchor := GetResizeAnchor(direction)
    sign := (direction == "left" or direction == "up") ? -1 : 1


    ;newx := x
    ;newy := y
    ;new_endx := endx
    ;new_endy := endy

 
    if (horizontal) {
        if (sign > 0){
            newx := endx - 2 * gpadx 
            new_endx := screenWidth + padx
        }else { 
            newx := -1 * padx 
            new_endx := x + 2 * gpadx
        } 
        oldw := (endx - x)
        neww := new_endx - newx 


        y = 
        endy = 
        newy =
        new_endy =

    } else if (vertical) {
        if ( sign > 0 ){
            newy := endy - 2 * gpady
            new_endy := screenHeight + pady
        }else {
            newy := -1 * pady
            new_endy := y + 2 * gpady
        }
        oldh := (endy - y)
        newh := new_endy - newy 


        x = 
        endx = 
        newx =
        new_endx =

    }


 
    isTowardBorder := InStr(GetBorderString(left, down, right, up), direction)

    ;debugMsg := "`nnx: " . nx . " `nny: " . ny . " `nisTowardBorder: " . isTowardBorder . "`nanchor: " . anchor . "`nvertical: " . vertical . "`nhorizontal: " . horizontal 

    ; MsgBox , 0x1000,  Debug Message, %debugMsg%  
    

    if (count == 4) {
        ;msgbox , count is 4
        if (horizontal) {
            nw := halfWidth + 2 * gpadx
            smoothResize(winid,anchor,nw,oldh,x,y,oldw,oldh )
            return
        }
        else if (vertical) {
            nh := halfHeight + 2 * gpady
            smoothResize(winid,anchor,oldw,nh,x,y,oldw,oldh)
            return
        }

    }

    if (count == 3){
        win_vertical := (up && down)
        win_horizontal := (left && right)
        if ( horizontal and win_horizontal  ){
            nw := halfWidth + 2*gpadx
            smoothResize(winid,anchor,nw,oldh,x,y,oldw,oldh)
            return
        }else if (vertical and win_vertical){
            nh := halfHeight + 2* gpady
            smoothResize(winid,anchor,oldw,nh,x,y,oldw,oldh)
            return
        }

    }

    if ( count == 2 && orientation == "both" ) {
        if ( vertical ) {
            orientation := "horizontal"
            vert_comp := compArray[1] 
            oppArray.Push(vert_comp)
            compArray.RemoveAt(1)
        }else if ( horizontal ){
            orientation := "vertical"
            hor_comp := compArray[2]
            oppArray.Push(hor_comp)
            compArray.RemoveAt(2)
        }

    }

    if (isTowardBorder ){
        Return
        }
    ;msgbox , hi ther iam here 
    WinMove , ahk_id %winid% , , newx, newy, neww, newh
    
    vertical_orient := orientation == "vertical"
    horizontal_orient := orientation == "horizontal"

    if ( ( vertical && vertical_orient ) or ( horizontal && horizontal_orient ) ){
        loop % compArray.Length(){
            this_id := compArray[A_Index]
            WinMove , ahk_id %this_id% , , x, y, oldw, oldh
        }
    }

    if ( ( vertical && horizontal_orient ) or ( horizontal && vertical_orient ) ){
        loop % compArray.Length(){
            this_id := compArray[A_Index]
            WinMove , ahk_id %this_id% , ,newx, newy, neww, newh
        }

        loop % oppArray.Length(){
            this_id := oppArray[A_Index]
            WinMove , ahk_id %this_id% , , x, y, oldw, oldh
        }
    } 

    return
        
    ;if (count == 2){
       ;if (isTowardBorder)
            ;Return 
        ;return
    ;}else{
        ;Return
    ;}

}

; MoveEdge(direction) {
;     WinGet, id, ID, A

;     ; SysGet, screenWidth, 78
;     screenWidth := A_ScreenWidth
;     ; SysGet, screenHeight, 79
;     screenHeight := A_ScreenHeight

;     ; Check if window is maximized
;     WinGet, MinMax, MinMax, ahk_id %id%
;     maximized := (MinMax = 1)

;     ; If maximized, restore and set half width/height
;     if maximized {
;         WinRestore, ahk_id %id%
;         Sleep, 50
;     }

;     WinGetPos, x, y, w, h, ahk_id %id%

;     ; For horizontal movement, set width to half screen if needed
;     if (direction = "left" || direction = "right") {
;         if maximized
;             w := screenWidth/2
;     }

;     ; For vertical movement, set height to half screen if needed
;     if (direction = "up" || direction = "down") {
;         if maximized
;             h := screenHeight/2
;     }

;     if (direction = "left") {
;         if (x <= 0) {
;             newX := screenWidth - w  ; move to right edge if already left aligned
;         } else {
;             newX := 0
;         }
;         WinMove, ahk_id %id%, , newX, y, w, h
;     }
;     else if (direction = "right") {
;         if (x + w >= screenWidth) {
;             newX := 0  ; move to left edge if already right aligned
;         } else {
;             newX := screenWidth - w
;         }
;         WinMove, ahk_id %id%, , newX, y, w, h
;     }
;     else if (direction = "up") {
;         ; if (y <= 0) {
;         ;     newY := screenHeight - h  ; move to bottom edge if already top aligned
;         ; } else {
;         newY := 0
;         ; }
;         WinMove, ahk_id %id%, , x, newY, w, h
;     }
;     else if (direction = "down") {
;         ; if (y + h >= screenHeight) {
;         ;     newY := 0  ; move to top edge if already bottom aligned
;         ; } else {
;         newY := screenHeight - h
;         ; }
;         WinMove, ahk_id %id%, , x, newY, w, h
;     }
; }

; Global variables to store base window geometry and screen width
global storedX, storedY, storedW, storedH, screenW

#o::OpenSelectorAndPlace()

OpenSelectorAndPlace() {
    ; Store geometry of current active window (assumed to be Program A)
    WinGet, baseID, ID, A
    WinGetPos, baseX, baseY, baseW, baseH, ahk_id %baseID%
    ; SysGet, screenWidth, 78

    ; Save values in global variables for later use
    global storedX := baseX, storedY := baseY, storedW := baseW, storedH := baseH

    ; Open persistent Task Switcher with Ctrl+Alt+Tab
    Send, ^!{Tab}

    ; Start timer to watch for active window change
    SetTimer, CheckTaskSelection, 200
    return
}

CheckTaskSelection:
    ; Get the currently active window and its class
    WinGet, activeID, ID, A
    if (!activeID)
        return
    WinGetClass, class, ahk_id %activeID%

    ; Check if the active window is no longer the Task Switcher
    if (class != "XamlExplorerHostIslandWindow") {
        ; Assume the user has selected a new window. Position it to fill the remaining gap.
        newX := storedX + storedW
        newY := storedY
        newW := A_ScreenWidth - storedW
        newH := storedH
        ; Move and resize the newly selected window
        WinWait ahk_id %activeID%
        WinRestore, ahk_id %activeID%

        ; WinMove, (newX), (newY), (newW), (newH)
        WinMove, ahk_id %activeID%, , newX, newY, newW, newH
        ;     MsgBox % "New window selected: " . activeID . " " . class . " " . newX . " " . newY . " " . newW . " " . newH
        ;    MsgBox loop ended now resizing
        ; Stop the timer as our job is done
        SetTimer, CheckTaskSelection, Off
    }
return

; ********************************************************************************
; **************************** Utility Functions ********************************
; ********************************************************************************
get_border_count(winid, ByRef left, ByRef down, ByRef right, ByRef up) {
    ; Initialize all alignment flags to false
    left := false
    down := false
    right := false
    up := false

    ; Use built-in screen dimensions
    WinGetPos,,,,h, ahk_class Shell_TrayWnd
    yPad := 0, xPad := 0 , ; only on fullscreen mode the padding can be set to = -4 ,which mean that it has no effect because of minus ( window is bigger than screen)
    screenWidth := A_ScreenWidth - xPad
    screenHeight := A_ScreenHeight - yPad - h
    ; Get window position and size
    WinGetPos, wx, wy, ww, wh, ahk_id %winid%

    count := 0
    ; Determine if the window is aligned to each border
    if (wx <= 0){
        left := true
        count++
    }
    if (wy <= 0){
        up := true
        count++
    }
    if ((wx + ww) >= screenWidth){
        right := true
        count++
    }

    if ((wy + wh) >= screenHeight){
        down := true
        count++
    }

    ; Count the number of true alignment flags
    return count
}
; --- Provided Functions ---
IsWindowVisible(win:="A") {
    hwnd := WinExist(win)

    ; taskbar dimension
    WinGetPos,,,,t_h, ahk_class Shell_TrayWnd

    WinGet, style, MinMax, ahk_id %this_id%
    if (style = -1)
        return False

    WinGetPos, X, Y, W, H, % win
    margin := 24
    ; pad := 0
    ; if style == 1
    ;     pad := 8
    X := X + margin
    Y := Y + margin

    H :=  H - t_h - 2*margin
    W := W - 2*margin

    if H <=  0
        return False

    EndX := X + W
    EndY := Y + H
    MidX := X + W//2
    MidY := Y + H//2
    count := (hwnd == WindowFromPoint(X, Y) ? 1 : 0)
        + (hwnd == WindowFromPoint(X, EndY) ? 1 : 0)
        + (hwnd == WindowFromPoint(EndX, Y) ? 1 : 0)
        + (hwnd == WindowFromPoint(EndX, EndY) ? 1 : 0)
        + (hwnd == WindowFromPoint(MidX, MidY) ? 1 : 0)
    if (count > 2 ) {
        return True
    }
    return False
}

WindowFromPoint(X, Y) {
    return DllCall("GetAncestor", "UInt", DllCall("WindowFromPoint", "UInt64", X | (Y << 32)), "UInt", 2)
}

GetVisibleWindows() {
    visibleWindows := []
    WinGet, windowCount, List
    Loop, %windowCount% {
        this_id := windowCount%A_Index%
        if (IsWindowVisible("ahk_id " . this_id)) {
            visibleWindows.push(this_id)
        }
    }
    return visibleWindows
}

; ********************************************************************************
; **************************** MAIN Utility Functions ********************************
; ********************************************************************************

getNeighbours(winid, ByRef companion, ByRef opponent) {
    orientation := ""
    companion := []
    opponent := []

    ; Retrieve all visible windows
    visibleWindows := GetVisibleWindows()
    total := visibleWindows.Length()

    ; Prepare arrays/objects for border counts and border details for each window
    borderCounts := {} ; key: window id, value: count
    borders := {}      ; key: window id, value: {left, right, top, bottom}

    ; Compute border counts and store border details for each visible window
    for index, wid in visibleWindows {
        left := false, right := false, top := false, bottom := false
        count := get_border_count(wid, left, bottom, right, top)
        borderCounts[wid] := count
        borders[wid] := {left:left, right:right, top:top, bottom:bottom}
    }

    if (total = 1) {
        ; First case: Single window
        orientation := "full"
        return orientation
    }
    else if (total = 2) {
        ; Second case: Two windows
        first := visibleWindows[1]
        b := borders[first]
        if (b.top && b.bottom)
            orientation := "vertical"
        else if (b.left && b.right)
            orientation := "horizontal"
        else
            orientation := "unknown"

        ; Identify opponent for winid among the two windows
        for _, wid in visibleWindows {
            if (wid != winid) {
                opponent.Push(wid)
            }
        }
        return orientation
    }
    else if (total = 3) {
        ; Third case: Three windows
        specialID := ""
        ; Loop through all windows to find one with borderCount = 3 and determine orientation
        for index, wid in visibleWindows {
            count := borderCounts[wid]
            if (count = 3) {
                specialID := wid
                b := borders[wid]
                if (b.top && b.bottom)
                    orientation := "vertical"
                else if (b.left && b.right)
                    orientation := "horizontal"
                else
                    orientation := "unknown"
            }
        }

        if (winid = specialID) {
            ; The window with borderCount 3 has no companion; others are opponents
            for index, wid in visibleWindows {
                if (wid != winid) {
                    opponent.Push(wid)
                }
            }
        } else {
            ; For winid != specialID: specialID becomes opponent, the other becomes companion.
            for _, wid in visibleWindows {
                if (wid = winid)
                    continue
                if (wid = specialID) {
                    opponent.Push(wid)
                } else {
                    companion.Push(wid)
                }
            }
        }
        return orientation
    }
    else if (total = 4) {
        ; Fourth case: Four windows
        localBorders := borders[winid]
        localCount := borderCounts[winid]
        threshold := 24 

        ; Check for edge case: half width & half height
        ; *******************************************************************

        ;WinGetPos, wx, wy, ww, wh, ahk_id %winid%
        ;WinGetPos,,,,taskbar_height, ahk_class Shell_TrayWnd
        ;halfWidth := A_ScreenWidth / 2
        ;halfHeight := ( A_ScreenHeight - taskbar_height )  / 2
;
        ;diffWidth := Abs(ww - halfWidth)
        ;diffHeight := Abs(wh - halfHeight)
;
        ;if ( diffWidth <= threshold  && diffHeight <= threshold ) {
            ;orientation := "both"
            ;verticalCompanion := ""
            ;horizontalCompanion := ""
            ;for index, wid in visibleWindows {
                ;if (wid = winid) continue
                    ;b := borders[wid]
                ;if ((localBorders.left && b.left) || (localBorders.right && b.right)) {
                    ;verticalCompanion := wid
                ;}
                ;if ((localBorders.top && b.top) || (localBorders.bottom && b.bottom)) {
                    ;horizontalCompanion := wid
                ;}
            ;}
            ;; Store companions in order: vertical then horizontal
            ;if (verticalCompanion != "")
                ;companion.Push(verticalCompanion)
            ;if (horizontalCompanion != "")
                ;companion.Push(horizontalCompanion)
;
            ;; Find the remaining window as opponent
            ;for index, wid in visibleWindows {
                ;if (wid != winid && wid != verticalCompanion && wid != horizontalCompanion) {
                    ;opponent.Push(wid)
                    ;break
                ;}
            ;}
            ;return orientation
        ;}

        ; General four-window case
        verticalCompanion := ""
        horizontalCompanion := ""
        for _, wid in visibleWindows {
            if (wid = winid)
                continue

            b1 := borders[winid]
            b2 := borders[wid]
            sharesOne := false

            ; Check if wid shares at least one border with winid
            if ((b1.left and b2.left) or (b1.right and b2.right)
                or (b1.top and b2.top) or (b1.bottom and b2.bottom)) {
                sharesOne := true
            }

            if (!sharesOne) {
                opponent.Push(wid)
                continue
            }

            ; Determine temporary orientation based on shared border
            tempOrientation := ""
            if ((b1.left and b2.left) or (b1.right and b2.right)) {
                tempOrientation := "vertical"
            } else if ((b1.top and b2.top) or (b1.bottom and b2.bottom)) {
                tempOrientation := "horizontal"
            }

            ; Get positions and sizes of both windows
            WinGetPos, wx1, wy1, ww1, wh1, ahk_id %winid%
            WinGetPos, wx2, wy2, ww2, wh2, ahk_id %wid%

            if (tempOrientation = "vertical" and Abs( ww1 - ww2) < threshold) {
                verticalCompanion := wid
                orientation := "vertical"
            } else if (tempOrientation = "horizontal" and Abs(wh1 - wh2) < threshold) {
                horizontalCompanion := wid
                orientation := "horizontal"
            }else {
                opponent.Push(wid)
            }

            ;isCompanion := false
            ;if (isCompanion) {
                ;orientation := tempOrientation
                ;companion.Push(wid)
            ;} else {
                ;opponent.Push(wid)
            ;}
        }
        if (verticalCompanion != "")
            companion.Push(verticalCompanion)
        if (horizontalCompanion != "")
            companion.Push(horizontalCompanion)
        if ( verticalCompanion != "" && horizontalCompanion != "" ){
            orientation := "both"
        }
        return orientation
    }

    return orientation
}

smoothResize(winid, anchor, newWidth, newHeight,x, y, curWidth, curHeight) {
    ; Retrieve current window position and size
    ; WinGetPos, x, y, curWidth, curHeight, ahk_id %winid%
    dx := newWidth - curWidth
    dy := newHeight - curHeight

    ; Precalculate edges based on current position and size
    rightEdge := x + curWidth
    bottomEdge := y + curHeight
    steps := 1
    ; Loop through steps to perform incremental resizing
    Loop, %steps% {
        factor := A_Index / steps
        ; Calculate intermediate dimensions
        interWidth := curWidth + dx * factor
        interHeight := curHeight + dy * factor

        ; Determine new position based on anchor
        if (anchor = 1) { ; Top left fixed
            newX := x
            newY := y
        } else if (anchor = 2) { ; Top right fixed
            newX := rightEdge - interWidth
            newY := y
        } else if (anchor = 3) { ; Bottom right fixed
            newX := rightEdge - interWidth
            newY := bottomEdge - interHeight
        } else if (anchor = 4) { ; Bottom left fixed
            newX := x
            newY := bottomEdge - interHeight
        }

        ; Apply intermediate position and size
        WinMove, ahk_id %winid%, , newX, newY, interWidth, interHeight
        ; No Sleep for smooth continuous resize
    }

    ; Final adjustment to ensure exact target size and position
    if (anchor = 1) {
        finalX := x
        finalY := y
    } else if (anchor = 2) {
        finalX := rightEdge - newWidth
        finalY := y
    } else if (anchor = 3) {
        finalX := rightEdge - newWidth
        finalY := bottomEdge - newHeight
    } else if (anchor = 4) {
        finalX := x
        finalY := bottomEdge - newHeight
    }

    WinMove, ahk_id %winid%, , finalX, finalY, newWidth, newHeight
}

; ********************************************************************************
; **************************** TEST Utility Functions ********************************
; ********************************************************************************
; --- Test the function with a hotkey ---

#b::  ; Press Win+T to test the function on the active window
    ; Get the active window's ID
    WinGet, activeID, ID, A

    ; Initialize border flags
    left := false
    down := false
    right := false
    up := false

    ; Call the utility function
    borderCount := get_border_count(activeID, left, down, right, up)

    ; Display the results in a message box
    MsgBox, 0x1000,Border Count,  Border count: %borderCount%`nLeft: %left%`nRight: %right%`nTop: %up%`nBottom: %down%
return

; --- Test Script ---
#v::  ; Press Win+V to list all really visible windows on screen.
    visibleWindows := GetVisibleWindows( )
    output := ""
    Loop % visibleWindows.Length(){
        this_id := visibleWindows[A_Index]
        WinGetTitle, title, ahk_id %this_id%
        ; Append window info to the result string
        output .= "ID: " . this_id . " - Title: " . title . "`n"
    }
    if (output = "")
        MsgBox, 0x1000,Visible Windows, No truly visible windows found.
    else
        MsgBox, 0x1000,Visible Windows, % "Really visible windows:`n" . output
return

#t::  ; Press Win+T to run the test
    results := ""
    visibleWindows := GetVisibleWindows()

    if (visibleWindows.Length() = 0) {
        MsgBox, 0x1000,Neighbours, No visible windows found.
        return
    }

    ; Iterate over each visible window and get its neighbours info
    for index, winid in visibleWindows {
        compArray := []  ; Initialize empty arrays for companions and opponents
        oppArray := []

        orientation := getNeighbours(winid, compArray, oppArray)

        companions := ArrayToTitleString(compArray)
        opponents := ArrayToTitleString(oppArray)

        ; Get current window title
        WinGetTitle, title, ahk_id %winid%
        if (title = "")
            title := "Untitled Window"

        results .= "Window: " . title . "`n"
        results .= "Orientation: " . orientation . "`n"
        results .= "Companions: " . (companions ? companions : "None") . "`n"
        results .= "Opponents: " . (opponents ? opponents : "None") . "`n"
        results .= "--------------------------`n"
    }

    ; Display all results in a scrollable GUI for better readability
    Gui, New, +Resize   +AlwaysOnTop, Visible Windows Neighbours
    Gui, Add, Edit, w800 h600 ReadOnly vOutput, %results%
    Gui, Show, , Visible Windows Neighbours
return

ArrayToTitleString(arr) {
    str := ""
    for index, val in arr {
        WinGetTitle, title, ahk_id %val%
        if (title = "")
            title := "Untitled Window"
        str .= title . ", "
    }
    if (StrLen(str) > 0)
        str := SubStr(str, 1, -2)  ; Remove trailing comma and space
    return str
}

; ArrayToString(arr) {
;     str := ""
;     for index, wid in arr {
;         WinGetTitle, title, ahk_id %wid%
;         str .= (title ? title : "Unknown") . ", "
;     }
;     if (StrLen(str) > 0)
;         str := SubStr(str, 1, -2)  ; Remove trailing comma and space
;     return str
; }

; #r::  ; Press Win+T to run the test
;     results := ""
;     visibleWindows := GetVisibleWindows()

;     if (visibleWindows.Length() = 0) {
;         MsgBox, No visible windows found.
;         return
;     }

;     ; Iterate over each visible window and get its neighbours info
;     for index, winid in visibleWindows {
;         ; Get the title of the current window
;         WinGetTitle, currentTitle, ahk_id %winid%

;         compArray := []  ; Initialize empty arrays for companion and opponent
;         oppArray := []

;         orientation := getNeighbours(winid, compArray, oppArray)

;         companions := ArrayToString(compArray)
;         opponents := ArrayToString(oppArray)

;         results .= "Window: " . (currentTitle ? currentTitle : "Unknown") . "`n"
;         results .= "Orientation: " . orientation . "`n"
;         results .= "Companions: " . (companions ? companions : "None") . "`n"
;         results .= "Opponents: " . (opponents ? opponents : "None") . "`n"
;         results .= "--------------------------`n"
;     }

;     MsgBox, 0x1000,Neighbours, %results%
; return

#r::  ; Press Win+Shift+R to run the smoothResize test sequence
    ; Retrieve active window ID
    WinGet, winid, ID, A

    ; Define screen dimensions and target sizes
    fullWidth := A_ScreenWidth
    fullHeight := A_ScreenHeight
    quarterWidth := fullWidth / 2
    quarterHeight := fullHeight / 2
    duration := 0  ; Duration for each smooth resize in milliseconds

    ; Ensure the active window starts full screen
    WinMove, ahk_id %winid%, , 0, 0, fullWidth, fullHeight
    Sleep, 500  ; Pause briefly to observe full-screen state

    ; Loop over each anchor from 1 to 4
    Loop, 4 {
        anchor := A_Index

       WinGetPos, x, y, curWidth, curHeight, ahk_id %winid%
        ; Smooth resize to quarter screen from current anchor
        smoothResize(winid, anchor, quarterWidth, quarterHeight, x, y, curWidth, curHeight)
        ; WinMove, ahk_id %winid%, , newX, newY, interWidth, interHeight
        Sleep, 500  ; Brief pause to observe the quarter-resize

       WinGetPos, x, y, curWidth, curHeight, ahk_id %winid%
        ; Smooth resize back to full screen from same anchor
        smoothResize(winid, anchor, fullWidth, fullHeight, x, y, curWidth, curHeight)
        Sleep, 500  ; Brief pause to observe full-screen state again
    }
return
