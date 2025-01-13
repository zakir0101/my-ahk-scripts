# prompt 1

I want to create autohotkey script (v1) that will do the following:

1. navigate visible windows with 'win+[dir]', where dir one of (j = down , k = up, h = left, l = right)

2. increase window size with 'win+shift+[dir]' (same directions) , where l/h will increase/decrease width and j/k will increase/decrease height.

3. minimize window with 'win+m'

4. close window with 'win+w'

5. 'win+alt+[dir]' will move window to the edge of the screen in the direction of dir.consider following rules :
    - if it was aligned to the left, and the direction is right, it will align to the right, and vice versa.
    - if window was maximized, and dir was right, it will align to the right + set width to 50% of the screen width (and vice versa)

## some rules :
a. windows are either aligned to the left or right of the screen, and they are not overlapping.
b. windows are either aligned to the top or bottom of the screen, and they are not overlapping.
c. maximum number of windows is 4, and they are aligned to the corners of the screen.


[ summary : I want the behavior of the windows to be similar to vim/neovim , where I can navigate between windows and resize them easily. if you now other way to accomplish this please let me know. ]


# prompt 2
okay , that was not a bad start.

lets consider the following workflow or use case , describing the journy of a user who only want to use or shortcut for opening,moving and resizing windows ( on windows 11 os ) , so basicly the user has 4 programs installed A,B,C,D , and we will imagine a couple of scenarios :

## scenario 1
start position : all programs are minimized 
end position : 3 programs are opened , C at the bottom ( full screen width ) and A , B at the top ( each one is half of the screen width )

the user start by opening program A ( which open maximized ), he press win+alt+h to move it to the left,
after that he resize width of the window using (win+shift+left) to increase the width of the window,
then he press some shortcut like win+o for instance to open the selecter (XamlExplorerHostIslandWindow )  and select one window which then fill the remaining gap on the right side of the screen.

### requirements :

for this senirio we need to:
1. modify the behavior of the move function so that it additionally set the width of the window to 50% of the screen width if the window was maximized , before moving it to the left or right. for verical movement it should work the same way.
2.create function that intercept the win+o shortcut and some how open the selecter (XamlExplorerHostIslandWindow ) and select the window that the user want to open, and put it in the empty place 


[ for now I just need you to do this , we will discuss the other scenarios later ]




# prompt 3

now I want you to help me write a couple of utility functions that will help us later .

## utility function 1 : get_border_count 

signature : get_border_count(winid , byref left , byref bottom, byref right , byref top) -> int
arguments all except winid are byref boolean , and they will be set to true if the window is aligned to the corresponding border of the screen.

alo write a simple test for the function ( forinstance you set any keybind to call the function and display the result in a message box )


# prompt 4

## 2. Uitlity function 2 : is_window_visible

here we want to determine if a window is really visible on screen ( not style visible ) , we will follow this approach I found on the internet :


'''
Whether a window is visible on the screen is less of a yes-no question, but rather "how much of a window has to be visible for it to be considered visible?". Does the window have to be 100% visible, not hidden behind anything nor offscreen? What if 1 pixel of the window is hidden - is the window still visible? 10% of the window hidden? 50%?

You could use WindowFromPoint DllCall to hit-test every single point of the window and calculate the visible percentage, but I've usually settled for at least 3 points of 5 being visible: the 4 corners and the center. So at least 50% of the window needs to be visible in this case. This is what the following IsWindowVisible function does:
; True if at least 3 points of 5 of the window are visible (4 corners and the center point)
IsWindowVisible(win:="A") { 
    hwnd := WinExist(win)
    WinGetPos, X, Y, W, H, % win
    count := (hwnd == WindowFromPoint(X, Y) ? 1 : 0) + (hwnd == WindowFromPoint(X, Y+H-1) ? 1 : 0) + (hwnd == WindowFromPoint(X+W-1, Y) ? 1 : 0) + (hwnd == WindowFromPoint(X+W-1, Y+H-1) ? 1 : 0) + (hwnd == WindowFromPoint(X+W//2, Y+H//2) ? 1 : 0)
    if count > 2
        return True
    return False
}

WindowFromPoint(X, Y) { ; by SKAN and Linear Spoon
    return DllCall( "GetAncestor", "UInt"
            , DllCall( "WindowFromPoint", "UInt64", X | (Y << 32))
            , "UInt", GA_ROOT := 2 )
}

'''

your task is to write tests for this function , by displaying all currently (really) visible windows on screen , ( first you can filter by style visiblity to improve the performance ).

[ by the way style returen by WinGet has following convension , 1 == maximaized , -1 == minimized , 0 = any thing else , so we can filter the minimized ones at first ]



