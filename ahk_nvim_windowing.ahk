
; =========================
; Hotkey Definitions
; =========================

RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 1

#m::WinMinimize, A

;#w::WinClose, A

; 5. Move window to screen edge with Win+Alt+[h/j/k/l]




;

; #o::OpenAndPlaceWindow()

; ==========================
; Global Variables
; ==========================

; Screen dimensions and padding
 ;screenWidth, screenHeight, halfWidth, halfHeight, padx, pady, gpadx, gpady , trayHeight = 
LoadGlobalVariables() {
     global ;

    if ( not DECLARED ){
        declareGlobalVariables()
        return
    }

    compArray := [],    oppArray := [] , layoutOrientation := ""
    winGroups := {}

    winAttributes := {} , VisibleWindows := [] , FloatingWindows := [] 

    emptyCornerMap := W_CORNER1 | W_CORNER2 | W_CORNER3 | W_CORNER4
}


declareGlobalVariables() {
    global ;
    DECLARED := true 
    screenWidth = , screenHeight = , halfWidth = , halfHeight = , padx =  , pady =  , gpadx =  , gpady =  , trayHeight = 0
    MIN_WIDTH := 500 , MIN_HEIGHT := 250 
    screenWidth := round(A_ScreenWidth)
    screenHeight := round(A_ScreenHeight )
    halfWidth := screenWidth / 2
    halfHeight :=  screenHeight   / 2




    ; define an int to represent screen height (as binary grid) ,where each bit indicate that the specifc grid point is occupied , totla number of bit = screen Height / (resolution = 100 )
    resolution := 50.0
    widthPoints := round(screenWidth / resolution)
    heightPoints := round(screenHeight / resolution)
    xMap := ( 0x1 << widthPoints ) - 1
    yMap := ( 0x1 << heightPoints ) - 1


    ; Tray height
    WinGetPos,,,,tray_height, ahk_class Shell_TrayWnd
    trayHeight := tray_height 

    ; Padding
    padx := 16 
    gpadx := 8
    pady := 8 
    gpady := 8

    ; Active and current window IDs
    activeID = , currentID = 
    winAttributes := {} , VisibleWindows := [] , FloatingWindows := [] 


    ; Arrays to store window groups
    compArray := [],    oppArray := [] , layoutOrientation := ""
    winGroups := {}



    ; B_Border Costant and W_corner value should not overlap ( W_corner1 is between B_left and B_top )
    ONE := 0x1
    B_LEFT := ONE << 4 | ONE << 12, B_TOP := ONE << 6 , B_RIGHT := ONE << 8 , B_BOTTOM := ONE << 10 
    W_CORNER1 := ONE << 5 , W_CORNER2 := ONE << 7 , W_CORNER3 := ONE << 9 , W_CORNER4 := ONE << 11
    B_FAKE := ONE << 3 | ONE << 13

    B_BOTH := ONE << 20  

    B_ALL := B_LEFT | B_TOP | B_RIGHT | B_BOTTOM
    W_ALL := W_CORNER1 | W_CORNER2 | W_CORNER3 | W_CORNER4
    emptyCornerMap := W_CORNER1 | W_CORNER2 | W_CORNER3 | W_CORNER4

    B_VERTICAL := B_TOP | B_BOTTOM
    B_HORIZONTAL := B_LEFT | B_RIGHT

    ; Corner Constant ( Clockwise )
    B_CORNER1 := B_LEFT | B_TOP
    B_CORNER2 := B_RIGHT | B_TOP
    B_CORNER3 := B_RIGHT | B_BOTTOM
    B_CORNER4 := B_LEFT | B_BOTTOM


    ; Mode Constants
    M_RESIZE := ONE << 1  , M_FILL := ONE << 2 , M_MOVE_FREE:= ONE << 3 , M_MOVE_RESTRICTED := ONE << 4 , M_NONE := 0


    M_MOVE := M_MOVE_FREE | M_MOVE_RESTRICTED

    ;local someGlobalVariablesString := "screenWidth: " . screenWidth . "`n" . "screenHeight: " . screenHeight . "`n" . "halfWidth: " . halfWidth . "`n" . "halfHeight: " . halfHeight . "`n" . "padx: " . padx . "`n" . "pady: " . pady . "`n" . "gpadx: " . gpadx . "`n" . "gpady: " . gpady . "`n" . "trayHeight: " . trayHeight . "`n" . "MIN_WIDTH: " . MIN_WIDTH . "`n" . "MIN_HEIGHT: " . MIN_HEIGHT . "`n" . "resolution: " . resolution . "`n" . "ONE: " . ONE . "`n" . "B_LEFT: " . B_LEFT . "`n" . "B_TOP: " . B_TOP . "`n" . "B_RIGHT: " . B_RIGHT . "`n" . "B_BOTTOM: " . B_BOTTOM . "`n" . "W_CORNER1: " . W_CORNER1 . "`n" . "W_CORNER2: " . W_CORNER2 . "`n" . "W_CORNER3: " . W_CORNER3 . "`n" . "W_CORNER4: " . W_CORNER4 . "`n" . "B_FAKE: " . B_FAKE . "`n" . "B_BOTH: " . B_BOTH . "`n" . "B_ALL: " . B_ALL . "`n" . "W_ALL: " . W_ALL . "`n" . "emptyCornerMap: " . emptyCornerMap . "`n" . "B_VERTICAL: " . B_VERTICAL . "`n" . "B_HORIZONTAL: " . B_HORIZONTAL . "`n" . "B_CORNER1: " . B_CORNER1 . "`n" . "B_CORNER2: " . B_CORNER2 . "`n" . "B_CORNER3: " . B_CORNER3 . "`n" . "B_CORNER4: " . B_CORNER4 . "`n" . "M_RESIZE: " . M_RESIZE . "`n" . "M_FILL: " . M_FILL . "`n" . "M_MOVE_FREE: " . M_MOVE_FREE . "`n" . "M_MOVE_RESTRICTED: " . M_MOVE_RESTRICTED . "`n" . "M_MOVE: " . M_MOVE 
;
}

