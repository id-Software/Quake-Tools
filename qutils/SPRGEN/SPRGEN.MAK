# Microsoft Developer Studio Generated NMAKE File, Format Version 4.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=sprgen - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to sprgen - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "sprgen - Win32 Release" && "$(CFG)" != "sprgen - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "sprgen.mak" CFG="sprgen - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "sprgen - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "sprgen - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "sprgen - Win32 Debug"
RSC=rc.exe
CPP=cl.exe

!IF  "$(CFG)" == "sprgen - Win32 Release"

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

ALL : "$(OUTDIR)\sprgen.exe"

CLEAN : 
	-@erase ".\Release\sprgen.exe"
	-@erase ".\Release\scriplib.obj"
	-@erase ".\Release\sprgen.obj"
	-@erase ".\Release\cmdlib.obj"
	-@erase ".\Release\lbmlib.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/sprgen.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/sprgen.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/sprgen.pdb" /machine:I386 /out:"$(OUTDIR)/sprgen.exe" 
LINK32_OBJS= \
	".\Release\scriplib.obj" \
	".\Release\sprgen.obj" \
	".\Release\cmdlib.obj" \
	".\Release\lbmlib.obj"

"$(OUTDIR)\sprgen.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

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

ALL : "$(OUTDIR)\sprgen.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\sprgen.exe"
	-@erase ".\Debug\cmdlib.obj"
	-@erase ".\Debug\scriplib.obj"
	-@erase ".\Debug\lbmlib.obj"
	-@erase ".\Debug\sprgen.obj"
	-@erase ".\Debug\sprgen.ilk"
	-@erase ".\Debug\sprgen.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/sprgen.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/sprgen.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/sprgen.pdb" /debug /machine:I386 /out:"$(OUTDIR)/sprgen.exe" 
LINK32_OBJS= \
	".\Debug\cmdlib.obj" \
	".\Debug\scriplib.obj" \
	".\Debug\lbmlib.obj" \
	".\Debug\sprgen.obj"

"$(OUTDIR)\sprgen.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "sprgen - Win32 Release"
# Name "sprgen - Win32 Debug"

!IF  "$(CFG)" == "sprgen - Win32 Release"

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\sprgen.c

!IF  "$(CFG)" == "sprgen - Win32 Release"

DEP_CPP_SPRGE=\
	".\spritegn.h"\
	".\..\common\cmdlib.h"\
	".\..\common\scriplib.h"\
	".\..\common\lbmlib.h"\
	

"$(INTDIR)\sprgen.obj" : $(SOURCE) $(DEP_CPP_SPRGE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

DEP_CPP_SPRGE=\
	".\spritegn.h"\
	".\..\common\cmdlib.h"\
	

"$(INTDIR)\sprgen.obj" : $(SOURCE) $(DEP_CPP_SPRGE) "$(INTDIR)"


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

SOURCE=\quake\utils2\common\lbmlib.c
DEP_CPP_LBMLI=\
	".\..\common\cmdlib.h"\
	".\..\common\lbmlib.h"\
	

"$(INTDIR)\lbmlib.obj" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\scriplib.h

!IF  "$(CFG)" == "sprgen - Win32 Release"

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\lbmlib.h

!IF  "$(CFG)" == "sprgen - Win32 Release"

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=\quake\utils2\common\cmdlib.h

!IF  "$(CFG)" == "sprgen - Win32 Release"

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