# prompt 5

## 3. Uitlity function 3 : get the Companion, Oponent And Orientation
let me explain first the concept of compantion :
- every window should at least be full width or full height ( if not both )
- if a window is not full width and not full height, then it should have other window (companion) which make it full width ( orientation = "horizontal" ) or it should have other window which make it full height ( orientation = "vertical" ) , both the window and its companion share one attribute ( either width or height ) , and complement each other in the other attribute to match the screen size.j
- if a window is only full width it has NO companion and its orientation is horizontal , and if it is only full height it has no companion and its orientation is vertical.

now let me explain the concept of oponent :
- after we determine the companion of a window, the remaning rectangle of the screen is considered openent area, it could be completly empty or have exactly one window or maximum 2 windows where the second one is the companion of the first one.
- if a window is both full width and full height , then it has no oponent and no companion, and its orientation is "full".

to find the companion and openent and orientation of a window , we could do the following :
- main entry point is getNeibours(byref companion , byref oponent ) -> orientation 
[ companion is either a single window or null, oponent is either null , array of one window or array of two windows ]
- and there are 2 other function getCompanion and getOponent which are called by getNeibours

first in getneibours we will determine the orientation of the window , then we will call getCompanion if we expect any , then getOpenent , and if we expect the openent to have a companion we will call getCompanion again.


# prompt 6
this was very intellegent from you , to break the problem into smaller parts, before starting with solution.

now I got more insight and I have a better Idea for increasing performance ...
we will have only one function getNeibours ,and it will work like this :
first we retrive all visible windows, and loop over them ...
for each visible window we use our function getBorderCount to check its boundry.
given that in my environment we each window should at least have to border aligned to the screen , we can easly find out wether its compantion, oponent and orientation.
and also considering the fact that we already know in advance how many visble windows we have , we can even simplify the process further .

what are your thoughts on this ?


# prompt 7

it look like we are not on the same page ...
consider the following .. visible windows can only be 4,3,2,1 or 0.
so we basicly have only four cases :

## first case :
getVisibleWindows returned 1 window to us ...
this mean the window is full width and full height , and it has no companion and no oponent.

## second case :
getVisibleWindows returned 2 windows to us ...
this mean both of them are openent to each other , and both have same orientation


## third case :
getVisibleWindows returned 3 windows to us ...
so there is only one possible case :
2 of them are companion exactly one of them is either full width or full height. and remaining 2 are companion.

## fourth case :
getVisibleWindows returned 4 windows to us ... ( most complex case )
this mean each window is aligned to one of the corners of the screen, 2 of them are companion and the other 2 are the oponent to the first 2.


given that the screen has 4 corners, and the each window has 4 borders ( where at least 2 of them are aligned , borderCount >= 2 ) 

in the  *first case* we expect that window to have borderCount = 4 , and henced solved no further calculation needed.

in the *second case* we expect that each window to have borderCount = 3 , and by checking the exact border we can determine the orientation ,  if bottom and top are both true .. then vertical , regradless of the third border.  and if left and right are true .. then horizontal , regardless of the third border .

in the *third case* we expect that one window to have borderCount = 3 and the other 2 to have borderCount = 2 , but of course they are not orderd , so we loop through them and once we find the one with borderCount = 3 we can determine its orientation, and given that we already know the "window in question" we can determine which of the other 2 is companion(??) and which is oponent. [ note that if the "window in question" is the one with borderCount = 3 , then it has no companion ]

in the *last case* we expect that each window to have borderCount = 2 , and when loopin through the other window ( excluding the "one in question") we check which for each one of the three the following condition :
- does it share  one of the 2 borders with the "window of question", if not its openent.
- if it shares one border , then we temporarly set the orientation accordinglly ( if both share right or left border then tempOrientation = "vertical", ..etc), then we check the dimesion of both in the dir opossite to the tempOrientation ( if vertical then we check width , if horizontal we check height ) , if they are equal then that one is a companion , otherwise its openent.

but there is only one *edge case* : 
- if there are four windows , and the "window in question" has height = 50% of Screen && width = 50% of the screen , then we can't determine its orientation , and we will end up having 2 companiions ( but each one has a different orientation ) which is confusing ...
umm ... let me think ....
its better to handle this edge case in its own code ( not using the same *fourth case* code ) ....
in this *edge case* we can set the orientation to a new value = "both" , and we make sure that the the companion list has the vertical companion first the horizontal one second , and the oponent the last remaining window only.


what are your thoughts ??


# prompt 8