; =========================
; Function Definitions
; =========================


GetDirection(direction){
    global ;
    local dir 
    if (direction == 1) {
        dir := B_HORIZONTAL
    } else if( direction == 3) {
        dir := B_HORIZONTAL
    } else if (direction == 2) {
        dir := B_VERTICAL 
    } else if (direction == 4) {
        dir := B_VERTICAL
    }
    return dir
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

GetEndBorder(){
    
}

GetWinGrid(winObj, direction){
    global resolution
    ; if dir == horizontal , then we should compare height to check for overlapping , and vice versa
    if ( direction == B_HORIZONTAL ){
        start := round( winObj.y / resolution )
        end := round( winObj.endy / resolution )
    } else if ( direction == B_VERTICAL ){
        start := round( winObj.x / resolution )
        end := round( winObj.endx / resolution )
    } 
    ; Generate the mask: bits [n..m] = 1
    ; (m-n+1) is how many bits we want set
    mask := (1 << (end - start + 1)) - 1
    mask = mask << start
    return mask 
}







MoveEdge(   direction , B_END , sign   ) {
    global

    local winid := WinExist("A")

    local oppArray := []

    ;GetVisibleWindows()
    local windowCount
    WinGet, windowCount, List,
    Loop, %windowCount% {
        local this_id := windowCount%A_Index%
        IsWindowVisible( this_id) ;"ahk_id " .
    }



    local attr:= winAttributes[winid]
    local borders := attr.borders
    local originCorner := attr.corners
    local borderCount := attr.borderCount
    local this_mode := M_MOVE_RESTRICTED
  



    if ( borderCount == 4 ){
        this_mode := M_RESIZE 
    } 
    else
    if ( borderCount == 3 ){ 
        local  layoutDirection :=  ( borders & B_HORIZONTAL == B_HORIZONTAL ) ? B_HORIZONTAL : B_VERTICAL 
        if ( layoutDirection == direction ){
            this_mode := M_RESIZE 
        } else if ( borders & B_END ){
            this_mode := M_NONE
            return
        } else {
            local otherBorder := ( B_ALL ^ borders ) 
            local otherCorner1 := otherBorder << 1
            local otherCorner2 := otherBorder >> 1
            if ( otherBorder == B_LEFT){
                otherCorner1 := otherCorner1 & ~B_FAKE  
                otherCorner2 := otherCorner2 & ~B_FAKE
            }

            if ( winGroups[otherCorner1]){
                oppArray.Push(winGroups[otherCorner1])
            }

            if ( winGroups[otherCorner2]){
                oppArray.Push(winGroups[otherCorner2])
            }
            
            if ( oppArray.Length() == 0 ){
                this_mode := M_FILL 
            }else{
                this_mode := M_MOVE_FREE
            }


        }

    }
    else
    if ( borderCount == 2 ){
        if ( borders & B_END ){
            this_mode := M_NONE
            return
        }
        local otherDirection := B_ALL ^ direction
        local oppositeBorder := direction & ~borders
        local commonBorder := otherDirection & borders
        local endBorders := commonBorder | oppositeBorder
        local endCorner := ( endBorders << 1 ) & ( endBorders >> 1 )
        local otherWindow := winGroups[endCorner]
        if (otherWindow && otherWindow != winid ){
            oppArray.Push(otherWindow)
        }else{
            local diagonalBorder := ( B_ALL ^ borders ) 
            local diagonalCorner := ( diagonalBorder << 1 ) & ( diagonalBorder >> 1 )
            local diagonalWin := winGroups[diagonalCorner]
            if ( diagonalWin ){
                local this_grid := GetWinGrid(winAttributes[winid], direction)
                local diagonal_grid := GetWinGrid(winAttributes[diagonalWin], direction)
                if ( this_grid & diagonal_grid ){
                    ; do something
                    oppArray.Push(diagonalWin)
                }else{
                    this_mode := M_FILL 
                }
            }else{
                this_mode := M_FILL 
            }
        }
    }
   if ( this_mode & M_RESIZE ){

        if ( direction == B_HORIZONTAL ){
            if ( sign > 0 ){
                attr.newx := halfWidth - gpadx
            } else {
                attr.newendx := halfWidth + gpadx
            }
        } else if ( direction == B_VERTICAL ){
            if ( sign > 0 ){
                attr.newy := halfHeight - gpady
            } else {
                attr.newendy := halfHeight + gpady
            }
        }    
    }
    else
    if ( this_mode & M_FILL ){
        if ( direction == B_HORIZONTAL ){
            if ( sign > 0 ){
                attr.newendx := screenWidth + padx
            } else {
                attr.newx := -1 * padx
            }
        } else if ( direction == B_VERTICAL ){
            if ( sign > 0 ){
                attr.newendy := screenHeight + pady
            } else {
                attr.newy := -1 * pady
            }
        }
    }
    else
    if ( this_mode & M_MOVE){
        local swapGroup := [ ]
        if ( this_mode & M_MOVE_RESTRICTED ){
            local swapGroup := [ "x" , "endx" , "y" , "endy" ]
            if (oppArray.Length() != 1  ){
                msgBox , Error: OppArray length is not 1  in M_MOVE_RESTRICTED
            }
        }else{
            if ( direction == B_HORIZONTAL ){
                swapGroup := [ "x" , "endx" ] 
            }else if ( direction == B_VERTICAL ){
                swapGroup := [ "y" , "endy" ]
            } 
        }
        local oppAttr := 1 
        for index, win in oppArray{
             oppAttr := winAttributes[win]
            for _ , at in swapGroup{
                if (index == 1 ){
                    oppAttr[("new" . at)] := attr[(at)]
                    attr[("new" . at )] := oppAttr[(at)]
                }else if (win != oppArray[1]){
                    oppAttr[("new" . at)] := attr[(at)]
                }
            }
            WinMove , ahk_id %win% , , oppAttr.newx, oppAttr.newy, (oppAttr.newendx - oppAttr.newx ), ( oppAttr.newendy - oppAttr.newy ) 

        oppAttr := winAttributes[(oppArray[1])] 

        }
         
        WinMove , ahk_id %winid% , , attr.newx, attr.newy, (attr.newendx - attr.newx ), ( attr.newendy - attr.newy ) 

        return
    }

    WinMove , ahk_id %winid% , , attr.newx, attr.newy, (attr.newendx - attr.newx ), ( attr.newendy - attr.newy ) 

    return
    
        

}


global storedX, storedY, storedW, storedH, screenW

#o::OpenSelectorAndPlace()

OpenSelectorAndPlace() {
    WinGet, baseID, ID, A
    WinGetPos, baseX, baseY, baseW, baseH, ahk_id %baseID%
                                                   
    global storedX := baseX, storedY := baseY, storedW := baseW, storedH := baseH

    Send, ^!{Tab}

    SetTimer, CheckTaskSelection, 200
    return
}

CheckTaskSelection:
                                                   
    WinGet, activeID, ID, A
    if (!activeID)
        return
    WinGetClass, class, ahk_id %activeID%
                                                               
    if (class != "XamlExplorerHostIslandWindow") {
                                                                                           
        newX := storedX + storedW
        newY := storedY
        newW := A_ScreenWidth - storedW
        newH := storedH
                                                   
        WinWait ahk_id %activeID%
        WinRestore, ahk_id %activeID%
                                                 
        WinMove, ahk_id %activeID%, , newX, newY, newW, newH

        SetTimer, CheckTaskSelection, Off
    }
return

; ********************************************************************************
; **************************** Utility Functions ********************************
; ********************************************************************************


IsWindowVisible(win:="A") {
    global

    local this_id , x ,y , w , h , MidX , MidY , hwnd , endx , endy , margin , pixleCount , style , count ,  borders

    ;this_id := WinExist(win)
    this_id := win
    local title
    WinGetTitle, title, ahk_id %this_id% 
    
    
    ; strip() string 
    if ( InStr(title , "Program Manager") ) {
        return False
    }

    WinGet, style, MinMax, ahk_id %this_id%

    if (style = -1)
        return False

    WinGetPos, x, y, w, h, ahk_id %this_id%
    margin := 24
    endx   := x + w
    endy   := y + h

    X := x + margin 
    Y := Y + margin 
    EndX := endx - margin 
    EndY := endy - margin 


    if ( h <=  MIN_HEIGHT or w <= MIN_WIDTH )
        return False

    MidX := (X + EndX) // 2 
    MidY := Y + EndY // 2 
    hwnd := this_id
    pixleCount := (hwnd == WindowFromPoint(X, Y) ? 1 : 0)
        + (hwnd == WindowFromPoint(X, EndY) ? 1 : 0)
        + (hwnd == WindowFromPoint(EndX, Y) ? 1 : 0)
        + (hwnd == WindowFromPoint(EndX, EndY) ? 1 : 0)
        + (hwnd == WindowFromPoint(MidX, MidY) ? 1 : 0)

    if (pixleCount < 3 ) {
        WinMinimize, ahk_id %this_id%
        return False 
    }


    x := round( x / resolution ) * resolution
    y := round( y / resolution ) * resolution
    endx := round( endx / resolution ) * resolution
    endy := round( endy / resolution ) * resolution

    borders := 0x0 
    count := 0
    if (x <= padx){
        x := -1 * padx
        borders := borders | B_LEFT
        count++
    }else {
        x := x - gpadx
    }
    if (y <= pady){
        up := true
        y := -1 * pady
        borders := borders | B_TOP
        count++
    }else{
        y := y - gpady
    }
    if ( endx >= screenWidth - padx){
        right := true
        endx := screenWidth + padx
        borders := borders | B_RIGHT
        count++
    }else{
        endx := endx + gpadx
    }

    if ( endy >= screenHeight - pady){
        down := true
        endy := screenHeight + pady
        borders := borders | B_BOTTOM
        count++
    }else{
        endy := endy + gpady
    }

    if ( count <= 1 ){
        FloatWindows.push(this_id)
        return False 
    }




    winCorners := ( borders << 1 ) & ( borders >> 1 )
    emptyCornerMap := emptyCornerMap & ~winCorners
   

    winGroups[(winCorners & W_CORNER1)] := this_id
    winGroups[(winCorners & W_CORNER2)] := this_id
    winGroups[(winCorners & W_CORNER3)] := this_id
    winGroups[(winCorners & W_CORNER4)] := this_id
    
    

    winAttributes[(this_id)] := {borders : borders, corners: winCorners, borderCount:count, x:x, y:y, endx:endx, endy:endy,newx : x, newy : y, newendx : endx, newendy : endy, title:title}
    VisibleWindows.push(this_id)

    return True 
}

WindowFromPoint(X, Y) {
    return DllCall("GetAncestor", "UInt", DllCall("WindowFromPoint", "UInt64", X | (Y << 32)), "UInt", 2)
}

GetVisibleWindows() {
    WinGet, windowCount, List
    Loop, %windowCount% {
        this_id := windowCount%A_Index%
        IsWindowVisible( this_id) ;"ahk_id " .
    }
}

; ************************************************************************
; **************************** Utility Functions *************************
; ************************************************************************

smoothResize(winid, anchor, newWidth, newHeight,x, y, curWidth, curHeight) {
    dx := newWidth - curWidth
    dy := newHeight - curHeight
                                                          
    rightEdge := x + curWidth
    bottomEdge := y + curHeight
    steps := 1
                                                        
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



#v::  ;
    TestGetVisibleWindow()
    return  

TestGetVisibleWindow() {
    global 
    VisibleWindows := [] 
    winAttributes := {}
    winGroups := {}
    local output , attr , this_id
    if ( not DECLARED ){
        declareGlobalVariables()
    }
    GetVisibleWindows( )
    output := ""
    Loop % VisibleWindows.Length(){
        this_id := visibleWindows[A_Index]
        attr := winAttributes[this_id]
        output .= AttributesToString(A_Index, attr)
    }
    for key, value in winGroups{
        output .= key . " : " . winAttributes[value].title  . "`n"
    }
    if (output = ""){
        MsgBox, 0x1000,Visible Windows, No truly visible windows found.
    }else{
        MsgBox, 0x1000,Visible Windows, % "Really visible windows:`n" . output
    }

}

#w::  
    TestIsWindowVisible() 
    return



TestIsWindowVisible(){
    global ;
    
    if ( not DECLARED ){
        declareGlobalVariables()
    }

    VisibleWindows := [] 
    winAttributes := {}

    local winid , visible , attr


    winid := WinExist("A")
    visible := IsWindowVisible( "ahk_id " . winid)
    attr := winAttributes[winid]
    if ( VisibleWindows.Length() > 0 ){
        ;MsgBox, 0x1000,Active Window Attributes,%  "there are " . (VisibleWindows.Length() ) . "visible windows found."
    }
    if (visible){
        if ( not attr ){
            ;MsgBox, 0x1000,Active Window Attributes, No attributes found.
        } else {
            ;MsgBox, 0x1000,Active Window Attributes, % AttributesToString(1, attr)
            Gui, New, +Resize   +AlwaysOnTop, Visible Windows Neighbours
            Gui, Add, Edit, w800 h600 ReadOnly vOutput, % AttributesToString(1, attr)        
            Gui, Show, , Visible Windows Neighbours
        }
    }
    else{
        MsgBox, 0x1000,Active Window Attributes, No visible window found.
    }
    return
}



AttributesToString(index , attr){
    global
    local  output_string , horiz_string , horiz_empty , vert_left_string , vert_right_string , vert_both_string , vert_dict , corner_string , coord 


    borders := attr.borders
    corners := attr.corners
    ; specially border should be displayed in a readable way in a multi line string 
    ; corner will be diplayed in same ( text ) diagram as border , for instance if a window has left-bottom-top , it could be diplayed as....
    ;  + ------
    ;  |
    ;  |
    ;  + ------ 
    ;write the algorithm to display the border and corner in a readable way

    coord := "X: " . attr.x . "    Y: " . attr.y . "    EndX: " . attr.endx . "    EndY: " . attr.endy
    horiz_string := " --------- "
    horiz_empty :=  "           "
    vert_left_string := "|`n|`"
    vert_right_string := "               |`n               |"
    vert_both_string :=  "|              |`n|              |"
    vert_dict := { (B_LEFT) : vert_left_string , (B_RIGHT) : vert_right_string , (B_HORIZONTAL) : vert_both_string }

    corner_string := "+"
    output_string := "( " . index . " ) Window : "  . attr.title . "`n"
    output_string .= (corners & W_CORNER1) ? corner_string : " "
    output_string .= (borders & B_TOP) ? horiz_string : horiz_empty
    output_string .= (corners & W_CORNER2) ? corner_string : " "
    output_string .= "`n"
    output_string .= vert_dict[borders & B_HORIZONTAL] . "           " . coord . "`n"
    output_string .= (corners & W_CORNER4) ? corner_string : " "
    output_string .= (borders & B_BOTTOM) ? horiz_string : horiz_empty
    output_string .= (corners & W_CORNER3) ? corner_string : " "

    output_string .= "`n`n`n`n"
    ; now x ,y , endx , endy should be displayed in a readable way
    return output_string
}


;#t::  
    ;results := ""
    ;visibleWindows := GetVisibleWindows()
;
    ;if (visibleWindows.Length() = 0) {
        ;MsgBox, 0x1000,Neighbours, No visible windows found.
        ;return
    ;}
;
    ;for index, winid in visibleWindows {
        ;compArray := []  
        ;oppArray := []
;
        ;orientation := getNeighbours(winid, compArray, oppArray)
;
        ;companions := ArrayToTitleString(compArray)
        ;opponents := ArrayToTitleString(oppArray)
;
        ;WinGetTitle, title, ahk_id %winid%
        ;if (title = "")
            ;title := "Untitled Window"
;
        ;results .= "Window: " . title . "`n"
        ;results .= "Orientation: " . orientation . "`n"
        ;results .= "Companions: " . (companions ? companions : "None") . "`n"
        ;results .= "Opponents: " . (opponents ? opponents : "None") . "`n"
        ;results .= "--------------------------`n"
    ;}
;
    ;Gui, New, +Resize   +AlwaysOnTop, Visible Windows Neighbours
    ;Gui, Add, Edit, w800 h600 ReadOnly vOutput, %results%
    ;Gui, Show, , Visible Windows Neighbours
;return
;
;ArrayToTitleString(arr) {
    ;str := ""
    ;for index, val in arr {
        ;WinGetTitle, title, ahk_id %val%
        ;if (title = "")
            ;title := "Untitled Window"
        ;str .= title . ", "
    ;}
    ;if (StrLen(str) > 0)
        ;str := SubStr(str, 1, -2)  
    ;return str
;}


#r::  
    WinGet, winid, ID, A
    fullWidth := A_ScreenWidth
    fullHeight := A_ScreenHeight
    quarterWidth := fullWidth / 2
    quarterHeight := fullHeight / 2
    duration := 0 

    WinMove, ahk_id %winid%, , 0, 0, fullWidth, fullHeight
    Sleep, 500 

    Loop, 4 {
        anchor := A_Index

       WinGetPos, x, y, curWidth, curHeight, ahk_id %winid%
        smoothResize(winid, anchor, quarterWidth, quarterHeight, x, y, curWidth, curHeight)
        Sleep, 500 
       WinGetPos, x, y, curWidth, curHeight, ahk_id %winid%
        smoothResize(winid, anchor, fullWidth, fullHeight, x, y, curWidth, curHeight)
        Sleep, 500 
    }
return










#^h::
    LoadGlobalVariables()
    MoveEdge( B_HORIZONTAL, B_LEFT , -1)
    ;MoveEdge( 1 , -1)
    return
#^l::
    LoadGlobalVariables()
    MoveEdge( B_HORIZONTAL, B_RIGHT , 1)
    return
#^k::
    LoadGlobalVariables()
    MoveEdge( B_VERTICAL, B_TOP , -1)
    return
#^j::
    LoadGlobalVariables()
    MoveEdge( B_VERTICAL, B_BOTTOM , 1)
    return
