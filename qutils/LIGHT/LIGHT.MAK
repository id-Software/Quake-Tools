# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=light - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to light - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "light - Win32 Release" && "$(CFG)" != "light - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "light.mak" CFG="light - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "light - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "light - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "light - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "light - Win32 Release"

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

ALL : "$(OUTDIR)\light.exe"

CLEAN : 
	-@erase ".\Release\light.exe"
	-@erase ".\Release\trilib.obj"
	-@erase ".\Release\threads.obj"
	-@erase ".\Release\mathlib.obj"
	-@erase ".\Release\light.obj"
	-@erase ".\Release\entities.obj"
	-@erase ".\Release\bspfile.obj"
	-@erase ".\Release\ltface.obj"
	-@erase ".\Release\cmdlib.obj"
	-@erase ".\Release\trace.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/light.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/light.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/light.pdb" /machine:I386 /out:"$(OUTDIR)/light.exe" 
LINK32_OBJS= \
	".\Release\trilib.obj" \
	".\Release\threads.obj" \
	".\Release\mathlib.obj" \
	".\Release\light.obj" \
	".\Release\entities.obj" \
	".\Release\bspfile.obj" \
	".\Release\ltface.obj" \
	".\Release\cmdlib.obj" \
	".\Release\trace.obj"

"$(OUTDIR)\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

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

ALL : "$(OUTDIR)\light.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\light.exe"
	-@erase ".\Debug\threads.obj"
	-@erase ".\Debug\trilib.obj"
	-@erase ".\Debug\bspfile.obj"
	-@erase ".\Debug\light.obj"
	-@erase ".\Debug\trace.obj"
	-@erase ".\Debug\entities.obj"
	-@erase ".\Debug\mathlib.obj"
	-@erase ".\Debug\ltface.obj"
	-@erase ".\Debug\cmdlib.obj"
	-@erase ".\Debug\light.ilk"
	-@erase ".\Debug\light.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/light.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/light.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/light.pdb" /debug /machine:I386 /out:"$(OUTDIR)/light.exe" 
LINK32_OBJS= \
	".\Debug\threads.obj" \
	".\Debug\trilib.obj" \
	".\Debug\bspfile.obj" \
	".\Debug\light.obj" \
	".\Debug\trace.obj" \
	".\Debug\entities.obj" \
	".\Debug\mathlib.obj" \
	".\Debug\ltface.obj" \
	".\Debug\cmdlib.obj"

"$(OUTDIR)\light.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "light - Win32 Release"
# Name "light - Win32 Debug"

!IF  "$(CFG)" == "light - Win32 Release"

!ELSEIF  "$(CFG)" == "light - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\trace.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_TRACE=\
	".\light.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_TRACE=\
	".\light.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\entities.h"\
	".\threads.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\threads.c
DEP_CPP_THREA=\
	".\..\common\cmdlib.h"\
	".\threads.h"\
	

"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\ltface.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_LTFAC=\
	".\light.h"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_LTFAC=\
	".\light.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\entities.h"\
	".\threads.h"\
	

"$(INTDIR)\ltface.obj" : $(SOURCE) $(DEP_CPP_LTFAC) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\light.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_LIGHT=\
	".\light.h"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_LIGHT=\
	".\light.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\entities.h"\
	".\threads.h"\
	

"$(INTDIR)\light.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\entities.c

!IF  "$(CFG)" == "light - Win32 Release"

DEP_CPP_ENTIT=\
	".\light.h"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "light - Win32 Debug"

DEP_CPP_ENTIT=\
	".\light.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\entities.h"\
	".\threads.h"\
	

"$(INTDIR)\entities.obj" : $(SOURCE) $(DEP_CPP_ENTIT) "$(INTDIR)"


!ENDIF 

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
# End Target
# End Project
################################################################################
