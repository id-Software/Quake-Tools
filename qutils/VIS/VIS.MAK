# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=vis - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to vis - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "vis - Win32 Release" && "$(CFG)" != "vis - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "vis.mak" CFG="vis - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "vis - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "vis - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "vis - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "vis - Win32 Release"

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

ALL : "$(OUTDIR)\vis.exe"

CLEAN : 
	-@erase ".\Release\vis.exe"
	-@erase ".\Release\soundpvs.obj"
	-@erase ".\Release\vis.obj"
	-@erase ".\Release\bspfile.obj"
	-@erase ".\Release\flow.obj"
	-@erase ".\Release\cmdlib.obj"
	-@erase ".\Release\mathlib.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/vis.pdb" /machine:I386 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)/soundpvs.obj" \
	"$(INTDIR)/vis.obj" \
	"$(INTDIR)/bspfile.obj" \
	"$(INTDIR)/flow.obj" \
	"$(INTDIR)/cmdlib.obj" \
	"$(INTDIR)/mathlib.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

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

ALL : "$(OUTDIR)\vis.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\vis.exe"
	-@erase ".\Debug\mathlib.obj"
	-@erase ".\Debug\vis.obj"
	-@erase ".\Debug\cmdlib.obj"
	-@erase ".\Debug\flow.obj"
	-@erase ".\Debug\bspfile.obj"
	-@erase ".\Debug\soundpvs.obj"
	-@erase ".\Debug\vis.ilk"
	-@erase ".\Debug\vis.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/vis.pdb" /debug /machine:I386 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)/mathlib.obj" \
	"$(INTDIR)/vis.obj" \
	"$(INTDIR)/cmdlib.obj" \
	"$(INTDIR)/flow.obj" \
	"$(INTDIR)/bspfile.obj" \
	"$(INTDIR)/soundpvs.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "vis - Win32 Release"
# Name "vis - Win32 Debug"

!IF  "$(CFG)" == "vis - Win32 Release"

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\vis.c
DEP_CPP_VIS_C=\
	".\vis.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	

"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\soundpvs.c
DEP_CPP_SOUND=\
	".\vis.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	

"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\flow.c
DEP_CPP_FLOW_=\
	".\vis.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	

"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"


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

SOURCE=\quake\utils2\common\bspfile.c
DEP_CPP_BSPFI=\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


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
# End Target
# End Project
################################################################################
