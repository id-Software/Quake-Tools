
CFLAGS = -g -Wall

EXES = qcc

all: $(EXES)

install:
	make app
	cp $(EXES) /LocalApps

app:
	make "CFLAGS = -O4 -g -Wall -arch i386 -arch hppa"

debug:
	make "CFLAGS = -g -Wall"

profile:
	make "CFLAGS = -pg -Wall"

clean:
	rm -f *.o $(EXES)

.c.o: ; cc -c $(CFLAGS) -o $@ $*.c

QCCFILES = qcc.o pr_lex.o pr_comp.o cmdlib.o
qcc : $(QCCFILES)
	cc $(CFLAGS) -o qcc $(QCCFILES)
