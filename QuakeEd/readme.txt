
5/18/96

This is a dump of the current source code for QuakeEd, our map editing application.

This does not include everything necessary to build maps.  There are graphics files, prog files, and other utilities needed.  I plan on releasing a full development set of tools after the game ships.  This is just intended to help out anyone working on their own map editor.

This is a NEXTSTEP application, so hardly anyone is going to be able to use the code as is.  This is not an OPENSTEP application.  It doesn't even use the foundation kit, so porting to gnustep or openstep-solaris/mach/nt would not be trivial.

There are lots of mixed case and >8 character filenames, so I'm using unix gnutar (compressed) format.

Because most people won't have access to a NEXTSTEP machine, I took pictures of some of the more important stuff from interface builder:

mainwindow.tiff	: a screenshot of the primary window
inspectors.tiff : a screenshot of the important inspector views
help.txt		: a dump of the (minimal) help inspector's contents.

I included some sample data to help you follow the code:

quake.qpr		: our current project file
jrbase1.map 	: a sample map
triggers.qc		: a sample qc source file that includes some /*QUAKED comments

There will not be any major changes to this code base.  I am eagerly looking forward to writing a brand new editor for windows NT + open GL as soon as Quake ships.

This application was really not a very good fit for NEXTSTEP.  The display postscript model fundamentally doesn't fit very well with what we need here -- if you run in an 8 bit color mode, the line drawing runs at an ok speed, but the texture view goes half the speed it should as it dithers from 24 bit color down to 8 bit.  If you run in 24 bit color mode, you get less screen real estate and significantly slower line drawing as a 3 megabyte XY view is flushed.  Sigh.  If anyone does actually run this on NEXTSTEP be advised that you want a fast machine.  I never had the time to properly optimize QuakeEd.

The texture view rendering code in here is crap.  Anyone coding a new editor is strongly advised to just use an available optimized library, like open GL or direct 3D.


John Carmack
Id Software
johnc@idsoftware.com
