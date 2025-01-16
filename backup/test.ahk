#q::
    ;WinIdTest()
    bitwiseTEST()
    ;TestList()    
    return

WinIdTest(){
    winid := WinExist("A")
    len1 := strLen("")
    msg := winid . "_"
    len2 := strLen( msg)
    msg := winid . "_" . winid . "_"
    len3 := strLen(msg)
     
    msgBox , % "Len1 is: " . len1 "`nLen2 is: " . len2 . "`nlen3 is: " . len3

}

TestList(){
value1 := 0x1
value2 := 0x2
value3 := 0x4
 listA := {  (value1) : "hallo", ( value2  ) : "world", ( value3  ) : "test" }

value1Out := listA[value1]
value2Out := listA[value2]
value3Out := listA[value3]

msg := value1 . " : " . value1Out . "`n" . value2 . " : " . value2Out . "`n" . value3 . " : " . listA[value3] . "`n" 


 for key, value in listA{
    msg .= key . " : " . value . "`n"
 }

 msgBox, % msg 
}

bitwiseTEST(){
    valueOne := 0x1
    ;shift left
    value1 := valueOne << 0
    value2 := valueOne << 1
    value3 := valueOne << 2
    value5 := valueOne << 5
    value10 := valueOne << 10 
    test1 := 3 & value1
    test2 := 3 & value2
    test3 := 3 & value3




    debugMsg := "valueOne: " . value1 . "`n" . "value2: " . value2 . "`n" . "value3: " . value3 . "`n" . "value5: " . value5 . "`n" . "value10: " . value10
    resultMsg := "test1: " . test1 . "`n" . "test2: " . test2 . "`n" . "test3: " . test3
    ;msgbox , % debugMsg . "`n" . resultMsg 




    ;shift cycle test : schift vauue 1 till it cycle back to 1
    valueOne := 0x1
    value := valueOne
    counter := 0 
    loop, 100{
        value := value << 1
        counter++ 
        if(value <= 1){
            break
        }
    }
    ;msgbox, % counter 


    ; start with value 0xF and shift it back till 0x1 , save all value in string
    
    testValue := 0x1010100010000
    value := TestValue
    ;if (value & 0x1){
        ;value := value | ( 0x1 << (8 * 4))
    ;}
    rightShift := value >> 4 
    leftShift := value << 4 
    both := rightShift & leftShift
    originalValue :=  Format("{1:#x}`r`n", testValue) 
    rightShiftValue :=  Format("{1:#x}`r`n", rightShift)
    leftShiftValue :=  Format("{1:#x}`r`n", leftShift) 
    bothValue :=  Format("{1:#x}`r`n", both)
    msgbox, % originalValue . "`n" . rightShiftValue . "`n" . leftShiftValue . "`n" . bothValue
    ;counter := 0
    ;valueString := ""
    ;loop, 100{
        ;value := value >> 1
        ;counter++ 
        ;valueString .=  Format("1:#x}`r`n", )
        ;if(value <= -9){
            ;break
        ;}
    ;}

    ;msgbox, % valueString
 ;

}


bitwiseTEST2(){


}
