
EXES = qcc
NTEXES = qcc.exe

#==============================================================================

EXT=	.o

all: $(EXES)

clean:
	rm *.o *.obj $(EXES) $(NTEXES)

next:
	make "CFLAGS = -g -Wall -I.."

nextinstall:
	make "CFLAGS = -O4 -g -Wall  -I.. -arch i386 -arch hppa"
	cp $(EXES) /LocalApps

alpha:
	make "CFLAGS = -g  -I.." "LDFLAGS = -lm"

alphainstall:
	make "CFLAGS = -O4  -I.." "LDFLAGS = -lm"
	cp $(EXES) /LocalApps

nt:
	nmake /nologo "CFLAGS =  -nologo -Zi -DWIN32 -I.." "LDFLAGS = " "EXT = .obj"

ntinstall:
	nmake /nologo "CFLAGS =  -nologo -Ox -G5 -DWIN32 -I.." "LDFLAGS = " "EXT = .obj"
	cp $(NTEXES) f:\nt\id

#==============================================================================

QCCFILES = qcc$(EXT) pr_lex$(EXT) pr_comp$(EXT) cmdlib$(EXT)
qcc : $(QCCFILES)
	$(CC) $(CFLAGS) -o qcc $(QCCFILES)

cmdlib$(EXT) : ../cmdlib.c
	$(CC) $(CFLAGS) -c -o cmdlib$(EXT) ../cmdlib.c
