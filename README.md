# NOTE:

this project is temporary , and should soon be deprecated , because of poor language feater and developement enviroment.

I may use compination of pwsh script or small c++ programm and windows lib to make these feature without use of ahk .




this file ( [MS-LCID]-210625.pdf ) contains the different language codes used by some of the script , it can be found in internet .


## to compile a script you need to :

1. download ahk v1 ( v2 is very very bad , has no support at all )

2. use following command :
```bash
compiler_U32.exe /in your_script.ahk1 /out output.exe /bin path_to_bin
```
[bin can be found in the same compiler directory.

3. to avoid compiler issues name all script [.ahk1] , "1" at the end !!!.

4. you can also run the script directly without compilation using ahk_u32 main program [ have not tested it yet ]

5. vscode has support for ahk , but vim does not.


