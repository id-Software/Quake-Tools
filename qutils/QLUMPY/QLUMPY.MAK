# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=qlumpy - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to qlumpy - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "qlumpy - Win32 Release" && "$(CFG)" != "qlumpy - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "qlumpy.mak" CFG="qlumpy - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qlumpy - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qlumpy - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "qlumpy - Win32 Debug"
RSC=rc.exe
CPP=cl.exe

!IF  "$(CFG)" == "qlumpy - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\qlumpy.exe"

CLEAN : 
	-@erase ".\Release\qlumpy.exe"
	-@erase ".\Release\quakegrb.obj"
	-@erase ".\Release\qlumpy.obj"
	-@erase ".\Release\wadlib.obj"
	-@erase ".\Release\scriplib.obj"
	-@erase ".\Release\cmdlib.obj"
	-@erase ".\Release\lbmlib.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/qlumpy.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qlumpy.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/qlumpy.pdb" /machine:I386 /out:"$(OUTDIR)/qlumpy.exe" 
LINK32_OBJS= \
	".\Release\quakegrb.obj" \
	".\Release\qlumpy.obj" \
	".\Release\wadlib.obj" \
	".\Release\scriplib.obj" \
	".\Release\cmdlib.obj" \
	".\Release\lbmlib.obj"

"$(OUTDIR)\qlumpy.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qlumpy - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\qlumpy.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\qlumpy.exe"
	-@erase ".\Debug\lbmlib.obj"
	-@erase ".\Debug\scriplib.obj"
	-@erase ".\Debug\cmdlib.obj"
	-@erase ".\Debug\qlumpy.obj"
	-@erase ".\Debug\quakegrb.obj"
	-@erase ".\Debug\wadlib.obj"
	-@erase ".\Debug\qlumpy.ilk"
	-@erase ".\Debug\qlumpy.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/qlumpy.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qlumpy.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/qlumpy.pdb" /debug /machine:I386 /out:"$(OUTDIR)/qlumpy.exe" 
LINK32_OBJS= \
	".\Debug\lbmlib.obj" \
	".\Debug\scriplib.obj" \
	".\Debug\cmdlib.obj" \
	".\Debug\qlumpy.obj" \
	".\Debug\quakegrb.obj" \
	".\Debug\wadlib.obj"

"$(OUTDIR)\qlumpy.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "qlumpy - Win32 Release"
# Name "qlumpy - Win32 Debug"

!IF  "$(CFG)" == "qlumpy - Win32 Release"

!ELSEIF  "$(CFG)" == "qlumpy - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\quakegrb.c

!IF  "$(CFG)" == "qlumpy - Win32 Release"

DEP_CPP_QUAKE=\
	".\qlumpy.h"\
	".\..\common\cmdlib.h"\
	".\..\common\scriplib.h"\
	".\..\common\lbmlib.h"\
	".\..\common\wadlib.h"\
	

"$(INTDIR)\quakegrb.obj" : $(SOURCE) $(DEP_CPP_QUAKE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qlumpy - Win32 Debug"

DEP_CPP_QUAKE=\
	".\qlumpy.h"\
	".\..\common\cmdlib.h"\
	".\..\common\scriplib.h"\
	".\..\common\lbmlib.h"\
	

"$(INTDIR)\quakegrb.obj" : $(SOURCE) $(DEP_CPP_QUAKE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qlumpy.c

!IF  "$(CFG)" == "qlumpy - Win32 Release"

DEP_CPP_QLUMP=\
	".\qlumpy.h"\
	".\..\common\cmdlib.h"\
	".\..\common\scriplib.h"\
	".\..\common\lbmlib.h"\
	".\..\common\wadlib.h"\
	

"$(INTDIR)\qlumpy.obj" : $(SOURCE) $(DEP_CPP_QLUMP) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qlumpy - Win32 Debug"

DEP_CPP_QLUMP=\
	".\qlumpy.h"\
	".\..\common\cmdlib.h"\
	".\..\common\scriplib.h"\
	".\..\common\lbmlib.h"\
	

"$(INTDIR)\qlumpy.obj" : $(SOURCE) $(DEP_CPP_QLUMP) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\cmdlib.c
DEP_CPP_CMDLI=\
	".\..\common\cmdlib.h"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	{$(INCLUDE)}"\sys\STAT.H"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\scriplib.c
DEP_CPP_SCRIP=\
	".\..\common\cmdlib.h"\
	".\..\common\scriplib.h"\
	

"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\wadlib.c
DEP_CPP_WADLI=\
	{$(INCLUDE)}"\sys\TYPES.H"\
	{$(INCLUDE)}"\sys\STAT.H"\
	".\..\common\cmdlib.h"\
	".\..\common\wadlib.h"\
	

"$(INTDIR)\wadlib.obj" : $(SOURCE) $(DEP_CPP_WADLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\lbmlib.c
DEP_CPP_LBMLI=\
	".\..\common\cmdlib.h"\
	".\..\common\lbmlib.h"\
	

"$(INTDIR)\lbmlib.obj" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
# End Target
# End Project
################################################################################
