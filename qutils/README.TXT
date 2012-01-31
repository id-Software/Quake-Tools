
This is the readme from our most recent licensed developer CD.  Not all of it is applicable to this source upload, because the map editor, source data, and game source code have not been made freely available (gotta have some reason to charge lots of $$$ for it...), but it is the best documentation I have.

-- John Carmack




Quake Development CD 9/4/96
---------------------------

Included is all of the source data and utilities necessary to generate all of the data distributed with quake, and the main executable itself.  You can modify the data in place, or copy the data you wish to modify to an addon directory and work from there.

The win-32 tools have not been extensively tested yet, because we still do most of our work on unix.


Completely building Quake code and data:
---------------------------------------

This process can take quite some time on a slow machine.  I am omiting the steps to rebuild all the maps, otherwise it would take all day (literally).

Install VC++ and MASM.  You don't need MASM if you are going to use DJGPP to compile the dos version instead of using the windows version.

Copy the contents of the quake development cd to /quake on any drive.  The directory MUST be called "quake", because that string is searched for by the utilities to provide compatability between unix directories mounted inside a tree, and windows directories mounted on a drive letter.  You can move it off of root, but it will require changes in a few batch files.

Add drive:\quake\bin_nt to your path.

cd \quake\utils
install			// compiles all of the utilities and copies them to \quake\bin_nt

cd \quake\id1\gfx
foreach %i in (*.ls) do qlumpy %i	// regrab all 2d graphics
// gfx.ls	: graphics that are statically loaded: the small font, status bar stuff, etc
// cached.ls	: graphics that are dynamically cached: menus, console background, etc
// the other .ls files are texture paletes for map editing

cd \quake\id1\progs
sprgen sprites.qc	// regrab the sprites used in the 3d world (all three of them)

foreach %i in (*.qc) do modelgen %i	// regrab all 3d models
// many of the .qc files do not actually specify a model, but
// running them through modelgen is harmless

qcc			// rebuild progs.dat and files.dat

qfiles -bspmodels	// reads files.dat and runs qbsp and light on all external
			// brush models (health boxes, ammo boxes, etc)
qfiles -pak 0		// builds \quake\id1\pak0.pak
qfiles -pak 1		// builds \quake\id1\pak1.pak
// note that you should not leave the pak files in your development directory, because
// you won't be able to override any of the contents.  If you are doing your work
// in an add-on directory, it isn't a problem, and the pak files will load faster
// than the discrete files.

cd \quake\code
mw			// a batch file that compiles the windows version of quake
q +map newmap		// a batch file that runs "quake -basedir \quake +map newmap"




the bsp tools
-------------

The bsp tools are usually run straight from the map editor, but they can also be called from the command line.

cd \quake\id1\maps
qbsp dm1		// processes dm1.map into dm1.bsp
light dm1		// generates lightmaps for dm1.bsp.  If you run "light -extra dm1", it will make smoother shadow
			// edges by oversampling.
vis dm1			// generates a potentially visible set (PVS) structure for dm1.bsp.  This will only work if
			// the map is leak-free.  You can run "vis -fast dm1" to generate a rough PVS without
			// spending very much time.
bspinfo newmap		// dumps the stats on newmap

QuakeEd
-------
You are not expected to be able to figure out how to use QuakeEd from the (nonexistant) documentation we have.  You get one full day with one of our map designers for tutoring.

If you want to try it out anyway:

cd \quake\id1		// the directory that contains the quake.qe3 project file
qe3			// see quakeed.txt for a box-room walkthrough

QuakeEd is still undergoing development.  The version included in bin_nt is a newer version than the source included in utils.  I don't have the current source here right now.

Expect new versions over the next few weeks.


The main source code:
--------------------
You can use the djgpp compiler (http://www.delorie.com) to rebuild quake for dos.  We used a cross-compiler built for our Digital Unix alpha system that works very rapidly, but the dos hosted compiler is quite slow.

Our reccomended procedure is to forget about dos and just work with the windows version for code changes.  

Currently at id we compile for three different platforms: NEXTSTEP, dos, and windows.  The code also compiles for linux, but that is not part of our regular process.  The C code is totally portable, but the assembly code was writen for GAS, which was unfreindly for windows development.  Michael wrote a GAS to MASM translator to allow the assembly code to compile under windows.  We still consider
the GAS code (.s) to be the master, and derive the masm (.asm) code from it inside the makefile.  If you are never going to touch
the assembly code (we don't reccoment you do), or you are willing to take full responsibility for it, you can throw out the .s files
and just use the .asm.

The direct-sound driver is not very good right now.  You may want to run with "-nosound".


The utilities source:
--------------------

Each utility has a seperate directory of code with a VC++ project file.  They all share several code files in the "common" directory.  The NT versions of these utilities have not been very extensively tested, as we still use DEC Unix for most of our work (soon to change).  The two source files you are most likely to change are: common/lbmlib.c to load a more common graphics format, like pcx, and common/trilib.c to load a 3D format other than Alias object seperated triangles.


qe3 : The map editor.  Designed for use on open GL accelerated systems such as intergraph or glint-TX based systems, but it will still run on the basic NT software version.  REQUIRES A 3-BUTTON MOUSE!

qbsp / light / vis : these utilities are called directly from the map editor to process .map files into .bsp files.  They can be executed by hand if desired.

bspinfo : a command line utility that will dump the count and size statistics on a .bsp file.

qlumpy : the 2-D graphics grabber.  Grabs graphics off of .lbm pictures.  Used for grabbing the 2d graphics used by quake (status bar stuff, fonts, etc), and also used for grabbing the textures to be viewed in qe3 and extracted by qbsp.  Qlumpy script files have the default extension ".ls" (LumpyScript).

qcc : the Quake-C compiler.  Reads "progs.src", then compiles all of the files listed there.  Generates "progs.dat" for use by quake at runtime, "progdefs.h" for use at compile time, and "files.dat" to be used as input for qfiles.exe.

qfiles : Builds pak files based on the contents of "files.dat" writen out by qcc.  It can also regenerate all of the .bsp models used in a project, which is required if any changes to the file format have been made.

sprgen : the sprite model grabber.  Grabs 2d graphics and creates a .spr file.

modelgen : the 3-D model grabber.  Combines skin graphics with 3d frames to produce a .mdl file.  The commands are parsed out of .qc files that can also be read by qcc, so a single source can both generate and use the data.

texmake : creates 2d wireframe outlines of a 3d model that can be drawn on to give a texture to a model.  This is only done once per model, or when the base frame changes.
Example:
cd \quake\id1\models\torch
texmake base		// reads base.tri and creates the graphic base.lbm
copy base.lbm skin.lbm	// never work on the base skin, it might get overwritten
cd \quake\id1\progs
modelgen torch.qc	// creates torch.mdl out of files in \quake\id1\models\torch



Continuing development work at id:
------------------------------
winquake : work is still being done on the direct-X drivers for quake.

qe3 : the NT editor does not yet have full functionality for texture positioning and entity connecting.

qrad : a radiosity replacement for light.exe.  Instead of placing light entities, certain textures automatically become light emiters.  The light bounces off of surfaces, so a single light panel can light all sides of a room.

qcsg / qbsp / qwrite : qbsp.exe is being broken up into multiple programs to reduce memory usage and provide a better means for experimentation.  It should get faster, as well.

visx : a faster replacement for vis.


