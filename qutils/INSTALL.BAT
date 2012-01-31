cd qlumpy
nmake /f "qlumpy.mak" CFG="qlumpy - Win32 Release"
copy release\qlumpy.exe \quake\bin_nt

cd ..\texmake
nmake /f "texmake.mak" CFG="texmake - Win32 Release"
copy release\texmake.exe \quake\bin_nt

cd ..\modelgen
nmake /f "modelgen.mak" CFG="modelgen - Win32 Release"
copy release\modelgen.exe \quake\bin_nt

cd ..\sprgen
nmake /f "sprgen.mak" CFG="sprgen - Win32 Release"
copy release\sprgen.exe \quake\bin_nt


cd ..\qbsp
nmake /f "qbsp.mak" CFG="qbsp - Win32 Release"
copy release\qbsp.exe \quake\bin_nt

cd ..\light
nmake /f "light.mak" CFG="light - Win32 Release"
copy release\light.exe \quake\bin_nt

cd ..\vis
nmake /f "vis.mak" CFG="vis - Win32 Release"
copy release\vis.exe \quake\bin_nt

cd ..\bspinfo
nmake /f "bspinfo.mak" CFG="bspinfo - Win32 Release"
copy release\bspinfo.exe \quake\bin_nt


cd ..\qcc
nmake /f "qcc.mak" CFG="qcc - Win32 Release"
copy release\qcc.exe \quake\bin_nt

cd ..\qfiles
nmake /f "qfiles.mak" CFG="qfiles - Win32 Release"
copy release\qfiles.exe \quake\bin_nt

cd ..