just small correction , in *third case* , you should not JUST "Loop through windows to find the one with borderCount = 3" , instead you should normaly loop through all of them , once you find the one with borderCount = 3 , you can set the orientation, but also consider before checking the "window in question" ...

did you get it ?

# prompt 9

just some quick fix before I start testing the code ,

1- companion and oponent should always be array of windows , even if they are empty or have only one window.
2- in the *third case* , you wrote

```ahk
     ; Determine relationships for winid in a three-window scenario
        if (winid = specialID) {
            ; The window with borderCount 3 has no companion; others are opponents
            companion := ""
            opponents := []  ; using an AutoHotkey array for opponents
            for index, wid in visibleWindows {
                if (wid != winid)
                    opponents.Push(wid)
            }
            opponent := opponents
        } else {
            ; For winid with borderCount = 2, find its companion and opponent among the others.
            for index, wid in visibleWindows {
                if (wid = winid || wid = specialID)
                    continue
                ; Compare winid with each candidate to determine if they're companions
                b1 := borders[winid]
                b2 := borders[wid]
                share := false
                if (orientation = "horizontal" && ((b1.left && b2.left) || (b1.right && b2.right)))
                    share := true
                else if (orientation = "vertical" && ((b1.top && b2.top) || (b1.bottom && b2.bottom)))
                    share := true

                if (share) {
                    companion := wid
                } else {
                    ; Collect opponents in an array; could be one or more windows.
                    if (!IsObject(opponent))
                        opponent := []
                    opponent.Push(wid)
                }
            }
```

the else branch here is over complicated , if we already now that the larger one ( with count = 3 ) is not the "one in question" , then immediately it become oponent , and the other one become companion , so we can simplify the code further , wright ?

3- also please try to finish the general *fourth case* its really not that complicated ...

[ please don't send the whole thing again ]

# prompt 10

good , except for the general *fourth case* , please read this spec again , and try to implement it correctly , if you have question please ask me before writing code ...

'''
in the *last case* we expect that each window to have borderCount = 2 , and when loopin through the other window ( excluding the "one in question") we check which for each one of the three the following condition :
- does it share  one of the 2 borders with the "window of question", if not its openent.
- if it shares one border , then we temporarly set the orientation accordinglly ( if both share right or left border then tempOrientation = "vertical", ..etc), then we check the dimesion of both in the dir opossite to the tempOrientation ( if vertical then we check width , if horizontal we check height ) , if they are equal then that one is a companion , otherwise its openent.
'''

# Prompt 11

everthing is great , just a little modification and now the Neighbours function works perfectlly ( I will not send the modified code , because I changed verly little things )

now to next utility function ...

## Utility Function 4 : smoothResize( winid , anchor , newWdith , newHeight , duration )

the idea here the tradional way of resizing ( using winMov ) does alway assume that the anchor is top left corner of the window , and the window will be resized from that point , but what if we want to resize the window from the left side , it will be chunky , so I want to solve this problem..

one idea that I have is to increamently apply change ,for instance if we want to resize the window from the left side , we can start by moving the window to the left by dx pixel , and resize it by dx till finish the whole length.

what do you think , do you have better ideas or better suggestion regarding this algorithm or function signature ??

# Prompt 12

I did not look at your code , because I was not satisfied with way you defined the variable anchor , in my opinion it should be an integer either 1 ,2 3,  or 4 , where 1 is top left corner , and we go clockwise till 4 which is bottom left corner.


# prompt 13

lets write a test for it , in test the active window shodow be (normally ) resized to full screen , then using our new function we resize it to fit the first quartal (top-left) of the screen then also back to full using our new function , after that we resize it to the top right corner and back , and so on ... ( clockwise )


# prompt 14

now we want to modify the behavior of our old MoveEdge function , so that :

1. it really on our new function smoothResize ,whenever a resize is needed.
2. in addition to the old specification , we have these new requirments :
    - if the window is full height ( border top and bottom are true ) and the user try to move it to the top , then it should resize to a qurter of at top , and vice versa for bottom direction.
    - if the window is full width ( border left and right are true ) and the user try to move it to the left , then it should resize to a qurter of at left , and vice versa for right direction.
    - for now thats it , but after testing these features I have other requirments.
    


## old specification :
'''
1. increase window size with 'win+shift+[dir]' (same directions) , where l/h will increase/decrease width and j/k will increase/decrease height.

2. modify the behavior of the move function so that it additionally set the width of the window to 50% of the screen width if the window was maximized , before moving it to the left or right. for verical movement it should work the same way.


'''

# solve the equation :

screenWidth + padX = x + width
then 
width = screenWidth - x + padX


