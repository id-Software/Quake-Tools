# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=texmake - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to texmake - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "texmake - Win32 Release" && "$(CFG)" !=\
 "texmake - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "texmake.mak" CFG="texmake - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "texmake - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "texmake - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "texmake - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "texmake - Win32 Release"

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

ALL : "$(OUTDIR)\texmake.exe"

CLEAN : 
	-@erase ".\Release\texmake.exe"
	-@erase ".\Release\mathlib.obj"
	-@erase ".\Release\cmdlib.obj"
	-@erase ".\Release\lbmlib.obj"
	-@erase ".\Release\trilib.obj"
	-@erase ".\Release\texmake.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/texmake.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/texmake.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/texmake.pdb" /machine:I386 /out:"$(OUTDIR)/texmake.exe" 
LINK32_OBJS= \
	".\Release\mathlib.obj" \
	".\Release\cmdlib.obj" \
	".\Release\lbmlib.obj" \
	".\Release\trilib.obj" \
	".\Release\texmake.obj"

"$(OUTDIR)\texmake.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "texmake - Win32 Debug"

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

ALL : "$(OUTDIR)\texmake.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\texmake.exe"
	-@erase ".\Debug\cmdlib.obj"
	-@erase ".\Debug\lbmlib.obj"
	-@erase ".\Debug\trilib.obj"
	-@erase ".\Debug\mathlib.obj"
	-@erase ".\Debug\texmake.obj"
	-@erase ".\Debug\texmake.ilk"
	-@erase ".\Debug\texmake.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/texmake.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/texmake.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/texmake.pdb" /debug /machine:I386 /out:"$(OUTDIR)/texmake.exe" 
LINK32_OBJS= \
	".\Debug\cmdlib.obj" \
	".\Debug\lbmlib.obj" \
	".\Debug\trilib.obj" \
	".\Debug\mathlib.obj" \
	".\Debug\texmake.obj"

"$(OUTDIR)\texmake.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "texmake - Win32 Release"
# Name "texmake - Win32 Debug"

!IF  "$(CFG)" == "texmake - Win32 Release"

!ELSEIF  "$(CFG)" == "texmake - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\texmake.c
DEP_CPP_TEXMA=\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\lbmlib.h"\
	".\..\common\trilib.h"\
	

"$(INTDIR)\texmake.obj" : $(SOURCE) $(DEP_CPP_TEXMA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\mathlib.c
DEP_CPP_MATHL=\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
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

SOURCE=\quake\utils2\common\trilib.c
DEP_CPP_TRILI=\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\trilib.h"\
	

"$(INTDIR)\trilib.obj" : $(SOURCE) $(DEP_CPP_TRILI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
# End Target
# End Project
################################################################################
