# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=qbsp - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to qbsp - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "qbsp - Win32 Release" && "$(CFG)" != "qbsp - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "qbsp.mak" CFG="qbsp - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qbsp - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qbsp - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "qbsp - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "qbsp - Win32 Release"

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

ALL : "$(OUTDIR)\qbsp.exe"

CLEAN : 
	-@erase ".\Release\qbsp.exe"
	-@erase ".\Release\mathlib.obj"
	-@erase ".\Release\solidbsp.obj"
	-@erase ".\Release\portals.obj"
	-@erase ".\Release\surfaces.obj"
	-@erase ".\Release\nodraw.obj"
	-@erase ".\Release\cmdlib.obj"
	-@erase ".\Release\csg4.obj"
	-@erase ".\Release\brush.obj"
	-@erase ".\Release\merge.obj"
	-@erase ".\Release\map.obj"
	-@erase ".\Release\region.obj"
	-@erase ".\Release\bspfile.obj"
	-@erase ".\Release\writebsp.obj"
	-@erase ".\Release\outside.obj"
	-@erase ".\Release\qbsp.obj"
	-@erase ".\Release\tjunc.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/qbsp.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/qbsp.pdb" /machine:I386 /out:"$(OUTDIR)/qbsp.exe" 
LINK32_OBJS= \
	".\Release\mathlib.obj" \
	".\Release\solidbsp.obj" \
	".\Release\portals.obj" \
	".\Release\surfaces.obj" \
	".\Release\nodraw.obj" \
	".\Release\cmdlib.obj" \
	".\Release\csg4.obj" \
	".\Release\brush.obj" \
	".\Release\merge.obj" \
	".\Release\map.obj" \
	".\Release\region.obj" \
	".\Release\bspfile.obj" \
	".\Release\writebsp.obj" \
	".\Release\outside.obj" \
	".\Release\qbsp.obj" \
	".\Release\tjunc.obj"

"$(OUTDIR)\qbsp.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

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

ALL : "$(OUTDIR)\qbsp.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\qbsp.exe"
	-@erase ".\Debug\region.obj"
	-@erase ".\Debug\mathlib.obj"
	-@erase ".\Debug\csg4.obj"
	-@erase ".\Debug\portals.obj"
	-@erase ".\Debug\surfaces.obj"
	-@erase ".\Debug\tjunc.obj"
	-@erase ".\Debug\nodraw.obj"
	-@erase ".\Debug\outside.obj"
	-@erase ".\Debug\map.obj"
	-@erase ".\Debug\bspfile.obj"
	-@erase ".\Debug\solidbsp.obj"
	-@erase ".\Debug\brush.obj"
	-@erase ".\Debug\merge.obj"
	-@erase ".\Debug\qbsp.obj"
	-@erase ".\Debug\cmdlib.obj"
	-@erase ".\Debug\writebsp.obj"
	-@erase ".\Debug\qbsp.ilk"
	-@erase ".\Debug\qbsp.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/qbsp.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/qbsp.pdb" /debug /machine:I386 /out:"$(OUTDIR)/qbsp.exe" 
LINK32_OBJS= \
	".\Debug\region.obj" \
	".\Debug\mathlib.obj" \
	".\Debug\csg4.obj" \
	".\Debug\portals.obj" \
	".\Debug\surfaces.obj" \
	".\Debug\tjunc.obj" \
	".\Debug\nodraw.obj" \
	".\Debug\outside.obj" \
	".\Debug\map.obj" \
	".\Debug\bspfile.obj" \
	".\Debug\solidbsp.obj" \
	".\Debug\brush.obj" \
	".\Debug\merge.obj" \
	".\Debug\qbsp.obj" \
	".\Debug\cmdlib.obj" \
	".\Debug\writebsp.obj"

"$(OUTDIR)\qbsp.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "qbsp - Win32 Release"
# Name "qbsp - Win32 Debug"

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\writebsp.c
DEP_CPP_WRITE=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\writebsp.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\tjunc.c
DEP_CPP_TJUNC=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\tjunc.obj" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\surfaces.c
DEP_CPP_SURFA=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\surfaces.obj" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\solidbsp.c
DEP_CPP_SOLID=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\solidbsp.obj" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\region.c
DEP_CPP_REGIO=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\region.obj" : $(SOURCE) $(DEP_CPP_REGIO) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\qbsp.c
DEP_CPP_QBSP_=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\qbsp.obj" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\portals.c
DEP_CPP_PORTA=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\portals.obj" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\outside.c
DEP_CPP_OUTSI=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\outside.obj" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\nodraw.c
DEP_CPP_NODRA=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\nodraw.obj" : $(SOURCE) $(DEP_CPP_NODRA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\merge.c
DEP_CPP_MERGE=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\merge.obj" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\map.c
DEP_CPP_MAP_C=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\csg4.c
DEP_CPP_CSG4_=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\csg4.obj" : $(SOURCE) $(DEP_CPP_CSG4_) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\brush.c
DEP_CPP_BRUSH=\
	".\bsp5.h"\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	".\..\common\bspfile.h"\
	".\map.h"\
	

"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"


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

SOURCE=\quake\utils2\common\mathlib.c
DEP_CPP_MATHL=\
	".\..\common\cmdlib.h"\
	".\..\common\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\mathlib.h

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\cmdlib.h

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\bspfile.h

!IF  "$(CFG)" == "qbsp - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp - Win32 Debug"

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
