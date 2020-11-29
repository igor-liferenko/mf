% This program is copyright (C) 1984 by D. E. Knuth; all rights are reserved.
% Copying of this file is authorized only if (1) you are D. E. Knuth, or if
% (2) you make absolutely no changes to your copy. (The WEB system provides
% for alterations via an auxiliary file; the master file should stay intact.)
% In other words, METAFONT is under essentially the same ground rules as TeX.

% TeX is a trademark of the American Mathematical Society.
% METAFONT is a trademark of Addison-Wesley Publishing Company.

% Version 0 was completed on July 28, 1984.
% Version 1 was completed on January 4, 1986; it corresponds to "Volume D".
% Version 1.1 trivially corrected the punctuation in one message (June 1986).
% Version 1.2 corrected an arithmetic overflow problem (July 1986).
% Version 1.3 improved rounding when elliptical pens are made (November 1986).
% Version 1.4 corrected scan_declared_variable timing (May 1988).
% Version 1.5 fixed negative halving in allocator when mem_min<0 (June 1988).
% Version 1.6 kept open_log_file from calling fatal_error (November 1988).
% Version 1.7 solved that problem a better way (December 1988).
% Version 1.8 introduced major changes for 8-bit extensions (September 1989).
% Version 1.9 improved skimping and was edited for style (December 1989).
% Version 2.0 fixed bug in addto; released with TeX version 3.0 (March 1990).
% Version 2.7 made consistent with TeX version 3.1 (September 1990).
% Version 2.71 fixed bug in draw, allowed unprintable filenames (March 1992).
% Version 2.718 fixed bug in <Choose a dependent...> (March 1995).
% Version 2.7182 fixed bugs related to "<unprintable char>" (August 1996).
% Version 2.71828 suppressed autorounding in dangerous cases (June 2003).
% Version 2.718281 was a general cleanup with minor fixes (February 2008).
% Version 2.7182818 was similar (January 2014).

% A reward of $327.68 will be paid to the first finder of any remaining bug.

% Although considerable effort has been expended to make the METAFONT program
% correct and reliable, no warranty is implied; the author disclaims any
% obligation or liability for damages, including but not limited to
% special, indirect, or consequential damages arising out of or in
% connection with the use or performance of this software. This work has
% been a ``labor of love'' and the author hopes that users enjoy it.

% Here is TeX material that gets inserted after \input webmac
\def\hang{\hangindent 3em\noindent\ignorespaces}
\def\textindent#1{\hangindent2.5em\noindent\hbox to2.5em{\hss#1 }\ignorespaces}
\font\ninerm=cmr9
\let\mc=\ninerm % medium caps for names like SAIL
\def\PASCAL{Pascal}
\def\ph{\hbox{Pascal-H}}
\def\psqrt#1{\sqrt{\mathstrut#1}}
\def\k{_{k+1}}
\def\pct!{{\char`\%}} % percent sign in ordinary text
\font\tenlogo=logo10 % font used for the METAFONT logo
\font\logos=logosl10
\font\eightlogo=logo8
\def\MF{{\tenlogo META}\-{\tenlogo FONT}}
\def\<#1>{$\langle#1\rangle$}
\def\section{\mathhexbox278}
\let\swap=\leftrightarrow
\def\round{\mathop{\rm round}\nolimits}

\def\(#1){} % this is used to make section names sort themselves better
\def\9#1{} % this is used for sort keys in the index via @@:sort key}{entry@@>

\outer\def\N#1. \[#2]#3.{\MN#1.\vfil\eject % begin starred section
  \def\rhead{PART #2:\uppercase{#3}} % define running headline
  \message{*\modno} % progress report
  \edef\next{\write\cont{\Z{\?#2]#3}{\modno}{\the\pageno}}}\next
  \ifon\startsection{\bf\ignorespaces#3.\quad}\ignorespaces}
\let\?=\relax % we want to be able to \write a \?

\def\title{{\eightlogo METAFONT}}
\def\topofcontents{\hsize 5.5in
  \vglue -30pt plus 1fil minus 1.5in
  \def\?##1]{\hbox to 1in{\hfil##1.\ }}
  }
\def\botofcontents{\vskip 0pt plus 1fil minus 1.5in}
\pageno=3
\def\glob{13} % this should be the section number of "<Global...>"
\def\gglob{20, 26} % this should be the next two sections of "<Global...>"

@* Introduction.
This is \MF, a font compiler intended to produce typefaces of high quality.
The \PASCAL\ program that follows is the definition of \MF84, a standard
@:PASCAL}{\PASCAL@>
@!@:METAFONT84}{\MF84@>
version of \MF\ that is designed to be highly portable so that identical output
will be obtainable on a great variety of computers. The conventions
of \MF84 are the same as those of \TeX82.

The main purpose of the following program is to explain the algorithms of \MF\
as clearly as possible. As a result, the program will not necessarily be very
efficient when a particular \PASCAL\ compiler has translated it into a
particular machine language. However, the program has been written so that it
can be tuned to run efficiently in a wide variety of operating environments
by making comparatively few changes. Such flexibility is possible because
the documentation that follows is written in the \.{WEB} language, which is
at a higher level than \PASCAL; the preprocessing step that converts \.{WEB}
to \PASCAL\ is able to introduce most of the necessary refinements.
Semi-automatic translation to other languages is also feasible, because the
program below does not make extensive use of features that are peculiar to
\PASCAL.

A large piece of software like \MF\ has inherent complexity that cannot
be reduced below a certain level of difficulty, although each individual
part is fairly simple by itself. The \.{WEB} language is intended to make
the algorithms as readable as possible, by reflecting the way the
individual program pieces fit together and by providing the
cross-references that connect different parts. Detailed comments about
what is going on, and about why things were done in certain ways, have
been liberally sprinkled throughout the program.  These comments explain
features of the implementation, but they rarely attempt to explain the
\MF\ language itself, since the reader is supposed to be familiar with
{\sl The {\logos METAFONT\/}book}.
@.WEB@>
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>

@ The present implementation has a long ancestry, beginning in the spring
of~1977, when its author wrote a prototype set of subroutines and macros
@^Knuth, Donald Ervin@>
that were used to develop the first Computer Modern fonts.
This original proto-\MF\ required the user to recompile a {\mc SAIL} program
whenever any character was changed, because it was not a ``language'' for
font design; the language was {\mc SAIL}. After several hundred characters
had been designed in that way, the author developed an interpretable language
called \MF, in which it was possible to express the Computer Modern programs
less cryptically. A complete \MF\ processor was designed and coded by the
author in 1979. This program, written in {\mc SAIL}, was adapted for use
with a variety of typesetting equipment and display terminals by Leo Guibas,
Lyle Ramshaw, and David Fuchs.
@^Guibas, Leonidas Ioannis@>
@^Ramshaw, Lyle Harold@>
@^Fuchs, David Raymond@>
Major improvements to the design of Computer Modern fonts were made in the
spring of 1982, after which it became clear that a new language would
better express the needs of letterform designers. Therefore an entirely
new \MF\ language and system were developed in 1984; the present system
retains the name and some of the spirit of \MF79, but all of the details
have changed.

No doubt there still is plenty of room for improvement, but the author
is firmly committed to keeping \MF84 ``frozen'' from now on; stability
and reliability are to be its main virtues.

On the other hand, the \.{WEB} description can be extended without changing
the core of \MF84 itself, and the program has been designed so that such
extensions are not extremely difficult to make.
The |banner| string defined here should be changed whenever \MF\
undergoes any modifications, so that it will be clear which version of
\MF\ might be the guilty party when a problem arises.
@^extensions to \MF@>
@^system dependencies@>

If this program is changed, the resulting system should not be called
`\MF\kern.5pt'; the official name `\MF\kern.5pt' by itself is reserved
for software systems that are fully compatible with each other.
A special test suite called the ``\.{TRAP} test'' is available for
helping to determine whether an implementation deserves to be
known as `\MF\kern.5pt' [cf.~Stanford Computer Science report CS1095,
January 1986].

@d banner	"This is METAFONT, Version 2.7182818" /*printed when \MF\ starts*/ 

@ Different \PASCAL s have slightly different conventions, and the present
@!@:PASCAL H}{\ph@>
program expresses \MF\ in terms of the \PASCAL\ that was
available to the author in 1984. Constructions that apply to
this particular compiler, which we shall call \ph, should help the
reader see how to make an appropriate interface for other systems
if necessary. (\ph\ is Charles Hedrick's modification of a compiler
@^Hedrick, Charles Locke@>
for the DECsystem-10 that was originally developed at the University of
Hamburg; cf.\ {\sl SOFTWARE---Practice \AM\ Experience \bf6} (1976),
29--42. The \MF\ program below is intended to be adaptable, without
extensive changes, to most other versions of \PASCAL, so it does not fully
use the admirable features of \ph. Indeed, a conscious effort has been
made here to avoid using several idiosyncratic features of standard
\PASCAL\ itself, so that most of the code can be translated mechanically
into other high-level languages. For example, the `\&{with}' and `\\{new}'
features are not used, nor are pointer types, set types, or enumerated
scalar types; there are no `\&{var}' parameters, except in the case of files
or in the system-dependent |paint_row| procedure;
there are no tag fields on variant records; there are no |double| variables;
no procedures are declared local to other procedures.)

The portions of this program that involve system-dependent code, where
changes might be necessary because of differences between \PASCAL\ compilers
and/or differences between
operating systems, can be identified by looking at the sections whose
numbers are listed under `system dependencies' in the index. Furthermore,
the index entries for `dirty \PASCAL' list all places where the restrictions
of \PASCAL\ have not been followed perfectly, for one reason or another.
@!@^system dependencies@>
@!@^dirty \PASCAL@>

@ The program begins with a normal \PASCAL\ program heading, whose
components will be filled in later, using the conventions of \.{WEB}.
@.WEB@>
For example, the portion of the program called `\X\glob:Global
variables\X' below will be replaced by a sequence of variable declarations
that starts in $\section\glob$ of this documentation. In this way, we are able
to define each individual global variable when we are prepared to
understand what it means; we do not have to define all of the globals at
once.  Cross references in $\section\glob$, where it says ``See also
sections \gglob, \dots,'' also make it possible to look at the set of
all global variables, if desired.  Similar remarks apply to the other
portions of the program heading.

Actually the heading shown here is not quite normal: The || line
does not mention any |output| file, because \ph\ would ask the \MF\ user
to specify a file name if |output| were specified here.
@:PASCAL H}{\ph@>
@^system dependencies@>

@f type true /*but `|type|' will not be treated as a reserved word*/ 

@p@t\4@>@<Compiler directives@>@;
 /*all file names are defined dynamically*/ 
@<Labels in the outer block@>@;
@<Constants in the outer block@>@;
@<Types in the outer block@>@;
@<Global variables@>@;
@#
void initialize(void) /*this procedure gets things started properly*/ 
  {@+@<Local variables for initialization@>@;
  @<Set initial values of key variables@>;@/
  } @#
@t\4@>@<Basic printing procedures@>@;
@t\4@>@<Error handling procedures@>@;

@ The overall \MF\ program begins with the heading just shown, after which
comes a bunch of procedure declarations and function declarations.
Finally we will get to the main program, which begins with the
comment `|start_here|'. If you want to skip down to the
main program now, you can look up `|start_here|' in the index.
But the author suggests that the best way to understand this program
is to follow pretty much the order of \MF's components as they appear in the
\.{WEB} description you are now reading, since the present ordering is
intended to combine the advantages of the ``bottom up'' and ``top down''
approaches to the problem of understanding a somewhat complicated system.

@ Three labels must be declared in the main program, so we give them
symbolic names.

@<Labels in the out...@>=
@t\hskip-2pt@>@t\hskip-2pt@>@,
   /*key control points*/ 

@ Some of the code below is intended to be used only when diagnosing the
strange behavior that sometimes occurs when \MF\ is being installed or
when system wizards are fooling around with \MF\ without quite knowing
what they are doing. Such code will not normally be compiled; it is
delimited by the codewords `$|debug|\ldots|debug|$', with apologies
to people who wish to preserve the purity of English.

Similarly, there is some conditional code delimited by
`$|stat|\ldots|tats|$' that is intended for use when statistics are to be
kept about \MF's memory usage.  The |stat| $\ldots$ |tats| code also
implements special diagnostic information that is printed when
$\\{tracingedges}>1$.
@^debugging@>

@ This program has two important variations: (1) There is a long and slow
version called \.{INIMF}, which does the extra calculations needed to
@.INIMF@>
initialize \MF's internal tables; and (2)~there is a shorter and faster
production version, which cuts the initialization to a bare minimum.
Parts of the program that are needed in (1) but not in (2) are delimited by
the codewords `$|init|\ldots|tini|$'.

@ If the first character of a \PASCAL\ comment is a dollar sign,
\ph\ treats the comment as a list of ``compiler directives'' that will
affect the translation of this program into machine language.  The
directives shown below specify full checking and inclusion of the \PASCAL\
debugger when \MF\ is being debugged, but they cause range checking and other
redundant code to be eliminated when the production system is being generated.
Arithmetic overflow will be detected in all cases.
@:PASCAL H}{\ph@>
@^system dependencies@>
@^overflow in arithmetic@>

@<Compiler directives@>=
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define odd(X)       ((X)&1)
#define chr(X)       (X)
#define ord(X)       ((int)(X))
#define abs(X)       ((X)>-(X)?(X):-(X)) /* FIXME: is it needed? */

@h

@ This \MF\ implementation conforms to the rules of the {\sl Pascal User
@:PASCAL}{\PASCAL@>
@^system dependencies@>
Manual} published by Jensen and Wirth in 1975, except where system-dependent
@^Wirth, Niklaus@>
@^Jensen, Kathleen@>
code is necessary to make a useful system program, and except in another
respect where such conformity would unnecessarily obscure the meaning
and clutter up the code: We assume that |case| statements may include a
default case that applies if no matching label is found. Thus, we shall use
constructions like
$$\vbox{\halign{\ignorespaces#\hfil\cr
|case x|\cr
1: $\langle\,$code for $x=1\,\rangle$;\cr
3: $\langle\,$code for $x=3\,\rangle$;\cr
|default:| $\langle\,$code for |x!=1| and |x!=3|$\,\rangle$\cr
|} |\cr}}$$
since most \PASCAL\ compilers have plugged this hole in the language by
incorporating some sort of default mechanism. For example, the \ph\
compiler allows `|default:|:' as a default label, and other \PASCAL s allow
syntaxes like `\&{else}' or `\&{otherwise}' or `\\{otherwise}:', etc. The
definitions of |default:| and |} | should be changed to agree with
local conventions.  Note that no semicolon appears before |} | in
this program, so the definition of |} | should include a semicolon
if the compiler wants one. (Of course, if no default mechanism is
available, the |case| statements of \MF\ will have to be laboriously
extended by listing all remaining cases. People who are stuck with such
\PASCAL s have, in fact, done this, successfully but not happily!)
@:PASCAL H}{\ph@>

@ The following parameters can be changed at compile time to extend or
reduce \MF's capacity. They may have different values in \.{INIMF} and
in production versions of \MF.
@.INIMF@>
@^system dependencies@>

@<Constants...@>=
enum {@+@!mem_max=30000@+}; /*greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise | >= mem_top|*/ 
enum {@+@!max_internal=100@+}; /*maximum number of internal quantities*/ 
enum {@+@!buf_size=500@+}; /*maximum number of characters simultaneously present in
  current lines of open files; must not exceed |max_halfword|*/ 
enum {@+@!error_line=72@+}; /*width of context lines on terminal error messages*/ 
enum {@+@!half_error_line=42@+}; /*width of first lines of contexts in terminal
  error messages; should be between 30 and |error_line-15|*/ 
enum {@+@!max_print_line=79@+}; /*width of longest text lines output; should be at least 60*/ 
enum {@+@!screen_width=768@+}; /*number of pixels in each row of screen display*/ 
enum {@+@!screen_depth=1024@+}; /*number of pixels in each column of screen display*/ 
enum {@+@!stack_size=30@+}; /*maximum number of simultaneous input sources*/ 
enum {@+@!max_strings=2000@+}; /*maximum number of strings; must not exceed |max_halfword|*/ 
enum {@+@!string_vacancies=8000@+}; /*the minimum number of characters that should be
  available for the user's identifier names and strings,
  after \MF's own error messages are stored*/ 
enum {@+@!pool_size=32000@+}; /*maximum number of characters in strings, including all
  error messages and help texts, and the names of all identifiers;
  must exceed |string_vacancies| by the total
  length of \MF's own strings, which is currently about 22000*/ 
enum {@+@!move_size=5000@+}; /*space for storing moves in a single octant*/ 
enum {@+@!max_wiggle=300@+}; /*number of autorounded points per cycle*/ 
enum {@+@!gf_buf_size=800@+}; /*size of the output buffer, must be a multiple of 8*/ 
enum {@+@!file_name_size=40@+}; /*file names shouldn't be longer than this*/ 
const char *@!pool_name="MFbases:MF.POOL                         ";
   /*string of length |file_name_size|; tells where the string pool appears*/ 
@.MFbases@>
enum {@+@!path_size=300@+}; /*maximum number of knots between breakpoints of a path*/ 
enum {@+@!bistack_size=785@+}; /*size of stack for bisection algorithms;
  should probably be left at this value*/ 
enum {@+@!header_size=100@+}; /*maximum number of \.{TFM} header words, times~4*/ 
enum {@+@!lig_table_size=5000@+}; /*maximum number of ligature/kern steps, must be
  at least 255 and at most 32510*/ 
enum {@+@!max_kerns=500@+}; /*maximum number of distinct kern amounts*/ 
enum {@+@!max_font_dimen=50@+}; /*maximum number of \&{fontdimen} parameters*/ 

@ Like the preceding parameters, the following quantities can be changed
at compile time to extend or reduce \MF's capacity. But if they are changed,
it is necessary to rerun the initialization program \.{INIMF}
@.INIMF@>
to generate new tables for the production \MF\ program.
One can't simply make helter-skelter changes to the following constants,
since certain rather complex initialization
numbers are computed from them. They are defined here using
\.{WEB} macros, instead of being put into \PASCAL's || list, in order to
emphasize this distinction.

@d mem_min	0 /*smallest index in the |mem| array, must not be less
  than |min_halfword|*/ 
@d mem_top	30000 /*largest index in the |mem| array dumped by \.{INIMF};
  must be substantially larger than |mem_min|
  and not greater than |mem_max|*/ 
@d hash_size	2100 /*maximum number of symbolic tokens,
  must be less than |max_halfword-3*param_size|*/ 
@d hash_prime	1777 /*a prime number equal to about 85\pct! of |hash_size|*/ 
@d max_in_open	6 /*maximum number of input files and error insertions that
  can be going on simultaneously*/ 
@d param_size	150 /*maximum number of simultaneous macro parameters*/ 
@^system dependencies@>

@ In case somebody has inadvertently made bad settings of the ``constants,''
\MF\ checks them using a global variable called |bad|.

This is the first of many sections of \MF\ where global variables are
defined.

@<Glob...@>=
int @!bad; /*is some ``constant'' wrong?*/ 

@ Later on we will say `\ignorespaces|if (mem_max >= max_halfword) bad=10|',
or something similar. (We can't do that until |max_halfword| has been defined.)

@<Check the ``constant'' values for consistency@>=
bad=0;
if ((half_error_line < 30)||(half_error_line > error_line-15)) bad=1;
if (max_print_line < 60) bad=2;
if (gf_buf_size%8!=0) bad=3;
if (mem_min+1100 > mem_top) bad=4;
if (hash_prime > hash_size) bad=5;
if (header_size%4!=0) bad=6;
if ((lig_table_size < 255)||(lig_table_size > 32510)) bad=7;

@ Labels are given symbolic names by the following definitions, so that
occasional |goto| statements will be meaningful. We insert the label
`|end|' just before the `\ignorespaces|} |\unskip' of a procedure in
which we have used the `|goto end|' statement defined below; the label
`|restart|' is occasionally used at the very beginning of a procedure; and
the label `|reswitch|' is occasionally used just prior to a |case|
statement in which some cases change the conditions and we wish to branch
to the newly applicable case.  Loops that are set up with the |loop|
construction defined below are commonly exited by going to `|done|' or to
`|found|' or to `|not_found|', and they are sometimes repeated by going to
`|resume|'.  If two or more parts of a subroutine start differently but
end up the same, the shared code may be gathered together at
`|common_ending|'.

Incidentally, this program never declares a label that isn't actually used,
because some fussy \PASCAL\ compilers will complain about redundant labels.

@d done3	33 /*for exiting the third loop in a very long block*/ 
@d done4	34 /*for exiting the fourth loop in an extremely long block*/ 
@d done5	35 /*for exiting the fifth loop in an immense block*/ 
@d done6	36 /*for exiting the sixth loop in a block*/ 
@d found1	41 /*like |found|, when there's more than one per routine*/ 
@d found2	42 /*like |found|, when there's more than two per routine*/ 
@ Here are some macros for common programming idioms.

@d incr(X)	X=X+1 /*increase a variable by unity*/ 
@d decr(X)	X=X-1 /*decrease a variable by unity*/ 
@d negate(X)	X=-X /*change the sign of a variable*/ 
@d double(X)	X=X+X /*multiply a variable by two*/ 
@d loop	@+while (true) @+ /*repeat over and over until a |goto| happens*/ 
@f loop else
   /*\.{WEB}'s |else| acts like `\ignorespaces|while true do|\unskip'*/ 
@d do_nothing	 /*empty statement*/ 
@* The character set.
In order to make \MF\ readily portable to a wide variety of
computers, all of its input text is converted to an internal eight-bit
code that includes standard ASCII, the ``American Standard Code for
Information Interchange.''  This conversion is done immediately when each
character is read in. Conversely, characters are converted from ASCII to
the user's external representation just before they are output to a
text file.
@^ASCII code@>

Such an internal code is relevant to users of \MF\ only with respect to
the \&{char} and \&{ASCII} operations, and the comparison of strings.

@ Characters of text that have been converted to \MF's internal form
are said to be of type |ASCII_code|, which is a subrange of the integers.

@<Types...@>=
typedef uint8_t ASCII_code; /*eight-bit numbers*/ 

@ The original \PASCAL\ compiler was designed in the late 60s, when six-bit
character sets were common, so it did not make provision for lowercase
letters. Nowadays, of course, we need to deal with both capital and small
letters in a convenient way, especially in a program for font design;
so the present specification of \MF\ has been written under the assumption
that the \PASCAL\ compiler and run-time system permit the use of text files
with more than 64 distinguishable characters. More precisely, we assume that
the character set contains at least the letters and symbols associated
with ASCII codes 040 through 0176; all of these characters are now
available on most computer terminals.

Since we are dealing with more characters than were present in the first
\PASCAL\ compilers, we have to decide what to call the associated data
type. Some \PASCAL s use the original name |unsigned char| for the
characters in text files, even though there now are more than 64 such
characters, while other \PASCAL s consider |unsigned char| to be a 64-element
subrange of a larger data type that has some other name.

In order to accommodate this difference, we shall use the name |text_char|
to stand for the data type of the characters that are converted to and
from |ASCII_code| when they are input and output. We shall also assume
that |text_char| consists of the elements |chr(first_text_char)| through
|chr(last_text_char)|, inclusive. The following definitions should be
adjusted if necessary.
@^system dependencies@>

@d text_char	char /*the data type of characters in text files*/ 
@d first_text_char	0 /*ordinal number of the smallest element of |text_char|*/ 
@d last_text_char	127 /*ordinal number of the largest element of |text_char|*/ 

@<Local variables for init...@>=
int @!i;

@ The \MF\ processor converts between ASCII code and
the user's external character set by means of arrays |xord| and |xchr|
that are analogous to \PASCAL's |ord| and |chr| functions.

@<Glob...@>=
ASCII_code @!xord[128];
   /*specifies conversion of input characters*/ 
text_char @!xchr[256];
   /*specifies conversion of output characters*/ 

@ Since we are assuming that our \PASCAL\ system is able to read and
write the visible characters of standard ASCII (although not
necessarily using the ASCII codes to represent them), the following
assignment statements initialize the standard part of the |xchr| array
properly, without needing any system-dependent changes. On the other
hand, it is possible to implement \MF\ with less complete character
sets, and in such cases it will be necessary to change something here.
@^system dependencies@>

@<Set init...@>=
xchr[040]= ' ' ;
xchr[041]= '!' ;
xchr[042]= '"' ;
xchr[043]= '#' ;
xchr[044]= '$' ;
xchr[045]= '%' ;
xchr[046]= '&' ;
xchr[047]= '\'' ;@/
xchr[050]= '(' ;
xchr[051]= ')' ;
xchr[052]= '*' ;
xchr[053]= '+' ;
xchr[054]= ',' ;
xchr[055]= '-' ;
xchr[056]= '.' ;
xchr[057]= '/' ;@/
xchr[060]= '0' ;
xchr[061]= '1' ;
xchr[062]= '2' ;
xchr[063]= '3' ;
xchr[064]= '4' ;
xchr[065]= '5' ;
xchr[066]= '6' ;
xchr[067]= '7' ;@/
xchr[070]= '8' ;
xchr[071]= '9' ;
xchr[072]= ':' ;
xchr[073]= ';' ;
xchr[074]= '<' ;
xchr[075]= '=' ;
xchr[076]= '>' ;
xchr[077]= '?' ;@/
xchr[0100]= '@@' ;
xchr[0101]= 'A' ;
xchr[0102]= 'B' ;
xchr[0103]= 'C' ;
xchr[0104]= 'D' ;
xchr[0105]= 'E' ;
xchr[0106]= 'F' ;
xchr[0107]= 'G' ;@/
xchr[0110]= 'H' ;
xchr[0111]= 'I' ;
xchr[0112]= 'J' ;
xchr[0113]= 'K' ;
xchr[0114]= 'L' ;
xchr[0115]= 'M' ;
xchr[0116]= 'N' ;
xchr[0117]= 'O' ;@/
xchr[0120]= 'P' ;
xchr[0121]= 'Q' ;
xchr[0122]= 'R' ;
xchr[0123]= 'S' ;
xchr[0124]= 'T' ;
xchr[0125]= 'U' ;
xchr[0126]= 'V' ;
xchr[0127]= 'W' ;@/
xchr[0130]= 'X' ;
xchr[0131]= 'Y' ;
xchr[0132]= 'Z' ;
xchr[0133]= '[' ;
xchr[0134]= '\\' ;
xchr[0135]= ']' ;
xchr[0136]= '^' ;
xchr[0137]= '_' ;@/
xchr[0140]= '`' ;
xchr[0141]= 'a' ;
xchr[0142]= 'b' ;
xchr[0143]= 'c' ;
xchr[0144]= 'd' ;
xchr[0145]= 'e' ;
xchr[0146]= 'f' ;
xchr[0147]= 'g' ;@/
xchr[0150]= 'h' ;
xchr[0151]= 'i' ;
xchr[0152]= 'j' ;
xchr[0153]= 'k' ;
xchr[0154]= 'l' ;
xchr[0155]= 'm' ;
xchr[0156]= 'n' ;
xchr[0157]= 'o' ;@/
xchr[0160]= 'p' ;
xchr[0161]= 'q' ;
xchr[0162]= 'r' ;
xchr[0163]= 's' ;
xchr[0164]= 't' ;
xchr[0165]= 'u' ;
xchr[0166]= 'v' ;
xchr[0167]= 'w' ;@/
xchr[0170]= 'x' ;
xchr[0171]= 'y' ;
xchr[0172]= 'z' ;
xchr[0173]= '{' ;
xchr[0174]= '|' ;
xchr[0175]= '}' ;
xchr[0176]= '~' ;@/

@ The ASCII code is ``standard'' only to a certain extent, since many
computer installations have found it advantageous to have ready access
to more than 94 printing characters.  If \MF\ is being used
on a garden-variety \PASCAL\ for which only standard ASCII
codes will appear in the input and output files, it doesn't really matter
what codes are specified in |xchr[0 dotdot 037]|, but the safest policy is to
blank everything out by using the code shown below.

However, other settings of |xchr| will make \MF\ more friendly on
computers that have an extended character set, so that users can type things
like `\.^^Z' instead of `\.{<>}'.
People with extended character sets can
assign codes arbitrarily, giving an |xchr| equivalent to whatever
characters the users of \MF\ are allowed to have in their input files.
Appropriate changes to \MF's |char_class| table should then be made.
(Unlike \TeX, each installation of \MF\ has a fixed assignment of category
codes, called the |char_class|.) Such changes make portability of programs
more difficult, so they should be introduced cautiously if at all.
@^character set dependencies@>
@^system dependencies@>

@<Set init...@>=
for (i=0; i<=037; i++) xchr[i]= ' ' ;
for (i=0177; i<=0377; i++) xchr[i]= ' ' ;

@ The following system-independent code makes the |xord| array contain a
suitable inverse to the information in |xchr|. Note that if |xchr[i]==xchr[j]|
where |i < j < 0177|, the value of |xord[xchr[i]]| will turn out to be
|j| or more; hence, standard ASCII code numbers will be used instead of
codes below 040 in case there is a coincidence.

@<Set init...@>=
for (i=first_text_char; i<=last_text_char; i++) xord[chr(i)]=0177;
for (i=0200; i<=0377; i++) xord[xchr[i]]=i;
for (i=0; i<=0176; i++) xord[xchr[i]]=i;

@* Input and output.
The bane of portability is the fact that different operating systems treat
input and output quite differently, perhaps because computer scientists
have not given sufficient attention to this problem. People have felt somehow
that input and output are not part of ``real'' programming. Well, it is true
that some kinds of programming are more fun than others. With existing
input/output conventions being so diverse and so messy, the only sources of
joy in such parts of the code are the rare occasions when one can find a
way to make the program a little less bad than it might have been. We have
two choices, either to attack I/O now and get it over with, or to postpone
I/O until near the end. Neither prospect is very attractive, so let's
get it over with.

The basic operations we need to do are (1)~inputting and outputting of
text, to or from a file or the user's terminal; (2)~inputting and
outputting of eight-bit bytes, to or from a file; (3)~instructing the
operating system to initiate (``open'') or to terminate (``close'') input or
output from a specified file; (4)~testing whether the end of an input
file has been reached; (5)~display of bits on the user's screen.
The bit-display operation will be discussed in a later section; we shall
deal here only with more traditional kinds of I/O.

\MF\ needs to deal with two kinds of files.
We shall use the term |alpha_file| for a file that contains textual data,
and the term |byte_file| for a file that contains eight-bit binary information.
These two types turn out to be the same on many computers, but
sometimes there is a significant distinction, so we shall be careful to
distinguish between them. Standard protocols for transferring
such files from computer to computer, via high-speed networks, are
now becoming available to more and more communities of users.

The program actually makes use also of a third kind of file, called a
|word_file|, when dumping and reloading base information for its own
initialization.  We shall define a word file later; but it will be possible
for us to specify simple operations on word files before they are defined.

@<Types...@>=
typedef uint8_t eight_bits; /*unsigned one-byte quantity*/ 
typedef struct {@+FILE *f;@+text_char@,d;@+} alpha_file; /*files that contain textual data*/ 
typedef struct {@+FILE *f;@+eight_bits@,d;@+} byte_file; /*files that contain binary data*/ 

@ Most of what we need to do with respect to input and output can be handled
by the I/O facilities that are standard in \PASCAL, i.e., the routines
called |get|, |put|, |eof|, and so on. But
standard \PASCAL\ does not allow file variables to be associated with file
names that are determined at run time, so it cannot be used to implement
\MF; some sort of extension to \PASCAL's ordinary |reset| and |rewrite|
is crucial for our purposes. We shall assume that |name_of_file| is a variable
of an appropriate type such that the \PASCAL\ run-time system being used to
implement \MF\ can open a file whose external name is specified by
|name_of_file|.
@^system dependencies@>

@<Glob...@>=
char @!name_of_file0[file_name_size+1]={0}, *const @!name_of_file = @!name_of_file0-1;@;@/
   /*on some systems this may be a \&{record} variable*/ 
uint8_t @!name_length;@/ /*this many characters are actually
  relevant in |name_of_file| (the rest are blank)*/ 

@ The \ph\ compiler with which the present version of \MF\ was prepared has
extended the rules of \PASCAL\ in a very convenient way. To open file~|f|,
we can write
$$\vbox{\halign{#\hfil\qquad&#\hfil\cr
|reset(f,@t\\{name}@>,"/O")|&for input;\cr
|rewrite(f,@t\\{name}@>,"/O")|&for output.\cr}}$$
The `\\{name}' parameter, which is of type `\ignorespaces|
array[@t\<\\{any}>@>]text_char|', stands for the name of
the external file that is being opened for input or output.
Blank spaces that might appear in \\{name} are ignored.

The `\.{/O}' parameter tells the operating system not to issue its own
error messages if something goes wrong. If a file of the specified name
cannot be found, or if such a file cannot be opened for some other reason
(e.g., someone may already be trying to write the same file), we will have
|@!erstat(f)!=0| after an unsuccessful |reset| or |rewrite|.  This allows
\MF\ to undertake appropriate corrective action.
@:PASCAL H}{\ph@>
@^system dependencies@>

\MF's file-opening procedures return |false| if no file identified by
|name_of_file| could be opened.

@d reset_OK(X)	erstat(X)==0
@d rewrite_OK(X)	erstat(X)==0

@p bool a_open_in(@!alpha_file *@!f)
   /*open a text file for input*/ 
{@+reset((*f), name_of_file,"r");return reset_OK((*f));
} 
@#
bool a_open_out(@!alpha_file *@!f)
   /*open a text file for output*/ 
{@+rewrite((*f), name_of_file,"w");return rewrite_OK((*f));
} 
@#
bool b_open_out(@!byte_file *@!f)
   /*open a binary file for output*/ 
{@+rewrite((*f), name_of_file,"wb");return rewrite_OK((*f));
} 
@#
bool w_open_in(@!word_file *@!f)
   /*open a word file for input*/ 
{@+reset((*f), name_of_file,"rb");return reset_OK((*f));
} 
@#
bool w_open_out(@!word_file *@!f)
   /*open a word file for output*/ 
{@+rewrite((*f), name_of_file,"wb");return rewrite_OK((*f));
} 

@ Files can be closed with the \ph\ routine `|pascal_close(f)|', which
@:PASCAL H}{\ph@>
@^system dependencies@>
should be used when all input or output with respect to |f| has been completed.
This makes |f| available to be opened again, if desired; and if |f| was used for
output, the |pascal_close| operation makes the corresponding external file appear
on the user's area, ready to be read.

@p void a_close(@!alpha_file *@!f) /*close a text file*/ 
{@+pascal_close((*f));
} 
@#
void b_close(@!byte_file *@!f) /*close a binary file*/ 
{@+pascal_close((*f));
} 
@#
void w_close(@!word_file *@!f) /*close a word file*/ 
{@+pascal_close((*f));
} 

@ Binary input and output are done with \PASCAL's ordinary |get| and |put|
procedures, so we don't have to make any other special arrangements for
binary~I/O. Text output is also easy to do with standard \PASCAL\ routines.
The treatment of text input is more difficult, however, because
of the necessary translation to |ASCII_code| values.
\MF's conventions should be efficient, and they should
blend nicely with the user's operating environment.

@ Input from text files is read one line at a time, using a routine called
|input_ln|. This function is defined in terms of global variables called
|buffer|, |first|, and |last| that will be described in detail later; for
now, it suffices for us to know that |buffer| is an array of |ASCII_code|
values, and that |first| and |last| are indices into this array
representing the beginning and ending of a line of text.

@<Glob...@>=
ASCII_code @!buffer[buf_size+1]; /*lines of characters being read*/ 
uint16_t @!first; /*the first unused position in |buffer|*/ 
uint16_t @!last; /*end of the line just input to |buffer|*/ 
uint16_t @!max_buf_stack; /*largest index used in |buffer|*/ 

@ The |input_ln| function brings the next line of input from the specified
field into available positions of the buffer array and returns the value
|true|, unless the file has already been entirely read, in which case it
returns |false| and sets |last=first|.  In general, the |ASCII_code|
numbers that represent the next line of the file are input into
|buffer[first]|, |buffer[first+1]|, \dots, |buffer[last-1]|; and the
global variable |last| is set equal to |first| plus the length of the
line. Trailing blanks are removed from the line; thus, either |last==first|
(in which case the line was entirely blank) or |buffer[last-1]!=' '|.
@^inner loop@>

An overflow error is given, however, if the normal actions of |input_ln|
would make |last >= buf_size|; this is done so that other parts of \MF\
can safely look at the contents of |buffer[last+1]| without overstepping
the bounds of the |buffer| array. Upon entry to |input_ln|, the condition
|first < buf_size| will always hold, so that there is always room for an
``empty'' line.

The variable |max_buf_stack|, which is used to keep track of how large
the |buf_size| parameter must be to accommodate the present job, is
also kept up to date by |input_ln|.

If the |bypass_eoln| parameter is |true|, |input_ln| will do a |get|
before looking at the first character of the line; this skips over
an |eoln| that was in |f.d|. The procedure does not do a |get| when it
reaches the end of the line; therefore it can be used to acquire input
from the user's terminal as well as from ordinary text files.

Standard \PASCAL\ says that a file should have |eoln| immediately
before |eof|, but \MF\ needs only a weaker restriction: If |eof|
occurs in the middle of a line, the system function |eoln| should return
a |true| result (even though |f.d| will be undefined).

@p bool input_ln(@!alpha_file *@!f, bool @!bypass_eoln)
   /*inputs the next line or returns |false|*/ 
{@+uint16_t @!last_nonblank; /*|last| with trailing blanks removed*/ 
if (bypass_eoln) if (!eof((*f))) get((*f));
   /*input the first character of the line into |f.d|*/ 
last=first; /*cf.\ Matthew 19\thinspace:\thinspace30*/ 
if (eof((*f))) return false;
else{@+last_nonblank=first;
  while (!eoln((*f))) 
    {@+if (last >= max_buf_stack) 
      {@+max_buf_stack=last+1;
      if (max_buf_stack==buf_size) 
        @<Report overflow of the input buffer, and abort@>;
      } 
    buffer[last]=xord[(*f).d];get((*f));incr(last);
    if (buffer[last-1]!=' ') last_nonblank=last;
    } 
  last=last_nonblank;return true;
  } 
} 

@ The user's terminal acts essentially like other files of text, except
that it is used both for input and for output. When the terminal is
considered an input file, the file variable is called |term_in|, and when it
is considered an output file the file variable is |term_out|.
@^system dependencies@>

@<Glob...@>=
alpha_file @!term_in; /*the terminal as an input file*/ 
alpha_file @!term_out; /*the terminal as an output file*/ 

@ Here is how to open the terminal files
in \ph. The `\.{/I}' switch suppresses the first |get|.
@:PASCAL H}{\ph@>
@^system dependencies@>

@d t_open_in   term_in.f=stdin /*open the terminal for text input*/ 
@d t_open_out   term_out.f=stdout /*open the terminal for text output*/ 

@ Sometimes it is necessary to synchronize the input/output mixture that
happens on the user's terminal, and three system-dependent
procedures are used for this
purpose. The first of these, |update_terminal|, is called when we want
to make sure that everything we have output to the terminal so far has
actually left the computer's internal buffers and been sent.
The second, |clear_terminal|, is called when we wish to cancel any
input that the user may have typed ahead (since we are about to
issue an unexpected error message). The third, |wake_up_terminal|,
is supposed to revive the terminal if the user has disabled it by
some instruction to the operating system.  The following macros show how
these operations can be specified in \ph:
@:PASCAL H}{\ph@>
@^system dependencies@>

@d update_terminal	fflush(term_out.f) /*empty the terminal output buffer*/ 
@d clear_terminal	fflush(term_in.f) /*clear the terminal input buffer*/ 
@d wake_up_terminal	do_nothing /*cancel the user's cancellation of output*/ 

@ We need a special routine to read the first line of \MF\ input from
the user's terminal. This line is different because it is read before we
have opened the transcript file; there is sort of a ``chicken and
egg'' problem here. If the user types `\.{input cmr10}' on the first
line, or if some macro invoked by that line does such an \.{input},
the transcript file will be named `\.{cmr10.log}'; but if no \.{input}
commands are performed during the first line of terminal input, the transcript
file will acquire its default name `\.{mfput.log}'. (The transcript file
will not contain error messages generated by the first line before the
first \.{input} command.)
@.mfput@>

The first line is even more special if we are lucky enough to have an operating
system that treats \MF\ differently from a run-of-the-mill \PASCAL\ object
program. It's nice to let the user start running a \MF\ job by typing
a command line like `\.{MF cmr10}'; in such a case, \MF\ will operate
as if the first line of input were `\.{cmr10}', i.e., the first line will
consist of the remainder of the command line, after the part that invoked \MF.

The first line is special also because it may be read before \MF\ has
input a base file. In such cases, normal error messages cannot yet
be given. The following code uses concepts that will be explained later.
(If the \PASCAL\ compiler does not support non-local |@!goto|\unskip, the
@^system dependencies@>
statement `|goto exit(0)|' should be replaced by something that
quietly terminates the program.)

@<Report overflow of the input buffer, and abort@>=
if (base_ident==0) 
  {@+write_ln(term_out,"Buffer size exceeded!");exit(0);
@.Buffer size exceeded@>
  } 
else{@+cur_input.loc_field=first;cur_input.limit_field=last-1;
  overflow("buffer size", buf_size);
@:METAFONT capacity exceeded buffer size}{\quad buffer size@>
  } 

@ Different systems have different ways to get started. But regardless of
what conventions are adopted, the routine that initializes the terminal
should satisfy the following specifications:

\yskip\textindent{1)}It should open file |term_in| for input from the
  terminal. (The file |term_out| will already be open for output to the
  terminal.)

\textindent{2)}If the user has given a command line, this line should be
  considered the first line of terminal input. Otherwise the
  user should be prompted with `\.{**}', and the first line of input
  should be whatever is typed in response.

\textindent{3)}The first line of input, which might or might not be a
  command line, should appear in locations |first| to |last-1| of the
  |buffer| array.

\textindent{4)}The global variable |loc| should be set so that the
  character to be read next by \MF\ is in |buffer[loc]|. This
  character should not be blank, and we should have |loc < last|.

\yskip\noindent(It may be necessary to prompt the user several times
before a non-blank line comes in. The prompt is `\.{**}' instead of the
later `\.*' because the meaning is slightly different: `\.{input}' need
not be typed immediately after~`\.{**}'.)

@d loc	cur_input.loc_field /*location of first unread character in |buffer|*/ 

@ The following program does the required initialization
without retrieving a possible command line.
It should be clear how to modify this routine to deal with command lines,
if the system permits them.
@^system dependencies@>

@p bool init_terminal(void) /*gets the terminal input started*/ 
{@+
t_open_in;
loop@+{@+wake_up_terminal;pascal_write(term_out,"**");update_terminal;
@.**@>
  if (!input_ln(&term_in, true))  /*this shouldn't happen*/ 
    {@+write_ln(term_out);
    pascal_write(term_out,"! End of file on the terminal... why?");
@.End of file on the terminal@>
    return false;
    } 
  loc=first;
  while ((loc < last)&&(buffer[loc]==' ')) incr(loc);
  if (loc < last) 
    {@+return true;
     /*return unless the line was all blank*/ 
    } 
  write_ln(term_out,"Please type the name of your input file.");
  } 
} 

@* String handling.
Symbolic token names and diagnostic messages are variable-length strings
of eight-bit characters. Since \PASCAL\ does not have a well-developed string
mechanism, \MF\ does all of its string processing by homegrown methods.

Elaborate facilities for dynamic strings are not needed, so all of the
necessary operations can be handled with a simple data structure.
The array |str_pool| contains all of the (eight-bit) ASCII codes in all
of the strings, and the array |str_start| contains indices of the starting
points of each string. Strings are referred to by integer numbers, so that
string number |s| comprises the characters |str_pool[j]| for
|str_start[s] <= j < str_start[s+1]|. Additional integer variables
|pool_ptr| and |str_ptr| indicate the number of entries used so far
in |str_pool| and |str_start|, respectively; locations
|str_pool[pool_ptr]| and |str_start[str_ptr]| are
ready for the next string to be allocated.

String numbers 0 to 255 are reserved for strings that correspond to single
ASCII characters. This is in accordance with the conventions of \.{WEB},
@.WEB@>
which converts single-character strings into the ASCII code number of the
single character involved, while it converts other strings into integers
and builds a string pool file. Thus, when the string constant \.{"."} appears
in the program below, \.{WEB} converts it into the integer 46, which is the
ASCII code for a period, while \.{WEB} will convert a string like \.{"hello"}
into some integer greater than~255. String number 46 will presumably be the
single character `\..'\thinspace; but some ASCII codes have no standard visible
representation, and \MF\ may need to be able to print an arbitrary
ASCII character, so the first 256 strings are used to specify exactly what
should be printed for each of the 256 possibilities.

Elements of the |str_pool| array must be ASCII codes that can actually be
printed; i.e., they must have an |xchr| equivalent in the local
character set. (This restriction applies only to preloaded strings,
not to those generated dynamically by the user.)

Some \PASCAL\ compilers won't pack integers into a single byte unless the
integers lie in the range |-128 dotdot 127|. To accommodate such systems
we access the string pool only via macros that can easily be redefined.
@^system dependencies@>

@d si(X)	X /*convert from |ASCII_code| to |packed_ASCII_code|*/ 
@d so(X)	X /*convert from |packed_ASCII_code| to |ASCII_code|*/ 

@<Types...@>=
typedef uint16_t pool_pointer; /*for variables that point into |str_pool|*/ 
typedef uint16_t str_number; /*for variables that point into |str_start|*/ 
typedef uint8_t packed_ASCII_code; /*elements of |str_pool| array*/ 

@ @<Glob...@>=
@<prepare for string pool initialization@>@;
packed_ASCII_code @!str_pool[pool_size+1]= @<|str_pool| initialization@>; /*the characters*/ 
pool_pointer @!str_start[max_strings+1]= {@<|str_start| initialization@>}; /*the starting pointers*/ 
pool_pointer @!pool_ptr=@<|pool_ptr| initialization@>; /*first unused position in |str_pool|*/ 
str_number @!str_ptr=@<|str_ptr| initialization@>; /*number of the current string being created*/
pool_pointer @!init_pool_ptr; /*the starting value of |pool_ptr|*/ 
str_number @!init_str_ptr; /*the starting value of |str_ptr|*/ 
pool_pointer @!max_pool_ptr; /*the maximum so far of |pool_ptr|*/ 
str_number @!max_str_ptr; /*the maximum so far of |str_ptr|*/ 

@ Several of the elementary string operations are performed using \.{WEB}
macros instead of \PASCAL\ procedures, because many of the
operations are done quite frequently and we want to avoid the
overhead of procedure calls. For example, here is
a simple macro that computes the length of a string.
@.WEB@>

@d length(X)	(str_start[X+1]-str_start[X]) /*the number of characters
  in string number \#*/ 

@ The length of the current string is called |cur_length|:

@d cur_length	(pool_ptr-str_start[str_ptr])

@ Strings are created by appending character codes to |str_pool|.
The |append_char| macro, defined here, does not check to see if the
value of |pool_ptr| has gotten too high; this test is supposed to be
made before |append_char| is used.

To test if there is room to append |l| more characters to |str_pool|,
we shall write |str_room(l)|, which aborts \MF\ and gives an
apologetic error message if there isn't enough room.

@d append_char(X)	 /*put |ASCII_code| \# at the end of |str_pool|*/ 
{@+str_pool[pool_ptr]=si(X);incr(pool_ptr);
} 
@d str_room(X)	 /*make sure that the pool hasn't overflowed*/ 
  {@+if (pool_ptr+X > max_pool_ptr) 
    {@+if (pool_ptr+X > pool_size) 
      overflow("pool size", pool_size-init_pool_ptr);
@:METAFONT capacity exceeded pool size}{\quad pool size@>
    max_pool_ptr=pool_ptr+X;
    } 
  } 

@ \MF's string expressions are implemented in a brute-force way: Every
new string or substring that is needed is simply copied into the string pool.

Such a scheme can be justified because string expressions aren't a big
deal in \MF\ applications; strings rarely need to be saved from one
statement to the next. But it would waste space needlessly if we didn't
try to reclaim the space of strings that are going to be used only once.

Therefore a simple reference count mechanism is provided: If there are
@^reference counts@>
no references to a certain string from elsewhere in the program, and
if there are no references to any strings created subsequent to it,
then the string space will be reclaimed.

The number of references to string number |s| will be |str_ref[s]|. The
special value |str_ref[s]==max_str_ref==127| is used to denote an unknown
positive number of references; such strings will never be recycled. If
a string is ever referred to more than 126 times, simultaneously, we
put it in this category. Hence a single byte suffices to store each |str_ref|.

@d max_str_ref	127 /*``infinite'' number of references*/ 
@d add_str_ref(X)	{@+if (str_ref[X] < max_str_ref) incr(str_ref[X]);
  } 

@<Glob...@>=
uint8_t @!str_ref[max_strings+1];

@ Here's what we do when a string reference disappears:

@d delete_str_ref(X)	{@+if (str_ref[X] < max_str_ref) 
    if (str_ref[X] > 1) decr(str_ref[X]);@+else flush_string(X);
    } 

@<Declare the procedure called |flush_string|@>=
void flush_string(str_number @!s)
{@+if (s < str_ptr-1) str_ref[s]=0;
else@/do@+{decr(str_ptr);
  }@+ while (!(str_ref[str_ptr-1]!=0));
pool_ptr=str_start[str_ptr];
} 

@ Once a sequence of characters has been appended to |str_pool|, it
officially becomes a string when the function |make_string| is called.
This function returns the identification number of the new string as its
value.

@p str_number make_string(void) /*current string enters the pool*/ 
{@+if (str_ptr==max_str_ptr) 
  {@+if (str_ptr==max_strings) 
    overflow("number of strings", max_strings-init_str_ptr);
@:METAFONT capacity exceeded number of strings}{\quad number of strings@>
  incr(max_str_ptr);
  } 
str_ref[str_ptr]=1;incr(str_ptr);str_start[str_ptr]=pool_ptr;
return str_ptr-1;
} 

@ The following subroutine compares string |s| with another string of the
same length that appears in |buffer| starting at position |k|;
the result is |true| if and only if the strings are equal.

@p bool str_eq_buf(str_number @!s, int @!k)
   /*test equality of strings*/ 
{@+ /*loop exit*/ 
pool_pointer @!j; /*running index*/ 
bool @!result; /*result of comparison*/ 
j=str_start[s];
while (j < str_start[s+1]) 
  {@+if (so(str_pool[j])!=buffer[k]) 
    {@+result=false;goto not_found;
    } 
  incr(j);incr(k);
  } 
result=true;
not_found: return result;
} 

@ Here is a similar routine, but it compares two strings in the string pool,
and it does not assume that they have the same length. If the first string
is lexicographically greater than, less than, or equal to the second,
the result is respectively positive, negative, or zero.

@p int str_vs_str(str_number @!s, str_number @!t)
   /*test equality of strings*/ 
{@+
pool_pointer @!j, @!k; /*running indices*/ 
int @!ls, @!lt; /*lengths*/ 
int @!l; /*length remaining to test*/ 
ls=length(s);lt=length(t);
if (ls <= lt) l=ls;@+else l=lt;
j=str_start[s];k=str_start[t];
while (l > 0) 
  {@+if (str_pool[j]!=str_pool[k]) 
    {@+return str_pool[j]-str_pool[k];
    } 
  incr(j);incr(k);decr(l);
  } 
return ls-lt;
} 

@ The initial values of |str_pool|, |str_start|, |pool_ptr|,
and |str_ptr| are computed by the \.{INIMF} program, based in part
on the information that \.{WEB} has output while processing \MF.
@.INIMF@>
@^string pool@>

@p
#ifdef @!INIT
bool get_strings_started(void) /*initializes the string pool,
  but returns |false| if something goes wrong*/ 
{@+
int @!k, @!l; /*small indices or counters*/ 
uint8_t @!m, @!n; /*characters input from |pool_file|*/ 
str_number @!g; /*garbage*/ 
int @!a; /*accumulator for check sum*/ 
bool @!c; /*check sum has been checked*/ 
pool_ptr=0;str_ptr=0;max_pool_ptr=0;max_str_ptr=0;str_start[0]=0;
@<Make the first 256 strings@>;
@<Read the other strings from the \.{MF.POOL} file and return |true|, or give an error
message and return |false|@>;
} 
#endif

@ @d app_lc_hex(X)	l=X;
  if (l < 10) append_char(l+'0')@;@+else append_char(l-10+'a')

@<Make the first 256...@>=
for (k=0; k<=255; k++) 
  { if (@[@<Character |k| cannot be printed@>@]) 
    { append_char('^');append_char('^');
    if (k < 0100) append_char(k+0100)@;
    else if (k < 0200) append_char(k-0100)@;
    else{ app_lc_hex(k/16);app_lc_hex(k%16);
      } 
    } 
  else append_char(k);
  g=make_string();str_ref[g]=max_str_ref;
  } 

@ The first 128 strings will contain 95 standard ASCII characters, and the
other 33 characters will be printed in three-symbol form like `\.{\^\^A}'
unless a system-dependent change is made here. Installations that have
an extended character set, where for example |xchr[032]==@t\.{\'^^Z\'}@>|,
would like string 032 to be the single character 032 instead of the
three characters 0136, 0136, 0132 (\.{\^\^Z}). On the other hand,
even people with an extended character set will want to represent string
015 by \.{\^\^M}, since 015 is ASCII's ``carriage return'' code; the idea is
to produce visible strings instead of tabs or line-feeds or carriage-returns
or bell-rings or characters that are treated anomalously in text files.

Unprintable characters of codes 128--255 are, similarly, rendered
\.{\^\^80}--\.{\^\^ff}.

The boolean expression defined here should be |true| unless \MF\ internal
code number~|k| corresponds to a non-troublesome visible symbol in the
local character set.
If character |k| cannot be printed, and |k < 0200|, then character |k+0100| or
|k-0100| must be printable; moreover, ASCII codes
|[060 dotdot 071, 0136, 0141 dotdot 0146]|
must be printable.
@^character set dependencies@>
@^system dependencies@>

@<Character |k| cannot be printed@>=
  (k < ' ')||(k > '~')

@ When the \.{WEB} system program called \.{TANGLE} processes the \.{MF.WEB}
description that you are now reading, it outputs the \PASCAL\ program
\.{MF.PAS} and also a string pool file called \.{MF.POOL}. The \.{INIMF}
@.WEB@>@.INIMF@>
program reads the latter file, where each string appears as a two-digit decimal
length followed by the string itself, and the information is recorded in
\MF's string memory.

@<Glob...@>=
#ifdef @!INIT
alpha_file @!pool_file; /*the string-pool file output by \.{TANGLE}*/ 
#endif

@ @d bad_pool(X)	{@+wake_up_terminal;write_ln(term_out, X);
  a_close(&pool_file);return false;
  } 
@<Read the other strings...@>=
{@+int k;@+for(k=1; k<=file_name_size;k++)name_of_file[k]=pool_name[k-1];@+} /*we needn't set |name_length|*/ 
if (a_open_in(&pool_file)) 
  {@+c=false;
  @/do@+{@<Read one string, but return |false| if the string memory space is getting
too tight for comfort@>;
  }@+ while (!(c));
  a_close(&pool_file);return true;
  } 
else bad_pool("! I can't read MF.POOL.")
@.I can't read MF.POOL@>

@ @<Read one string...@>=
{@+if (eof(pool_file)) bad_pool("! MF.POOL has no check sum.");
@.MF.POOL has no check sum@>
pascal_read(pool_file, m);@+pascal_read(pool_file, n); /*read two digits of string length*/ 
if (m== '*' ) @<Check the pool check sum@>@;
else{@+if ((xord[m] < '0')||(xord[m] > '9')||@|
      (xord[n] < '0')||(xord[n] > '9')) 
    bad_pool("! MF.POOL line doesn't begin with two digits.");
@.MF.POOL line doesn't...@>
  l=xord[m]*10+xord[n]-'0'*11; /*compute the length*/ 
  if (pool_ptr+l+string_vacancies > pool_size) 
    bad_pool("! You have to increase POOLSIZE.");
@.You have to increase POOLSIZE@>
  for (k=1; k<=l; k++) 
    {@+if (eoln(pool_file)) m= ' ' ;@+else pascal_read(pool_file, m);
    append_char(xord[m]);
    } 
  read_ln(pool_file);g=make_string();str_ref[g]=max_str_ref;
  } 
} 

@ The \.{WEB} operation \.{@@\$} denotes the value that should be at the
end of this \.{MF.POOL} file; any other value means that the wrong pool
file has been loaded.
@^check sum@>

@<Check the pool check sum@>=
{@+a=0;k=1;
loop@+{@+if ((xord[n] < '0')||(xord[n] > '9')) 
  bad_pool("! MF.POOL check sum doesn't have nine digits.");
@.MF.POOL check sum...@>
  a=10*a+xord[n]-'0';
  if (k==9) goto done;
  incr(k);pascal_read(pool_file, n);
  } 
done: if (a!=0) bad_pool("! MF.POOL doesn't match; TANGLE me again.");
@.MF.POOL doesn't match@>
c=true;
} 

@* On-line and off-line printing.
Messages that are sent to a user's terminal and to the transcript-log file
are produced by several `|print|' procedures. These procedures will
direct their output to a variety of places, based on the setting of
the global variable |selector|, which has the following possible
values:

\yskip
\hang |term_and_log|, the normal setting, prints on the terminal and on the
  transcript file.

\hang |log_only|, prints only on the transcript file.

\hang |term_only|, prints only on the terminal.

\hang |no_print|, doesn't print at all. This is used only in rare cases
  before the transcript file is open.

\hang |pseudo|, puts output into a cyclic buffer that is used
  by the |show_context| routine; when we get to that routine we shall discuss
  the reasoning behind this curious mode.

\hang |new_string|, appends the output to the current string in the
  string pool.

\yskip
\noindent The symbolic names `|term_and_log|', etc., have been assigned
numeric codes that satisfy the convenient relations |no_print+1==term_only|,
|no_print+2==log_only|, |term_only+2==log_only+1==term_and_log|.

Three additional global variables, |tally| and |term_offset| and
|file_offset|, record the number of characters that have been printed
since they were most recently cleared to zero. We use |tally| to record
the length of (possibly very long) stretches of printing; |term_offset|
and |file_offset|, on the other hand, keep track of how many characters
have appeared so far on the current line that has been output to the
terminal or to the transcript file, respectively.

@d no_print	0 /*|selector| setting that makes data disappear*/ 
@d term_only	1 /*printing is destined for the terminal only*/ 
@d log_only	2 /*printing is destined for the transcript file only*/ 
@d term_and_log	3 /*normal |selector| setting*/ 
@d pseudo	4 /*special |selector| setting for |show_context|*/ 
@d new_string	5 /*printing is deflected to the string pool*/ 
@d max_selector	5 /*highest selector setting*/ 

@<Glob...@>=
alpha_file @!log_file; /*transcript of \MF\ session*/ 
uint8_t @!selector; /*where to print a message*/ 
uint8_t @!dig[23]; /*digits in a number being output*/ 
int @!tally; /*the number of characters recently printed*/ 
uint8_t @!term_offset;
   /*the number of characters on the current terminal line*/ 
uint8_t @!file_offset;
   /*the number of characters on the current file line*/ 
ASCII_code @!trick_buf[error_line+1]; /*circular buffer for
  pseudoprinting*/ 
int @!trick_count; /*threshold for pseudoprinting, explained later*/ 
int @!first_count; /*another variable for pseudoprinting*/ 

@ @<Initialize the output routines@>=
selector=term_only;tally=0;term_offset=0;file_offset=0;

@ Macro abbreviations for output to the terminal and to the log file are
defined here for convenience. Some systems need special conventions
for terminal output, and it is possible to adhere to those conventions
by changing |wterm|, |wterm_ln|, and |wterm_cr| here.
@^system dependencies@>

@<Compiler directives@>=
#define put(file)    @[fwrite(&((file).d),sizeof((file).d),1,(file).f)@]
#define get(file)    @[fread(&((file).d),sizeof((file).d),1,(file).f)@]

#define reset(file,name,mode)   @[((file).f=fopen((char *)(name)+1,mode),\
                                 (file).f!=NULL?get(file):0)@]
#define rewrite(file,name,mode) @[((file).f=fopen((char *)(name)+1,mode))@]
#define pascal_close(file)    @[fclose((file).f)@]
#define eof(file)    @[feof((file).f)@]
#define eoln(file)    @[((file).d=='\n'||eof(file))@]
#define erstat(file)   @[((file).f==NULL?-1:ferror((file).f))@]

#define pascal_read(file,x) @[((x)=(file).d,get(file))@]
#define read_ln(file)  @[do get(file); while (!eoln(file))@]

#define pascal_write(file, format,...)    @[fprintf(file.f,format,## __VA_ARGS__)@]
#define write_ln(file,...)	   @[pascal_write(file,__VA_ARGS__"\n")@]

#define wterm(format,...)	@[pascal_write(term_out,format, ## __VA_ARGS__)@]
#define wterm_ln(format,...)	@[wterm(format "\n", ## __VA_ARGS__)@]
#define wterm_cr	        @[pascal_write(term_out,"\n")@]
#define wlog(format, ...)	@[pascal_write(log_file,format, ## __VA_ARGS__)@]
#define wlog_ln(format, ...)   @[wlog(format "\n", ## __VA_ARGS__)@]
#define wlog_cr	        @[pascal_write(log_file,"\n")@]

@ To end a line of text output, we call |print_ln|.

@<Basic print...@>=
void print_ln(void) /*prints an end-of-line*/ 
{@+switch (selector) {
case term_and_log: {@+wterm_cr;wlog_cr;
  term_offset=0;file_offset=0;
  } @+break;
case log_only: {@+wlog_cr;file_offset=0;
  } @+break;
case term_only: {@+wterm_cr;term_offset=0;
  } @+break;
case no_print: case pseudo: case new_string: do_nothing;
}  /*there are no other cases*/ 
}  /*note that |tally| is not affected*/ 

@ The |print_char| procedure sends one character to the desired destination,
using the |xchr| array to map it into an external character compatible with
|input_ln|. All printing comes through |print_ln| or |print_char|.

@<Basic printing...@>=
void print_char(ASCII_code @!s) /*prints a single character*/ 
{@+switch (selector) {
case term_and_log: {@+wterm("%c",xchr[s]);wlog("%c",xchr[s]);
  incr(term_offset);incr(file_offset);
  if (term_offset==max_print_line) 
    {@+wterm_cr;term_offset=0;
    } 
  if (file_offset==max_print_line) 
    {@+wlog_cr;file_offset=0;
    } 
  } @+break;
case log_only: {@+wlog("%c",xchr[s]);incr(file_offset);
  if (file_offset==max_print_line) print_ln();
  } @+break;
case term_only: {@+wterm("%c",xchr[s]);incr(term_offset);
  if (term_offset==max_print_line) print_ln();
  } @+break;
case no_print: do_nothing;@+break;
case pseudo: if (tally < trick_count) trick_buf[tally%error_line]=s;@+break;
case new_string: {@+if (pool_ptr < pool_size) append_char(s);
  }  /*we drop characters if the string space is full*/ 
}  /*there are no other cases*/ 
incr(tally);
} 

@ An entire string is output by calling |print|. Note that if we are outputting
the single standard ASCII character \.c, we could call |print('c')|, since
|'c'==99| is the number of a single-character string, as explained above. But
|print_char('c')| is quicker, so \MF\ goes directly to the |print_char|
routine when it knows that this is safe. (The present implementation
assumes that it is always safe to print a visible ASCII character.)
@^system dependencies@>

@<Basic print...@>=
void print(int @!s) /*prints string |s|*/ 
{@+pool_pointer @!j; /*current character code position*/ 
if ((s < 0)||(s >= str_ptr)) s=@[@<|"???"|@>@]; /*this can't happen*/ 
@.???@>
if ((s < 256)&&(selector > pseudo)) print_char(s);
else{@+j=str_start[s];
  while (j < str_start[s+1]) 
    {@+print_char(so(str_pool[j]));incr(j);
    } 
  } 
} 

void print_str(char *s) /* the simple version */
{while (*s!=0) print_char(*s++);@+
} 

@ Sometimes it's necessary to print a string whose characters
may not be visible ASCII codes. In that case |slow_print| is used.

@<Basic print...@>=
void slow_print(int @!s) /*prints string |s|*/ 
{@+pool_pointer @!j; /*current character code position*/ 
if ((s < 0)||(s >= str_ptr)) s=@[@<|"???"|@>@]; /*this can't happen*/ 
@.???@>
if ((s < 256)&&(selector > pseudo)) print_char(s);
else{@+j=str_start[s];
  while (j < str_start[s+1]) 
    {@+print(so(str_pool[j]));incr(j);
    } 
  } 
} 

@ Here is the very first thing that \MF\ prints: a headline that identifies
the version number and base name. The |term_offset| variable is temporarily
incorrect, but the discrepancy is not serious since we assume that the banner
and base identifier together will occupy at most |max_print_line|
character positions.

@<Initialize the output...@>=
wterm("%s",banner);
if (base_ident==0) wterm_ln(" (no base preloaded)");
else{@+slow_print(base_ident);print_ln();
  } 
update_terminal;

@ The procedure |print_nl| is like |print|, but it makes sure that the
string appears at the beginning of a new line.

@<Basic print...@>=
void print_nl(char *@!s) /*prints string |s| at beginning of line*/ 
{@+if (((term_offset > 0)&&(odd(selector)))||@|
  ((file_offset > 0)&&(selector >= log_only))) print_ln();
print_str(s);
} 

@ An array of digits in the range |0 dotdot 9| is printed by |print_the_digs|.

@<Basic print...@>=
void print_the_digs(eight_bits @!k)
   /*prints |dig[k-1]|$\,\ldots\,$|dig[0]|*/ 
{@+while (k > 0) 
  {@+decr(k);print_char('0'+dig[k]);
  } 
} 

@ The following procedure, which prints out the decimal representation of a
given integer |n|, has been written carefully so that it works properly
if |n==0| or if |(-n)| would cause overflow. It does not apply |%| or |/|
to negative arguments, since such operations are not implemented consistently
by all \PASCAL\ compilers.

@<Basic print...@>=
void print_int(int @!n) /*prints an integer in decimal form*/ 
{@+uint8_t k; /*index to current digit; we assume that $|n|<10^{23}$*/ 
int @!m; /*used to negate |n| in possibly dangerous cases*/ 
k=0;
if (n < 0) 
  {@+print_char('-');
  if (n > -100000000) negate(n);
  else{@+m=-1-n;n=m/10;m=(m%10)+1;k=1;
    if (m < 10) dig[0]=m;
    else{@+dig[0]=0;incr(n);
      } 
    } 
  } 
@/do@+{dig[k]=n%10;n=n/10;incr(k);
}@+ while (!(n==0));
print_the_digs(k);
} 

@ \MF\ also makes use of a trivial procedure to print two digits. The
following subroutine is usually called with a parameter in the range |0 <= n <= 99|.

@p void print_dd(int @!n) /*prints two least significant digits*/ 
{@+n=abs(n)%100;print_char('0'+(n/10));
print_char('0'+(n%10));
} 

@ Here is a procedure that asks the user to type a line of input,
assuming that the |selector| setting is either |term_only| or |term_and_log|.
The input is placed into locations |first| through |last-1| of the
|buffer| array, and echoed on the transcript file if appropriate.

This procedure is never called when |interaction < scroll_mode|.

@d prompt_input(X)	{@+wake_up_terminal;print_str(X);term_input();
    }  /*prints a string and gets a line of input*/ 

@p void term_input(void) /*gets a line from the terminal*/ 
{@+int @!k; /*index into |buffer|*/ 
update_terminal; /*now the user sees the prompt for sure*/ 
if (!input_ln(&term_in, true)) fatal_error("End of file on the terminal!");
@.End of file on the terminal@>
term_offset=0; /*the user's line ended with \<\rm return>*/ 
decr(selector); /*prepare to echo the input*/ 
if (last!=first) for (k=first; k<=last-1; k++) print(buffer[k]);
print_ln();buffer[last]='%';incr(selector); /*restore previous status*/ 
} 

@* Reporting errors.
When something anomalous is detected, \MF\ typically does something like this:
$$\vbox{\halign{#\hfil\cr
|print_err("Something anomalous has been detected");|\cr
|help3("This is the first line of my offer to help.")|\cr
|("This is the second line. I'm trying to")|\cr
|("explain the best way for you to proceed.");|\cr
|error;|\cr}}$$
A two-line help message would be given using |help2|, etc.; these informal
helps should use simple vocabulary that complements the words used in the
official error message that was printed. (Outside the U.S.A., the help
messages should preferably be translated into the local vernacular. Each
line of help is at most 60 characters long, in the present implementation,
so that |max_print_line| will not be exceeded.)

The |print_err| procedure supplies a `\.!' before the official message,
and makes sure that the terminal is awake if a stop is going to occur.
The |error| procedure supplies a `\..' after the official message, then it
shows the location of the error; and if |interaction==error_stop_mode|,
it also enters into a dialog with the user, during which time the help
message may be printed.
@^system dependencies@>

@ The global variable |interaction| has four settings, representing increasing
amounts of user interaction:

@d batch_mode	0 /*omits all stops and omits terminal output*/ 
@d nonstop_mode	1 /*omits all stops*/ 
@d scroll_mode	2 /*omits error stops*/ 
@d error_stop_mode	3 /*stops at every opportunity to interact*/ 
@d print_err(X)	{@+if (interaction==error_stop_mode) wake_up_terminal;
  print_nl("! ");print_str(X);
@.!\relax@>
  } 

@<Glob...@>=
uint8_t @!interaction; /*current level of interaction*/ 

@ @<Set init...@>=interaction=error_stop_mode;

@ \MF\ is careful not to call |error| when the print |selector| setting
might be unusual. The only possible values of |selector| at the time of
error messages are

\yskip\hang|no_print| (when |interaction==batch_mode|
  and |log_file| not yet open);

\hang|term_only| (when |interaction > batch_mode| and |log_file| not yet open);

\hang|log_only| (when |interaction==batch_mode| and |log_file| is open);

\hang|term_and_log| (when |interaction > batch_mode| and |log_file| is open).

@<Initialize the print |selector| based on |interaction|@>=
if (interaction==batch_mode) selector=no_print;@+else selector=term_only

@ A global variable |deletions_allowed| is set |false| if the |get_next|
routine is active when |error| is called; this ensures that |get_next|
will never be called recursively.
@^recursion@>

The global variable |history| records the worst level of error that
has been detected. It has four possible values: |spotless|, |warning_issued|,
|error_message_issued|, and |fatal_error_stop|.

Another global variable, |error_count|, is increased by one when an
|error| occurs without an interactive dialog, and it is reset to zero at
the end of every statement.  If |error_count| reaches 100, \MF\ decides
that there is no point in continuing further.

@d spotless	0 /*|history| value when nothing has been amiss yet*/ 
@d warning_issued	1 /*|history| value when |begin_diagnostic| has been called*/ 
@d error_message_issued	2 /*|history| value when |error| has been called*/ 
@d fatal_error_stop	3 /*|history| value when termination was premature*/ 

@<Glob...@>=
bool @!deletions_allowed; /*is it safe for |error| to call |get_next|?*/ 
uint8_t @!history; /*has the source input been clean so far?*/ 
int8_t @!error_count; /*the number of scrolled errors since the
  last statement ended*/ 

@ The value of |history| is initially |fatal_error_stop|, but it will
be changed to |spotless| if \MF\ survives the initialization process.

@<Set init...@>=
deletions_allowed=true;error_count=0; /*|history| is initialized elsewhere*/ 

@ Since errors can be detected almost anywhere in \MF, we want to declare the
error procedures near the beginning of the program. But the error procedures
in turn use some other procedures, which need to be declared |forward|
before we get to |error| itself.

It is possible for |error| to be called recursively if some error arises
when |get_next| is being used to delete a token, and/or if some fatal error
occurs while \MF\ is trying to fix a non-fatal one. But such recursion
@^recursion@>
is never more than two levels deep.

@<Error handling...@>=
void normalize_selector(void);@/
void get_next(void);@/
void term_input(void);@/
void show_context(void);@/
void begin_file_reading(void);@/
void open_log_file(void);@/
void close_files_and_terminate(void);@/
void clear_for_error_prompt(void);@/
@t\4\hskip-\fontdimen2\font@>@;
#ifdef @!DEBUG
void debug_help(void);
#else
#define debug_help() do_nothing
#endif
@;@/
@t\4@>@<Declare the procedure called |flush_string|@>@;

@ Individual lines of help are recorded in the array |help_line|, which
contains entries in positions |0 dotdot(help_ptr-1)|. They should be printed
in reverse order, i.e., with |help_line[0]| appearing last.

@d hlp1(X)	help_line[0]=X;@+} 
@d hlp2(X)	help_line[1]=X;hlp1
@d hlp3(X)	help_line[2]=X;hlp2
@d hlp4(X)	help_line[3]=X;hlp3
@d hlp5(X)	help_line[4]=X;hlp4
@d hlp6(X)	help_line[5]=X;hlp5
@d help0	help_ptr=0 /*sometimes there might be no help*/ 
@d help1	@+{@+help_ptr=1;hlp1 /*use this with one help line*/ 
@d help2	@+{@+help_ptr=2;hlp2 /*use this with two help lines*/ 
@d help3	@+{@+help_ptr=3;hlp3 /*use this with three help lines*/ 
@d help4	@+{@+help_ptr=4;hlp4 /*use this with four help lines*/ 
@d help5	@+{@+help_ptr=5;hlp5 /*use this with five help lines*/ 
@d help6	@+{@+help_ptr=6;hlp6 /*use this with six help lines*/ 

@<Glob...@>=
char *@!help_line[6]; /*helps for the next |error|*/ 
uint8_t @!help_ptr; /*the number of help lines present*/ 
bool @!use_err_help; /*should the |err_help| string be shown?*/ 
str_number @!err_help; /*a string set up by \&{errhelp}*/ 

@ @<Set init...@>=
help_ptr=0;use_err_help=false;err_help=0;

@ The |jump_out| procedure just cuts across all active procedure levels and
goes to |end_of_MF|. This is the only nontrivial |@!goto| statement in the
whole program. It is used when there is no recovery from a particular error.

Some \PASCAL\ compilers do not implement non-local |goto| statements.
@^system dependencies@>
In such cases the body of |jump_out| should simply be
`|close_files_and_terminate|;\thinspace' followed by a call on some system
procedure that quietly terminates the program.

@<Error hand...@>=
void jump_out(void)
{@+ close_files_and_terminate(); exit(0);
} 

@ Here now is the general |error| routine.

@<Error hand...@>=
void error(void) /*completes the job of error reporting*/ 
{@+
ASCII_code @!c; /*what the user types*/ 
int @!s1, @!s2, @!s3; /*used to save global variables when deleting tokens*/ 
pool_pointer @!j; /*character position being printed*/ 
if (history < error_message_issued) history=error_message_issued;
print_char('.');show_context();
if (interaction==error_stop_mode) @<Get user's advice and |return|@>;
incr(error_count);
if (error_count==100) 
  {@+print_nl("(That makes 100 errors; please try again.)");
@.That makes 100 errors...@>
  history=fatal_error_stop;jump_out();
  } 
@<Put help message on the transcript file@>;
} 

@ @<Get user's advice...@>=
loop@+{@+resume: clear_for_error_prompt();prompt_input("? ");
@.?\relax@>
  if (last==first) return;
  c=buffer[first];
  if (c >= 'a') c=c+'A'-'a'; /*convert to uppercase*/ 
  @<Interpret code |c| and |return| if done@>;
  } 

@ It is desirable to provide an `\.E' option here that gives the user
an easy way to return from \MF\ to the system editor, with the offending
line ready to be edited. But such an extension requires some system
wizardry, so the present implementation simply types out the name of the
file that should be
edited and the relevant line number.
@^system dependencies@>

There is a secret `\.D' option available when the debugging routines haven't
been commented~out.
@^debugging@>

@<Interpret code |c| and |return| if done@>=
switch (c) {
case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': if (deletions_allowed) 
  @<Delete |c-"0"| tokens and |goto continue|@>@;@+break;
@t\4\4@>@;
#ifdef @!DEBUG
case 'D': {@+debug_help();goto resume;@+} 
#endif
case 'E': if (file_ptr > 0) 
  {@+print_nl("You want to edit file ");
@.You want to edit file x@>
  slow_print(input_stack[file_ptr].name_field);
  print_str(" at line ");print_int(line);@/
  interaction=scroll_mode;jump_out();
  } @+break;
case 'H': @<Print the help information and |goto continue|@>@;
case 'I': @<Introduce new material from the terminal and |return|@>@;
case 'Q': case 'R': case 'S': @<Change the interaction level and |return|@>@;
case 'X': {@+interaction=scroll_mode;jump_out();
  } @+break;
default:do_nothing;
} @/
@<Print the menu of available options@>@;

@ @<Print the menu...@>=
{@+print_str("Type <return> to proceed, S to scroll future error messages,");@/
@.Type <return> to proceed...@>
print_nl("R to run without stopping, Q to run quietly,");@/
print_nl("I to insert something, ");
if (file_ptr > 0) print_str("E to edit your file,");
if (deletions_allowed) 
  print_nl("1 or ... or 9 to ignore the next 1 to 9 tokens of input,");
print_nl("H for help, X to quit.");
} 

@ Here the author of \MF\ apologizes for making use of the numerical
relation between |'Q'|, |'R'|, |'S'|, and the desired interaction settings
|batch_mode|, |nonstop_mode|, |scroll_mode|.
@^Knuth, Donald Ervin@>

@<Change the interaction...@>=
{@+error_count=0;interaction=batch_mode+c-'Q';
print_str("OK, entering ");
switch (c) {
case 'Q': {@+print_str("batchmode");decr(selector);
  } @+break;
case 'R': print_str("nonstopmode");@+break;
case 'S': print_str("scrollmode");
}  /*there are no other cases*/ 
print_str("...");print_ln();update_terminal;return;
} 

@ When the following code is executed, |buffer[(first+1)dotdot(last-1)]| may
contain the material inserted by the user; otherwise another prompt will
be given. In order to understand this part of the program fully, you need
to be familiar with \MF's input stacks.

@<Introduce new material...@>=
{@+begin_file_reading(); /*enter a new syntactic level for terminal input*/ 
if (last > first+1) 
  {@+loc=first+1;buffer[first]=' ';
  } 
else{@+prompt_input("insert>");loc=first;
@.insert>@>
  } 
first=last+1;cur_input.limit_field=last;return;
} 

@ We allow deletion of up to 99 tokens at a time.

@<Delete |c-"0"| tokens...@>=
{@+s1=cur_cmd;s2=cur_mod;s3=cur_sym;OK_to_interrupt=false;
if ((last > first+1)&&(buffer[first+1] >= '0')&&(buffer[first+1] <= '9')) 
  c=c*10+buffer[first+1]-'0'*11;
else c=c-'0';
while (c > 0) 
  {@+get_next(); /*one-level recursive call of |error| is possible*/ 
  @<Decrease the string reference count, if the current token is a string@>;
  decr(c);
  } 
cur_cmd=s1;cur_mod=s2;cur_sym=s3;OK_to_interrupt=true;
help2("I have just deleted some text, as you asked.")@/
("You can now delete more, or insert, or whatever.");
show_context();goto resume;
} 

@ @<Print the help info...@>=
{@+if (use_err_help) 
  {@+@<Print the string |err_help|, possibly on several lines@>;
  use_err_help=false;
  } 
else{@+if (help_ptr==0) 
    help2("Sorry, I don't know how to help in this situation.")@/
    @t\kern1em@>("Maybe you should try asking a human?");
  @/do@+{decr(help_ptr);print_str(help_line[help_ptr]);print_ln();
  }@+ while (!(help_ptr==0));
  } 
help4("Sorry, I already gave what help I could...")@/
  ("Maybe you should try asking a human?")@/
  ("An error might have occurred before I noticed any problems.")@/
  ("``If all else fails, read the instructions.'");@/
goto resume;
} 

@ @<Print the string |err_help|, possibly on several lines@>=
j=str_start[err_help];
while (j < str_start[err_help+1]) 
  {@+if (str_pool[j]!=si('%')) print(so(str_pool[j]));
  else if (j+1==str_start[err_help+1]) print_ln();
  else if (str_pool[j+1]!=si('%')) print_ln();
  else{@+incr(j);print_char('%');
    } 
  incr(j);
  } 

@ @<Put help message on the transcript file@>=
if (interaction > batch_mode) decr(selector); /*avoid terminal output*/ 
if (use_err_help) 
  {@+print_nl("");
  @<Print the string |err_help|, possibly on several lines@>;
  } 
else while (help_ptr > 0) 
  {@+decr(help_ptr);print_nl(help_line[help_ptr]);
  } 
print_ln();
if (interaction > batch_mode) incr(selector); /*re-enable terminal output*/ 
print_ln()

@ In anomalous cases, the print selector might be in an unknown state;
the following subroutine is called to fix things just enough to keep
running a bit longer.

@p void normalize_selector(void)
{@+if (log_opened) selector=term_and_log;
else selector=term_only;
if (job_name==0) open_log_file();
if (interaction==batch_mode) decr(selector);
} 

@ The following procedure prints \MF's last words before dying.

@d succumb	{@+if (interaction==error_stop_mode) 
    interaction=scroll_mode; /*no more interaction*/ 
  if (log_opened) error();
  if (interaction > batch_mode) debug_help();
  history=fatal_error_stop;jump_out(); /*irrecoverable error*/ 
  } 

@<Error hand...@>=
void fatal_error(char *@!s) /*prints |s|, and that's it*/ 
{@+normalize_selector();@/
print_err("Emergency stop");help1(s);succumb;
@.Emergency stop@>
} 

@ Here is the most dreaded error message.

@<Error hand...@>=
void overflow(char *@!s, int @!n) /*stop due to finiteness*/ 
{@+normalize_selector();
print_err("METAFONT capacity exceeded, sorry [");
@.METAFONT capacity exceeded ...@>
print_str(s);print_char('=');print_int(n);print_char(']');
help2("If you really absolutely need more capacity,")@/
  ("you can ask a wizard to enlarge me.");
succumb;
} 

@ The program might sometime run completely amok, at which point there is
no choice but to stop. If no previous error has been detected, that's bad
news; a message is printed that is really intended for the \MF\
maintenance person instead of the user (unless the user has been
particularly diabolical).  The index entries for `this can't happen' may
help to pinpoint the problem.
@^dry rot@>

@<Error hand...@>=
void confusion(str_number @!s)
   /*consistency check violated; |s| tells where*/ 
{@+normalize_selector();
if (history < error_message_issued) 
  {@+print_err("This can't happen (");print(s);print_char(')');
@.This can't happen@>
  help1("I'm broken. Please show this to someone who can fix can fix");
  } 
else{@+print_err("I can't go on meeting you like this");
@.I can't go on...@>
  help2("One of your faux pas seems to have wounded me deeply...")@/
    ("in fact, I'm barely conscious. Please fix it and try again.");
  } 
succumb;
} 

@ Users occasionally want to interrupt \MF\ while it's running.
If the \PASCAL\ runtime system allows this, one can implement
a routine that sets the global variable |interrupt| to some nonzero value
when such an interrupt is signalled. Otherwise there is probably at least
a way to make |interrupt| nonzero using the \PASCAL\ debugger.
@^system dependencies@>
@^debugging@>

@d check_interrupt	{@+if (interrupt!=0) pause_for_instructions();
  } 

@<Global...@>=
int @!interrupt; /*should \MF\ pause for instructions?*/ 
bool @!OK_to_interrupt; /*should interrupts be observed?*/ 

@ @<Set init...@>=
interrupt=0;OK_to_interrupt=true;

@ When an interrupt has been detected, the program goes into its
highest interaction level and lets the user have the full flexibility of
the |error| routine.  \MF\ checks for interrupts only at times when it is
safe to do this.

@p void pause_for_instructions(void)
{@+if (OK_to_interrupt) 
  {@+interaction=error_stop_mode;
  if ((selector==log_only)||(selector==no_print)) 
    incr(selector);
  print_err("Interruption");
@.Interruption@>
  help3("You rang?")@/
  ("Try to insert some instructions for me (e.g.,`I show x'),")@/
  ("unless you just want to quit by typing `X'.");
  deletions_allowed=false;error();deletions_allowed=true;
  interrupt=0;
  } 
} 

@ Many of \MF's error messages state that a missing token has been
inserted behind the scenes. We can save string space and program space
by putting this common code into a subroutine.

@p void missing_err(str_number @!s)
{@+print_err("Missing `");print(s);print_str("' has been inserted");
@.Missing...inserted@>
} 

@* Arithmetic with scaled numbers.
The principal computations performed by \MF\ are done entirely in terms of
integers less than $2^{31}$ in magnitude; thus, the arithmetic specified in this
program can be carried out in exactly the same way on a wide variety of
computers, including some small ones.
@^small computers@>

But \PASCAL\ does not define the @!|/|
operation in the case of negative dividends; for example, the result of
|(-2*n-1)/2| is |-(n+1)| on some computers and |-n| on others.
There are two principal types of arithmetic: ``translation-preserving,''
in which the identity |(a+q*b)/b==(a/b)+q| is valid; and
``negation-preserving,'' in which |(-a)/b==-(a/b)|. This leads to
two \MF s, which can produce different results, although the differences
should be negligible when the language is being used properly.
The \TeX\ processor has been defined carefully so that both varieties
of arithmetic will produce identical output, but it would be too
inefficient to constrain \MF\ in a similar way.

@d el_gordo	017777777777 /*$2^{31}-1$, the largest value that \MF\ likes*/ 

@ One of \MF's most common operations is the calculation of
$\lfloor{a+b\over2}\rfloor$,
the midpoint of two given integers |a| and~|b|. The only decent way to do
this in \PASCAL\ is to write `|(a+b)/2|'; but on most machines it is
far more efficient to calculate `|(a+b)| right shifted one bit'.

Therefore the midpoint operation will always be denoted by `|half(a+b)|'
in this program. If \MF\ is being implemented with languages that permit
binary shifting, the |half| macro should be changed to make this operation
as efficient as possible.

@d half(X)	(X)/2

@ A single computation might use several subroutine calls, and it is
desirable to avoid producing multiple error messages in case of arithmetic
overflow. So the routines below set the global variable |arith_error| to |true|
instead of reporting errors directly to the user.
@^overflow in arithmetic@>

@<Glob...@>=
bool @!arith_error; /*has arithmetic overflow occurred recently?*/ 

@ @<Set init...@>=
arith_error=false;

@ At crucial points the program will say |check_arith|, to test if
an arithmetic error has been detected.

@d check_arith	{@+if (arith_error) clear_arith();@+} 

@p void clear_arith(void)
{@+print_err("Arithmetic overflow");
@.Arithmetic overflow@>
help4("Uh, oh. A little while ago one of the quantities that I was")@/
  ("computing got too large, so I'm afraid your answers will be")@/
  ("somewhat askew. You'll probably have to adopt different")@/
  ("tactics next time. But I shall try to carry on anyway.");
error();arith_error=false;
} 

@ Addition is not always checked to make sure that it doesn't overflow,
but in places where overflow isn't too unlikely the |slow_add| routine
is used.

@p int slow_add(int @!x, int @!y)
{@+if (x >= 0) 
  if (y <= el_gordo-x) return x+y;
  else{@+arith_error=true;return el_gordo;
    } 
else if (-y <= el_gordo+x) return x+y;
  else{@+arith_error=true;return-el_gordo;
    } 
} 

@ Fixed-point arithmetic is done on {\sl scaled integers\/} that are multiples
of $2^{-16}$. In other words, a binary point is assumed to be sixteen bit
positions from the right end of a binary computer word.

@d quarter_unit	040000 /*$2^{14}$, represents 0.250000*/ 
@d half_unit	0100000 /*$2^{15}$, represents 0.50000*/ 
@d three_quarter_unit	0140000 /*$3\cdot2^{14}$, represents 0.75000*/ 
@d unity	0200000 /*$2^{16}$, represents 1.00000*/ 
@d two	0400000 /*$2^{17}$, represents 2.00000*/ 
@d three	0600000 /*$2^{17}+2^{16}$, represents 3.00000*/ 

@<Types...@>=
typedef int scaled; /*this type is used for scaled integers*/ 
typedef uint8_t small_number; /*this type is self-explanatory*/ 

@ The following function is used to create a scaled integer from a given decimal
fraction $(.d_0d_1\ldots d_{k-1})$, where |0 <= k <= 17|. The digit $d_i$ is
given in |dig[i]|, and the calculation produces a correctly rounded result.

@p scaled round_decimals(small_number @!k)
   /*converts a decimal fraction*/ 
{@+int @!a; /*the accumulator*/ 
a=0;
while (k > 0) 
  {@+decr(k);a=(a+dig[k]*two)/10;
  } 
return half(a+1);
} 

@ Conversely, here is a procedure analogous to |print_int|. If the output
of this procedure is subsequently read by \MF\ and converted by the
|round_decimals| routine above, it turns out that the original value will
be reproduced exactly. A decimal point is printed only if the value is
not an integer. If there is more than one way to print the result with
the optimum number of digits following the decimal point, the closest
possible value is given.

The invariant relation in the \&{repeat} loop is that a sequence of
decimal digits yet to be printed will yield the original number if and only if
they form a fraction~$f$ in the range $s-\delta\L10\cdot2^{16}f<s$.
We can stop if and only if $f=0$ satisfies this condition; the loop will
terminate before $s$ can possibly become zero.

@<Basic printing...@>=
void print_scaled(scaled @!s) /*prints scaled real, rounded to five
  digits*/ 
{@+scaled @!delta; /*amount of allowable inaccuracy*/ 
if (s < 0) 
  {@+print_char('-');negate(s); /*print the sign, if negative*/ 
  } 
print_int(s/unity); /*print the integer part*/ 
s=10*(s%unity)+5;
if (s!=5) 
  {@+delta=10;print_char('.');
  @/do@+{if (delta > unity) 
    s=s+0100000-(delta/2); /*round the final digit*/ 
  print_char('0'+(s/unity));s=10*(s%unity);delta=delta*10;
  }@+ while (!(s <= delta));
  } 
} 

@ We often want to print two scaled quantities in parentheses,
separated by a comma.

@<Basic printing...@>=
void print_two(scaled @!x, scaled @!y) /*prints `|(x, y)|'*/ 
{@+print_char('(');print_scaled(x);print_char(',');print_scaled(y);
print_char(')');
} 

@ The |scaled| quantities in \MF\ programs are generally supposed to be
less than $2^{12}$ in absolute value, so \MF\ does much of its internal
arithmetic with 28~significant bits of precision. A |fraction| denotes
a scaled integer whose binary point is assumed to be 28 bit positions
from the right.

@d fraction_half	01000000000 /*$2^{27}$, represents 0.50000000*/ 
@d fraction_one	02000000000 /*$2^{28}$, represents 1.00000000*/ 
@d fraction_two	04000000000 /*$2^{29}$, represents 2.00000000*/ 
@d fraction_three	06000000000 /*$3\cdot2^{28}$, represents 3.00000000*/ 
@d fraction_four	010000000000 /*$2^{30}$, represents 4.00000000*/ 

@<Types...@>=
typedef int fraction; /*this type is used for scaled fractions*/ 

@ In fact, the two sorts of scaling discussed above aren't quite
sufficient; \MF\ has yet another, used internally to keep track of angles
in units of $2^{-20}$ degrees.

@d forty_five_deg	0264000000 /*$45\cdot2^{20}$, represents $45^\circ$*/ 
@d ninety_deg	0550000000 /*$90\cdot2^{20}$, represents $90^\circ$*/ 
@d one_eighty_deg	01320000000 /*$180\cdot2^{20}$, represents $180^\circ$*/ 
@d three_sixty_deg	02640000000 /*$360\cdot2^{20}$, represents $360^\circ$*/ 

@<Types...@>=
typedef int angle; /*this type is used for scaled angles*/ 

@ The |make_fraction| routine produces the |fraction| equivalent of
|p/(double)q|, given integers |p| and~|q|; it computes the integer
$f=\lfloor2^{28}p/q+{1\over2}\rfloor$, when $p$ and $q$ are
positive. If |p| and |q| are both of the same scaled type |t|,
the ``type relation'' |make_fraction(t, t)==fraction| is valid;
and it's also possible to use the subroutine ``backwards,'' using
the relation |make_fraction(t, fraction)==t| between scaled types.

If the result would have magnitude $2^{31}$ or more, |make_fraction|
sets |arith_error=true|. Most of \MF's internal computations have
been designed to avoid this sort of error.

Notice that if 64-bit integer arithmetic were available,
we could simply compute |(@t$(2^{29}$@>*p+q)/(2*q)|.
But when we are restricted to \PASCAL's 32-bit arithmetic we
must either resort to multiple-precision maneuvering
or use a simple but slow iteration. The multiple-precision technique
would be about three times faster than the code adopted here, but it
would be comparatively long and tricky, involving about sixteen
additional multiplications and divisions.

This operation is part of \MF's ``inner loop''; indeed, it will
consume nearly 10\pct! of the running time (exclusive of input and output)
if the code below is left unchanged. A machine-dependent recoding
will therefore make \MF\ run faster. The present implementation
is highly portable, but slow; it avoids multiplication and division
except in the initial stage. System wizards should be careful to
replace it with a routine that is guaranteed to produce identical
results in all cases.
@^system dependencies@>

As noted below, a few more routines should also be replaced by machine-dependent
code, for efficiency. But when a procedure is not part of the ``inner loop,''
such changes aren't advisable; simplicity and robustness are
preferable to trickery, unless the cost is too high.
@^inner loop@>

@p fraction make_fraction(int @!p, int @!q)
{@+int @!f; /*the fraction bits, with a leading 1 bit*/ 
int @!n; /*the integer part of $\vert p/q\vert$*/ 
bool @!negative; /*should the result be negated?*/ 
int @!be_careful; /*disables certain compiler optimizations*/ 
if (p >= 0) negative=false;
else{@+negate(p);negative=true;
  } 
if (q <= 0) 
  {
#ifdef @!DEBUG
if (q==0) confusion('/');@;
#endif
@;@/
@:this can't happen /}{\quad \./@>
  negate(q);negative=!negative;
  } 
n=p/q;p=p%q;
if (n >= 8) 
  {@+arith_error=true;
  if (negative) return-el_gordo;@+else return el_gordo;
  } 
else{@+n=(n-1)*fraction_one;
  @<Compute $f=\lfloor 2^{28}(1+p/q)+{1\over2}\rfloor$@>;
  if (negative) return-(f+n);@+else return f+n;
  } 
} 

@ The |@/do@+{| loop here preserves the following invariant relations
between |f|, |p|, and~|q|:
(i)~|0 <= p < q|; (ii)~$fq+p=2^k(q+p_0)$, where $k$ is an integer and
$p_0$ is the original value of~$p$.

Notice that the computation specifies
|(p-q)+p| instead of |(p+p)-q|, because the latter could overflow.
Let us hope that optimizing compilers do not miss this point; a
special variable |be_careful| is used to emphasize the necessary
order of computation. Optimizing compilers should keep |be_careful|
in a register, not store it in memory.
@^inner loop@>

@<Compute $f=\lfloor 2^{28}(1+p/q)+{1\over2}\rfloor$@>=
f=1;
@/do@+{be_careful=p-q;p=be_careful+p;
if (p >= 0) f=f+f+1;
else{@+double(f);p=p+q;
  } 
}@+ while (!(f >= fraction_one));
be_careful=p-q;
if (be_careful+p >= 0) incr(f)

@ The dual of |make_fraction| is |take_fraction|, which multiplies a
given integer~|q| by a fraction~|f|. When the operands are positive, it
computes $p=\lfloor qf/2^{28}+{1\over2}\rfloor$, a symmetric function
of |q| and~|f|.

This routine is even more ``inner loopy'' than |make_fraction|;
the present implementation consumes almost 20\pct! of \MF's computation
time during typical jobs, so a machine-language or 64-bit
substitute is advisable.
@^inner loop@> @^system dependencies@>

@p int take_fraction(int @!q, fraction @!f)
{@+int @!p; /*the fraction so far*/ 
bool @!negative; /*should the result be negated?*/ 
int @!n; /*additional multiple of $q$*/ 
int @!be_careful; /*disables certain compiler optimizations*/ 
@<Reduce to the case that |f>=0| and |q>=0|@>;
if (f < fraction_one) n=0;
else{@+n=f/fraction_one;f=f%fraction_one;
  if (q <= el_gordo/n) n=n*q;
  else{@+arith_error=true;n=el_gordo;
    } 
  } 
f=f+fraction_one;
@<Compute $p=\lfloor qf/2^{28}+{1\over2}\rfloor-q$@>;
be_careful=n-el_gordo;
if (be_careful+p > 0) 
  {@+arith_error=true;n=el_gordo-p;
  } 
if (negative) return-(n+p);
else return n+p;
} 

@ @<Reduce to the case that |f>=0| and |q>=0|@>=
if (f >= 0) negative=false;
else{@+negate(f);negative=true;
  } 
if (q < 0) 
  {@+negate(q);negative=!negative;
  } 

@ The invariant relations in this case are (i)~$\lfloor(qf+p)/2^k\rfloor
=\lfloor qf_0/2^{28}+{1\over2}\rfloor$, where $k$ is an integer and
$f_0$ is the original value of~$f$; (ii)~$2^k\L f<2^{k+1}$.
@^inner loop@>

@<Compute $p=\lfloor qf/2^{28}+{1\over2}\rfloor-q$@>=
p=fraction_half; /*that's $2^{27}$; the invariants hold now with $k=28$*/ 
if (q < fraction_four) 
  @/do@+{if (odd(f)) p=half(p+q);@+else p=half(p);
  f=half(f);
  }@+ while (!(f==1));
else@/do@+{if (odd(f)) p=p+half(q-p);@+else p=half(p);
  f=half(f);
  }@+ while (!(f==1))


@ When we want to multiply something by a |scaled| quantity, we use a scheme
analogous to |take_fraction| but with a different scaling.
Given positive operands, |take_scaled|
computes the quantity $p=\lfloor qf/2^{16}+{1\over2}\rfloor$.

Once again it is a good idea to use 64-bit arithmetic if
possible; otherwise |take_scaled| will use more than 2\pct! of the running time
when the Computer Modern fonts are being generated.
@^inner loop@>

@p int take_scaled(int @!q, scaled @!f)
{@+int @!p; /*the fraction so far*/ 
bool @!negative; /*should the result be negated?*/ 
int @!n; /*additional multiple of $q$*/ 
int @!be_careful; /*disables certain compiler optimizations*/ 
@<Reduce to the case that |f>=0| and |q>=0|@>;
if (f < unity) n=0;
else{@+n=f/unity;f=f%unity;
  if (q <= el_gordo/n) n=n*q;
  else{@+arith_error=true;n=el_gordo;
    } 
  } 
f=f+unity;
@<Compute $p=\lfloor qf/2^{16}+{1\over2}\rfloor-q$@>;
be_careful=n-el_gordo;
if (be_careful+p > 0) 
  {@+arith_error=true;n=el_gordo-p;
  } 
if (negative) return-(n+p);
else return n+p;
} 

@ @<Compute $p=\lfloor qf/2^{16}+{1\over2}\rfloor-q$@>=
p=half_unit; /*that's $2^{15}$; the invariants hold now with $k=16$*/ 
@^inner loop@>
if (q < fraction_four) 
  @/do@+{if (odd(f)) p=half(p+q);@+else p=half(p);
  f=half(f);
  }@+ while (!(f==1));
else@/do@+{if (odd(f)) p=p+half(q-p);@+else p=half(p);
  f=half(f);
  }@+ while (!(f==1))

@ For completeness, there's also |make_scaled|, which computes a
quotient as a |scaled| number instead of as a |fraction|.
In other words, the result is $\lfloor2^{16}p/q+{1\over2}\rfloor$, if the
operands are positive. \ (This procedure is not used especially often,
so it is not part of \MF's inner loop.)

@p scaled make_scaled(int @!p, int @!q)
{@+int @!f; /*the fraction bits, with a leading 1 bit*/ 
int @!n; /*the integer part of $\vert p/q\vert$*/ 
bool @!negative; /*should the result be negated?*/ 
int @!be_careful; /*disables certain compiler optimizations*/ 
if (p >= 0) negative=false;
else{@+negate(p);negative=true;
  } 
if (q <= 0) 
  {
#ifdef @!DEBUG
if (q==0) confusion('/');
#endif
@;@/
@:this can't happen /}{\quad \./@>
  negate(q);negative=!negative;
  } 
n=p/q;p=p%q;
if (n >= 0100000) 
  {@+arith_error=true;
  if (negative) return-el_gordo;@+else return el_gordo;
  } 
else{@+n=(n-1)*unity;
  @<Compute $f=\lfloor 2^{16}(1+p/q)+{1\over2}\rfloor$@>;
  if (negative) return-(f+n);@+else return f+n;
  } 
} 

@ @<Compute $f=\lfloor 2^{16}(1+p/q)+{1\over2}\rfloor$@>=
f=1;
@/do@+{be_careful=p-q;p=be_careful+p;
if (p >= 0) f=f+f+1;
else{@+double(f);p=p+q;
  } 
}@+ while (!(f >= unity));
be_careful=p-q;
if (be_careful+p >= 0) incr(f)

@ Here is a typical example of how the routines above can be used.
It computes the function
$${1\over3\tau}f(\theta,\phi)=
{\tau^{-1}\bigl(2+\sqrt2\,(\sin\theta-{1\over16}\sin\phi)
 (\sin\phi-{1\over16}\sin\theta)(\cos\theta-\cos\phi)\bigr)\over
3\,\bigl(1+{1\over2}(\sqrt5-1)\cos\theta+{1\over2}(3-\sqrt5\,)\cos\phi\bigr)},$$
where $\tau$ is a |scaled| ``tension'' parameter. This is \MF's magic
fudge factor for placing the first control point of a curve that starts
at an angle $\theta$ and ends at an angle $\phi$ from the straight path.
(Actually, if the stated quantity exceeds 4, \MF\ reduces it to~4.)

The trigonometric quantity to be multiplied by $\sqrt2$ is less than $\sqrt2$.
(It's a sum of eight terms whose absolute values can be bounded using
relations such as $\sin\theta\cos\theta\L{1\over2}$.) Thus the numerator
is positive; and since the tension $\tau$ is constrained to be at least
$3\over4$, the numerator is less than $16\over3$. The denominator is
nonnegative and at most~6.  Hence the fixed-point calculations below
are guaranteed to stay within the bounds of a 32-bit computer word.

The angles $\theta$ and $\phi$ are given implicitly in terms of |fraction|
arguments |st|, |ct|, |sf|, and |cf|, representing $\sin\theta$, $\cos\theta$,
$\sin\phi$, and $\cos\phi$, respectively.

@p fraction velocity(fraction @!st, fraction @!ct, fraction @!sf, fraction @!cf, scaled @!t)
{@+int @!acc, @!num, @!denom; /*registers for intermediate calculations*/ 
acc=take_fraction(st-(sf/16), sf-(st/16));
acc=take_fraction(acc, ct-cf);
num=fraction_two+take_fraction(acc, 379625062);
   /*$2^{28}\sqrt2\approx379625062.497$*/ 
denom=fraction_three+take_fraction(ct, 497706707)+take_fraction(cf, 307599661);
   /*$3\cdot2^{27}\cdot(\sqrt5-1)\approx497706706.78$ and
    $3\cdot2^{27}\cdot(3-\sqrt5\,)\approx307599661.22$*/ 
if (t!=unity) num=make_scaled(num, t);
   /*|make_scaled(fraction, scaled)==fraction|*/ 
if (num/4 >= denom) return fraction_four;
else return make_fraction(num, denom);
} 

@ The following somewhat different subroutine tests rigorously if $ab$ is
greater than, equal to, or less than~$cd$,
given integers $(a,b,c,d)$. In most cases a quick decision is reached.
The result is $+1$, 0, or~$-1$ in the three respective cases.

@d return_sign(X)	{@+return X;
  } 

@p int ab_vs_cd(int @!a, int b, int c, int d)
{@+
int @!q, @!r; /*temporary registers*/ 
@<Reduce to the case that |a,c>=0|, |b,d>0|@>;
loop@+{@+q=a/d;r=c/b;
  if (q!=r) 
    if (q > r) return_sign(1)@;@+else return_sign(-1);
  q=a%d;r=c%b;
  if (r==0) 
    if (q==0) return_sign(0)@;@+else return_sign(1);
  if (q==0) return_sign(-1);
  a=b;b=q;c=d;d=r;
  }  /*now |a > d > 0| and |c > b > 0|*/ 
} 

@ @<Reduce to the case that |a...@>=
if (a < 0) 
  {@+negate(a);negate(b);
  } 
if (c < 0) 
  {@+negate(c);negate(d);
  } 
if (d <= 0) 
  {@+if (b >= 0) 
    if (((a==0)||(b==0))&&((c==0)||(d==0))) return_sign(0)@;
    else return_sign(1);
  if (d==0) 
    if (a==0) return_sign(0)@;@+else return_sign(-1);
  q=a;a=c;c=q;q=-b;b=-d;d=q;
  } 
else if (b <= 0) 
  {@+if (b < 0) if (a > 0) return_sign(-1);
  if (c==0) return_sign(0)@;else return_sign(-1);
  } 

@ We conclude this set of elementary routines with some simple rounding
and truncation operations that are coded in a machine-independent fashion.
The routines are slightly complicated because we want them to work
without overflow whenever $-2^{31}\L x<2^{31}$.

@p scaled floor_scaled(scaled @!x)
   /*$2^{16}\lfloor x/2^{16}\rfloor$*/ 
{@+int @!be_careful; /*temporary register*/ 
if (x >= 0) return x-(x%unity);
else{@+be_careful=x+1;
  return x+((-be_careful)%unity)+1-unity;
  } 
} 
@#
int floor_unscaled(scaled @!x)
   /*$\lfloor x/2^{16}\rfloor$*/ 
{@+int @!be_careful; /*temporary register*/ 
if (x >= 0) return x/unity;
else{@+be_careful=x+1;return-(1+((-be_careful)/unity));
  } 
} 
@#
int round_unscaled(scaled @!x)
   /*$\lfloor x/2^{16}+.5\rfloor$*/ 
{@+int @!be_careful; /*temporary register*/ 
if (x >= half_unit) return 1+((x-half_unit)/unity);
else if (x >= -half_unit) return 0;
else{@+be_careful=x+1;
  return-(1+((-be_careful-half_unit)/unity));
  } 
} 
@#
scaled round_fraction(fraction @!x)
   /*$\lfloor x/2^{12}+.5\rfloor$*/ 
{@+int @!be_careful; /*temporary register*/ 
if (x >= 2048) return 1+((x-2048)/4096);
else if (x >= -2048) return 0;
else{@+be_careful=x+1;
  return-(1+((-be_careful-2048)/4096));
  } 
} 

@* Algebraic and transcendental functions.
\MF\ computes all of the necessary special functions from scratch, without
relying on |double| arithmetic or system subroutines for sines, cosines, etc.

@ To get the square root of a |scaled| number |x|, we want to calculate
$s=\lfloor 2^8\!\sqrt x +{1\over2}\rfloor$. If $x>0$, this is the unique
integer such that $2^{16}x-s\L s^2<2^{16}x+s$. The following subroutine
determines $s$ by an iterative method that maintains the invariant
relations $x=2^{46-2k}x_0\bmod 2^{30}$, $0<y=\lfloor 2^{16-2k}x_0\rfloor
-s^2+s\L q=2s$, where $x_0$ is the initial value of $x$. The value of~$y$
might, however, be zero at the start of the first iteration.

@p scaled square_rt(scaled @!x)
{@+small_number @!k; /*iteration control counter*/ 
int @!y, @!q; /*registers for intermediate calculations*/ 
if (x <= 0) @<Handle square root of zero or negative argument@>@;
else{@+k=23;q=2;
  while (x < fraction_two)  /*i.e., |while x < @t$2^{29}$@>|\unskip*/ 
    {@+decr(k);x=x+x+x+x;
    } 
  if (x < fraction_four) y=0;
  else{@+x=x-fraction_four;y=1;
    } 
  @/do@+{@<Decrease |k| by 1, maintaining the invariant relations between |x|, |y|,
and~|q|@>;
  }@+ while (!(k==0));
  return half(q);
  } 
} 

@ @<Handle square root of zero...@>=
{@+if (x < 0) 
  {@+print_err("Square root of ");
@.Square root...replaced by 0@>
  print_scaled(x);print_str(" has been replaced by 0");
  help2("Since I don't take square roots of negative numbers,")@/
    ("I'm zeroing this one. Proceed, with fingers crossed.");
  error();
  } 
return 0;
} 

@ @<Decrease |k| by 1, maintaining...@>=
double(x);double(y);
if (x >= fraction_four)  /*note that |fraction_four==@t$2^{30}$@>|*/ 
  {@+x=x-fraction_four;incr(y);
  } 
double(x);y=y+y-q;double(q);
if (x >= fraction_four) 
  {@+x=x-fraction_four;incr(y);
  } 
if (y > q) 
  {@+y=y-q;q=q+2;
  } 
else if (y <= 0) 
  {@+q=q-2;y=y+q;
  } 
decr(k)

@ Pythagorean addition $\psqrt{a^2+b^2}$ is implemented by an elegant
iterative scheme due to Cleve Moler and Donald Morrison [{\sl IBM Journal
@^Moler, Cleve Barry@>
@^Morrison, Donald Ross@>
of Research and Development\/ \bf27} (1983), 577--581]. It modifies |a| and~|b|
in such a way that their Pythagorean sum remains invariant, while the
smaller argument decreases.

@p int pyth_add(int @!a, int @!b)
{@+
fraction @!r; /*register used to transform |a| and |b|*/ 
bool @!big; /*is the result dangerously near $2^{31}$?*/ 
a=abs(a);b=abs(b);
if (a < b) 
  {@+r=b;b=a;a=r;
  }  /*now |0 <= b <= a|*/ 
if (b > 0) 
  {@+if (a < fraction_two) big=false;
  else{@+a=a/4;b=b/4;big=true;
    }  /*we reduced the precision to avoid arithmetic overflow*/ 
  @<Replace |a| by an approximation to $\psqrt{a^2+b^2}$@>;
  if (big) 
    if (a < fraction_two) a=a+a+a+a;
    else{@+arith_error=true;a=el_gordo;
      } 
  } 
return a;
} 

@ The key idea here is to reflect the vector $(a,b)$ about the
line through $(a,b/2)$.

@<Replace |a| by an approximation to $\psqrt{a^2+b^2}$@>=
loop@+{@+r=make_fraction(b, a);
  r=take_fraction(r, r); /*now $r\approx b^2/a^2$*/ 
  if (r==0) goto done;
  r=make_fraction(r, fraction_four+r);
  a=a+take_fraction(a+a, r);b=take_fraction(b, r);
  } 
done: 

@ Here is a similar algorithm for $\psqrt{a^2-b^2}$.
It converges slowly when $b$ is near $a$, but otherwise it works fine.

@p int pyth_sub(int @!a, int @!b)
{@+
fraction @!r; /*register used to transform |a| and |b|*/ 
bool @!big; /*is the input dangerously near $2^{31}$?*/ 
a=abs(a);b=abs(b);
if (a <= b) @<Handle erroneous |pyth_sub| and set |a:=0|@>@;
else{@+if (a < fraction_four) big=false;
  else{@+a=half(a);b=half(b);big=true;
    } 
  @<Replace |a| by an approximation to $\psqrt{a^2-b^2}$@>;
  if (big) a=a+a;
  } 
return a;
} 

@ @<Replace |a| by an approximation to $\psqrt{a^2-b^2}$@>=
loop@+{@+r=make_fraction(b, a);
  r=take_fraction(r, r); /*now $r\approx b^2/a^2$*/ 
  if (r==0) goto done;
  r=make_fraction(r, fraction_four-r);
  a=a-take_fraction(a+a, r);b=take_fraction(b, r);
  } 
done: 

@ @<Handle erroneous |pyth_sub| and set |a:=0|@>=
{@+if (a < b) 
  {@+print_err("Pythagorean subtraction ");print_scaled(a);
  print_str("+-+");print_scaled(b);print_str(" has been replaced by 0");
@.Pythagorean...@>
  help2("Since I don't take square roots of negative numbers,")@/
    ("I'm zeroing this one. Proceed, with fingers crossed.");
  error();
  } 
a=0;
} 

@ The subroutines for logarithm and exponential involve two tables.
The first is simple: |two_to_the[k]| equals $2^k$. The second involves
a bit more calculation, which the author claims to have done correctly:
|spec_log[k]| is $2^{27}$ times $\ln\bigl(1/(1-2^{-k})\bigr)=
2^{-k}+{1\over2}2^{-2k}+{1\over3}2^{-3k}+\cdots\,$, rounded to the
nearest integer.

@<Glob...@>=
int @!two_to_the[31]; /*powers of two*/ 
int @!spec_log0[28], *const @!spec_log = @!spec_log0-1; /*special logarithms*/ 

@ @<Local variables for initialization@>=
int @!k; /*all-purpose loop index*/ 

@ @<Set init...@>=
two_to_the[0]=1;
for (k=1; k<=30; k++) two_to_the[k]=2*two_to_the[k-1];
spec_log[1]=93032640;
spec_log[2]=38612034;
spec_log[3]=17922280;
spec_log[4]=8662214;
spec_log[5]=4261238;
spec_log[6]=2113709;
spec_log[7]=1052693;
spec_log[8]=525315;
spec_log[9]=262400;
spec_log[10]=131136;
spec_log[11]=65552;
spec_log[12]=32772;
spec_log[13]=16385;
for (k=14; k<=27; k++) spec_log[k]=two_to_the[27-k];
spec_log[28]=1;

@ Here is the routine that calculates $2^8$ times the natural logarithm
of a |scaled| quantity; it is an integer approximation to $2^{24}\ln(x/2^{16})$,
when |x| is a given positive integer.

The method is based on exercise 1.2.2--25 in {\sl The Art of Computer
Programming\/}: During the main iteration we have $1\L 2^{-30}x<1/(1-2^{1-k})$,
and the logarithm of $2^{30}x$ remains to be added to an accumulator
register called~$y$. Three auxiliary bits of accuracy are retained in~$y$
during the calculation, and sixteen auxiliary bits to extend |y| are
kept in~|z| during the initial argument reduction. (We add
$100\cdot2^{16}=6553600$ to~|z| and subtract 100 from~|y| so that |z| will
not become negative; also, the actual amount subtracted from~|y| is~96,
not~100, because we want to add~4 for rounding before the final division by~8.)

@p scaled m_log(scaled @!x)
{@+int @!y, @!z; /*auxiliary registers*/ 
int @!k; /*iteration counter*/ 
if (x <= 0) @<Handle non-positive logarithm@>@;
else{@+y=1302456956+4-100; /*$14\times2^{27}\ln2\approx1302456956.421063$*/ 
  z=27595+6553600; /*and $2^{16}\times .421063\approx 27595$*/ 
  while (x < fraction_four) 
    {@+double(x);y=y-93032639;z=z-48782;
    }  /*$2^{27}\ln2\approx 93032639.74436163$
      and $2^{16}\times.74436163\approx 48782$*/ 
  y=y+(z/unity);k=2;
  while (x > fraction_four+4) 
    @<Increase |k| until |x| can be multiplied by a factor of $2^{-k}$, and adjust
$y$ accordingly@>;
  return y/8;
  } 
} 

@ @<Increase |k| until |x| can...@>=
{@+z=((x-1)/two_to_the[k])+1; /*$z=\lceil x/2^k\rceil$*/ 
while (x < fraction_four+z) 
  {@+z=half(z+1);k=k+1;
  } 
y=y+spec_log[k];x=x-z;
} 

@ @<Handle non-positive logarithm@>=
{@+print_err("Logarithm of ");
@.Logarithm...replaced by 0@>
print_scaled(x);print_str(" has been replaced by 0");
help2("Since I don't take logs of non-positive numbers,")@/
  ("I'm zeroing this one. Proceed, with fingers crossed.");
error();return 0;
} 

@ Conversely, the exponential routine calculates $\exp(x/2^8)$,
when |x| is |scaled|. The result is an integer approximation to
$2^{16}\exp(x/2^{24})$, when |x| is regarded as an integer.

@p scaled m_exp(scaled @!x)
{@+small_number @!k; /*loop control index*/ 
int @!y, @!z; /*auxiliary registers*/ 
if (x > 174436200) 
     /*$2^{24}\ln((2^{31}-1)/2^{16})\approx 174436199.51$*/ 
  {@+arith_error=true;return el_gordo;
  } 
else if (x < -197694359) return 0;
     /*$2^{24}\ln(2^{-1}/2^{16})\approx-197694359.45$*/ 
else{@+if (x <= 0) 
    {@+z=-8*x;y=04000000; /*$y=2^{20}$*/ 
    } 
  else{@+if (x <= 127919879) z=1023359037-8*x;
       /*$2^{27}\ln((2^{31}-1)/2^{20})\approx 1023359037.125$*/ 
    else z=8*(174436200-x); /*|z| is always nonnegative*/ 
    y=el_gordo;
    } 
  @<Multiply |y| by $\exp(-z/2^{27})$@>;
  if (x <= 127919879) return(y+8)/16;@+else return y;
  } 
} 

@ The idea here is that subtracting |spec_log[k]| from |z| corresponds
to multiplying |y| by $1-2^{-k}$.

A subtle point (which had to be checked) was that if $x=127919879$, the
value of~|y| will decrease so that |y+8| doesn't overflow. In fact,
$z$ will be 5 in this case, and |y| will decrease by~64 when |k==25|
and by~16 when |k==27|.

@<Multiply |y| by...@>=
k=1;
while (z > 0) 
  {@+while (z >= spec_log[k]) 
    {@+z=z-spec_log[k];
    y=y-1-((y-two_to_the[k-1])/two_to_the[k]);
    } 
  incr(k);
  } 

@ The trigonometric subroutines use an auxiliary table such that
|spec_atan[k]| contains an approximation to the |angle| whose tangent
is~$1/2^k$.

@<Glob...@>=
angle @!spec_atan0[26], *const @!spec_atan = @!spec_atan0-1; /*$\arctan2^{-k}$ times $2^{20}\cdot180/\pi$*/ 

@ @<Set init...@>=
spec_atan[1]=27855475;
spec_atan[2]=14718068;
spec_atan[3]=7471121;
spec_atan[4]=3750058;
spec_atan[5]=1876857;
spec_atan[6]=938658;
spec_atan[7]=469357;
spec_atan[8]=234682;
spec_atan[9]=117342;
spec_atan[10]=58671;
spec_atan[11]=29335;
spec_atan[12]=14668;
spec_atan[13]=7334;
spec_atan[14]=3667;
spec_atan[15]=1833;
spec_atan[16]=917;
spec_atan[17]=458;
spec_atan[18]=229;
spec_atan[19]=115;
spec_atan[20]=57;
spec_atan[21]=29;
spec_atan[22]=14;
spec_atan[23]=7;
spec_atan[24]=4;
spec_atan[25]=2;
spec_atan[26]=1;

@ Given integers |x| and |y|, not both zero, the |n_arg| function
returns the |angle| whose tangent points in the direction $(x,y)$.
This subroutine first determines the correct octant, then solves the
problem for |0 <= y <= x|, then converts the result appropriately to
return an answer in the range |-one_eighty_deg <= @t$\theta$@> <= one_eighty_deg|.
(The answer is |+one_eighty_deg| if |y==0| and |x < 0|, but an answer of
|-one_eighty_deg| is possible if, for example, |y==-1| and $x=-2^{30}$.)

The octants are represented in a ``Gray code,'' since that turns out
to be computationally simplest.

@d negate_x	1
@d negate_y	2
@d switch_x_and_y	4
@d first_octant	1
@d second_octant	(first_octant+switch_x_and_y)
@d third_octant	(first_octant+switch_x_and_y+negate_x)
@d fourth_octant	(first_octant+negate_x)
@d fifth_octant	(first_octant+negate_x+negate_y)
@d sixth_octant	(first_octant+switch_x_and_y+negate_x+negate_y)
@d seventh_octant	(first_octant+switch_x_and_y+negate_y)
@d eighth_octant	(first_octant+negate_y)

@p angle n_arg(int @!x, int @!y)
{@+angle @!z; /*auxiliary register*/ 
int @!t; /*temporary storage*/ 
small_number @!k; /*loop counter*/ 
uint8_t @!octant; /*octant code*/ 
if (x >= 0) octant=first_octant;
else{@+negate(x);octant=first_octant+negate_x;
  } 
if (y < 0) 
  {@+negate(y);octant=octant+negate_y;
  } 
if (x < y) 
  {@+t=y;y=x;x=t;octant=octant+switch_x_and_y;
  } 
if (x==0) @<Handle undefined arg@>@;
else{@+@<Set variable |z| to the arg of $(x,y)$@>;
  @<Return an appropriate answer based on |z| and |octant|@>;
  } 
} 

@ @<Handle undefined arg@>=
{@+print_err("angle(0,0) is taken as zero");
@.angle(0,0)...zero@>
help2("The `angle' between two identical points is undefined.")@/
  ("I'm zeroing this one. Proceed, with fingers crossed.");
error();return 0;
} 

@ @<Return an appropriate answer...@>=
switch (octant) {
case first_octant: return z;@+break;
case second_octant: return ninety_deg-z;@+break;
case third_octant: return ninety_deg+z;@+break;
case fourth_octant: return one_eighty_deg-z;@+break;
case fifth_octant: return z-one_eighty_deg;@+break;
case sixth_octant: return-z-ninety_deg;@+break;
case seventh_octant: return z-ninety_deg;@+break;
case eighth_octant: return-z;
}  /*there are no other cases*/ 

@ At this point we have |x >= y >= 0|, and |x > 0|. The numbers are scaled up
or down until $2^{28}\L x<2^{29}$, so that accurate fixed-point calculations
will be made.

@<Set variable |z| to the arg...@>=
while (x >= fraction_two) 
  {@+x=half(x);y=half(y);
  } 
z=0;
if (y > 0) 
  {@+while (x < fraction_one) 
    {@+double(x);double(y);
    } 
  @<Increase |z| to the arg of $(x,y)$@>;
  } 

@ During the calculations of this section, variables |x| and~|y|
represent actual coordinates $(x,2^{-k}y)$. We will maintain the
condition |x >= y|, so that the tangent will be at most $2^{-k}$.
If $x<2y$, the tangent is greater than $2^{-k-1}$. The transformation
$(a,b)\mapsto(a+b\tan\phi,b-a\tan\phi)$ replaces $(a,b)$ by
coordinates whose angle has decreased by~$\phi$; in the special case
$a=x$, $b=2^{-k}y$, and $\tan\phi=2^{-k-1}$, this operation reduces
to the particularly simple iteration shown here. [Cf.~John E. Meggitt,
@^Meggitt, John E.@>
{\sl IBM Journal of Research and Development\/ \bf6} (1962), 210--226.]

The initial value of |x| will be multiplied by at most
$(1+{1\over2})(1+{1\over8})(1+{1\over32})\cdots\approx 1.7584$; hence
there is no chance of integer overflow.

@<Increase |z|...@>=
k=0;
@/do@+{double(y);incr(k);
if (y > x) 
  {@+z=z+spec_atan[k];t=x;x=x+(y/two_to_the[k+k]);y=y-t;
  } 
}@+ while (!(k==15));
@/do@+{double(y);incr(k);
if (y > x) 
  {@+z=z+spec_atan[k];y=y-x;
  } 
}@+ while (!(k==26))

@ Conversely, the |n_sin_cos| routine takes an |angle| and produces the sine
and cosine of that angle. The results of this routine are
stored in global integer variables |n_sin| and |n_cos|.

@<Glob...@>=
fraction @!n_sin, @!n_cos; /*results computed by |n_sin_cos|*/ 

@ Given an integer |z| that is $2^{20}$ times an angle $\theta$ in degrees,
the purpose of |n_sin_cos(z)| is to set
|x==@t$r\cos\theta$@>| and |y==@t$r\sin\theta$@>| (approximately),
for some rather large number~|r|. The maximum of |x| and |y|
will be between $2^{28}$ and $2^{30}$, so that there will be hardly
any loss of accuracy. Then |x| and~|y| are divided by~|r|.

@p void n_sin_cos(angle @!z) /*computes a multiple of the sine and cosine*/ 
{@+small_number @!k; /*loop control variable*/ 
uint8_t @!q; /*specifies the quadrant*/ 
fraction @!r; /*magnitude of |(x, y)|*/ 
int @!x, @!y, @!t; /*temporary registers*/ 
while (z < 0) z=z+three_sixty_deg;
z=z%three_sixty_deg; /*now |0 <= z < three_sixty_deg|*/ 
q=z/forty_five_deg;z=z%forty_five_deg;
x=fraction_one;y=x;
if (!odd(q)) z=forty_five_deg-z;
@<Subtract angle |z| from |(x,y)|@>;
@<Convert |(x,y)| to the octant determined by~|q|@>;
r=pyth_add(x, y);n_cos=make_fraction(x, r);n_sin=make_fraction(y, r);
} 

@ In this case the octants are numbered sequentially.

@<Convert |(x,...@>=
switch (q) {
case 0: do_nothing;@+break;
case 1: {@+t=x;x=y;y=t;
  } @+break;
case 2: {@+t=x;x=-y;y=t;
  } @+break;
case 3: negate(x);@+break;
case 4: {@+negate(x);negate(y);
  } @+break;
case 5: {@+t=x;x=-y;y=-t;
  } @+break;
case 6: {@+t=x;x=y;y=-t;
  } @+break;
case 7: negate(y);
}  /*there are no other cases*/ 

@ The main iteration of |n_sin_cos| is similar to that of |n_arg| but
applied in reverse. The values of |spec_atan[k]| decrease slowly enough
that this loop is guaranteed to terminate before the (nonexistent) value
|spec_atan[27]| would be required.

@<Subtract angle |z|...@>=
k=1;
while (z > 0) 
  {@+if (z >= spec_atan[k]) 
    {@+z=z-spec_atan[k];t=x;@/
    x=t+y/two_to_the[k];
    y=y-t/two_to_the[k];
    } 
  incr(k);
  } 
if (y < 0) y=0 /*this precaution may never be needed*/ 

@ And now let's complete our collection of numeric utility routines
by considering random number generation.
\MF\ generates pseudo-random numbers with the additive scheme recommended
in Section 3.6 of {\sl The Art of Computer Programming}; however, the
results are random fractions between 0 and |fraction_one-1|, inclusive.

There's an auxiliary array |randoms| that contains 55 pseudo-random
fractions. Using the recurrence $x_n=(x_{n-55}-x_{n-24})\bmod 2^{28}$,
we generate batches of 55 new $x_n$'s at a time by calling |new_randoms|.
The global variable |j_random| tells which element has most recently
been consumed.

@<Glob...@>=
fraction @!randoms[55]; /*the last 55 random values generated*/ 
uint8_t @!j_random; /*the number of unused |randoms|*/ 

@ To consume a random fraction, the program below will say `|next_random|'
and then it will fetch |randoms[j_random]|. The |next_random| macro
actually accesses the numbers backwards; blocks of 55~$x$'s are
essentially being ``flipped.'' But that doesn't make them less random.

@d next_random	if (j_random==0) new_randoms();
  else decr(j_random)

@p void new_randoms(void)
{@+uint8_t @!k; /*index into |randoms|*/ 
fraction @!x; /*accumulator*/ 
for (k=0; k<=23; k++) 
  {@+x=randoms[k]-randoms[k+31];
  if (x < 0) x=x+fraction_one;
  randoms[k]=x;
  } 
for (k=24; k<=54; k++) 
  {@+x=randoms[k]-randoms[k-24];
  if (x < 0) x=x+fraction_one;
  randoms[k]=x;
  } 
j_random=54;
} 

@ To initialize the |randoms| table, we call the following routine.

@p void init_randoms(scaled @!seed)
{@+fraction @!j, @!jj, @!k; /*more or less random integers*/ 
uint8_t @!i; /*index into |randoms|*/ 
j=abs(seed);
while (j >= fraction_one) j=half(j);
k=1;
for (i=0; i<=54; i++) 
  {@+jj=k;k=j-k;j=jj;
  if (k < 0) k=k+fraction_one;
  randoms[(i*21)%55]=j;
  } 
new_randoms();new_randoms();new_randoms(); /*``warm up'' the array*/ 
} 

@ To produce a uniform random number in the range |0 <= u < x| or |0 >= u > x|
or |0==u==x|, given a |scaled| value~|x|, we proceed as shown here.

Note that the call of |take_fraction| will produce the values 0 and~|x|
with about half the probability that it will produce any other particular
values between 0 and~|x|, because it rounds its answers.

@p scaled unif_rand(scaled @!x)
{@+scaled @!y; /*trial value*/ 
next_random;y=take_fraction(abs(x), randoms[j_random]);
if (y==abs(x)) return 0;
else if (x > 0) return y;
else return-y;
} 

@ Finally, a normal deviate with mean zero and unit standard deviation
can readily be obtained with the ratio method (Algorithm 3.4.1R in
{\sl The Art of Computer Programming\/}).

@p scaled norm_rand(void)
{@+int @!x, @!u, @!l; /*what the book would call $2^{16}X$, $2^{28}U$,
  and $-2^{24}\ln U$*/ 
@/do@+{
  @/do@+{next_random;
  x=take_fraction(112429, randoms[j_random]-fraction_half);
     /*$2^{16}\sqrt{8/e}\approx 112428.82793$*/ 
  next_random;u=randoms[j_random];
  }@+ while (!(abs(x) < u));
x=make_fraction(x, u);
l=139548960-m_log(u); /*$2^{24}\cdot12\ln2\approx139548959.6165$*/ 
}@+ while (!(ab_vs_cd(1024, l, x, x) >= 0));
return x;
} 

@* Packed data.
In order to make efficient use of storage space, \MF\ bases its major data
structures on a |memory_word|, which contains either a (signed) integer,
possibly scaled, or a small number of fields that are one half or one
quarter of the size used for storing integers.

If |x| is a variable of type |memory_word|, it contains up to four
fields that can be referred to as follows:
$$\vbox{\halign{\hfil#&#\hfil&#\hfil\cr
|x|&.|i|&(an |int|)\cr
|x|&.|sc|\qquad&(a |scaled| integer)\cr
|x.hh.lh|, |x.hh|&.|rh|&(two halfword fields)\cr
|x.hh.b0|, |x.hh.b1|, |x.hh|&.|rh|&(two quarterword fields, one halfword
  field)\cr
|x.qqqq.b0|, |x.qqqq.b1|, |x.qqqq|&.|b2|, |x.qqqq.b3|\hskip-100pt
  &\qquad\qquad\qquad(four quarterword fields)\cr}}$$
This is somewhat cumbersome to write, and not very readable either, but
macros will be used to make the notation shorter and more transparent.
The \PASCAL\ code below gives a formal definition of |memory_word| and
its subsidiary types, using packed variant records. \MF\ makes no
assumptions about the relative positions of the fields within a word.

Since we are assuming 32-bit integers, a halfword must contain at least
16 bits, and a quarterword must contain at least 8 bits.
@^system dependencies@>
But it doesn't hurt to have more bits; for example, with enough 36-bit
words you might be able to have |mem_max| as large as 262142.

N.B.: Valuable memory space will be dreadfully wasted unless \MF\ is compiled
by a \PASCAL\ that packs all of the |memory_word| variants into
the space of a single integer. Some \PASCAL\ compilers will pack an
integer whose subrange is `|0 dotdot 255|' into an eight-bit field, but others
insist on allocating space for an additional sign bit; on such systems you
can get 256 values into a quarterword only if the subrange is `|-128 dotdot 127|'.

The present implementation tries to accommodate as many variations as possible,
so it makes few assumptions. If integers having the subrange
`|min_quarterword dotdot max_quarterword|' can be packed into a quarterword,
and if integers having the subrange `|min_halfword dotdot max_halfword|'
can be packed into a halfword, everything should work satisfactorily.

It is usually most efficient to have |min_quarterword==min_halfword==0|,
so one should try to achieve this unless it causes a severe problem.
The values defined here are recommended for most 32-bit computers.

@d min_quarterword	0 /*smallest allowable value in a |quarterword|*/ 
@d max_quarterword	255 /*largest allowable value in a |quarterword|*/ 
@d min_halfword	0 /*smallest allowable value in a |halfword|*/ 
@d max_halfword	65535 /*largest allowable value in a |halfword|*/ 

@ Here are the inequalities that the quarterword and halfword values
must satisfy (or rather, the inequalities that they mustn't satisfy):

@<Check the ``constant''...@>=
#ifdef @!INIT
if (mem_max!=mem_top) bad=10;
#endif
@;@/
if (mem_max < mem_top) bad=10;
if ((min_quarterword > 0)||(max_quarterword < 127)) bad=11;
if ((min_halfword > 0)||(max_halfword < 32767)) bad=12;
if ((min_quarterword < min_halfword)||@|
  (max_quarterword > max_halfword)) bad=13;
if ((mem_min < min_halfword)||(mem_max >= max_halfword)) bad=14;
if (max_strings > max_halfword) bad=15;
if (buf_size > max_halfword) bad=16;
if ((max_quarterword-min_quarterword < 255)||@|
  (max_halfword-min_halfword < 65535)) bad=17;

@ The operation of subtracting |min_halfword| occurs rather frequently in
\MF, so it is convenient to abbreviate this operation by using the macro
|ho| defined here.  \MF\ will run faster with respect to compilers that
don't optimize the expression `|x-0|', if this macro is simplified in the
obvious way when |min_halfword==0|. Similarly, |qi| and |qo| are used for
input to and output from quarterwords.
@^system dependencies@>

@d ho(X)	X-min_halfword
   /*to take a sixteen-bit item from a halfword*/ 
@d qo(X)	X-min_quarterword /*to read eight bits from a quarterword*/ 
@d qi(X)	X+min_quarterword /*to store eight bits in a quarterword*/ 

@ The reader should study the following definitions closely:
@^system dependencies@>

@d sc	i /*|scaled| data is equivalent to |int|*/ 

@<Types...@>=
typedef uint8_t quarterword; /*1/4 of a word*/ 
typedef uint16_t halfword; /*1/2 of a word*/ 
typedef uint8_t two_choices; /*used when there are two variants in a record*/ 
typedef uint8_t three_choices; /*used when there are three variants in a record*/ 
typedef struct { @;@/
  halfword @!rh;
  union { 
  halfword @!lh;
  struct { quarterword @!b0;quarterword @!b1;} ;
  };} two_halves;
typedef struct { @;@/
  quarterword @!b0;
  quarterword @!b1;
  quarterword @!b2;
  quarterword @!b3;
  } four_quarters;
typedef struct { @;@/
  union { 
  int @!i;
  two_halves @!hh;
  four_quarters @!qqqq;
  };} memory_word;
typedef struct {@+FILE *f;@+memory_word@,d;@+} word_file;

@ When debugging, we may want to print a |memory_word| without knowing
what type it is; so we print it in all modes.
@^dirty \PASCAL@>@^debugging@>

@p
#ifdef @!DEBUG
void print_word(memory_word @!w)
   /*prints |w| in all ways*/ 
{@+print_int(w.i);print_char(' ');@/
print_scaled(w.sc);print_char(' ');print_scaled(w.sc/010000);print_ln();@/
print_int(w.hh.lh);print_char('=');print_int(w.hh.b0);print_char(':');
print_int(w.hh.b1);print_char(';');print_int(w.hh.rh);print_char(' ');@/
print_int(w.qqqq.b0);print_char(':');print_int(w.qqqq.b1);print_char(':');
print_int(w.qqqq.b2);print_char(':');print_int(w.qqqq.b3);
} 
#endif

@* Dynamic memory allocation.
The \MF\ system does nearly all of its own memory allocation, so that it
can readily be transported into environments that do not have automatic
facilities for strings, garbage collection, etc., and so that it can be in
control of what error messages the user receives. The dynamic storage
requirements of \MF\ are handled by providing a large array |mem| in
which consecutive blocks of words are used as nodes by the \MF\ routines.

Pointer variables are indices into this array, or into another array
called |eqtb| that will be explained later. A pointer variable might
also be a special flag that lies outside the bounds of |mem|, so we
allow pointers to assume any |halfword| value. The minimum memory
index represents a null pointer.

@d pointer	halfword /*a flag or a location in |mem| or |eqtb|*/ 
@d null	mem_min /*the null pointer*/ 

@ The |mem| array is divided into two regions that are allocated separately,
but the dividing line between these two regions is not fixed; they grow
together until finding their ``natural'' size in a particular job.
Locations less than or equal to |lo_mem_max| are used for storing
variable-length records consisting of two or more words each. This region
is maintained using an algorithm similar to the one described in exercise
2.5--19 of {\sl The Art of Computer Programming}. However, no size field
appears in the allocated nodes; the program is responsible for knowing the
relevant size when a node is freed. Locations greater than or equal to
|hi_mem_min| are used for storing one-word records; a conventional
\.{AVAIL} stack is used for allocation in this region.

Locations of |mem| between |mem_min| and |mem_top| may be dumped as part
of preloaded base files, by the \.{INIMF} preprocessor.
@.INIMF@>
Production versions of \MF\ may extend the memory at the top end in order to
provide more space; these locations, between |mem_top| and |mem_max|,
are always used for single-word nodes.

The key pointers that govern |mem| allocation have a prescribed order:
$$\hbox{|null==mem_min < lo_mem_max < hi_mem_min < mem_top <= mem_end <= mem_max|.}$$

@<Glob...@>=
memory_word @!mem0[mem_max-mem_min+1], *const @!mem = @!mem0-mem_min; /*the big dynamic storage area*/ 
pointer @!lo_mem_max; /*the largest location of variable-size memory in use*/ 
pointer @!hi_mem_min; /*the smallest location of one-word memory in use*/ 

@ Users who wish to study the memory requirements of specific applications can
use optional special features that keep track of current and
maximum memory usage. When code between the delimiters |
#ifdef @!STAT
| $\ldots$
|tats| is not ``commented out,'' \MF\ will run a bit slower but it will
report these statistics when |tracing_stats| is positive.

@<Glob...@>=
int @!var_used, @!dyn_used; /*how much memory is in use*/ 
#ifdef @!DEBUG
#define incr_dyn_used @[incr(dyn_used)@]
#define decr_dyn_used @[decr(dyn_used)@]
#else
#define incr_dyn_used
#define decr_dyn_used
#endif
 
@ Let's consider the one-word memory region first, since it's the
simplest. The pointer variable |mem_end| holds the highest-numbered location
of |mem| that has ever been used. The free locations of |mem| that
occur between |hi_mem_min| and |mem_end|, inclusive, are of type
|two_halves|, and we write |info(p)| and |link(p)| for the |lh|
and |rh| fields of |mem[p]| when it is of this type. The single-word
free locations form a linked list
$$|avail|,\;\hbox{|link(avail)|},\;\hbox{|link(link(avail))|},\;\ldots$$
terminated by |null|.

@d link(X)	mem[X].hh.rh /*the |link| field of a memory word*/ 
@d info(X)	mem[X].hh.lh /*the |info| field of a memory word*/ 

@<Glob...@>=
pointer @!avail; /*head of the list of available one-word nodes*/ 
pointer @!mem_end; /*the last one-word node used in |mem|*/ 

@ If one-word memory is exhausted, it might mean that the user has forgotten
a token like `\&{enddef}' or `\&{endfor}'. We will define some procedures
later that try to help pinpoint the trouble.

@p@t\4@>@<Declare the procedure called |show_token_list|@>@;
@t\4@>@<Declare the procedure called |runaway|@>@;

@ The function |get_avail| returns a pointer to a new one-word node whose
|link| field is null. However, \MF\ will halt if there is no more room left.
@^inner loop@>

@p pointer get_avail(void) /*single-word node allocation*/ 
{@+pointer @!p; /*the new node being got*/ 
p=avail; /*get top location in the |avail| stack*/ 
if (p!=null) avail=link(avail); /*and pop it off*/ 
else if (mem_end < mem_max)  /*or go into virgin territory*/ 
  {@+incr(mem_end);p=mem_end;
  } 
else{@+decr(hi_mem_min);p=hi_mem_min;
  if (hi_mem_min <= lo_mem_max) 
    {@+runaway(); /*if memory is exhausted, display possible runaway text*/ 
    overflow("main memory size", mem_max+1-mem_min);
       /*quit; all one-word nodes are busy*/ 
@:METAFONT capacity exceeded main memory size}{\quad main memory size@>
    } 
  } 
link(p)=null; /*provide an oft-desired initialization of the new node*/ 
incr_dyn_used; /*maintain statistics*/ 
return p;
} 

@ Conversely, a one-word node is recycled by calling |free_avail|.

@d free_avail(X)	 /*single-word node liberation*/ 
  {@+link(X)=avail;avail=X;
    decr_dyn_used;
  } 

@ There's also a |fast_get_avail| routine, which saves the procedure-call
overhead at the expense of extra programming. This macro is used in
the places that would otherwise account for the most calls of |get_avail|.
@^inner loop@>

@d fast_get_avail(X)	@t@>@;@/
  {@+X=avail; /*avoid |get_avail| if possible, to save time*/ 
  if (X==null) X=get_avail();
  else{@+avail=link(X);link(X)=null;
        incr_dyn_used;
    } 
  } 

@ The available-space list that keeps track of the variable-size portion
of |mem| is a nonempty, doubly-linked circular list of empty nodes,
pointed to by the roving pointer |rover|.

Each empty node has size 2 or more; the first word contains the special
value |max_halfword| in its |link| field and the size in its |info| field;
the second word contains the two pointers for double linking.

Each nonempty node also has size 2 or more. Its first word is of type
|two_halves|\kern-1pt, and its |link| field is never equal to |max_halfword|.
Otherwise there is complete flexibility with respect to the contents
of its other fields and its other words.

(We require |mem_max < max_halfword| because terrible things can happen
when |max_halfword| appears in the |link| field of a nonempty node.)

@d empty_flag	max_halfword /*the |link| of an empty variable-size node*/ 
@d is_empty(X)	(link(X)==empty_flag) /*tests for empty node*/ 
@d node_size	info /*the size field in empty variable-size nodes*/ 
@d llink(X)	info(X+1) /*left link in doubly-linked list of empty nodes*/ 
@d rlink(X)	link(X+1) /*right link in doubly-linked list of empty nodes*/ 

@<Glob...@>=
pointer @!rover; /*points to some node in the list of empties*/ 

@ A call to |get_node| with argument |s| returns a pointer to a new node
of size~|s|, which must be 2~or more. The |link| field of the first word
of this new node is set to null. An overflow stop occurs if no suitable
space exists.

If |get_node| is called with $s=2^{30}$, it simply merges adjacent free
areas and returns the value |max_halfword|.

@p pointer get_node(int @!s) /*variable-size node allocation*/ 
{@+
pointer @!p; /*the node currently under inspection*/ 
pointer @!q; /*the node physically after node |p|*/ 
int @!r; /*the newly allocated node, or a candidate for this honor*/ 
int @!t, @!tt; /*temporary registers*/ 
@^inner loop@>
restart: p=rover; /*start at some free node in the ring*/ 
@/do@+{@<Try to allocate within node |p| and its physical successors, and |goto found|
if allocation was possible@>;
p=rlink(p); /*move to the next node in the ring*/ 
}@+ while (!(p==rover)); /*repeat until the whole list has been traversed*/ 
if (s==010000000000) 
  {@+return max_halfword;
  } 
if (lo_mem_max+2 < hi_mem_min) if (lo_mem_max+2 <= mem_min+max_halfword) 
  @<Grow more variable-size memory and |goto restart|@>;
overflow("main memory size", mem_max+1-mem_min);
   /*sorry, nothing satisfactory is left*/ 
@:METAFONT capacity exceeded main memory size}{\quad main memory size@>
found: link(r)=null; /*this node is now nonempty*/ 
#ifdef @!STAT
var_used=var_used+s; /*maintain usage statistics*/ 
#endif
@;@/
return r;
} 

@ The lower part of |mem| grows by 1000 words at a time, unless
we are very close to going under. When it grows, we simply link
a new node into the available-space list. This method of controlled
growth helps to keep the |mem| usage consecutive when \MF\ is
implemented on ``virtual memory'' systems.
@^virtual memory@>

@<Grow more variable-size memory and |goto restart|@>=
{@+if (hi_mem_min-lo_mem_max >= 1998) t=lo_mem_max+1000;
else t=lo_mem_max+1+(hi_mem_min-lo_mem_max)/2;
   /*|lo_mem_max+2 <= t < hi_mem_min|*/ 
if (t > mem_min+max_halfword) t=mem_min+max_halfword;
p=llink(rover);q=lo_mem_max;rlink(p)=q;llink(rover)=q;@/
rlink(q)=rover;llink(q)=p;link(q)=empty_flag;node_size(q)=t-lo_mem_max;@/
lo_mem_max=t;link(lo_mem_max)=null;info(lo_mem_max)=null;
rover=q;goto restart;
} 

@ @<Try to allocate...@>=
q=p+node_size(p); /*find the physical successor*/ 
while (is_empty(q))  /*merge node |p| with node |q|*/ 
  {@+t=rlink(q);tt=llink(q);
@^inner loop@>
  if (q==rover) rover=t;
  llink(t)=tt;rlink(tt)=t;@/
  q=q+node_size(q);
  } 
r=q-s;
if (r > p+1) @<Allocate from the top of node |p| and |goto found|@>;
if (r==p) if (rlink(p)!=p) 
  @<Allocate entire node |p| and |goto found|@>;
node_size(p)=q-p /*reset the size in case it grew*/ 

@ @<Allocate from the top...@>=
{@+node_size(p)=r-p; /*store the remaining size*/ 
rover=p; /*start searching here next time*/ 
goto found;
} 

@ Here we delete node |p| from the ring, and let |rover| rove around.

@<Allocate entire...@>=
{@+rover=rlink(p);t=llink(p);
llink(rover)=t;rlink(t)=rover;
goto found;
} 

@ Conversely, when some variable-size node |p| of size |s| is no longer needed,
the operation |free_node(p, s)| will make its words available, by inserting
|p| as a new empty node just before where |rover| now points.

@p void free_node(pointer @!p, halfword @!s) /*variable-size node
  liberation*/ 
{@+pointer @!q; /*|llink(rover)|*/ 
node_size(p)=s;link(p)=empty_flag;
@^inner loop@>
q=llink(rover);llink(p)=q;rlink(p)=rover; /*set both links*/ 
llink(rover)=p;rlink(q)=p; /*insert |p| into the ring*/ 
#ifdef @!STAT
var_used=var_used-s;
#endif
@; /*maintain statistics*/ 
} 

@ Just before \.{INIMF} writes out the memory, it sorts the doubly linked
available space list. The list is probably very short at such times, so a
simple insertion sort is used. The smallest available location will be
pointed to by |rover|, the next-smallest by |rlink(rover)|, etc.

@p
#ifdef @!INIT
void sort_avail(void) /*sorts the available variable-size nodes
  by location*/ 
{@+pointer @!p, @!q, @!r; /*indices into |mem|*/ 
pointer @!old_rover; /*initial |rover| setting*/ 
p=get_node(010000000000); /*merge adjacent free areas*/ 
p=rlink(rover);rlink(rover)=max_halfword;old_rover=rover;
while (p!=old_rover) @<Sort |p| into the list starting at |rover| and advance |p|
to |rlink(p)|@>;
p=rover;
while (rlink(p)!=max_halfword) 
  {@+llink(rlink(p))=p;p=rlink(p);
  } 
rlink(p)=rover;llink(rover)=p;
} 
#endif

@ The following |while | loop is guaranteed to
terminate, since the list that starts at
|rover| ends with |max_halfword| during the sorting procedure.

@<Sort |p|...@>=
if (p < rover) 
  {@+q=p;p=rlink(q);rlink(q)=rover;rover=q;
  } 
else{@+q=rover;
  while (rlink(q) < p) q=rlink(q);
  r=rlink(p);rlink(p)=rlink(q);rlink(q)=p;p=r;
  } 

@* Memory layout.
Some areas of |mem| are dedicated to fixed usage, since static allocation is
more efficient than dynamic allocation when we can get away with it. For
example, locations |mem_min| to |mem_min+2| are always used to store the
specification for null pen coordinates that are `$(0,0)$'. The
following macro definitions accomplish the static allocation by giving
symbolic names to the fixed positions. Static variable-size nodes appear
in locations |mem_min| through |lo_mem_stat_max|, and static single-word nodes
appear in locations |hi_mem_stat_min| through |mem_top|, inclusive.

@d null_coords	mem_min /*specification for pen offsets of $(0,0)$*/ 
@d null_pen	null_coords+3 /*we will define |coord_node_size==3|*/ 
@d dep_head	null_pen+10 /*and |pen_node_size==10|*/ 
@d zero_val	dep_head+2 /*two words for a permanently zero value*/ 
@d temp_val	zero_val+2 /*two words for a temporary value node*/ 
@d end_attr	temp_val /*we use |end_attr+2| only*/ 
@d inf_val	end_attr+2 /*and |inf_val+1| only*/ 
@d bad_vardef	inf_val+2 /*two words for \&{vardef} error recovery*/ 
@d lo_mem_stat_max	bad_vardef+1 /*largest statically
  allocated word in the variable-size |mem|*/ 
@#
@d sentinel	mem_top /*end of sorted lists*/ 
@d temp_head	mem_top-1 /*head of a temporary list of some kind*/ 
@d hold_head	mem_top-2 /*head of a temporary list of another kind*/ 
@d hi_mem_stat_min	mem_top-2 /*smallest statically allocated word in
  the one-word |mem|*/ 

@ The following code gets the dynamic part of |mem| off to a good start,
when \MF\ is initializing itself the slow way.

@<Initialize table entries (done by \.{INIMF} only)@>=
rover=lo_mem_stat_max+1; /*initialize the dynamic memory*/ 
link(rover)=empty_flag;
node_size(rover)=1000; /*which is a 1000-word available node*/ 
llink(rover)=rover;rlink(rover)=rover;@/
lo_mem_max=rover+1000;link(lo_mem_max)=null;info(lo_mem_max)=null;@/
for (k=hi_mem_stat_min; k<=mem_top; k++) 
  mem[k]=mem[lo_mem_max]; /*clear list heads*/ 
avail=null;mem_end=mem_top;
hi_mem_min=hi_mem_stat_min; /*initialize the one-word memory*/ 
var_used=lo_mem_stat_max+1-mem_min;dyn_used=mem_top+1-hi_mem_min;
   /*initialize statistics*/ 

@ The procedure |flush_list(p)| frees an entire linked list of one-word
nodes that starts at a given position, until coming to |sentinel| or a
pointer that is not in the one-word region. Another procedure,
|flush_node_list|, frees an entire linked list of one-word and two-word
nodes, until coming to a |null| pointer.
@^inner loop@>

@p void flush_list(pointer @!p) /*makes list of single-word nodes
  available*/ 
{@+
pointer @!q, @!r; /*list traversers*/ 
if (p >= hi_mem_min) if (p!=sentinel) 
  {@+r=p;
  @/do@+{q=r;r=link(r);
  decr_dyn_used;
  if (r < hi_mem_min) goto done;
  }@+ while (!(r==sentinel));
  done:  /*now |q| is the last node on the list*/ 
  link(q)=avail;avail=p;
  } 
} 
@#
void flush_node_list(pointer @!p)
{@+pointer @!q; /*the node being recycled*/ 
while (p!=null) 
  {@+q=p;p=link(p);
  if (q < hi_mem_min) free_node(q, 2);@+else free_avail(q);
  } 
} 

@ If \MF\ is extended improperly, the |mem| array might get screwed up.
For example, some pointers might be wrong, or some ``dead'' nodes might not
have been freed when the last reference to them disappeared. Procedures
|check_mem| and |search_mem| are available to help diagnose such
problems. These procedures make use of two arrays called |is_free| and
|was_free| that are present only if \MF's debugging routines have
been included. (You may want to decrease the size of |mem| while you
@^debugging@>
are debugging.)

@<Glob...@>=
#ifdef @!DEBUG
bool @!is_free0[mem_max-mem_min+1], *const @!is_free = @!is_free0-mem_min; /*free cells*/ 
@t\hskip1em@>bool @!was_free0[mem_max-mem_min+1], *const @!was_free = @!was_free0-mem_min;
   /*previously free cells*/ 
@t\hskip1em@>pointer @!was_mem_end, @!was_lo_max, @!was_hi_min;
   /*previous |mem_end|, |lo_mem_max|, and |hi_mem_min|*/ 
@t\hskip1em@>bool @!panicking; /*do we want to check memory constantly?*/ 
#endif

@ @<Set initial...@>=
#ifdef @!DEBUG
was_mem_end=mem_min; /*indicate that everything was previously free*/ 
was_lo_max=mem_min;was_hi_min=mem_max;
panicking=false;
#endif

@ Procedure |check_mem| makes sure that the available space lists of
|mem| are well formed, and it optionally prints out all locations
that are reserved now but were free the last time this procedure was called.

@p
#ifdef @!DEBUG
void check_mem(bool @!print_locs)
{@+ /*loop exits*/ 
pointer @!p, @!q, @!r; /*current locations of interest in |mem|*/ 
bool @!clobbered; /*is something amiss?*/ 
for (p=mem_min; p<=lo_mem_max; p++) is_free[p]=false; /*you can probably
  do this faster*/ 
for (p=hi_mem_min; p<=mem_end; p++) is_free[p]=false; /*ditto*/ 
@<Check single-word |avail| list@>;
@<Check variable-size |avail| list@>;
@<Check flags of unavailable nodes@>;
@<Check the list of linear dependencies@>;
if (print_locs) @<Print newly busy locations@>;
for (p=mem_min; p<=lo_mem_max; p++) was_free[p]=is_free[p];
for (p=hi_mem_min; p<=mem_end; p++) was_free[p]=is_free[p];
   /*|was_free=is_free| might be faster*/ 
was_mem_end=mem_end;was_lo_max=lo_mem_max;was_hi_min=hi_mem_min;
} 
#endif

@ @<Check single-word...@>=
p=avail;q=null;clobbered=false;
while (p!=null) 
  {@+if ((p > mem_end)||(p < hi_mem_min)) clobbered=true;
  else if (is_free[p]) clobbered=true;
  if (clobbered) 
    {@+print_nl("AVAIL list clobbered at ");
@.AVAIL list clobbered...@>
    print_int(q);goto done1;
    } 
  is_free[p]=true;q=p;p=link(q);
  } 
done1: 

@ @<Check variable-size...@>=
p=rover;q=null;clobbered=false;
@/do@+{if ((p >= lo_mem_max)||(p < mem_min)) clobbered=true;
  else if ((rlink(p) >= lo_mem_max)||(rlink(p) < mem_min)) clobbered=true;
  else if (!(is_empty(p))||(node_size(p) < 2)||@|
   (p+node_size(p) > lo_mem_max)||@|(llink(rlink(p))!=p)) clobbered=true;
  if (clobbered) 
  {@+print_nl("Double-AVAIL list clobbered at ");
@.Double-AVAIL list clobbered...@>
  print_int(q);goto done2;
  } 
for (q=p; q<=p+node_size(p)-1; q++)  /*mark all locations free*/ 
  {@+if (is_free[q]) 
    {@+print_nl("Doubly free location at ");
@.Doubly free location...@>
    print_int(q);goto done2;
    } 
  is_free[q]=true;
  } 
q=p;p=rlink(p);
}@+ while (!(p==rover));
done2: 

@ @<Check flags...@>=
p=mem_min;
while (p <= lo_mem_max)  /*node |p| should not be empty*/ 
  {@+if (is_empty(p)) 
    {@+print_nl("Bad flag at ");print_int(p);
@.Bad flag...@>
    } 
  while ((p <= lo_mem_max)&&!is_free[p]) incr(p);
  while ((p <= lo_mem_max)&&is_free[p]) incr(p);
  } 

@ @<Print newly busy...@>=
{@+print_nl("New busy locs:");
@.New busy locs@>
for (p=mem_min; p<=lo_mem_max; p++) 
  if (!is_free[p]&&((p > was_lo_max)||was_free[p])) 
    {@+print_char(' ');print_int(p);
    } 
for (p=hi_mem_min; p<=mem_end; p++) 
  if (!is_free[p]&&
   ((p < was_hi_min)||(p > was_mem_end)||was_free[p])) 
    {@+print_char(' ');print_int(p);
    } 
} 

@ The |search_mem| procedure attempts to answer the question ``Who points
to node~|p|?'' In doing so, it fetches |link| and |info| fields of |mem|
that might not be of type |two_halves|. Strictly speaking, this is
@^dirty \PASCAL@>
undefined in \PASCAL, and it can lead to ``false drops'' (words that seem to
point to |p| purely by coincidence). But for debugging purposes, we want
to rule out the places that do {\sl not\/} point to |p|, so a few false
drops are tolerable.

@p
#ifdef @!DEBUG
void search_mem(pointer @!p) /*look for pointers to |p|*/ 
{@+int @!q; /*current position being searched*/ 
for (q=mem_min; q<=lo_mem_max; q++) 
  {@+if (link(q)==p) 
    {@+print_nl("LINK(");print_int(q);print_char(')');
    } 
  if (info(q)==p) 
    {@+print_nl("INFO(");print_int(q);print_char(')');
    } 
  } 
for (q=hi_mem_min; q<=mem_end; q++) 
  {@+if (link(q)==p) 
    {@+print_nl("LINK(");print_int(q);print_char(')');
    } 
  if (info(q)==p) 
    {@+print_nl("INFO(");print_int(q);print_char(')');
    } 
  } 
@<Search |eqtb| for equivalents equal to |p|@>;
} 
#endif

@* The command codes.
Before we can go much further, we need to define symbolic names for the internal
code numbers that represent the various commands obeyed by \MF. These codes
are somewhat arbitrary, but not completely so. For example,
some codes have been made adjacent so that |case| statements in the
program need not consider cases that are widely spaced, or so that |case|
statements can be replaced by |if (| statements. A command can begin an
expression if and only if its code lies between |min_primary_command| and
|max_primary_command|, inclusive. The first token of a statement that doesn't
begin with an expression has a command code between |min_command| and
|max_statement_command|, inclusive. The ordering of the highest-numbered
commands (|comma < semicolon < end_group < stop|) is crucial for the parsing
and error-recovery methods of this program.

At any rate, here is the list, for future reference.

@d if_test	1 /*conditional text (\&{if})*/ 
@d fi_or_else	2 /*delimiters for conditionals (\&{elseif}, \&{else}, \&{fi})*/ 
@d input	3 /*input a source file (\&{input}, \&{endinput})*/ 
@d iteration	4 /*iterate (\&{for}, \&{forsuffixes}, \&{forever}, \&{endfor})*/ 
@d repeat_loop	5 /*special command substituted for \&{endfor}*/ 
@d exit_test	6 /*premature exit from a loop (\&{exitif})*/ 
@d relax	7 /*do nothing (\.{\char`\\})*/ 
@d scan_tokens	8 /*put a string into the input buffer*/ 
@d expand_after	9 /*look ahead one token*/ 
@d defined_macro	10 /*a macro defined by the user*/ 
@d min_command	(defined_macro+1)
@d display_command	11 /*online graphic output (\&{display})*/ 
@d save_command	12 /*save a list of tokens (\&{save})*/ 
@d interim_command	13 /*save an internal quantity (\&{interim})*/ 
@d let_command	14 /*redefine a symbolic token (\&{let})*/ 
@d new_internal	15 /*define a new internal quantity (\&{newinternal})*/ 
@d macro_def	16 /*define a macro (\&{def}, \&{vardef}, etc.)*/ 
@d ship_out_command	17 /*output a character (\&{shipout})*/ 
@d add_to_command	18 /*add to edges (\&{addto})*/ 
@d cull_command	19 /*cull and normalize edges (\&{cull})*/ 
@d tfm_command	20 /*command for font metric info (\&{ligtable}, etc.)*/ 
@d protection_command	21 /*set protection flag (\&{outer}, \&{inner})*/ 
@d show_command	22 /*diagnostic output (\&{show}, \&{showvariable}, etc.)*/ 
@d mode_command	23 /*set interaction level (\&{batchmode}, etc.)*/ 
@d random_seed	24 /*initialize random number generator (\&{randomseed})*/ 
@d message_command	25 /*communicate to user (\&{message}, \&{errmessage})*/ 
@d every_job_command	26 /*designate a starting token (\&{everyjob})*/ 
@d delimiters	27 /*define a pair of delimiters (\&{delimiters})*/ 
@d open_window	28 /*define a window on the screen (\&{openwindow})*/ 
@d special_command	29 /*output special info (\&{special}, \&{numspecial})*/ 
@d type_name	30 /*declare a type (\&{numeric}, \&{pair}, etc.)*/ 
@d max_statement_command	type_name
@d min_primary_command	type_name
@d left_delimiter	31 /*the left delimiter of a matching pair*/ 
@d begin_group	32 /*beginning of a group (\&{begingroup})*/ 
@d nullary	33 /*an operator without arguments (e.g., \&{normaldeviate})*/ 
@d unary	34 /*an operator with one argument (e.g., \&{sqrt})*/ 
@d str_op	35 /*convert a suffix to a string (\&{str})*/ 
@d cycle	36 /*close a cyclic path (\&{cycle})*/ 
@d primary_binary	37 /*binary operation taking `\&{of}' (e.g., \&{point})*/ 
@d capsule_token	38 /*a value that has been put into a token list*/ 
@d string_token	39 /*a string constant (e.g., |@[@<|"hello"|@>@]|)*/ 
@d internal_quantity	40 /*internal numeric parameter (e.g., \&{pausing})*/ 
@d min_suffix_token	internal_quantity
@d tag_token	41 /*a symbolic token without a primitive meaning*/ 
@d numeric_token	42 /*a numeric constant (e.g., \.{3.14159})*/ 
@d max_suffix_token	numeric_token
@d plus_or_minus	43 /*either `\.+' or `\.-'*/ 
@d max_primary_command	plus_or_minus /*should also be |numeric_token+1|*/ 
@d min_tertiary_command	plus_or_minus
@d tertiary_secondary_macro	44 /*a macro defined by \&{secondarydef}*/ 
@d tertiary_binary	45 /*an operator at the tertiary level (e.g., `\.{++}')*/ 
@d max_tertiary_command	tertiary_binary
@d left_brace	46 /*the operator `\.{\char`\{}'*/ 
@d min_expression_command	left_brace
@d path_join	47 /*the operator `\.{..}'*/ 
@d ampersand	48 /*the operator `\.\&'*/ 
@d expression_tertiary_macro	49 /*a macro defined by \&{tertiarydef}*/ 
@d expression_binary	50 /*an operator at the expression level (e.g., `\.<')*/ 
@d equals	51 /*the operator `\.='*/ 
@d max_expression_command	equals
@d and_command	52 /*the operator `\&{and}'*/ 
@d min_secondary_command	and_command
@d secondary_primary_macro	53 /*a macro defined by \&{primarydef}*/ 
@d slash	54 /*the operator `\./'*/ 
@d secondary_binary	55 /*an operator at the binary level (e.g., \&{shifted})*/ 
@d max_secondary_command	secondary_binary
@d param_type	56 /*type of parameter (\&{primary}, \&{expr}, \&{suffix}, etc.)*/ 
@d controls	57 /*specify control points explicitly (\&{controls})*/ 
@d tension	58 /*specify tension between knots (\&{tension})*/ 
@d at_least	59 /*bounded tension value (\&{atleast})*/ 
@d curl_command	60 /*specify curl at an end knot (\&{curl})*/ 
@d macro_special	61 /*special macro operators (\&{quote}, \.{\#\AT!}, etc.)*/ 
@d right_delimiter	62 /*the right delimiter of a matching pair*/ 
@d left_bracket	63 /*the operator `\.['*/ 
@d right_bracket	64 /*the operator `\.]'*/ 
@d right_brace	65 /*the operator `\.{\char`\}}'*/ 
@d with_option	66 /*option for filling (\&{withpen}, \&{withweight})*/ 
@d cull_op	67 /*the operator `\&{keeping}' or `\&{dropping}'*/ 
@d thing_to_add	68
   /*variant of \&{addto} (\&{contour}, \&{doublepath}, \&{also})*/ 
@d of_token	69 /*the operator `\&{of}'*/ 
@d from_token	70 /*the operator `\&{from}'*/ 
@d to_token	71 /*the operator `\&{to}'*/ 
@d at_token	72 /*the operator `\&{at}'*/ 
@d in_window	73 /*the operator `\&{inwindow}'*/ 
@d step_token	74 /*the operator `\&{step}'*/ 
@d until_token	75 /*the operator `\&{until}'*/ 
@d lig_kern_token	76
   /*the operators `\&{kern}' and `\.{=:}' and `\.{=:\char'174}', etc.*/ 
@d assignment	77 /*the operator `\.{:=}'*/ 
@d skip_to	78 /*the operation `\&{skipto}'*/ 
@d bchar_label	79 /*the operator `\.{\char'174\char'174:}'*/ 
@d double_colon	80 /*the operator `\.{::}'*/ 
@d colon	81 /*the operator `\.:'*/ 
@#
@d comma	82 /*the operator `\.,', must be |colon+1|*/ 
@d end_of_statement	cur_cmd > comma
@d semicolon	83 /*the operator `\.;', must be |comma+1|*/ 
@d end_group	84 /*end a group (\&{endgroup}), must be |semicolon+1|*/ 
@d stop	85 /*end a job (\&{end}, \&{dump}), must be |end_group+1|*/ 
@d max_command_code	stop
@d outer_tag	(max_command_code+1) /*protection code added to command code*/ 

@<Types...@>=
typedef uint8_t command_code;

@ Variables and capsules in \MF\ have a variety of ``types,''
distinguished by the following code numbers:

@d undefined	0 /*no type has been declared*/ 
@d unknown_tag	1 /*this constant is added to certain type codes below*/ 
@d vacuous	1 /*no expression was present*/ 
@d boolean_type	2 /*\&{boolean} with a known value*/ 
@d unknown_boolean	(boolean_type+unknown_tag)
@d string_type	4 /*\&{string} with a known value*/ 
@d unknown_string	(string_type+unknown_tag)
@d pen_type	6 /*\&{pen} with a known value*/ 
@d unknown_pen	(pen_type+unknown_tag)
@d future_pen	8 /*subexpression that will become a \&{pen} at a higher level*/ 
@d path_type	9 /*\&{path} with a known value*/ 
@d unknown_path	(path_type+unknown_tag)
@d picture_type	11 /*\&{picture} with a known value*/ 
@d unknown_picture	(picture_type+unknown_tag)
@d transform_type	13 /*\&{transform} variable or capsule*/ 
@d pair_type	14 /*\&{pair} variable or capsule*/ 
@d numeric_type	15 /*variable that has been declared \&{numeric} but not used*/ 
@d known	16 /*\&{numeric} with a known value*/ 
@d dependent	17 /*a linear combination with |fraction| coefficients*/ 
@d proto_dependent	18 /*a linear combination with |scaled| coefficients*/ 
@d independent	19 /*\&{numeric} with unknown value*/ 
@d token_list	20 /*variable name or suffix argument or text argument*/ 
@d structured	21 /*variable with subscripts and attributes*/ 
@d unsuffixed_macro	22 /*variable defined with \&{vardef} but no \.{\AT!\#}*/ 
@d suffixed_macro	23 /*variable defined with \&{vardef} and \.{\AT!\#}*/ 
@#
@d unknown_types	case unknown_boolean: case unknown_string: 
  case unknown_pen: case unknown_picture: case unknown_path

@<Basic printing procedures@>=
void print_type(small_number @!t)
{@+switch (t) {
case vacuous: print_str("vacuous");@+break;
case boolean_type: print_str("boolean");@+break;
case unknown_boolean: print_str("unknown boolean");@+break;
case string_type: print_str("string");@+break;
case unknown_string: print_str("unknown string");@+break;
case pen_type: print_str("pen");@+break;
case unknown_pen: print_str("unknown pen");@+break;
case future_pen: print_str("future pen");@+break;
case path_type: print_str("path");@+break;
case unknown_path: print_str("unknown path");@+break;
case picture_type: print_str("picture");@+break;
case unknown_picture: print_str("unknown picture");@+break;
case transform_type: print_str("transform");@+break;
case pair_type: print_str("pair");@+break;
case known: print_str("known numeric");@+break;
case dependent: print_str("dependent");@+break;
case proto_dependent: print_str("proto-dependent");@+break;
case numeric_type: print_str("numeric");@+break;
case independent: print_str("independent");@+break;
case token_list: print_str("token list");@+break;
case structured: print_str("structured");@+break;
case unsuffixed_macro: print_str("unsuffixed macro");@+break;
case suffixed_macro: print_str("suffixed macro");@+break;
default:print_str("undefined");
} 
} 

@ Values inside \MF\ are stored in two-word nodes that have a |name_type|
as well as a |type|. The possibilities for |name_type| are defined
here; they will be explained in more detail later.

@d root	0 /*|name_type| at the top level of a variable*/ 
@d saved_root	1 /*same, when the variable has been saved*/ 
@d structured_root	2 /*|name_type| where a |structured| branch occurs*/ 
@d subscr	3 /*|name_type| in a subscript node*/ 
@d attr	4 /*|name_type| in an attribute node*/ 
@d x_part_sector	5 /*|name_type| in the \&{xpart} of a node*/ 
@d y_part_sector	6 /*|name_type| in the \&{ypart} of a node*/ 
@d xx_part_sector	7 /*|name_type| in the \&{xxpart} of a node*/ 
@d xy_part_sector	8 /*|name_type| in the \&{xypart} of a node*/ 
@d yx_part_sector	9 /*|name_type| in the \&{yxpart} of a node*/ 
@d yy_part_sector	10 /*|name_type| in the \&{yypart} of a node*/ 
@d capsule	11 /*|name_type| in stashed-away subexpressions*/ 
@d token	12 /*|name_type| in a numeric token or string token*/ 

@ Primitive operations that produce values have a secondary identification
code in addition to their command code; it's something like genera and species.
For example, `\.*' has the command code |primary_binary|, and its
secondary identification is |times|. The secondary codes start at 30 so that
they don't overlap with the type codes; some type codes (e.g., |string_type|)
are used as operators as well as type identifications.

@d true_code	30 /*operation code for \.{true}*/ 
@d false_code	31 /*operation code for \.{false}*/ 
@d null_picture_code	32 /*operation code for \.{nullpicture}*/ 
@d null_pen_code	33 /*operation code for \.{nullpen}*/ 
@d job_name_op	34 /*operation code for \.{jobname}*/ 
@d read_string_op	35 /*operation code for \.{readstring}*/ 
@d pen_circle	36 /*operation code for \.{pencircle}*/ 
@d normal_deviate	37 /*operation code for \.{normaldeviate}*/ 
@d odd_op	38 /*operation code for \.{odd}*/ 
@d known_op	39 /*operation code for \.{known}*/ 
@d unknown_op	40 /*operation code for \.{unknown}*/ 
@d not_op	41 /*operation code for \.{not}*/ 
@d decimal	42 /*operation code for \.{decimal}*/ 
@d reverse	43 /*operation code for \.{reverse}*/ 
@d make_path_op	44 /*operation code for \.{makepath}*/ 
@d make_pen_op	45 /*operation code for \.{makepen}*/ 
@d total_weight_op	46 /*operation code for \.{totalweight}*/ 
@d oct_op	47 /*operation code for \.{oct}*/ 
@d hex_op	48 /*operation code for \.{hex}*/ 
@d ASCII_op	49 /*operation code for \.{ASCII}*/ 
@d char_op	50 /*operation code for \.{char}*/ 
@d length_op	51 /*operation code for \.{length}*/ 
@d turning_op	52 /*operation code for \.{turningnumber}*/ 
@d x_part	53 /*operation code for \.{xpart}*/ 
@d y_part	54 /*operation code for \.{ypart}*/ 
@d xx_part	55 /*operation code for \.{xxpart}*/ 
@d xy_part	56 /*operation code for \.{xypart}*/ 
@d yx_part	57 /*operation code for \.{yxpart}*/ 
@d yy_part	58 /*operation code for \.{yypart}*/ 
@d sqrt_op	59 /*operation code for \.{sqrt}*/ 
@d m_exp_op	60 /*operation code for \.{mexp}*/ 
@d m_log_op	61 /*operation code for \.{mlog}*/ 
@d sin_d_op	62 /*operation code for \.{sind}*/ 
@d cos_d_op	63 /*operation code for \.{cosd}*/ 
@d floor_op	64 /*operation code for \.{floor}*/ 
@d uniform_deviate	65 /*operation code for \.{uniformdeviate}*/ 
@d char_exists_op	66 /*operation code for \.{charexists}*/ 
@d angle_op	67 /*operation code for \.{angle}*/ 
@d cycle_op	68 /*operation code for \.{cycle}*/ 
@d plus	69 /*operation code for \.+*/ 
@d minus	70 /*operation code for \.-*/ 
@d times	71 /*operation code for \.**/ 
@d over	72 /*operation code for \./*/ 
@d pythag_add	73 /*operation code for \.{++}*/ 
@d pythag_sub	74 /*operation code for \.{+-+}*/ 
@d or_op	75 /*operation code for \.{or}*/ 
@d and_op	76 /*operation code for \.{and}*/ 
@d less_than	77 /*operation code for \.<*/ 
@d less_or_equal	78 /*operation code for \.{<=}*/ 
@d greater_than	79 /*operation code for \.>*/ 
@d greater_or_equal	80 /*operation code for \.{>=}*/ 
@d equal_to	81 /*operation code for \.=*/ 
@d unequal_to	82 /*operation code for \.{<>}*/ 
@d concatenate	83 /*operation code for \.\&*/ 
@d rotated_by	84 /*operation code for \.{rotated}*/ 
@d slanted_by	85 /*operation code for \.{slanted}*/ 
@d scaled_by	86 /*operation code for \.{scaled}*/ 
@d shifted_by	87 /*operation code for \.{shifted}*/ 
@d transformed_by	88 /*operation code for \.{transformed}*/ 
@d x_scaled	89 /*operation code for \.{xscaled}*/ 
@d y_scaled	90 /*operation code for \.{yscaled}*/ 
@d z_scaled	91 /*operation code for \.{zscaled}*/ 
@d intersect	92 /*operation code for \.{intersectiontimes}*/ 
@d double_dot	93 /*operation code for improper \.{..}*/ 
@d substring_of	94 /*operation code for \.{substring}*/ 
@d min_of	substring_of
@d subpath_of	95 /*operation code for \.{subpath}*/ 
@d direction_time_of	96 /*operation code for \.{directiontime}*/ 
@d point_of	97 /*operation code for \.{point}*/ 
@d precontrol_of	98 /*operation code for \.{precontrol}*/ 
@d postcontrol_of	99 /*operation code for \.{postcontrol}*/ 
@d pen_offset_of	100 /*operation code for \.{penoffset}*/ 

@p void print_op(quarterword @!c)
{@+if (c <= numeric_type) print_type(c);
else switch (c) {
case true_code: print_str("true");@+break;
case false_code: print_str("false");@+break;
case null_picture_code: print_str("nullpicture");@+break;
case null_pen_code: print_str("nullpen");@+break;
case job_name_op: print_str("jobname");@+break;
case read_string_op: print_str("readstring");@+break;
case pen_circle: print_str("pencircle");@+break;
case normal_deviate: print_str("normaldeviate");@+break;
case odd_op: print_str("odd");@+break;
case known_op: print_str("known");@+break;
case unknown_op: print_str("unknown");@+break;
case not_op: print_str("not");@+break;
case decimal: print_str("decimal");@+break;
case reverse: print_str("reverse");@+break;
case make_path_op: print_str("makepath");@+break;
case make_pen_op: print_str("makepen");@+break;
case total_weight_op: print_str("totalweight");@+break;
case oct_op: print_str("oct");@+break;
case hex_op: print_str("hex");@+break;
case ASCII_op: print_str("ASCII");@+break;
case char_op: print_str("char");@+break;
case length_op: print_str("length");@+break;
case turning_op: print_str("turningnumber");@+break;
case x_part: print_str("xpart");@+break;
case y_part: print_str("ypart");@+break;
case xx_part: print_str("xxpart");@+break;
case xy_part: print_str("xypart");@+break;
case yx_part: print_str("yxpart");@+break;
case yy_part: print_str("yypart");@+break;
case sqrt_op: print_str("sqrt");@+break;
case m_exp_op: print_str("mexp");@+break;
case m_log_op: print_str("mlog");@+break;
case sin_d_op: print_str("sind");@+break;
case cos_d_op: print_str("cosd");@+break;
case floor_op: print_str("floor");@+break;
case uniform_deviate: print_str("uniformdeviate");@+break;
case char_exists_op: print_str("charexists");@+break;
case angle_op: print_str("angle");@+break;
case cycle_op: print_str("cycle");@+break;
case plus: print_char('+');@+break;
case minus: print_char('-');@+break;
case times: print_char('*');@+break;
case over: print_char('/');@+break;
case pythag_add: print_str("++");@+break;
case pythag_sub: print_str("+-+");@+break;
case or_op: print_str("or");@+break;
case and_op: print_str("and");@+break;
case less_than: print_char('<');@+break;
case less_or_equal: print_str("<=");@+break;
case greater_than: print_char('>');@+break;
case greater_or_equal: print_str(">=");@+break;
case equal_to: print_char('=');@+break;
case unequal_to: print_str("<>");@+break;
case concatenate: print_str("&");@+break;
case rotated_by: print_str("rotated");@+break;
case slanted_by: print_str("slanted");@+break;
case scaled_by: print_str("scaled");@+break;
case shifted_by: print_str("shifted");@+break;
case transformed_by: print_str("transformed");@+break;
case x_scaled: print_str("xscaled");@+break;
case y_scaled: print_str("yscaled");@+break;
case z_scaled: print_str("zscaled");@+break;
case intersect: print_str("intersectiontimes");@+break;
case substring_of: print_str("substring");@+break;
case subpath_of: print_str("subpath");@+break;
case direction_time_of: print_str("directiontime");@+break;
case point_of: print_str("point");@+break;
case precontrol_of: print_str("precontrol");@+break;
case postcontrol_of: print_str("postcontrol");@+break;
case pen_offset_of: print_str("penoffset");@+break;
default:print_str("..");
} 
} 

@ \MF\ also has a bunch of internal parameters that a user might want to
fuss with. Every such parameter has an identifying code number, defined here.

@d tracing_titles	1 /*show titles online when they appear*/ 
@d tracing_equations	2 /*show each variable when it becomes known*/ 
@d tracing_capsules	3 /*show capsules too*/ 
@d tracing_choices	4 /*show the control points chosen for paths*/ 
@d tracing_specs	5 /*show subdivision of paths into octants before digitizing*/ 
@d tracing_pens	6 /*show details of pens that are made*/ 
@d tracing_commands	7 /*show commands and operations before they are performed*/ 
@d tracing_restores	8 /*show when a variable or internal is restored*/ 
@d tracing_macros	9 /*show macros before they are expanded*/ 
@d tracing_edges	10 /*show digitized edges as they are computed*/ 
@d tracing_output	11 /*show digitized edges as they are output*/ 
@d tracing_stats	12 /*show memory usage at end of job*/ 
@d tracing_online	13 /*show long diagnostics on terminal and in the log file*/ 
@d year	14 /*the current year (e.g., 1984)*/ 
@d month	15 /*the current month (e.g., 3 $\equiv$ March)*/ 
@d day	16 /*the current day of the month*/ 
@d time	17 /*the number of minutes past midnight when this job started*/ 
@d char_code	18 /*the number of the next character to be output*/ 
@d char_ext	19 /*the extension code of the next character to be output*/ 
@d char_wd	20 /*the width of the next character to be output*/ 
@d char_ht	21 /*the height of the next character to be output*/ 
@d char_dp	22 /*the depth of the next character to be output*/ 
@d char_ic	23 /*the italic correction of the next character to be output*/ 
@d char_dx	24 /*the device's $x$ movement for the next character, in pixels*/ 
@d char_dy	25 /*the device's $y$ movement for the next character, in pixels*/ 
@d design_size	26 /*the unit of measure used for |char_wd dotdot char_ic|, in points*/ 
@d hppp	27 /*the number of horizontal pixels per point*/ 
@d vppp	28 /*the number of vertical pixels per point*/ 
@d x_offset	29 /*horizontal displacement of shipped-out characters*/ 
@d y_offset	30 /*vertical displacement of shipped-out characters*/ 
@d pausing	31 /*positive to display lines on the terminal before they are read*/ 
@d showstopping	32 /*positive to stop after each \&{show} command*/ 
@d fontmaking	33 /*positive if font metric output is to be produced*/ 
@d proofing	34 /*positive for proof mode, negative to suppress output*/ 
@d smoothing	35 /*positive if moves are to be ``smoothed''*/ 
@d autorounding	36 /*controls path modification to ``good'' points*/ 
@d granularity	37 /*autorounding uses this pixel size*/ 
@d fillin	38 /*extra darkness of diagonal lines*/ 
@d turning_check	39 /*controls reorientation of clockwise paths*/ 
@d warning_check	40 /*controls error message when variable value is large*/ 
@d boundary_char	41 /*the right boundary character for ligatures*/ 
@d max_given_internal	41

@<Glob...@>=
scaled @!internal0[max_internal], *const @!internal = @!internal0-1;
   /*the values of internal quantities*/ 
str_number @!int_name0[max_internal], *const @!int_name = @!int_name0-1;
   /*their names*/ 
uint8_t @!int_ptr;
   /*the maximum internal quantity defined so far*/ 

@ @<Set init...@>=
for (k=1; k<=max_given_internal; k++) internal[k]=0;
int_ptr=max_given_internal;

@ The symbolic names for internal quantities are put into \MF's hash table
by using a routine called |primitive|, which will be defined later. Let us
enter them now, so that we don't have to list all those names again
anywhere else.

@<Put each of \MF's primitives into the hash table@>=
primitive(@[@<|"tracingtitles"|@>@], internal_quantity, tracing_titles);@/
@!@:tracingtitles_}{\&{tracingtitles} primitive@>
primitive(@[@<|"tracingequations"|@>@], internal_quantity, tracing_equations);@/
@!@:tracing_equations_}{\&{tracingequations} primitive@>
primitive(@[@<|"tracingcapsules"|@>@], internal_quantity, tracing_capsules);@/
@!@:tracing_capsules_}{\&{tracingcapsules} primitive@>
primitive(@[@<|"tracingchoices"|@>@], internal_quantity, tracing_choices);@/
@!@:tracing_choices_}{\&{tracingchoices} primitive@>
primitive(@[@<|"tracingspecs"|@>@], internal_quantity, tracing_specs);@/
@!@:tracing_specs_}{\&{tracingspecs} primitive@>
primitive(@[@<|"tracingpens"|@>@], internal_quantity, tracing_pens);@/
@!@:tracing_pens_}{\&{tracingpens} primitive@>
primitive(@[@<|"tracingcommands"|@>@], internal_quantity, tracing_commands);@/
@!@:tracing_commands_}{\&{tracingcommands} primitive@>
primitive(@[@<|"tracingrestores"|@>@], internal_quantity, tracing_restores);@/
@!@:tracing_restores_}{\&{tracingrestores} primitive@>
primitive(@[@<|"tracingmacros"|@>@], internal_quantity, tracing_macros);@/
@!@:tracing_macros_}{\&{tracingmacros} primitive@>
primitive(@[@<|"tracingedges"|@>@], internal_quantity, tracing_edges);@/
@!@:tracing_edges_}{\&{tracingedges} primitive@>
primitive(@[@<|"tracingoutput"|@>@], internal_quantity, tracing_output);@/
@!@:tracing_output_}{\&{tracingoutput} primitive@>
primitive(@[@<|"tracingstats"|@>@], internal_quantity, tracing_stats);@/
@!@:tracing_stats_}{\&{tracingstats} primitive@>
primitive(@[@<|"tracingonline"|@>@], internal_quantity, tracing_online);@/
@!@:tracing_online_}{\&{tracingonline} primitive@>
primitive(@[@<|"year"|@>@], internal_quantity, year);@/
@!@:year_}{\&{year} primitive@>
primitive(@[@<|"month"|@>@], internal_quantity, month);@/
@!@:month_}{\&{month} primitive@>
primitive(@[@<|"day"|@>@], internal_quantity, day);@/
@!@:day_}{\&{day} primitive@>
primitive(@[@<|"time"|@>@], internal_quantity, time);@/
@!@:time_}{\&{time} primitive@>
primitive(@[@<|"charcode"|@>@], internal_quantity, char_code);@/
@!@:char_code_}{\&{charcode} primitive@>
primitive(@[@<|"charext"|@>@], internal_quantity, char_ext);@/
@!@:char_ext_}{\&{charext} primitive@>
primitive(@[@<|"charwd"|@>@], internal_quantity, char_wd);@/
@!@:char_wd_}{\&{charwd} primitive@>
primitive(@[@<|"charht"|@>@], internal_quantity, char_ht);@/
@!@:char_ht_}{\&{charht} primitive@>
primitive(@[@<|"chardp"|@>@], internal_quantity, char_dp);@/
@!@:char_dp_}{\&{chardp} primitive@>
primitive(@[@<|"charic"|@>@], internal_quantity, char_ic);@/
@!@:char_ic_}{\&{charic} primitive@>
primitive(@[@<|"chardx"|@>@], internal_quantity, char_dx);@/
@!@:char_dx_}{\&{chardx} primitive@>
primitive(@[@<|"chardy"|@>@], internal_quantity, char_dy);@/
@!@:char_dy_}{\&{chardy} primitive@>
primitive(@[@<|"designsize"|@>@], internal_quantity, design_size);@/
@!@:design_size_}{\&{designsize} primitive@>
primitive(@[@<|"hppp"|@>@], internal_quantity, hppp);@/
@!@:hppp_}{\&{hppp} primitive@>
primitive(@[@<|"vppp"|@>@], internal_quantity, vppp);@/
@!@:vppp_}{\&{vppp} primitive@>
primitive(@[@<|"xoffset"|@>@], internal_quantity, x_offset);@/
@!@:x_offset_}{\&{xoffset} primitive@>
primitive(@[@<|"yoffset"|@>@], internal_quantity, y_offset);@/
@!@:y_offset_}{\&{yoffset} primitive@>
primitive(@[@<|"pausing"|@>@], internal_quantity, pausing);@/
@!@:pausing_}{\&{pausing} primitive@>
primitive(@[@<|"showstopping"|@>@], internal_quantity, showstopping);@/
@!@:showstopping_}{\&{showstopping} primitive@>
primitive(@[@<|"fontmaking"|@>@], internal_quantity, fontmaking);@/
@!@:fontmaking_}{\&{fontmaking} primitive@>
primitive(@[@<|"proofing"|@>@], internal_quantity, proofing);@/
@!@:proofing_}{\&{proofing} primitive@>
primitive(@[@<|"smoothing"|@>@], internal_quantity, smoothing);@/
@!@:smoothing_}{\&{smoothing} primitive@>
primitive(@[@<|"autorounding"|@>@], internal_quantity, autorounding);@/
@!@:autorounding_}{\&{autorounding} primitive@>
primitive(@[@<|"granularity"|@>@], internal_quantity, granularity);@/
@!@:granularity_}{\&{granularity} primitive@>
primitive(@[@<|"fillin"|@>@], internal_quantity, fillin);@/
@!@:fillin_}{\&{fillin} primitive@>
primitive(@[@<|"turningcheck"|@>@], internal_quantity, turning_check);@/
@!@:turning_check_}{\&{turningcheck} primitive@>
primitive(@[@<|"warningcheck"|@>@], internal_quantity, warning_check);@/
@!@:warning_check_}{\&{warningcheck} primitive@>
primitive(@[@<|"boundarychar"|@>@], internal_quantity, boundary_char);@/
@!@:boundary_char_}{\&{boundarychar} primitive@>

@ Well, we do have to list the names one more time, for use in symbolic
printouts.

@<Initialize table...@>=
int_name[tracing_titles]=@[@<|"tracingtitles"|@>@];
int_name[tracing_equations]=@[@<|"tracingequations"|@>@];
int_name[tracing_capsules]=@[@<|"tracingcapsules"|@>@];
int_name[tracing_choices]=@[@<|"tracingchoices"|@>@];
int_name[tracing_specs]=@[@<|"tracingspecs"|@>@];
int_name[tracing_pens]=@[@<|"tracingpens"|@>@];
int_name[tracing_commands]=@[@<|"tracingcommands"|@>@];
int_name[tracing_restores]=@[@<|"tracingrestores"|@>@];
int_name[tracing_macros]=@[@<|"tracingmacros"|@>@];
int_name[tracing_edges]=@[@<|"tracingedges"|@>@];
int_name[tracing_output]=@[@<|"tracingoutput"|@>@];
int_name[tracing_stats]=@[@<|"tracingstats"|@>@];
int_name[tracing_online]=@[@<|"tracingonline"|@>@];
int_name[year]=@[@<|"year"|@>@];
int_name[month]=@[@<|"month"|@>@];
int_name[day]=@[@<|"day"|@>@];
int_name[time]=@[@<|"time"|@>@];
int_name[char_code]=@[@<|"charcode"|@>@];
int_name[char_ext]=@[@<|"charext"|@>@];
int_name[char_wd]=@[@<|"charwd"|@>@];
int_name[char_ht]=@[@<|"charht"|@>@];
int_name[char_dp]=@[@<|"chardp"|@>@];
int_name[char_ic]=@[@<|"charic"|@>@];
int_name[char_dx]=@[@<|"chardx"|@>@];
int_name[char_dy]=@[@<|"chardy"|@>@];
int_name[design_size]=@[@<|"designsize"|@>@];
int_name[hppp]=@[@<|"hppp"|@>@];
int_name[vppp]=@[@<|"vppp"|@>@];
int_name[x_offset]=@[@<|"xoffset"|@>@];
int_name[y_offset]=@[@<|"yoffset"|@>@];
int_name[pausing]=@[@<|"pausing"|@>@];
int_name[showstopping]=@[@<|"showstopping"|@>@];
int_name[fontmaking]=@[@<|"fontmaking"|@>@];
int_name[proofing]=@[@<|"proofing"|@>@];
int_name[smoothing]=@[@<|"smoothing"|@>@];
int_name[autorounding]=@[@<|"autorounding"|@>@];
int_name[granularity]=@[@<|"granularity"|@>@];
int_name[fillin]=@[@<|"fillin"|@>@];
int_name[turning_check]=@[@<|"turningcheck"|@>@];
int_name[warning_check]=@[@<|"warningcheck"|@>@];
int_name[boundary_char]=@[@<|"boundarychar"|@>@];

@ The following procedure, which is called just before \MF\ initializes its
input and output, establishes the initial values of the date and time.
@^system dependencies@>
Since standard \PASCAL\ cannot provide such information, something special
is needed. The program here simply specifies July 4, 1776, at noon; but
users probably want a better approximation to the truth.

Note that the values are |scaled| integers. Hence \MF\ can no longer
be used after the year 32767.

@p void fix_date_and_time(void)
{@+internal[time]=12*60*unity; /*minutes since midnight*/ 
internal[day]=4*unity; /*fourth day of the month*/ 
internal[month]=7*unity; /*seventh month of the year*/ 
internal[year]=1776*unity; /*Anno Domini*/ 
} 

@ \MF\ is occasionally supposed to print diagnostic information that
goes only into the transcript file, unless |tracing_online| is positive.
Now that we have defined |tracing_online| we can define
two routines that adjust the destination of print commands:

@<Basic printing...@>=
void begin_diagnostic(void) /*prepare to do some tracing*/ 
{@+old_setting=selector;
if ((internal[tracing_online] <= 0)&&(selector==term_and_log)) 
  {@+decr(selector);
  if (history==spotless) history=warning_issued;
  } 
} 
@#
void end_diagnostic(bool @!blank_line)
   /*restore proper conditions after tracing*/ 
{@+print_nl("");
if (blank_line) print_ln();
selector=old_setting;
} 

@ Of course we had better declare another global variable, if the previous
routines are going to work.

@<Glob...@>=
uint8_t @!old_setting;

@ We will occasionally use |begin_diagnostic| in connection with line-number
printing, as follows. (The parameter |s| is typically |@[@<|"Path"|@>@]| or
|@[@<|"Cycle spec"|@>@]|, etc.)

@<Basic printing...@>=
void print_diagnostic(str_number @!s, str_number @!t, bool @!nuline)
{@+begin_diagnostic();
if (nuline) print_nl(""); print(s);
print_str(" at line ");print_int(line);
print(t);print_char(':');
} 

@ The 256 |ASCII_code| characters are grouped into classes by means of
the |char_class| table. Individual class numbers have no semantic
or syntactic significance, except in a few instances defined here.
There's also |max_class|, which can be used as a basis for additional
class numbers in nonstandard extensions of \MF.

@d digit_class	0 /*the class number of \.{0123456789}*/ 
@d period_class	1 /*the class number of `\..'*/ 
@d space_class	2 /*the class number of spaces and nonstandard characters*/ 
@d percent_class	3 /*the class number of `\.\%'*/ 
@d string_class	4 /*the class number of `\."'*/ 
@d right_paren_class	8 /*the class number of `\.)'*/ 
@d isolated_classes	case 5: case 6: case 7: case 8 /*characters that make length-one tokens only*/ 
@d letter_class	9 /*letters and the underline character*/ 
@d left_bracket_class	17 /*`\.['*/ 
@d right_bracket_class	18 /*`\.]'*/ 
@d invalid_class	20 /*bad character in the input*/ 
@d max_class	20 /*the largest class number*/ 

@<Glob...@>=
uint8_t @!char_class[256]; /*the class numbers*/ 

@ If changes are made to accommodate non-ASCII character sets, they should
follow the guidelines in Appendix~C of {\sl The {\logos METAFONT\/}book}.
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
@^system dependencies@>

@<Set init...@>=
for (k='0'; k<='9'; k++) char_class[k]=digit_class;
char_class['.']=period_class;
char_class[' ']=space_class;
char_class['%']=percent_class;
char_class['"']=string_class;@/
char_class[',']=5;
char_class[';']=6;
char_class['(']=7;
char_class[')']=right_paren_class;
for (k='A'; k<='Z'; k++) char_class[k]=letter_class;
for (k='a'; k<='z'; k++) char_class[k]=letter_class;
char_class['_']=letter_class;@/
char_class['<']=10;
char_class['=']=10;
char_class['>']=10;
char_class[':']=10;
char_class['|']=10;@/
char_class['`']=11;
char_class['\'']=11;@/
char_class['+']=12;
char_class['-']=12;@/
char_class['/']=13;
char_class['*']=13;
char_class['\\']=13;@/
char_class['!']=14;
char_class['?']=14;@/
char_class['#']=15;
char_class['&']=15;
char_class['@@']=15;
char_class['$']=15;@/
char_class['^']=16;
char_class['~']=16;@/
char_class['[']=left_bracket_class;
char_class[']']=right_bracket_class;@/
char_class['{']=19;
char_class['}']=19;@/
for (k=0; k<=' '-1; k++) char_class[k]=invalid_class;
for (k=127; k<=255; k++) char_class[k]=invalid_class;

@* The hash table.
Symbolic tokens are stored and retrieved by means of a fairly standard hash
table algorithm called the method of ``coalescing lists'' (cf.\ Algorithm 6.4C
in {\sl The Art of Computer Programming\/}). Once a symbolic token enters the
table, it is never removed.

The actual sequence of characters forming a symbolic token is
stored in the |str_pool| array together with all the other strings. An
auxiliary array |hash| consists of items with two halfword fields per
word. The first of these, called |next(p)|, points to the next identifier
belonging to the same coalesced list as the identifier corresponding to~|p|;
and the other, called |text(p)|, points to the |str_start| entry for
|p|'s identifier. If position~|p| of the hash table is empty, we have
|text(p)==0|; if position |p| is either empty or the end of a coalesced
hash list, we have |next(p)==0|.

An auxiliary pointer variable called |hash_used| is maintained in such a
way that all locations |p >= hash_used| are nonempty. The global variable
|st_count| tells how many symbolic tokens have been defined, if statistics
are being kept.

The first 256 locations of |hash| are reserved for symbols of length one.

There's a parallel array called |eqtb| that contains the current equivalent
values of each symbolic token. The entries of this array consist of
two halfwords called |eq_type| (a command code) and |equiv| (a secondary
piece of information that qualifies the |eq_type|).

@d next(X)	hash[X].lh /*link for coalesced lists*/ 
@d text(X)	hash[X].rh /*string number for symbolic token name*/ 
@d eq_type(X)	eqtb[X].lh /*the current ``meaning'' of a symbolic token*/ 
@d equiv(X)	eqtb[X].rh /*parametric part of a token's meaning*/ 
@d hash_base	257 /*hashing actually starts here*/ 
@d hash_is_full	(hash_used==hash_base) /*are all positions occupied?*/ 

@<Glob...@>=
pointer @!hash_used; /*allocation pointer for |hash|*/ 
int @!st_count; /*total number of known identifiers*/ 

@ Certain entries in the hash table are ``frozen'' and not redefinable,
since they are used in error recovery.

@d hash_top	hash_base+hash_size /*the first location of the frozen area*/ 
@d frozen_inaccessible	hash_top /*|hash| location to protect the frozen area*/ 
@d frozen_repeat_loop	hash_top+1 /*|hash| location of a loop-repeat token*/ 
@d frozen_right_delimiter	hash_top+2 /*|hash| location of a permanent `\.)'*/ 
@d frozen_left_bracket	hash_top+3 /*|hash| location of a permanent `\.['*/ 
@d frozen_slash	hash_top+4 /*|hash| location of a permanent `\./'*/ 
@d frozen_colon	hash_top+5 /*|hash| location of a permanent `\.:'*/ 
@d frozen_semicolon	hash_top+6 /*|hash| location of a permanent `\.;'*/ 
@d frozen_end_for	hash_top+7 /*|hash| location of a permanent \&{endfor}*/ 
@d frozen_end_def	hash_top+8 /*|hash| location of a permanent \&{enddef}*/ 
@d frozen_fi	hash_top+9 /*|hash| location of a permanent \&{fi}*/ 
@d frozen_end_group	hash_top+10
   /*|hash| location of a permanent `\.{endgroup}'*/ 
@d frozen_bad_vardef	hash_top+11 /*|hash| location of `\.{a bad variable}'*/ 
@d frozen_undefined	hash_top+12 /*|hash| location that never gets defined*/ 
@d hash_end	hash_top+12 /*the actual size of the |hash| and |eqtb| arrays*/ 

@<Glob...@>=
two_halves @!hash0[hash_base+hash_size+12], *const @!hash = @!hash0-1; /*the hash table*/ 
two_halves @!eqtb0[hash_base+hash_size+12], *const @!eqtb = @!eqtb0-1; /*the equivalents*/ 

@ @<Set init...@>=
next(1)=0;text(1)=0;eq_type(1)=tag_token;equiv(1)=null;
for (k=2; k<=hash_end; k++) 
  {@+hash[k]=hash[1];eqtb[k]=eqtb[1];
  } 

@ @<Initialize table entries...@>=
hash_used=frozen_inaccessible; /*nothing is used*/ 
st_count=0;@/
text(frozen_bad_vardef)=@[@<|"a bad variable"|@>@];
text(frozen_fi)=@[@<|"fi"|@>@];
text(frozen_end_group)=@[@<|"endgroup"|@>@];
text(frozen_end_def)=@[@<|"enddef"|@>@];
text(frozen_end_for)=@[@<|"endfor"|@>@];@/
text(frozen_semicolon)=';';
text(frozen_colon)=':';
text(frozen_slash)='/';
text(frozen_left_bracket)='[';
text(frozen_right_delimiter)=')';@/
text(frozen_inaccessible)=@[@<|" INACCESSIBLE"|@>@];@/
eq_type(frozen_right_delimiter)=right_delimiter;

@ @<Check the ``constant'' values...@>=
if (hash_end+max_internal > max_halfword) bad=21;

@ Here is the subroutine that searches the hash table for an identifier
that matches a given string of length~|l| appearing in |buffer[j dotdot
(j+l-1)]|. If the identifier is not found, it is inserted; hence it
will always be found, and the corresponding hash table address
will be returned.

@p pointer id_lookup(int @!j, int @!l) /*search the hash table*/ 
{@+ /*go here when you've found it*/ 
int @!h; /*hash code*/ 
pointer @!p; /*index in |hash| array*/ 
pointer @!k; /*index in |buffer| array*/ 
if (l==1) @<Treat special case of length 1 and |goto found|@>;
@<Compute the hash code |h|@>;
p=h+hash_base; /*we start searching here; note that |0 <= h < hash_prime|*/ 
loop@+{@+if (text(p) > 0) if (length(text(p))==l) 
    if (str_eq_buf(text(p), j)) goto found;
  if (next(p)==0) 
    @<Insert a new symbolic token after |p|, then make |p| point to it and |goto found|@>;
  p=next(p);
  } 
found: return p;
} 

@ @<Treat special case of length 1...@>=
{@+p=buffer[j]+1;text(p)=p-1;goto found;
} 

@ @<Insert a new symbolic...@>=
{@+if (text(p) > 0) 
  {@+@/do@+{if (hash_is_full) 
    overflow("hash size", hash_size);
@:METAFONT capacity exceeded hash size}{\quad hash size@>
  decr(hash_used);
  }@+ while (!(text(hash_used)==0)); /*search for an empty location in |hash|*/ 
  next(p)=hash_used;p=hash_used;
  } 
str_room(l);
for (k=j; k<=j+l-1; k++) append_char(buffer[k]);
text(p)=make_string();str_ref[text(p)]=max_str_ref;
#ifdef @!STAT
incr(st_count);
#endif
@;@/
goto found;
} 

@ The value of |hash_prime| should be roughly 85\pct! of |hash_size|, and it
should be a prime number.  The theory of hashing tells us to expect fewer
than two table probes, on the average, when the search is successful.
[See J.~S. Vitter, {\sl Journal of the ACM\/ \bf30} (1983), 231--258.]
@^Vitter, Jeffrey Scott@>

@<Compute the hash code |h|@>=
h=buffer[j];
for (k=j+1; k<=j+l-1; k++) 
  {@+h=h+h+buffer[k];
  while (h >= hash_prime) h=h-hash_prime;
  } 

@ @<Search |eqtb| for equivalents equal to |p|@>=
for (q=1; q<=hash_end; q++) 
  {@+if (equiv(q)==p) 
    {@+print_nl("EQUIV(");print_int(q);print_char(')');
    } 
  } 

@ We need to put \MF's ``primitive'' symbolic tokens into the hash
table, together with their command code (which will be the |eq_type|)
and an operand (which will be the |equiv|). The |primitive| procedure
does this, in a way that no \MF\ user can. The global value |cur_sym|
contains the new |eqtb| pointer after |primitive| has acted.

@p
#ifdef @!INIT
void primitive(str_number @!s, halfword @!c, halfword @!o)
{@+pool_pointer @!k; /*index into |str_pool|*/ 
int @!j; /*index into |buffer|*/ 
small_number @!l; /*length of the string*/ 
k=str_start[s];l=str_start[s+1]-k;
   /*we will move |s| into the (empty) |buffer|*/ 
for (j=0; j<=l-1; j++) buffer[j]=so(str_pool[k+j]);
cur_sym=id_lookup(0, l);@/
if (s >= 256)  /*we don't want to have the string twice*/ 
  {@+flush_string(str_ptr-1);text(cur_sym)=s;
  } 
eq_type(cur_sym)=c;equiv(cur_sym)=o;
} 
#endif

@ Many of \MF's primitives need no |equiv|, since they are identifiable
by their |eq_type| alone. These primitives are loaded into the hash table
as follows:

@<Put each of \MF's primitives into the hash table@>=
primitive(@[@<|".."|@>@], path_join, 0);@/
@!@:.._}{\.{..} primitive@>
primitive('[', left_bracket, 0);eqtb[frozen_left_bracket]=eqtb[cur_sym];@/
@!@:[ }{\.{[} primitive@>
primitive(']', right_bracket, 0);@/
@!@:] }{\.{]} primitive@>
primitive('}', right_brace, 0);@/
@!@:]]}{\.{\char`\}} primitive@>
primitive('{', left_brace, 0);@/
@!@:][}{\.{\char`\{} primitive@>
primitive(':', colon, 0);eqtb[frozen_colon]=eqtb[cur_sym];@/
@!@:: }{\.{:} primitive@>
primitive(@[@<|"::"|@>@], double_colon, 0);@/
@!@::: }{\.{::} primitive@>
primitive(@[@<|"||:"|@>@], bchar_label, 0);@/
@!@:::: }{\.{\char'174\char'174:} primitive@>
primitive(@[@<|":="|@>@], assignment, 0);@/
@!@::=_}{\.{:=} primitive@>
primitive(',', comma, 0);@/
@!@:, }{\., primitive@>
primitive(';', semicolon, 0);eqtb[frozen_semicolon]=eqtb[cur_sym];@/
@!@:; }{\.; primitive@>
primitive('\\', relax, 0);@/
@!@:]]\\}{\.{\char`\\} primitive@>
@#
primitive(@[@<|"addto"|@>@], add_to_command, 0);@/
@!@:add_to_}{\&{addto} primitive@>
primitive(@[@<|"at"|@>@], at_token, 0);@/
@!@:at_}{\&{at} primitive@>
primitive(@[@<|"atleast"|@>@], at_least, 0);@/
@!@:at_least_}{\&{atleast} primitive@>
primitive(@[@<|"begingroup"|@>@], begin_group, 0);bg_loc=cur_sym;@/
@!@:begin_group_}{\&{begingroup} primitive@>
primitive(@[@<|"controls"|@>@], controls, 0);@/
@!@:controls_}{\&{controls} primitive@>
primitive(@[@<|"cull"|@>@], cull_command, 0);@/
@!@:cull_}{\&{cull} primitive@>
primitive(@[@<|"curl"|@>@], curl_command, 0);@/
@!@:curl_}{\&{curl} primitive@>
primitive(@[@<|"delimiters"|@>@], delimiters, 0);@/
@!@:delimiters_}{\&{delimiters} primitive@>
primitive(@[@<|"display"|@>@], display_command, 0);@/
@!@:display_}{\&{display} primitive@>
primitive(@[@<|"endgroup"|@>@], end_group, 0);
 eqtb[frozen_end_group]=eqtb[cur_sym];eg_loc=cur_sym;@/
@!@:endgroup_}{\&{endgroup} primitive@>
primitive(@[@<|"everyjob"|@>@], every_job_command, 0);@/
@!@:every_job_}{\&{everyjob} primitive@>
primitive(@[@<|"exitif"|@>@], exit_test, 0);@/
@!@:exit_if_}{\&{exitif} primitive@>
primitive(@[@<|"expandafter"|@>@], expand_after, 0);@/
@!@:expand_after_}{\&{expandafter} primitive@>
primitive(@[@<|"from"|@>@], from_token, 0);@/
@!@:from_}{\&{from} primitive@>
primitive(@[@<|"inwindow"|@>@], in_window, 0);@/
@!@:in_window_}{\&{inwindow} primitive@>
primitive(@[@<|"interim"|@>@], interim_command, 0);@/
@!@:interim_}{\&{interim} primitive@>
primitive(@[@<|"let"|@>@], let_command, 0);@/
@!@:let_}{\&{let} primitive@>
primitive(@[@<|"newinternal"|@>@], new_internal, 0);@/
@!@:new_internal_}{\&{newinternal} primitive@>
primitive(@[@<|"of"|@>@], of_token, 0);@/
@!@:of_}{\&{of} primitive@>
primitive(@[@<|"openwindow"|@>@], open_window, 0);@/
@!@:open_window_}{\&{openwindow} primitive@>
primitive(@[@<|"randomseed"|@>@], random_seed, 0);@/
@!@:random_seed_}{\&{randomseed} primitive@>
primitive(@[@<|"save"|@>@], save_command, 0);@/
@!@:save_}{\&{save} primitive@>
primitive(@[@<|"scantokens"|@>@], scan_tokens, 0);@/
@!@:scan_tokens_}{\&{scantokens} primitive@>
primitive(@[@<|"shipout"|@>@], ship_out_command, 0);@/
@!@:ship_out_}{\&{shipout} primitive@>
primitive(@[@<|"skipto"|@>@], skip_to, 0);@/
@!@:skip_to_}{\&{skipto} primitive@>
primitive(@[@<|"step"|@>@], step_token, 0);@/
@!@:step_}{\&{step} primitive@>
primitive(@[@<|"str"|@>@], str_op, 0);@/
@!@:str_}{\&{str} primitive@>
primitive(@[@<|"tension"|@>@], tension, 0);@/
@!@:tension_}{\&{tension} primitive@>
primitive(@[@<|"to"|@>@], to_token, 0);@/
@!@:to_}{\&{to} primitive@>
primitive(@[@<|"until"|@>@], until_token, 0);@/
@!@:until_}{\&{until} primitive@>

@ Each primitive has a corresponding inverse, so that it is possible to
display the cryptic numeric contents of |eqtb| in symbolic form.
Every call of |primitive| in this program is therefore accompanied by some
straightforward code that forms part of the |print_cmd_mod| routine
explained below.

@<Cases of |print_cmd_mod| for symbolic printing of primitives@>=
case add_to_command: print_str("addto");@+break;
case assignment: print_str(":=");@+break;
case at_least: print_str("atleast");@+break;
case at_token: print_str("at");@+break;
case bchar_label: print_str("||:");@+break;
case begin_group: print_str("begingroup");@+break;
case colon: print_str(":");@+break;
case comma: print_str(",");@+break;
case controls: print_str("controls");@+break;
case cull_command: print_str("cull");@+break;
case curl_command: print_str("curl");@+break;
case delimiters: print_str("delimiters");@+break;
case display_command: print_str("display");@+break;
case double_colon: print_str("::");@+break;
case end_group: print_str("endgroup");@+break;
case every_job_command: print_str("everyjob");@+break;
case exit_test: print_str("exitif");@+break;
case expand_after: print_str("expandafter");@+break;
case from_token: print_str("from");@+break;
case in_window: print_str("inwindow");@+break;
case interim_command: print_str("interim");@+break;
case left_brace: print_str("{");@+break;
case left_bracket: print_str("[");@+break;
case let_command: print_str("let");@+break;
case new_internal: print_str("newinternal");@+break;
case of_token: print_str("of");@+break;
case open_window: print_str("openwindow");@+break;
case path_join: print_str("..");@+break;
case random_seed: print_str("randomseed");@+break;
case relax: print_char('\\');@+break;
case right_brace: print_str("}");@+break;
case right_bracket: print_str("]");@+break;
case save_command: print_str("save");@+break;
case scan_tokens: print_str("scantokens");@+break;
case semicolon: print_str(";");@+break;
case ship_out_command: print_str("shipout");@+break;
case skip_to: print_str("skipto");@+break;
case step_token: print_str("step");@+break;
case str_op: print_str("str");@+break;
case tension: print_str("tension");@+break;
case to_token: print_str("to");@+break;
case until_token: print_str("until");@+break;

@ We will deal with the other primitives later, at some point in the program
where their |eq_type| and |equiv| values are more meaningful.  For example,
the primitives for macro definitions will be loaded when we consider the
routines that define macros.
It is easy to find where each particular
primitive was treated by looking in the index at the end; for example, the
section where |@[@<|"def"|@>@]| entered |eqtb| is listed under `\&{def} primitive'.

@* Token lists.
A \MF\ token is either symbolic or numeric or a string, or it denotes
a macro parameter or capsule; so there are five corresponding ways to encode it
@^token@>
internally: (1)~A symbolic token whose hash code is~|p|
is represented by the number |p|, in the |info| field of a single-word
node in~|mem|. (2)~A numeric token whose |scaled| value is~|v| is
represented in a two-word node of~|mem|; the |type| field is |known|,
the |name_type| field is |token|, and the |value| field holds~|v|.
The fact that this token appears in a two-word node rather than a
one-word node is, of course, clear from the node address.
(3)~A string token is also represented in a two-word node; the |type|
field is |string_type|, the |name_type| field is |token|, and the
|value| field holds the corresponding |str_number|.  (4)~Capsules have
|name_type==capsule|, and their |type| and |value| fields represent
arbitrary values (in ways to be explained later).  (5)~Macro parameters
are like symbolic tokens in that they appear in |info| fields of
one-word nodes. The $k$th parameter is represented by |expr_base+k| if it
is of type \&{expr}, or by |suffix_base+k| if it is of type \&{suffix}, or
by |text_base+k| if it is of type \&{text}.  (Here |0 <= k < param_size|.)
Actual values of these parameters are kept in a separate stack, as we will
see later.  The constants |expr_base|, |suffix_base|, and |text_base| are,
of course, chosen so that there will be no confusion between symbolic
tokens and parameters of various types.

It turns out that |value(null)==0|, because |null==null_coords|;
we will make use of this coincidence later.

Incidentally, while we're speaking of coincidences, we might note that
the `\\{type}' field of a node has nothing to do with ``type'' in a
printer's sense. It's curious that the same word is used in such different ways.

@d type(X)	mem[X].hh.b0 /*identifies what kind of value this is*/ 
@d name_type(X)	mem[X].hh.b1 /*a clue to the name of this value*/ 
@d token_node_size	2 /*the number of words in a large token node*/ 
@d value_loc(X)	X+1 /*the word that contains the |value| field*/ 
@d value(X)	mem[value_loc(X)].i /*the value stored in a large token node*/ 
@d expr_base	hash_end+1 /*code for the zeroth \&{expr} parameter*/ 
@d suffix_base	expr_base+param_size /*code for the zeroth \&{suffix} parameter*/ 
@d text_base	suffix_base+param_size /*code for the zeroth \&{text} parameter*/ 

@<Check the ``constant''...@>=
if (text_base+param_size > max_halfword) bad=22;

@ A numeric token is created by the following trivial routine.

@p pointer new_num_tok(scaled @!v)
{@+pointer @!p; /*the new node*/ 
p=get_node(token_node_size);value(p)=v;
type(p)=known;name_type(p)=token;return p;
} 

@ A token list is a singly linked list of nodes in |mem|, where
each node contains a token and a link.  Here's a subroutine that gets rid
of a token list when it is no longer needed.

@p void token_recycle(void);@;@/
void flush_token_list(pointer @!p)
{@+pointer @!q; /*the node being recycled*/ 
while (p!=null) 
  {@+q=p;p=link(p);
  if (q >= hi_mem_min) free_avail(q)@;
  else{@+switch (type(q)) {
    case vacuous: case boolean_type: case known: do_nothing;@+break;
    case string_type: delete_str_ref(value(q))@;@+break;
    unknown_types: case pen_type: case path_type: case future_pen: case picture_type: 
     case pair_type: case transform_type: case dependent: case proto_dependent: case independent: 
      {@+g_pointer=q;token_recycle();
      } @+break;
    default:confusion(@[@<|"token"|@>@]);
@:this can't happen token}{\quad token@>
    } @/
    free_node(q, token_node_size);
    } 
  } 
} 

@ The procedure |show_token_list|, which prints a symbolic form of
the token list that starts at a given node |p|, illustrates these
conventions. The token list being displayed should not begin with a reference
count. However, the procedure is intended to be fairly robust, so that if the
memory links are awry or if |p| is not really a pointer to a token list,
almost nothing catastrophic can happen.

An additional parameter |q| is also given; this parameter is either null
or it points to a node in the token list where a certain magic computation
takes place that will be explained later. (Basically, |q| is non-null when
we are printing the two-line context information at the time of an error
message; |q| marks the place corresponding to where the second line
should begin.)

The generation will stop, and `\.{\char`\ ETC.}' will be printed, if the length
of printing exceeds a given limit~|l|; the length of printing upon entry is
assumed to be a given amount called |null_tally|. (Note that
|show_token_list| sometimes uses itself recursively to print
variable names within a capsule.)
@^recursion@>

Unusual entries are printed in the form of all-caps tokens
preceded by a space, e.g., `\.{\char`\ BAD}'.

@<Declare the procedure called |show_token_list|@>=
void print_capsule(void);@;@/
void show_token_list(int @!p, int @!q, int @!l, int @!null_tally)
{@+
small_number @!class, @!c; /*the |char_class| of previous and new tokens*/ 
int @!r, @!v; /*temporary registers*/ 
class=percent_class;
tally=null_tally;
while ((p!=null)&&(tally < l)) 
  {@+if (p==q) @<Do magic computation@>;
  @<Display token |p| and set |c| to its class; but |return| if there are problems@>;
  class=c;p=link(p);
  } 
if (p!=null) print_str(" ETC.");
@.ETC@>

} 

@ @<Display token |p| and set |c| to its class...@>=
c=letter_class; /*the default*/ 
if ((p < mem_min)||(p > mem_end)) 
  {@+print_str(" CLOBBERED");return;
@.CLOBBERED@>
  } 
if (p < hi_mem_min) @<Display two-word token@>@;
else{@+r=info(p);
  if (r >= expr_base) @<Display a parameter token@>@;
  else if (r < 1) 
    if (r==0) @<Display a collective subscript@>@;
    else print_str(" IMPOSSIBLE");
@.IMPOSSIBLE@>
  else{@+r=text(r);
    if ((r < 0)||(r >= str_ptr)) print_str(" NONEXISTENT");
@.NONEXISTENT@>
    else@<Print string |r| as a symbolic token and set |c| to its class@>;
    } 
  } 

@ @<Display two-word token@>=
if (name_type(p)==token) 
  if (type(p)==known) @<Display a numeric token@>@;
  else if (type(p)!=string_type) print_str(" BAD");
@.BAD@>
  else{@+print_char('"');slow_print(value(p));print_char('"');
    c=string_class;
    } 
else if ((name_type(p)!=capsule)||(type(p) < vacuous)||(type(p) > independent)) 
  print_str(" BAD");
else{@+g_pointer=p;print_capsule();c=right_paren_class;
  } 

@ @<Display a numeric token@>=
{@+if (class==digit_class) print_char(' ');
v=value(p);
if (v < 0) 
  {@+if (class==left_bracket_class) print_char(' ');
  print_char('[');print_scaled(v);print_char(']');
  c=right_bracket_class;
  } 
else{@+print_scaled(v);c=digit_class;
  } 
} 

@ Strictly speaking, a genuine token will never have |info(p)==0|.
But we will see later (in the |print_variable_name| routine) that
it is convenient to let |info(p)==0| stand for `\.{[]}'.

@<Display a collective subscript@>=
{@+if (class==left_bracket_class) print_char(' ');
print_str("[]");c=right_bracket_class;
} 

@ @<Display a parameter token@>=
{@+if (r < suffix_base) 
  {@+print_str("(EXPR");r=r-(expr_base);
@.EXPR@>
  } 
else if (r < text_base) 
  {@+print_str("(SUFFIX");r=r-(suffix_base);
@.SUFFIX@>
  } 
else{@+print_str("(TEXT");r=r-(text_base);
@.TEXT@>
  } 
print_int(r);print_char(')');c=right_paren_class;
} 

@ @<Print string |r| as a symbolic token...@>=
{@+c=char_class[so(str_pool[str_start[r]])];
if (c==class) 
  switch (c) {
  case letter_class: print_char('.');@+break;
  isolated_classes: do_nothing;@+break;
  default:print_char(' ');
  } 
slow_print(r);
} 

@ The following procedures have been declared |forward| with no parameters,
because the author dislikes \PASCAL's convention about |forward| procedures
with parameters. It was necessary to do something, because |show_token_list|
is recursive (although the recursion is limited to one level), and because
|flush_token_list| is syntactically (but not semantically) recursive.
@^recursion@>

@<Declare miscellaneous procedures that were declared |forward|@>=
void print_capsule(void)
{@+print_char('(');print_exp(g_pointer, 0);print_char(')');
} 
@#
void token_recycle(void)
{@+recycle_value(g_pointer);
} 

@ @<Glob...@>=
pointer @!g_pointer; /*(global) parameter to the |forward| procedures*/ 

@ Macro definitions are kept in \MF's memory in the form of token lists
that have a few extra one-word nodes at the beginning.

The first node contains a reference count that is used to tell when the
list is no longer needed. To emphasize the fact that a reference count is
present, we shall refer to the |info| field of this special node as the
|ref_count| field.
@^reference counts@>

The next node or nodes after the reference count serve to describe the
formal parameters. They consist of zero or more parameter tokens followed
by a code for the type of macro.

@d ref_count	info /*reference count preceding a macro definition or pen header*/ 
@d add_mac_ref(X)	incr(ref_count(X)) /*make a new reference to a macro list*/ 
@d general_macro	0 /*preface to a macro defined with a parameter list*/ 
@d primary_macro	1 /*preface to a macro with a \&{primary} parameter*/ 
@d secondary_macro	2 /*preface to a macro with a \&{secondary} parameter*/ 
@d tertiary_macro	3 /*preface to a macro with a \&{tertiary} parameter*/ 
@d expr_macro	4 /*preface to a macro with an undelimited \&{expr} parameter*/ 
@d of_macro	5 /*preface to a macro with
  undelimited `\&{expr} |x| \&{of}~|y|' parameters*/ 
@d suffix_macro	6 /*preface to a macro with an undelimited \&{suffix} parameter*/ 
@d text_macro	7 /*preface to a macro with an undelimited \&{text} parameter*/ 

@p void delete_mac_ref(pointer @!p)
   /*|p| points to the reference count of a macro list that is
    losing one reference*/ 
{@+if (ref_count(p)==null) flush_token_list(p);
else decr(ref_count(p));
} 

@ The following subroutine displays a macro, given a pointer to its
reference count.

@p@t\4@>@<Declare the procedure called |print_cmd_mod|@>@;
void show_macro(pointer @!p, int @!q, int @!l)
{@+
pointer @!r; /*temporary storage*/ 
p=link(p); /*bypass the reference count*/ 
while (info(p) > text_macro) 
  {@+r=link(p);link(p)=null;
  show_token_list(p, null, l, 0);link(p)=r;p=r;
  if (l > 0) l=l-tally;@+else return;
  }  /*control printing of `\.{ETC.}'*/ 
@.ETC@>
tally=0;
switch (info(p)) {
case general_macro: print_str("->");@+break;
@.->@>
case primary_macro: case secondary_macro: case tertiary_macro: {@+print_char('<');
  print_cmd_mod(param_type, info(p));print_str(">->");
  } @+break;
case expr_macro: print_str("<expr>->");@+break;
case of_macro: print_str("<expr>of<primary>->");@+break;
case suffix_macro: print_str("<suffix>->");@+break;
case text_macro: print_str("<text>->");
}  /*there are no other cases*/ 
show_token_list(link(p), q, l-tally, 0);
} 

@* Data structures for variables.
The variables of \MF\ programs can be simple, like `\.x', or they can
combine the structural properties of arrays and records, like `\.{x20a.b}'.
A \MF\ user assigns a type to a variable like \.{x20a.b} by saying, for
example, `\.{boolean} \.{x[]a.b}'. It's time for us to study how such
things are represented inside of the computer.

Each variable value occupies two consecutive words, either in a two-word
node called a value node, or as a two-word subfield of a larger node.  One
of those two words is called the |value| field; it is an integer,
containing either a |scaled| numeric value or the representation of some
other type of quantity. (It might also be subdivided into halfwords, in
which case it is referred to by other names instead of |value|.) The other
word is broken into subfields called |type|, |name_type|, and |link|.  The
|type| field is a quarterword that specifies the variable's type, and
|name_type| is a quarterword from which \MF\ can reconstruct the
variable's name (sometimes by using the |link| field as well).  Thus, only
1.25 words are actually devoted to the value itself; the other
three-quarters of a word are overhead, but they aren't wasted because they
allow \MF\ to deal with sparse arrays and to provide meaningful diagnostics.

In this section we shall be concerned only with the structural aspects of
variables, not their values. Later parts of the program will change the
|type| and |value| fields, but we shall treat those fields as black boxes
whose contents should not be touched.

However, if the |type| field is |structured|, there is no |value| field,
and the second word is broken into two pointer fields called |attr_head|
and |subscr_head|. Those fields point to additional nodes that
contain structural information, as we shall see.

@d subscr_head_loc(X)	X+1 /*where |value|, |subscr_head|, and |attr_head| are*/ 
@d attr_head(X)	info(subscr_head_loc(X)) /*pointer to attribute info*/ 
@d subscr_head(X)	link(subscr_head_loc(X)) /*pointer to subscript info*/ 
@d value_node_size	2 /*the number of words in a value node*/ 

@ An attribute node is three words long. Two of these words contain |type|
and |value| fields as described above, and the third word contains
additional information:  There is an |attr_loc| field, which contains the
hash address of the token that names this attribute; and there's also a
|parent| field, which points to the value node of |structured| type at the
next higher level (i.e., at the level to which this attribute is
subsidiary).  The |name_type| in an attribute node is `|attr|'.  The
|link| field points to the next attribute with the same parent; these are
arranged in increasing order, so that |attr_loc(link(p)) > attr_loc(p)|. The
final attribute node links to the constant |end_attr|, whose |attr_loc|
field is greater than any legal hash address. The |attr_head| in the
parent points to a node whose |name_type| is |structured_root|; this
node represents the null attribute, i.e., the variable that is relevant
when no attributes are attached to the parent. The |attr_head| node
has the fields of either
a value node, a subscript node, or an attribute node, depending on what
the parent would be if it were not structured; but the subscript and
attribute fields are ignored, so it effectively contains only the data of
a value node. The |link| field in this special node points to an attribute
node whose |attr_loc| field is zero; the latter node represents a collective
subscript `\.{[]}' attached to the parent, and its |link| field points to
the first non-special attribute node (or to |end_attr| if there are none).

A subscript node likewise occupies three words, with |type| and |value| fields
plus extra information; its |name_type| is |subscr|. In this case the
third word is called the |subscript| field, which is a |scaled| integer.
The |link| field points to the subscript node with the next larger
subscript, if any; otherwise the |link| points to the attribute node
for collective subscripts at this level. We have seen that the latter node
contains an upward pointer, so that the parent can be deduced.

The |name_type| in a parent-less value node is |root|, and the |link|
is the hash address of the token that names this value.

In other words, variables have a hierarchical structure that includes
enough threads running around so that the program is able to move easily
between siblings, parents, and children. An example should be helpful:
(The reader is advised to draw a picture while reading the following
description, since that will help to firm up the ideas.)
Suppose that `\.x' and `\.{x.a}' and `\.{x[]b}' and `\.{x5}'
and `\.{x20b}' have been mentioned in a user's program, where
\.{x[]b} has been declared to be of \&{boolean} type. Let |h(x)|, |h(a)|,
and |h(b)| be the hash addresses of \.x, \.a, and~\.b. Then
|eq_type(h(x))==tag_token| and |equiv(h(x))==p|, where |p|~is a two-word value
node with |name_type(p)==root| and |link(p)==h(x)|. We have |type(p)==structured|,
|attr_head(p)==q|, and |subscr_head(p)==r|, where |q| points to a value
node and |r| to a subscript node. (Are you still following this? Use
a pencil to draw a diagram.) The lone variable `\.x' is represented by
|type(q)| and |value(q)|; furthermore
|name_type(q)==structured_root| and |link(q)==q1|, where |q1| points
to an attribute node representing `\.{x[]}'. Thus |name_type(q1)==attr|,
|attr_loc(q1)==collective_subscript==0|, |parent(q1)==p|,
|type(q1)==structured|, |attr_head(q1)==qq|, and |subscr_head(q1)==qq1|;
|qq| is a three-word ``attribute-as-value'' node with |type(qq)==numeric_type|
(assuming that \.{x5} is numeric, because |qq| represents `\.{x[]}'
with no further attributes), |name_type(qq)==structured_root|,
|attr_loc(qq)==0|, |parent(qq)==p|, and
|link(qq)==qq1|. (Now pay attention to the next part.) Node |qq1| is
an attribute node representing `\.{x[][]}', which has never yet
occurred; its |type| field is |undefined|, and its |value| field is
undefined. We have |name_type(qq1)==attr|, |attr_loc(qq1)==collective_subscript|,
|parent(qq1)==q1|, and |link(qq1)==qq2|. Since |qq2| represents
`\.{x[]b}', |type(qq2)==unknown_boolean|; also |attr_loc(qq2)==h(b)|,
|parent(qq2)==q1|, |name_type(qq2)==attr|, |link(qq2)==end_attr|.
(Maybe colored lines will help untangle your picture.)
 Node |r| is a subscript node with |type| and |value|
representing `\.{x5}'; |name_type(r)==subscr|, |subscript(r)==5.0|,
and |link(r)==r1| is another subscript node. To complete the picture,
see if you can guess what |link(r1)| is; give up? It's~|q1|.
Furthermore |subscript(r1)==20.0|, |name_type(r1)==subscr|,
|type(r1)==structured|, |attr_head(r1)==qqq|, |subscr_head(r1)==qqq1|,
and we finish things off with three more nodes
|qqq|, |qqq1|, and |qqq2| hung onto~|r1|. (Perhaps you should start again
with a larger sheet of paper.) The value of variable `\.{x20b}'
appears in node~|qqq2==link(qqq1)|, as you can well imagine.
Similarly, the value of `\.{x.a}' appears in node |q2==link(q1)|, where
|attr_loc(q2)==h(a)| and |parent(q2)==p|.

If the example in the previous paragraph doesn't make things crystal
clear, a glance at some of the simpler subroutines below will reveal how
things work out in practice.

The only really unusual thing about these conventions is the use of
collective subscript attributes. The idea is to avoid repeating a lot of
type information when many elements of an array are identical macros
(for which distinct values need not be stored) or when they don't have
all of the possible attributes. Branches of the structure below collective
subscript attributes do not carry actual values except for macro identifiers;
branches of the structure below subscript nodes do not carry significant
information in their collective subscript attributes.

@d attr_loc_loc(X)	X+2 /*where the |attr_loc| and |parent| fields are*/ 
@d attr_loc(X)	info(attr_loc_loc(X)) /*hash address of this attribute*/ 
@d parent(X)	link(attr_loc_loc(X)) /*pointer to |structured| variable*/ 
@d subscript_loc(X)	X+2 /*where the |subscript| field lives*/ 
@d subscript(X)	mem[subscript_loc(X)].sc /*subscript of this variable*/ 
@d attr_node_size	3 /*the number of words in an attribute node*/ 
@d subscr_node_size	3 /*the number of words in a subscript node*/ 
@d collective_subscript	0 /*code for the attribute `\.{[]}'*/ 

@<Initialize table...@>=
attr_loc(end_attr)=hash_end+1;parent(end_attr)=null;

@ Variables of type \&{pair} will have values that point to four-word
nodes containing two numeric values. The first of these values has
|name_type==x_part_sector| and the second has |name_type==y_part_sector|;
the |link| in the first points back to the node whose |value| points
to this four-word node.

Variables of type \&{transform} are similar, but in this case their
|value| points to a 12-word node containing six values, identified by
|x_part_sector|, |y_part_sector|, |xx_part_sector|, |xy_part_sector|,
|yx_part_sector|, and |yy_part_sector|.

When an entire structured variable is saved, the |root| indication
is temporarily replaced by |saved_root|.

Some variables have no name; they just are used for temporary storage
while expressions are being evaluated. We call them {\sl capsules}.

@d x_part_loc(X)	X /*where the \&{xpart} is found in a pair or transform node*/ 
@d y_part_loc(X)	X+2 /*where the \&{ypart} is found in a pair or transform node*/ 
@d xx_part_loc(X)	X+4 /*where the \&{xxpart} is found in a transform node*/ 
@d xy_part_loc(X)	X+6 /*where the \&{xypart} is found in a transform node*/ 
@d yx_part_loc(X)	X+8 /*where the \&{yxpart} is found in a transform node*/ 
@d yy_part_loc(X)	X+10 /*where the \&{yypart} is found in a transform node*/ 
@#
@d pair_node_size	4 /*the number of words in a pair node*/ 
@d transform_node_size	12 /*the number of words in a transform node*/ 

@<Glob...@>=
small_number @!big_node_size0[pair_type-transform_type+1], *const @!big_node_size = @!big_node_size0-transform_type;

@ The |big_node_size| array simply contains two constants that \MF\
occasionally needs to know.

@<Set init...@>=
big_node_size[transform_type]=transform_node_size;
big_node_size[pair_type]=pair_node_size;

@ If |type(p)==pair_type| or |transform_type| and if |value(p)==null|, the
procedure call |init_big_node(p)| will allocate a pair or transform node
for~|p|.  The individual parts of such nodes are initially of type
|independent|.

@p void init_big_node(pointer @!p)
{@+pointer @!q; /*the new node*/ 
small_number @!s; /*its size*/ 
s=big_node_size[type(p)];q=get_node(s);
@/do@+{s=s-2;@<Make variable |q+s| newly independent@>;
name_type(q+s)=half(s)+x_part_sector;link(q+s)=null;
}@+ while (!(s==0));
link(q)=p;value(p)=q;
} 

@ The |id_transform| function creates a capsule for the
identity transformation.

@p pointer id_transform(void)
{@+pointer @!p, @!q, @!r; /*list manipulation registers*/ 
p=get_node(value_node_size);type(p)=transform_type;
name_type(p)=capsule;value(p)=null;init_big_node(p);q=value(p);
r=q+transform_node_size;
@/do@+{r=r-2;
type(r)=known;value(r)=0;
}@+ while (!(r==q));
value(xx_part_loc(q))=unity;value(yy_part_loc(q))=unity;
return p;
} 

@ Tokens are of type |tag_token| when they first appear, but they point
to |null| until they are first used as the root of a variable.
The following subroutine establishes the root node on such grand occasions.

@p void new_root(pointer @!x)
{@+pointer @!p; /*the new node*/ 
p=get_node(value_node_size);type(p)=undefined;name_type(p)=root;
link(p)=x;equiv(x)=p;
} 

@ These conventions for variable representation are illustrated by the
|print_variable_name| routine, which displays the full name of a
variable given only a pointer to its two-word value packet.

@p void print_variable_name(pointer @!p)
{@+
pointer @!q; /*a token list that will name the variable's suffix*/ 
pointer @!r; /*temporary for token list creation*/ 
while (name_type(p) >= x_part_sector) 
  @<Preface the output with a part specifier; |return| in the case of a capsule@>;
q=null;
while (name_type(p) > saved_root) 
  @<Ascend one level, pushing a token onto list |q| and replacing |p| by its parent@>;
r=get_avail();info(r)=link(p);link(r)=q;
if (name_type(p)==saved_root) print_str("(SAVED)");
@.SAVED@>
show_token_list(r, null, el_gordo, tally);flush_token_list(r);
} 

@ @<Ascend one level, pushing a token onto list |q|...@>=
{@+if (name_type(p)==subscr) 
  {@+r=new_num_tok(subscript(p));
  @/do@+{p=link(p);
  }@+ while (!(name_type(p)==attr));
  } 
else if (name_type(p)==structured_root) 
    {@+p=link(p);goto found;
    } 
else{@+if (name_type(p)!=attr) confusion(@[@<|"var"|@>@]);
@:this can't happen var}{\quad var@>
  r=get_avail();info(r)=attr_loc(p);
  } 
link(r)=q;q=r;
found: p=parent(p);
} 

@ @<Preface the output with a part specifier...@>=
{@+switch (name_type(p)) {
case x_part_sector: print_char('x');@+break;
case y_part_sector: print_char('y');@+break;
case xx_part_sector: print_str("xx");@+break;
case xy_part_sector: print_str("xy");@+break;
case yx_part_sector: print_str("yx");@+break;
case yy_part_sector: print_str("yy");@+break;
case capsule: {@+print_str("%CAPSULE");print_int(p-null);return;
@.CAPSULE@>
  } 
}  /*there are no other cases*/ 
print_str("part ");p=link(p-2*(name_type(p)-x_part_sector));
} 

@ The |interesting| function returns |true| if a given variable is not
in a capsule, or if the user wants to trace capsules.

@p bool interesting(pointer @!p)
{@+small_number @!t; /*a |name_type|*/ 
if (internal[tracing_capsules] > 0) return true;
else{@+t=name_type(p);
  if (t >= x_part_sector) if (t!=capsule) 
    t=name_type(link(p-2*(t-x_part_sector)));
  return(t!=capsule);
  } 
} 

@ Now here is a subroutine that converts an unstructured type into an
equivalent structured type, by inserting a |structured| node that is
capable of growing. This operation is done only when |name_type(p)==root|,
|subscr|, or |attr|.

The procedure returns a pointer to the new node that has taken node~|p|'s
place in the structure. Node~|p| itself does not move, nor are its
|value| or |type| fields changed in any way.

@p pointer new_structure(pointer @!p)
{@+pointer @!q, @!r; /*list manipulation registers*/ 
switch (name_type(p)) {
case root: {@+q=link(p);r=get_node(value_node_size);equiv(q)=r;
  } @+break;
case subscr: @<Link a new subscript node |r| in place of node |p|@>@;@+break;
case attr: @<Link a new attribute node |r| in place of node |p|@>@;@+break;
default:confusion(@[@<|"struct"|@>@]);
@:this can't happen struct}{\quad struct@>
} @/
link(r)=link(p);type(r)=structured;name_type(r)=name_type(p);
attr_head(r)=p;name_type(p)=structured_root;@/
q=get_node(attr_node_size);link(p)=q;subscr_head(r)=q;
parent(q)=r;type(q)=undefined;name_type(q)=attr;link(q)=end_attr;
attr_loc(q)=collective_subscript;return r;
} 

@ @<Link a new subscript node |r| in place of node |p|@>=
{@+q=p;
@/do@+{q=link(q);
}@+ while (!(name_type(q)==attr));
q=parent(q);r=subscr_head_loc(q); /*|link(r)==subscr_head(q)|*/ 
@/do@+{q=r;r=link(r);
}@+ while (!(r==p));
r=get_node(subscr_node_size);
link(q)=r;subscript(r)=subscript(p);
} 

@ If the attribute is |collective_subscript|, there are two pointers to
node~|p|, so we must change both of them.

@<Link a new attribute node |r| in place of node |p|@>=
{@+q=parent(p);r=attr_head(q);
@/do@+{q=r;r=link(r);
}@+ while (!(r==p));
r=get_node(attr_node_size);link(q)=r;@/
mem[attr_loc_loc(r)]=mem[attr_loc_loc(p)]; /*copy |attr_loc| and |parent|*/ 
if (attr_loc(p)==collective_subscript) 
  {@+q=subscr_head_loc(parent(p));
  while (link(q)!=p) q=link(q);
  link(q)=r;
  } 
} 

@ The |find_variable| routine is given a pointer~|t| to a nonempty token
list of suffixes; it returns a pointer to the corresponding two-word
value. For example, if |t| points to token \.x followed by a numeric
token containing the value~7, |find_variable| finds where the value of
\.{x7} is stored in memory. This may seem a simple task, and it
usually is, except when \.{x7} has never been referenced before.
Indeed, \.x may never have even been subscripted before; complexities
arise with respect to updating the collective subscript information.

If a macro type is detected anywhere along path~|t|, or if the first
item on |t| isn't a |tag_token|, the value |null| is returned.
Otherwise |p| will be a non-null pointer to a node such that
|undefined < type(p) < structured|.

@d abort_find	{@+return null;@+} 

@p pointer find_variable(pointer @!t)
{@+
pointer @!p, @!q, @!r, @!s; /*nodes in the ``value'' line*/ 
pointer @!pp, @!qq, @!rr, @!ss; /*nodes in the ``collective'' line*/ 
int @!n; /*subscript or attribute*/ 
memory_word @!save_word; /*temporary storage for a word of |mem|*/ 
@^inner loop@>
p=info(t);t=link(t);
if (eq_type(p)%outer_tag!=tag_token) abort_find;
if (equiv(p)==null) new_root(p);
p=equiv(p);pp=p;
while (t!=null) 
  {@+@<Make sure that both nodes |p| and |pp| are of |structured| type@>;
  if (t < hi_mem_min) 
    @<Descend one level for the subscript |value(t)|@>@;
  else@<Descend one level for the attribute |info(t)|@>;
  t=link(t);
  } 
if (type(pp) >= structured) 
  if (type(pp)==structured) pp=attr_head(pp);@+else abort_find;
if (type(p)==structured) p=attr_head(p);
if (type(p)==undefined) 
  {@+if (type(pp)==undefined) 
    {@+type(pp)=numeric_type;value(pp)=null;
    } 
  type(p)=type(pp);value(p)=null;
  } 
return p;
} 

@ Although |pp| and |p| begin together, they diverge when a subscript occurs;
|pp|~stays in the collective line while |p|~goes through actual subscript
values.

@<Make sure that both nodes |p| and |pp|...@>=
if (type(pp)!=structured) 
  {@+if (type(pp) > structured) abort_find;
  ss=new_structure(pp);
  if (p==pp) p=ss;
  pp=ss;
  }  /*now |type(pp)==structured|*/ 
if (type(p)!=structured)  /*it cannot be | > structured|*/ 
  p=new_structure(p) /*now |type(p)==structured|*/ 

@ We want this part of the program to be reasonably fast, in case there are
@^inner loop@>
lots of subscripts at the same level of the data structure. Therefore
we store an ``infinite'' value in the word that appears at the end of the
subscript list, even though that word isn't part of a subscript node.

@<Descend one level for the subscript |value(t)|@>=
{@+n=value(t);
pp=link(attr_head(pp)); /*now |attr_loc(pp)==collective_subscript|*/ 
q=link(attr_head(p));save_word=mem[subscript_loc(q)];
subscript(q)=el_gordo;s=subscr_head_loc(p); /*|link(s)==subscr_head(p)|*/ 
@/do@+{r=s;s=link(s);
}@+ while (!(n <= subscript(s)));
if (n==subscript(s)) p=s;
else{@+p=get_node(subscr_node_size);link(r)=p;link(p)=s;
  subscript(p)=n;name_type(p)=subscr;type(p)=undefined;
  } 
mem[subscript_loc(q)]=save_word;
} 

@ @<Descend one level for the attribute |info(t)|@>=
{@+n=info(t);
ss=attr_head(pp);
@/do@+{rr=ss;ss=link(ss);
}@+ while (!(n <= attr_loc(ss)));
if (n < attr_loc(ss)) 
  {@+qq=get_node(attr_node_size);link(rr)=qq;link(qq)=ss;
  attr_loc(qq)=n;name_type(qq)=attr;type(qq)=undefined;
  parent(qq)=pp;ss=qq;
  } 
if (p==pp) 
  {@+p=ss;pp=ss;
  } 
else{@+pp=ss;s=attr_head(p);
  @/do@+{r=s;s=link(s);
  }@+ while (!(n <= attr_loc(s)));
  if (n==attr_loc(s)) p=s;
  else{@+q=get_node(attr_node_size);link(r)=q;link(q)=s;
    attr_loc(q)=n;name_type(q)=attr;type(q)=undefined;
    parent(q)=p;p=q;
    } 
  } 
} 

@ Variables lose their former values when they appear in a type declaration,
or when they are defined to be macros or \&{let} equal to something else.
A subroutine will be defined later that recycles the storage associated
with any particular |type| or |value|; our goal now is to study a higher
level process called |flush_variable|, which selectively frees parts of a
variable structure.

This routine has some complexity because of examples such as
`\hbox{\tt numeric x[]a[]b}',
which recycles all variables of the form \.{x[i]a[j]b} (and no others), while
`\hbox{\tt vardef x[]a[]=...}'
discards all variables of the form \.{x[i]a[j]} followed by an arbitrary
suffix, except for the collective node \.{x[]a[]} itself. The obvious way
to handle such examples is to use recursion; so that's what we~do.
@^recursion@>

Parameter |p| points to the root information of the variable;
parameter |t| points to a list of one-word nodes that represent
suffixes, with |info==collective_subscript| for subscripts.

@p@t\4@>@<Declare subroutines for printing expressions@>@;@/
@t\4@>@<Declare basic dependency-list subroutines@>@;
@t\4@>@<Declare the recycling subroutines@>@;
@t\4@>@<Declare the procedure called |flush_cur_exp|@>@;
@t\4@>@<Declare the procedure called |flush_below_variable|@>@;
void flush_variable(pointer @!p, pointer @!t, bool @!discard_suffixes)
{@+
pointer @!q, @!r; /*list manipulation*/ 
halfword @!n; /*attribute to match*/ 
while (t!=null) 
  {@+if (type(p)!=structured) return;
  n=info(t);t=link(t);
  if (n==collective_subscript) 
    {@+r=subscr_head_loc(p);q=link(r); /*|q==subscr_head(p)|*/ 
    while (name_type(q)==subscr) 
      {@+flush_variable(q, t, discard_suffixes);
      if (t==null) 
        if (type(q)==structured) r=q;
        else{@+link(r)=link(q);free_node(q, subscr_node_size);
          } 
      else r=q;
      q=link(r);
      } 
    } 
  p=attr_head(p);
  @/do@+{r=p;p=link(p);
  }@+ while (!(attr_loc(p) >= n));
  if (attr_loc(p)!=n) return;
  } 
if (discard_suffixes) flush_below_variable(p);
else{@+if (type(p)==structured) p=attr_head(p);
  recycle_value(p);
  } 
} 

@ The next procedure is simpler; it wipes out everything but |p| itself,
which becomes undefined.

@<Declare the procedure called |flush_below_variable|@>=
void flush_below_variable(pointer @!p)
{@+pointer @!q, @!r; /*list manipulation registers*/ 
if (type(p)!=structured) 
  recycle_value(p); /*this sets |type(p)==undefined|*/ 
else{@+q=subscr_head(p);
  while (name_type(q)==subscr) 
    {@+flush_below_variable(q);r=q;q=link(q);
    free_node(r, subscr_node_size);
    } 
  r=attr_head(p);q=link(r);recycle_value(r);
  if (name_type(p) <= saved_root) free_node(r, value_node_size);
  else free_node(r, subscr_node_size);
     /*we assume that |subscr_node_size==attr_node_size|*/ 
  @/do@+{flush_below_variable(q);r=q;q=link(q);free_node(r, attr_node_size);
  }@+ while (!(q==end_attr));
  type(p)=undefined;
  } 
} 

@ Just before assigning a new value to a variable, we will recycle the
old value and make the old value undefined. The |und_type| routine
determines what type of undefined value should be given, based on
the current type before recycling.

@p small_number und_type(pointer @!p)
{@+switch (type(p)) {
case undefined: case vacuous: return undefined;@+break;
case boolean_type: case unknown_boolean: return unknown_boolean;@+break;
case string_type: case unknown_string: return unknown_string;@+break;
case pen_type: case unknown_pen: case future_pen: return unknown_pen;@+break;
case path_type: case unknown_path: return unknown_path;@+break;
case picture_type: case unknown_picture: return unknown_picture;@+break;
case transform_type: case pair_type: case numeric_type: return type(p);@+break;
case known: case dependent: case proto_dependent: case independent: return numeric_type;
}  /*there are no other cases*/ 
} 

@ The |clear_symbol| routine is used when we want to redefine the equivalent
of a symbolic token. It must remove any variable structure or macro
definition that is currently attached to that symbol. If the |saving|
parameter is true, a subsidiary structure is saved instead of destroyed.

@p void clear_symbol(pointer @!p, bool @!saving)
{@+pointer @!q; /*|equiv(p)|*/ 
q=equiv(p);
switch (eq_type(p)%outer_tag) {
case defined_macro: case secondary_primary_macro: case tertiary_secondary_macro: 
 case expression_tertiary_macro: if (!saving) delete_mac_ref(q);@+break;
case tag_token: if (q!=null) 
  if (saving) name_type(q)=saved_root;
  else{@+flush_below_variable(q);free_node(q, value_node_size);
    } @+break;@;
default:do_nothing;
} @/
eqtb[p]=eqtb[frozen_undefined];
} 

@* Saving and restoring equivalents.
The nested structure provided by \&{begingroup} and \&{endgroup}
allows |eqtb| entries to be saved and restored, so that temporary changes
can be made without difficulty.  When the user requests a current value to
be saved, \MF\ puts that value into its ``save stack.'' An appearance of
\&{endgroup} ultimately causes the old values to be removed from the save
stack and put back in their former places.

The save stack is a linked list containing three kinds of entries,
distinguished by their |info| fields. If |p| points to a saved item,
then

\smallskip\hang
|info(p)==0| stands for a group boundary; each \&{begingroup} contributes
such an item to the save stack and each \&{endgroup} cuts back the stack
until the most recent such entry has been removed.

\smallskip\hang
|info(p)==q|, where |1 <= q <= hash_end|, means that |mem[p+1]| holds the former
contents of |eqtb[q]|. Such save stack entries are generated by \&{save}
commands.

\smallskip\hang
|info(p)==hash_end+q|, where |q > 0|, means that |value(p)| is a |scaled|
integer to be restored to internal parameter number~|q|. Such entries
are generated by \&{interim} commands.

\smallskip\noindent
The global variable |save_ptr| points to the top item on the save stack.

@d save_node_size	2 /*number of words per non-boundary save-stack node*/ 
@d saved_equiv(X)	mem[X+1].hh /*where an |eqtb| entry gets saved*/ 
@d save_boundary_item(X)	{@+X=get_avail();info(X)=0;
  link(X)=save_ptr;save_ptr=X;
  } 

@<Glob...@>=pointer @!save_ptr; /*the most recently saved item*/ 

@ @<Set init...@>=save_ptr=null;

@ The |save_variable| routine is given a hash address |q|; it salts this
address in the save stack, together with its current equivalent,
then makes token~|q| behave as though it were brand new.

Nothing is stacked when |save_ptr==null|, however; there's no way to remove
things from the stack when the program is not inside a group, so there's
no point in wasting the space.

@p void save_variable(pointer @!q)
{@+pointer @!p; /*temporary register*/ 
if (save_ptr!=null) 
  {@+p=get_node(save_node_size);info(p)=q;link(p)=save_ptr;
  saved_equiv(p)=eqtb[q];save_ptr=p;
  } 
clear_symbol(q,(save_ptr!=null));
} 

@ Similarly, |save_internal| is given the location |q| of an internal
quantity like |tracing_pens|. It creates a save stack entry of the
third kind.

@p void save_internal(halfword @!q)
{@+pointer @!p; /*new item for the save stack*/ 
if (save_ptr!=null) 
  {@+p=get_node(save_node_size);info(p)=hash_end+q;
  link(p)=save_ptr;value(p)=internal[q];save_ptr=p;
  } 
} 

@ At the end of a group, the |unsave| routine restores all of the saved
equivalents in reverse order. This routine will be called only when there
is at least one boundary item on the save stack.

@p void unsave(void)
{@+pointer @!q; /*index to saved item*/ 
pointer @!p; /*temporary register*/ 
while (info(save_ptr)!=0) 
  {@+q=info(save_ptr);
  if (q > hash_end) 
    {@+if (internal[tracing_restores] > 0) 
      {@+begin_diagnostic();print_nl("{restoring ");
      slow_print(int_name[q-(hash_end)]);print_char('=');
      print_scaled(value(save_ptr));print_char('}');
      end_diagnostic(false);
      } 
    internal[q-(hash_end)]=value(save_ptr);
    } 
  else{@+if (internal[tracing_restores] > 0) 
      {@+begin_diagnostic();print_nl("{restoring ");
      slow_print(text(q));print_char('}');
      end_diagnostic(false);
      } 
    clear_symbol(q, false);
    eqtb[q]=saved_equiv(save_ptr);
    if (eq_type(q)%outer_tag==tag_token) 
      {@+p=equiv(q);
      if (p!=null) name_type(p)=root;
      } 
    } 
  p=link(save_ptr);free_node(save_ptr, save_node_size);save_ptr=p;
  } 
p=link(save_ptr);free_avail(save_ptr);save_ptr=p;
} 

@* Data structures for paths.
When a \MF\ user specifies a path, \MF\ will create a list of knots
and control points for the associated cubic spline curves. If the
knots are $z_0$, $z_1$, \dots, $z_n$, there are control points
$z_k^+$ and $z_{k+1}^-$ such that the cubic splines between knots
$z_k$ and $z_{k+1}$ are defined by B\'ezier's formula
@:Bezier}{B\'ezier, Pierre Etienne@>
$$\eqalign{z(t)&=B(z_k,z_k^+,z_{k+1}^-,z_{k+1};t)\cr
&=(1-t)^3z_k+3(1-t)^2tz_k^++3(1-t)t^2z_{k+1}^-+t^3z_{k+1}\cr}$$
for |0 <= t <= 1|.

There is a 7-word node for each knot $z_k$, containing one word of
control information and six words for the |x| and |y| coordinates
of $z_k^-$ and $z_k$ and~$z_k^+$. The control information appears
in the |left_type| and |right_type| fields, which each occupy
a quarter of the first word in the node; they specify properties
of the curve as it enters and leaves the knot. There's also a
halfword |link| field, which points to the following knot.

If the path is a closed contour, knots 0 and |n| are identical;
i.e., the |link| in knot |n-1| points to knot~0. But if the path
is not closed, the |left_type| of knot~0 and the |right_type| of knot~|n|
are equal to |endpoint|. In the latter case the |link| in knot~|n| points
to knot~0, and the control points $z_0^-$ and $z_n^+$ are not used.

@d left_type(X)	mem[X].hh.b0 /*characterizes the path entering this knot*/ 
@d right_type(X)	mem[X].hh.b1 /*characterizes the path leaving this knot*/ 
@d endpoint	0 /*|left_type| at path beginning and |right_type| at path end*/ 
@d x_coord(X)	mem[X+1].sc /*the |x| coordinate of this knot*/ 
@d y_coord(X)	mem[X+2].sc /*the |y| coordinate of this knot*/ 
@d left_x(X)	mem[X+3].sc /*the |x| coordinate of previous control point*/ 
@d left_y(X)	mem[X+4].sc /*the |y| coordinate of previous control point*/ 
@d right_x(X)	mem[X+5].sc /*the |x| coordinate of next control point*/ 
@d right_y(X)	mem[X+6].sc /*the |y| coordinate of next control point*/ 
@d knot_node_size	7 /*number of words in a knot node*/ 

@ Before the B\'ezier control points have been calculated, the memory
space they will ultimately occupy is taken up by information that can be
used to compute them. There are four cases:

\yskip
\textindent{$\bullet$} If |right_type==open|, the curve should leave
the knot in the same direction it entered; \MF\ will figure out a
suitable direction.

\yskip
\textindent{$\bullet$} If |right_type==curl|, the curve should leave the
knot in a direction depending on the angle at which it enters the next
knot and on the curl parameter stored in |right_curl|.

\yskip
\textindent{$\bullet$} If |right_type==given|, the curve should leave the
knot in a nonzero direction stored as an |angle| in |right_given|.

\yskip
\textindent{$\bullet$} If |right_type==explicit|, the B\'ezier control
point for leaving this knot has already been computed; it is in the
|right_x| and |right_y| fields.

\yskip\noindent
The rules for |left_type| are similar, but they refer to the curve entering
the knot, and to \\{left} fields instead of \\{right} fields.

Non-|explicit| control points will be chosen based on ``tension'' parameters
in the |left_tension| and |right_tension| fields. The
`\&{atleast}' option is represented by negative tension values.
@:at_least_}{\&{atleast} primitive@>

For example, the \MF\ path specification
$$\.{z0..z1..tension atleast 1..\{curl 2\}z2..z3\{-1,-2\}..tension
  3 and 4..p},$$
where \.p is the path `\.{z4..controls z45 and z54..z5}', will be represented
by the six knots
\def\lodash{\hbox to 1.1em{\thinspace\hrulefill\thinspace}}
$$\vbox{\halign{#\hfil&&\qquad#\hfil\cr
|left_type|&\\{left} info&|x_coord, y_coord|&|right_type|&\\{right} info\cr
\noalign{\yskip}
|endpoint|&\lodash$,\,$\lodash&$x_0,y_0$&|curl|&$1.0,1.0$\cr
|open|&\lodash$,1.0$&$x_1,y_1$&|open|&\lodash$,-1.0$\cr
|curl|&$2.0,-1.0$&$x_2,y_2$&|curl|&$2.0,1.0$\cr
|given|&$d,1.0$&$x_3,y_3$&|given|&$d,3.0$\cr
|open|&\lodash$,4.0$&$x_4,y_4$&|explicit|&$x_{45},y_{45}$\cr
|explicit|&$x_{54},y_{54}$&$x_5,y_5$&|endpoint|&\lodash$,\,$\lodash\cr}}$$
Here |d| is the |angle| obtained by calling |n_arg(-unity,-two)|.
Of course, this example is more complicated than anything a normal user
would ever write.

These types must satisfy certain restrictions because of the form of \MF's
path syntax:
(i)~|open| type never appears in the same node together with |endpoint|,
|given|, or |curl|.
(ii)~The |right_type| of a node is |explicit| if and only if the
|left_type| of the following node is |explicit|.
(iii)~|endpoint| types occur only at the ends, as mentioned above.

@d left_curl	left_x /*curl information when entering this knot*/ 
@d left_given	left_x /*given direction when entering this knot*/ 
@d left_tension	left_y /*tension information when entering this knot*/ 
@d right_curl	right_x /*curl information when leaving this knot*/ 
@d right_given	right_x /*given direction when leaving this knot*/ 
@d right_tension	right_y /*tension information when leaving this knot*/ 
@d explicit	1 /*|left_type| or |right_type| when control points are known*/ 
@d given	2 /*|left_type| or |right_type| when a direction is given*/ 
@d curl	3 /*|left_type| or |right_type| when a curl is desired*/ 
@d open	4 /*|left_type| or |right_type| when \MF\ should choose the direction*/ 

@ Here is a diagnostic routine that prints a given knot list
in symbolic form. It illustrates the conventions discussed above,
and checks for anomalies that might arise while \MF\ is being debugged.

@<Declare subroutines for printing expressions@>=
void print_path(pointer @!h, str_number @!s, bool @!nuline)
{@+
pointer @!p, @!q; /*for list traversal*/ 
print_diagnostic(@[@<|"Path"|@>@], s, nuline);print_ln();
@.Path at line...@>
p=h;
@/do@+{q=link(p);
if ((p==null)||(q==null)) 
  {@+print_nl("???");goto done; /*this won't happen*/ 
@.???@>
  } 
@<Print information for adjacent knots |p| and |q|@>;
p=q;
if ((p!=h)||(left_type(h)!=endpoint)) 
  @<Print two dots, followed by |given| or |curl| if present@>;
}@+ while (!(p==h));
if (left_type(h)!=endpoint) print_str("cycle");
done: end_diagnostic(true);
} 

@ @<Print information for adjacent knots...@>=
print_two(x_coord(p), y_coord(p));
switch (right_type(p)) {
case endpoint: {@+if (left_type(p)==open) print_str("{open?}"); /*can't happen*/ 
@.open?@>
  if ((left_type(q)!=endpoint)||(q!=h)) q=null; /*force an error*/ 
  goto done1;
  } 
case explicit: @<Print control points between |p| and |q|, then |goto done1|@>@;
case open: @<Print information for a curve that begins |open|@>;@+break;
case curl: case given: @<Print information for a curve that begins |curl| or |given|@>@;@+break;
default:print_str("???"); /*can't happen*/ 
@.???@>
} @/
if (left_type(q) <= explicit) print_str("..control?"); /*can't happen*/ 
@.control?@>
else if ((right_tension(p)!=unity)||(left_tension(q)!=unity)) 
  @<Print tension between |p| and |q|@>;
done1: 

@ Since |n_sin_cos| produces |fraction| results, which we will print as if they
were |scaled|, the magnitude of a |given| direction vector will be~4096.

@<Print two dots...@>=
{@+print_nl(" ..");
if (left_type(p)==given) 
  {@+n_sin_cos(left_given(p));print_char('{');
  print_scaled(n_cos);print_char(',');
  print_scaled(n_sin);print_char('}');
  } 
else if (left_type(p)==curl) 
  {@+print_str("{curl ");print_scaled(left_curl(p));print_char('}');
  } 
} 

@ @<Print tension between |p| and |q|@>=
{@+print_str("..tension ");
if (right_tension(p) < 0) print_str("atleast");
print_scaled(abs(right_tension(p)));
if (right_tension(p)!=left_tension(q)) 
  {@+print_str(" and ");
  if (left_tension(q) < 0) print_str("atleast");
  print_scaled(abs(left_tension(q)));
  } 
} 

@ @<Print control points between |p| and |q|, then |goto done1|@>=
{@+print_str("..controls ");print_two(right_x(p), right_y(p));print_str(" and ");
if (left_type(q)!=explicit) print_str("??"); /*can't happen*/ 
@.??@>
else print_two(left_x(q), left_y(q));
goto done1;
} 

@ @<Print information for a curve that begins |open|@>=
if ((left_type(p)!=explicit)&&(left_type(p)!=open)) 
  print_str("{open?}") /*can't happen*/ 
@.open?@>

@ A curl of 1 is shown explicitly, so that the user sees clearly that
\MF's default curl is present.

@<Print information for a curve that begins |curl|...@>=
{@+if (left_type(p)==open) print_str("??"); /*can't happen*/ 
@.??@>
if (right_type(p)==curl) 
  {@+print_str("{curl ");print_scaled(right_curl(p));
  } 
else{@+n_sin_cos(right_given(p));print_char('{');
  print_scaled(n_cos);print_char(',');print_scaled(n_sin);
  } 
print_char('}');
} 

@ If we want to duplicate a knot node, we can say |copy_knot|:

@p pointer copy_knot(pointer @!p)
{@+pointer @!q; /*the copy*/ 
uint8_t @!k; /*runs through the words of a knot node*/ 
q=get_node(knot_node_size);
for (k=0; k<=knot_node_size-1; k++) mem[q+k]=mem[p+k];
return q;
} 

@ The |copy_path| routine makes a clone of a given path.

@p pointer copy_path(pointer @!p)
{@+
pointer @!q, @!pp, @!qq; /*for list manipulation*/ 
q=get_node(knot_node_size); /*this will correspond to |p|*/ 
qq=q;pp=p;
loop@+{@+left_type(qq)=left_type(pp);
  right_type(qq)=right_type(pp);@/
  x_coord(qq)=x_coord(pp);y_coord(qq)=y_coord(pp);@/
  left_x(qq)=left_x(pp);left_y(qq)=left_y(pp);@/
  right_x(qq)=right_x(pp);right_y(qq)=right_y(pp);@/
  if (link(pp)==p) 
    {@+link(qq)=q;return q;
    } 
  link(qq)=get_node(knot_node_size);qq=link(qq);pp=link(pp);
  } 
} 

@ Similarly, there's a way to copy the {\sl reverse\/} of a path. This procedure
returns a pointer to the first node of the copy, if the path is a cycle,
but to the final node of a non-cyclic copy. The global
variable |path_tail| will point to the final node of the original path;
this trick makes it easier to implement `\&{doublepath}'.

All node types are assumed to be |endpoint| or |explicit| only.

@p pointer htap_ypoc(pointer @!p)
{@+
pointer @!q, @!pp, @!qq, @!rr; /*for list manipulation*/ 
q=get_node(knot_node_size); /*this will correspond to |p|*/ 
qq=q;pp=p;
loop@+{@+right_type(qq)=left_type(pp);left_type(qq)=right_type(pp);@/
  x_coord(qq)=x_coord(pp);y_coord(qq)=y_coord(pp);@/
  right_x(qq)=left_x(pp);right_y(qq)=left_y(pp);@/
  left_x(qq)=right_x(pp);left_y(qq)=right_y(pp);@/
  if (link(pp)==p) 
    {@+link(q)=qq;path_tail=pp;return q;
    } 
  rr=get_node(knot_node_size);link(rr)=qq;qq=rr;pp=link(pp);
  } 
} 

@ @<Glob...@>=
pointer @!path_tail; /*the node that links to the beginning of a path*/ 

@ When a cyclic list of knot nodes is no longer needed, it can be recycled by
calling the following subroutine.

@<Declare the recycling subroutines@>=
void toss_knot_list(pointer @!p)
{@+pointer @!q; /*the node being freed*/ 
pointer @!r; /*the next node*/ 
q=p;
@/do@+{r=link(q);free_node(q, knot_node_size);q=r;
}@+ while (!(q==p));
} 

@* Choosing control points.
Now we must actually delve into one of \MF's more difficult routines,
the |make_choices| procedure that chooses angles and control points for
the splines of a curve when the user has not specified them explicitly.
The parameter to |make_choices| points to a list of knots and
path information, as described above.

A path decomposes into independent segments at ``breakpoint'' knots,
which are knots whose left and right angles are both prespecified in
some way (i.e., their |left_type| and |right_type| aren't both open).

@p@t\4@>@<Declare the procedure called |solve_choices|@>@;
void make_choices(pointer @!knots)
{@+
pointer @!h; /*the first breakpoint*/ 
pointer @!p, @!q; /*consecutive breakpoints being processed*/ 
@<Other local variables for |make_choices|@>@;
check_arith; /*make sure that |arith_error==false|*/ 
if (internal[tracing_choices] > 0) 
  print_path(knots,@[@<|", before choices"|@>@], true);
@<If consecutive knots are equal, join them explicitly@>;
@<Find the first breakpoint, |h|, on the path; insert an artificial breakpoint if
the path is an unbroken cycle@>;
p=h;
@/do@+{@<Fill in the control points between |p| and the next breakpoint, then advance
|p| to that breakpoint@>;
}@+ while (!(p==h));
if (internal[tracing_choices] > 0) 
  print_path(knots,@[@<|", after choices"|@>@], true);
if (arith_error) @<Report an unexpected problem during the choice-making@>;
} 

@ @<Report an unexpected problem during the choice...@>=
{@+print_err("Some number got too big");
@.Some number got too big@>
help2("The path that I just computed is out of range.")@/
  ("So it will probably look funny. Proceed, for a laugh.");
put_get_error();arith_error=false;
} 

@ Two knots in a row with the same coordinates will always be joined
by an explicit ``curve'' whose control points are identical with the
knots.

@<If consecutive knots are equal, join them explicitly@>=
p=knots;
@/do@+{q=link(p);
if (x_coord(p)==x_coord(q)) if (y_coord(p)==y_coord(q)) 
 if (right_type(p) > explicit) 
  {@+right_type(p)=explicit;
  if (left_type(p)==open) 
    {@+left_type(p)=curl;left_curl(p)=unity;
    } 
  left_type(q)=explicit;
  if (right_type(q)==open) 
    {@+right_type(q)=curl;right_curl(q)=unity;
    } 
  right_x(p)=x_coord(p);left_x(q)=x_coord(p);@/
  right_y(p)=y_coord(p);left_y(q)=y_coord(p);
  } 
p=q;
}@+ while (!(p==knots))

@ If there are no breakpoints, it is necessary to compute the direction
angles around an entire cycle. In this case the |left_type| of the first
node is temporarily changed to |end_cycle|.

@d end_cycle	(open+1)

@<Find the first breakpoint, |h|, on the path...@>=
h=knots;
loop@+{@+if (left_type(h)!=open) goto done;
  if (right_type(h)!=open) goto done;
  h=link(h);
  if (h==knots) 
    {@+left_type(h)=end_cycle;goto done;
    } 
  } 
done: 

@ If |right_type(p) < given| and |q==link(p)|, we must have
|right_type(p)==left_type(q)==explicit| or |endpoint|.

@<Fill in the control points between |p| and the next breakpoint...@>=
q=link(p);
if (right_type(p) >= given) 
  {@+while ((left_type(q)==open)&&(right_type(q)==open)) q=link(q);
  @<Fill in the control information between consecutive breakpoints |p| and |q|@>;
  } 
p=q

@ Before we can go further into the way choices are made, we need to
consider the underlying theory. The basic ideas implemented in |make_choices|
are due to John Hobby, who introduced the notion of ``mock curvature''
@^Hobby, John Douglas@>
at a knot. Angles are chosen so that they preserve mock curvature when
a knot is passed, and this has been found to produce excellent results.

It is convenient to introduce some notations that simplify the necessary
formulas. Let $d_{k,k+1}=\vert z\k-z_k\vert$ be the (nonzero) distance
between knots |k| and |k+1|; and let
$${z\k-z_k\over z_k-z_{k-1}}={d_{k,k+1}\over d_{k-1,k}}e^{i\psi_k}$$
so that a polygonal line from $z_{k-1}$ to $z_k$ to $z\k$ turns left
through an angle of~$\psi_k$. We assume that $\vert\psi_k\vert\L180^\circ$.
The control points for the spline from $z_k$ to $z\k$ will be denoted by
$$\eqalign{z_k^+&=z_k+
  \textstyle{1\over3}\rho_k e^{i\theta_k}(z\k-z_k),\cr
 z\k^-&=z\k-
  \textstyle{1\over3}\sigma\k e^{-i\phi\k}(z\k-z_k),\cr}$$
where $\rho_k$ and $\sigma\k$ are nonnegative ``velocity ratios'' at the
beginning and end of the curve, while $\theta_k$ and $\phi\k$ are the
corresponding ``offset angles.'' These angles satisfy the condition
$$\theta_k+\phi_k+\psi_k=0,\eqno(*)$$
whenever the curve leaves an intermediate knot~|k| in the direction that
it enters.

@ Let $\alpha_k$ and $\beta\k$ be the reciprocals of the ``tension'' of
the curve at its beginning and ending points. This means that
$\rho_k=\alpha_k f(\theta_k,\phi\k)$ and $\sigma\k=\beta\k f(\phi\k,\theta_k)$,
where $f(\theta,\phi)$ is \MF's standard velocity function defined in
the |velocity| subroutine. The cubic spline $B(z_k^{\phantom+},z_k^+,
z\k^-,z\k^{\phantom+};t)$
has curvature
@^curvature@>
$${2\sigma\k\sin(\theta_k+\phi\k)-6\sin\theta_k\over\rho_k^2d_{k,k+1}}
\qquad{\rm and}\qquad
{2\rho_k\sin(\theta_k+\phi\k)-6\sin\phi\k\over\sigma\k^2d_{k,k+1}}$$
at |t==0| and |t==1|, respectively. The mock curvature is the linear
@^mock curvature@>
approximation to this true curvature that arises in the limit for
small $\theta_k$ and~$\phi\k$, if second-order terms are discarded.
The standard velocity function satisfies
$$f(\theta,\phi)=1+O(\theta^2+\theta\phi+\phi^2);$$
hence the mock curvatures are respectively
$${2\beta\k(\theta_k+\phi\k)-6\theta_k\over\alpha_k^2d_{k,k+1}}
\qquad{\rm and}\qquad
{2\alpha_k(\theta_k+\phi\k)-6\phi\k\over\beta\k^2d_{k,k+1}}.\eqno(**)$$

@ The turning angles $\psi_k$ are given, and equation $(*)$ above
determines $\phi_k$ when $\theta_k$ is known, so the task of
angle selection is essentially to choose appropriate values for each
$\theta_k$. When equation~$(*)$ is used to eliminate $\phi$~variables
from $(**)$, we obtain a system of linear equations of the form
$$A_k\theta_{k-1}+(B_k+C_k)\theta_k+D_k\theta\k=-B_k\psi_k-D_k\psi\k,$$
where
$$A_k={\alpha_{k-1}\over\beta_k^2d_{k-1,k}},
\qquad B_k={3-\alpha_{k-1}\over\beta_k^2d_{k-1,k}},
\qquad C_k={3-\beta\k\over\alpha_k^2d_{k,k+1}},
\qquad D_k={\beta\k\over\alpha_k^2d_{k,k+1}}.$$
The tensions are always $3\over4$ or more, hence each $\alpha$ and~$\beta$
will be at most $4\over3$. It follows that $B_k\G{5\over4}A_k$ and
$C_k\G{5\over4}D_k$; hence the equations are diagonally dominant;
hence they have a unique solution. Moreover, in most cases the tensions
are equal to~1, so that $B_k=2A_k$ and $C_k=2D_k$. This makes the
solution numerically stable, and there is an exponential damping
effect: The data at knot $k\pm j$ affects the angle at knot~$k$ by
a factor of~$O(2^{-j})$.

@ However, we still must consider the angles at the starting and ending
knots of a non-cyclic path. These angles might be given explicitly, or
they might be specified implicitly in terms of an amount of ``curl.''

Let's assume that angles need to be determined for a non-cyclic path
starting at $z_0$ and ending at~$z_n$. Then equations of the form
$$A_k\theta_{k-1}+(B_k+C_k)\theta_k+D_k\theta_{k+1}=R_k$$
have been given for $0<k<n$, and it will be convenient to introduce
equations of the same form for $k=0$ and $k=n$, where
$$A_0=B_0=C_n=D_n=0.$$
If $\theta_0$ is supposed to have a given value $E_0$, we simply
define $C_0=1$, $D_0=0$, and $R_0=E_0$. Otherwise a curl
parameter, $\gamma_0$, has been specified at~$z_0$; this means
that the mock curvature at $z_0$ should be $\gamma_0$ times the
mock curvature at $z_1$; i.e.,
$${2\beta_1(\theta_0+\phi_1)-6\theta_0\over\alpha_0^2d_{01}}
=\gamma_0{2\alpha_0(\theta_0+\phi_1)-6\phi_1\over\beta_1^2d_{01}}.$$
This equation simplifies to
$$(\alpha_0\chi_0+3-\beta_1)\theta_0+
 \bigl((3-\alpha_0)\chi_0+\beta_1\bigr)\theta_1=
 -\bigl((3-\alpha_0)\chi_0+\beta_1\bigr)\psi_1,$$
where $\chi_0=\alpha_0^2\gamma_0/\beta_1^2$; so we can set $C_0=
\chi_0\alpha_0+3-\beta_1$, $D_0=(3-\alpha_0)\chi_0+\beta_1$, $R_0=-D_0\psi_1$.
It can be shown that $C_0>0$ and $C_0B_1-A_1D_0>0$ when $\gamma_0\G0$,
hence the linear equations remain nonsingular.

Similar considerations apply at the right end, when the final angle $\phi_n$
may or may not need to be determined. It is convenient to let $\psi_n=0$,
hence $\theta_n=-\phi_n$. We either have an explicit equation $\theta_n=E_n$,
or we have
$$\bigl((3-\beta_n)\chi_n+\alpha_{n-1}\bigr)\theta_{n-1}+
(\beta_n\chi_n+3-\alpha_{n-1})\theta_n=0,\qquad
  \chi_n={\beta_n^2\gamma_n\over\alpha_{n-1}^2}.$$

When |make_choices| chooses angles, it must compute the coefficients of
these linear equations, then solve the equations. To compute the coefficients,
it is necessary to compute arctangents of the given turning angles~$\psi_k$.
When the equations are solved, the chosen directions $\theta_k$ are put
back into the form of control points by essentially computing sines and
cosines.

@ OK, we are ready to make the hard choices of |make_choices|.
Most of the work is relegated to an auxiliary procedure
called |solve_choices|, which has been introduced to keep
|make_choices| from being extremely long.

@<Fill in the control information between...@>=
@<Calculate the turning angles $\psi_k$ and the distances $d_{k,k+1}$; set $n$ to
the length of the path@>;
@<Remove |open| types at the breakpoints@>;
solve_choices(p, q, n)

@ It's convenient to precompute quantities that will be needed several
times later. The values of |delta_x[k]| and |delta_y[k]| will be the
coordinates of $z\k-z_k$, and the magnitude of this vector will be
|delta[k]==@t$d_{k,k+1}$@>|. The path angle $\psi_k$ between $z_k-z_{k-1}$
and $z\k-z_k$ will be stored in |psi[k]|.

@<Glob...@>=
scaled @!delta_x[path_size+1], @!delta_y[path_size+1], @!delta[path_size+1]; /*knot differences*/ 
angle @!psi0[path_size], *const @!psi = @!psi0-1; /*turning angles*/ 

@ @<Other local variables for |make_choices|@>=
uint16_t @!k, @!n; /*current and final knot numbers*/ 
pointer @!s, @!t; /*registers for list traversal*/ 
scaled @!delx, @!dely; /*directions where |open| meets |explicit|*/ 
fraction @!sine, @!cosine; /*trig functions of various angles*/ 

@ @<Calculate the turning angles...@>=
k=0;s=p;n=path_size;
@/do@+{t=link(s);
delta_x[k]=x_coord(t)-x_coord(s);
delta_y[k]=y_coord(t)-y_coord(s);
delta[k]=pyth_add(delta_x[k], delta_y[k]);
if (k > 0) 
  {@+sine=make_fraction(delta_y[k-1], delta[k-1]);
  cosine=make_fraction(delta_x[k-1], delta[k-1]);
  psi[k]=n_arg(take_fraction(delta_x[k], cosine)+
      take_fraction(delta_y[k], sine),
    take_fraction(delta_y[k], cosine)-
      take_fraction(delta_x[k], sine));
  } 
@:METAFONT capacity exceeded path size}{\quad path size@>
incr(k);s=t;
if (k==path_size) overflow("path size", path_size);
if (s==q) n=k;
}@+ while (!((k >= n)&&(left_type(s)!=end_cycle)));
if (k==n) psi[n]=0;@+else psi[k]=psi[1]

@ When we get to this point of the code, |right_type(p)| is either
|given| or |curl| or |open|. If it is |open|, we must have
|left_type(p)==end_cycle| or |left_type(p)==explicit|. In the latter
case, the |open| type is converted to |given|; however, if the
velocity coming into this knot is zero, the |open| type is
converted to a |curl|, since we don't know the incoming direction.

Similarly, |left_type(q)| is either |given| or |curl| or |open| or
|end_cycle|. The |open| possibility is reduced either to |given| or to |curl|.

@<Remove |open| types at the breakpoints@>=
if (left_type(q)==open) 
  {@+delx=right_x(q)-x_coord(q);dely=right_y(q)-y_coord(q);
  if ((delx==0)&&(dely==0)) 
    {@+left_type(q)=curl;left_curl(q)=unity;
    } 
  else{@+left_type(q)=given;left_given(q)=n_arg(delx, dely);
    } 
  } 
if ((right_type(p)==open)&&(left_type(p)==explicit)) 
  {@+delx=x_coord(p)-left_x(p);dely=y_coord(p)-left_y(p);
  if ((delx==0)&&(dely==0)) 
    {@+right_type(p)=curl;right_curl(p)=unity;
    } 
  else{@+right_type(p)=given;right_given(p)=n_arg(delx, dely);
    } 
  } 

@ Linear equations need to be solved whenever |n > 1|; and also when |n==1|
and exactly one of the breakpoints involves a curl. The simplest case occurs
when |n==1| and there is a curl at both breakpoints; then we simply draw
a straight line.

But before coding up the simple cases, we might as well face the general case,
since we must deal with it sooner or later, and since the general case
is likely to give some insight into the way simple cases can be handled best.

When there is no cycle, the linear equations to be solved form a tri-diagonal
system, and we can apply the standard technique of Gaussian elimination
to convert that system to a sequence of equations of the form
$$\theta_0+u_0\theta_1=v_0,\quad
\theta_1+u_1\theta_2=v_1,\quad\ldots,\quad
\theta_{n-1}+u_{n-1}\theta_n=v_{n-1},\quad
\theta_n=v_n.$$
It is possible to do this diagonalization while generating the equations.
Once $\theta_n$ is known, it is easy to determine $\theta_{n-1}$, \dots,
$\theta_1$, $\theta_0$; thus, the equations will be solved.

The procedure is slightly more complex when there is a cycle, but the
basic idea will be nearly the same. In the cyclic case the right-hand
sides will be $v_k+w_k\theta_0$ instead of simply $v_k$, and we will start
the process off with $u_0=v_0=0$, $w_0=1$. The final equation will be not
$\theta_n=v_n$ but $\theta_n+u_n\theta_1=v_n+w_n\theta_0$; an appropriate
ending routine will take account of the fact that $\theta_n=\theta_0$ and
eliminate the $w$'s from the system, after which the solution can be
obtained as before.

When $u_k$, $v_k$, and $w_k$ are being computed, the three pointer
variables |r|, |s|,~|t| will point respectively to knots |k-1|, |k|,
and~|k+1|. The $u$'s and $w$'s are scaled by $2^{28}$, i.e., they are
of type |fraction|; the $\theta$'s and $v$'s are of type |angle|.

@<Glob...@>=
angle @!theta[path_size+1]; /*values of $\theta_k$*/ 
fraction @!uu[path_size+1]; /*values of $u_k$*/ 
angle @!vv[path_size+1]; /*values of $v_k$*/ 
fraction @!ww[path_size+1]; /*values of $w_k$*/ 

@ Our immediate problem is to get the ball rolling by setting up the
first equation or by realizing that no equations are needed, and to fit
this initialization into a framework suitable for the overall computation.

@<Declare the procedure called |solve_choices|@>=
@t\4@>@<Declare subroutines needed by |solve_choices|@>@;
void solve_choices(pointer @!p, pointer @!q, halfword @!n)
{@+
int @!k; /*current knot number*/ 
pointer @!r, @!s, @!t; /*registers for list traversal*/ 
@<Other local variables for |solve_choices|@>@;
k=0;s=p;
loop@+{@+t=link(s);
  if (k==0) @<Get the linear equations started; or |return| with the control points
in place, if linear equations needn't be solved@>@;
  else switch (left_type(s)) {
    case end_cycle: case open: @<Set up equation to match mock curvatures at $z_k$;
then |goto found| with $\theta_n$ adjusted to equal $\theta_0$, if a cycle has ended@>@;@+break;
    case curl: @<Set up equation for a curl at $\theta_n$ and |goto found|@>@;
    case given: @<Calculate the given value of $\theta_n$ and |goto found|@>;
    }  /*there are no other cases*/ 
  r=s;s=t;incr(k);
  } 
found: @<Finish choosing angles and assigning control points@>;
} 

@ On the first time through the loop, we have |k==0| and |r| is not yet
defined. The first linear equation, if any, will have $A_0=B_0=0$.

@<Get the linear equations started...@>=
switch (right_type(s)) {
case given: if (left_type(t)==given) @<Reduce to simple case of two givens and |return|@>@;
  else@<Set up the equation for a given value of $\theta_0$@>@;@+break;
case curl: if (left_type(t)==curl) @<Reduce to simple case of straight line and |return|@>@;
  else@<Set up the equation for a curl at $\theta_0$@>@;@+break;
case open: {@+uu[0]=0;vv[0]=0;ww[0]=fraction_one;
  }  /*this begins a cycle*/ 
}  /*there are no other cases*/ 

@ The general equation that specifies equality of mock curvature at $z_k$ is
$$A_k\theta_{k-1}+(B_k+C_k)\theta_k+D_k\theta\k=-B_k\psi_k-D_k\psi\k,$$
as derived above. We want to combine this with the already-derived equation
$\theta_{k-1}+u_{k-1}\theta_k=v_{k-1}+w_{k-1}\theta_0$ in order to obtain
a new equation
$\theta_k+u_k\theta\k=v_k+w_k\theta_0$. This can be done by dividing the
equation
$$(B_k-u_{k-1}A_k+C_k)\theta_k+D_k\theta\k=-B_k\psi_k-D_k\psi\k-A_kv_{k-1}
    -A_kw_{k-1}\theta_0$$
by $B_k-u_{k-1}A_k+C_k$. The trick is to do this carefully with
fixed-point arithmetic, avoiding the chance of overflow while retaining
suitable precision.

The calculations will be performed in several registers that
provide temporary storage for intermediate quantities.

@<Other local variables for |solve_choices|@>=
fraction @!aa, @!bb, @!cc, @!ff, @!acc; /*temporary registers*/ 
scaled @!dd, @!ee; /*likewise, but |scaled|*/ 
scaled @!lt, @!rt; /*tension values*/ 

@ @<Set up equation to match mock curvatures...@>=
{@+@<Calculate the values $\\{aa}=A_k/B_k$, $\\{bb}=D_k/C_k$, $\\{dd}=(3-\alpha_{k-1})d_{k,k+1}$,
$\\{ee}=(3-\beta\k)d_{k-1,k}$, and $\\{cc}=(B_k-u_{k-1}A_k)/B_k$@>;
@<Calculate the ratio $\\{ff}=C_k/(C_k+B_k-u_{k-1}A_k)$@>;
uu[k]=take_fraction(ff, bb);
@<Calculate the values of $v_k$ and $w_k$@>;
if (left_type(s)==end_cycle) 
  @<Adjust $\theta_n$ to equal $\theta_0$ and |goto found|@>;
} 

@ Since tension values are never less than 3/4, the values |aa| and
|bb| computed here are never more than 4/5.

@<Calculate the values $\\{aa}=...@>=
if (abs(right_tension(r))==unity) 
  {@+aa=fraction_half;dd=2*delta[k];
  } 
else{@+aa=make_fraction(unity, 3*abs(right_tension(r))-unity);
  dd=take_fraction(delta[k],
    fraction_three-make_fraction(unity, abs(right_tension(r))));
  } 
if (abs(left_tension(t))==unity) 
  {@+bb=fraction_half;ee=2*delta[k-1];
  } 
else{@+bb=make_fraction(unity, 3*abs(left_tension(t))-unity);
  ee=take_fraction(delta[k-1],
    fraction_three-make_fraction(unity, abs(left_tension(t))));
  } 
cc=fraction_one-take_fraction(uu[k-1], aa)

@ The ratio to be calculated in this step can be written in the form
$$\beta_k^2\cdot\\{ee}\over\beta_k^2\cdot\\{ee}+\alpha_k^2\cdot
  \\{cc}\cdot\\{dd},$$
because of the quantities just calculated. The values of |dd| and |ee|
will not be needed after this step has been performed.

@<Calculate the ratio $\\{ff}=C_k/(C_k+B_k-u_{k-1}A_k)$@>=
dd=take_fraction(dd, cc);lt=abs(left_tension(s));rt=abs(right_tension(s));
if (lt!=rt)  /*$\beta_k^{-1}\ne\alpha_k^{-1}$*/ 
  if (lt < rt) 
    {@+ff=make_fraction(lt, rt);
    ff=take_fraction(ff, ff); /*$\alpha_k^2/\beta_k^2$*/ 
    dd=take_fraction(dd, ff);
    } 
  else{@+ff=make_fraction(rt, lt);
    ff=take_fraction(ff, ff); /*$\beta_k^2/\alpha_k^2$*/ 
    ee=take_fraction(ee, ff);
    } 
ff=make_fraction(ee, ee+dd)

@ The value of $u_{k-1}$ will be | <= 1| except when $k=1$ and the previous
equation was specified by a curl. In that case we must use a special
method of computation to prevent overflow.

Fortunately, the calculations turn out to be even simpler in this ``hard''
case. The curl equation makes $w_0=0$ and $v_0=-u_0\psi_1$, hence
$-B_1\psi_1-A_1v_0=-(B_1-u_0A_1)\psi_1=-\\{cc}\cdot B_1\psi_1$.

@<Calculate the values of $v_k$ and $w_k$@>=
acc=-take_fraction(psi[k+1], uu[k]);
if (right_type(r)==curl) 
  {@+ww[k]=0;
  vv[k]=acc-take_fraction(psi[1], fraction_one-ff);
  } 
else{@+ff=make_fraction(fraction_one-ff, cc); /*this is
    $B_k/(C_k+B_k-u_{k-1}A_k)<5$*/ 
  acc=acc-take_fraction(psi[k], ff);
  ff=take_fraction(ff, aa); /*this is $A_k/(C_k+B_k-u_{k-1}A_k)$*/ 
  vv[k]=acc-take_fraction(vv[k-1], ff);
  if (ww[k-1]==0) ww[k]=0;
  else ww[k]=-take_fraction(ww[k-1], ff);
  } 

@ When a complete cycle has been traversed, we have $\theta_k+u_k\theta\k=
v_k+w_k\theta_0$, for |1 <= k <= n|. We would like to determine the value of
$\theta_n$ and reduce the system to the form $\theta_k+u_k\theta\k=v_k$
for |0 <= k < n|, so that the cyclic case can be finished up just as if there
were no cycle.

The idea in the following code is to observe that
$$\eqalign{\theta_n&=v_n+w_n\theta_0-u_n\theta_1=\cdots\cr
&=v_n+w_n\theta_0-u_n\bigl(v_1+w_1\theta_0-u_1(v_2+\cdots
  -u_{n-2}(v_{n-1}+w_{n-1}\theta_0-u_{n-1}\theta_0)\ldots{})\bigr),\cr}$$
so we can solve for $\theta_n=\theta_0$.

@<Adjust $\theta_n$ to equal $\theta_0$ and |goto found|@>=
{@+aa=0;bb=fraction_one; /*we have |k==n|*/ 
@/do@+{decr(k);
if (k==0) k=n;
aa=vv[k]-take_fraction(aa, uu[k]);
bb=ww[k]-take_fraction(bb, uu[k]);
}@+ while (!(k==n)); /*now $\theta_n=\\{aa}+\\{bb}\cdot\theta_n$*/ 
aa=make_fraction(aa, fraction_one-bb);
theta[n]=aa;vv[0]=aa;
for (k=1; k<=n-1; k++) vv[k]=vv[k]+take_fraction(aa, ww[k]);
goto found;
} 

@ @d reduce_angle(X)	if (abs(X) > one_eighty_deg) 
  if (X > 0) X=X-three_sixty_deg;@+else X=X+three_sixty_deg

@<Calculate the given value of $\theta_n$...@>=
{@+theta[n]=left_given(s)-n_arg(delta_x[n-1], delta_y[n-1]);
reduce_angle(theta[n]);
goto found;
} 

@ @<Set up the equation for a given value of $\theta_0$@>=
{@+vv[0]=right_given(s)-n_arg(delta_x[0], delta_y[0]);
reduce_angle(vv[0]);
uu[0]=0;ww[0]=0;
} 

@ @<Set up the equation for a curl at $\theta_0$@>=
{@+cc=right_curl(s);lt=abs(left_tension(t));rt=abs(right_tension(s));
if ((rt==unity)&&(lt==unity)) 
  uu[0]=make_fraction(cc+cc+unity, cc+two);
else uu[0]=curl_ratio(cc, rt, lt);
vv[0]=-take_fraction(psi[1], uu[0]);ww[0]=0;
} 

@ @<Set up equation for a curl at $\theta_n$...@>=
{@+cc=left_curl(s);lt=abs(left_tension(s));rt=abs(right_tension(r));
if ((rt==unity)&&(lt==unity)) 
  ff=make_fraction(cc+cc+unity, cc+two);
else ff=curl_ratio(cc, lt, rt);
theta[n]=-make_fraction(take_fraction(vv[n-1], ff),
    fraction_one-take_fraction(ff, uu[n-1]));
goto found;
} 

@ The |curl_ratio| subroutine has three arguments, which our previous notation
encourages us to call $\gamma$, $\alpha^{-1}$, and $\beta^{-1}$. It is
a somewhat tedious program to calculate
$${(3-\alpha)\alpha^2\gamma+\beta^3\over
  \alpha^3\gamma+(3-\beta)\beta^2},$$
with the result reduced to 4 if it exceeds 4. (This reduction of curl
is necessary only if the curl and tension are both large.)
The values of $\alpha$ and $\beta$ will be at most~4/3.

@<Declare subroutines needed by |solve_choices|@>=
fraction curl_ratio(scaled @!gamma, scaled @!a_tension, scaled @!b_tension)
{@+fraction @!alpha, @!beta, @!num, @!denom, @!ff; /*registers*/ 
alpha=make_fraction(unity, a_tension);
beta=make_fraction(unity, b_tension);@/
if (alpha <= beta) 
  {@+ff=make_fraction(alpha, beta);ff=take_fraction(ff, ff);
  gamma=take_fraction(gamma, ff);@/
  beta=beta/010000; /*convert |fraction| to |scaled|*/ 
  denom=take_fraction(gamma, alpha)+three-beta;
  num=take_fraction(gamma, fraction_three-alpha)+beta;
  } 
else{@+ff=make_fraction(beta, alpha);ff=take_fraction(ff, ff);
  beta=take_fraction(beta, ff)/010000; /*convert |fraction| to |scaled|*/ 
  denom=take_fraction(gamma, alpha)+(ff/1365)-beta;
     /*$1365\approx 2^{12}/3$*/ 
  num=take_fraction(gamma, fraction_three-alpha)+beta;
  } 
if (num >= denom+denom+denom+denom) return fraction_four;
else return make_fraction(num, denom);
} 

@ We're in the home stretch now.

@<Finish choosing angles and assigning control points@>=
for (k=n-1; k>=0; k--) theta[k]=vv[k]-take_fraction(theta[k+1], uu[k]);
s=p;k=0;
@/do@+{t=link(s);@/
n_sin_cos(theta[k]);st=n_sin;ct=n_cos;@/
n_sin_cos(-psi[k+1]-theta[k+1]);sf=n_sin;cf=n_cos;@/
set_controls(s, t, k);@/
incr(k);s=t;
}@+ while (!(k==n))

@ The |set_controls| routine actually puts the control points into
a pair of consecutive nodes |p| and~|q|. Global variables are used to
record the values of $\sin\theta$, $\cos\theta$, $\sin\phi$, and
$\cos\phi$ needed in this calculation.

@<Glob...@>=
fraction @!st, @!ct, @!sf, @!cf; /*sines and cosines*/ 

@ @<Declare subroutines needed by |solve_choices|@>=
void set_controls(pointer @!p, pointer @!q, int @!k)
{@+fraction @!rr, @!ss; /*velocities, divided by thrice the tension*/ 
scaled @!lt, @!rt; /*tensions*/ 
fraction @!sine; /*$\sin(\theta+\phi)$*/ 
lt=abs(left_tension(q));rt=abs(right_tension(p));
rr=velocity(st, ct, sf, cf, rt);
ss=velocity(sf, cf, st, ct, lt);
if ((right_tension(p) < 0)||(left_tension(q) < 0)) @<Decrease the velocities, if necessary,
to stay inside the bounding triangle@>;
right_x(p)=x_coord(p)+take_fraction(
  take_fraction(delta_x[k], ct)-take_fraction(delta_y[k], st), rr);
right_y(p)=y_coord(p)+take_fraction(
  take_fraction(delta_y[k], ct)+take_fraction(delta_x[k], st), rr);
left_x(q)=x_coord(q)-take_fraction(
  take_fraction(delta_x[k], cf)+take_fraction(delta_y[k], sf), ss);
left_y(q)=y_coord(q)-take_fraction(
  take_fraction(delta_y[k], cf)-take_fraction(delta_x[k], sf), ss);
right_type(p)=explicit;left_type(q)=explicit;
} 

@ The boundedness conditions $\\{rr}\L\sin\phi\,/\sin(\theta+\phi)$ and
$\\{ss}\L\sin\theta\,/\sin(\theta+\phi)$ are to be enforced if $\sin\theta$,
$\sin\phi$, and $\sin(\theta+\phi)$ all have the same sign. Otherwise
there is no ``bounding triangle.''

@<Decrease the velocities, if necessary...@>=
if (((st >= 0)&&(sf >= 0))||((st <= 0)&&(sf <= 0))) 
  {@+sine=take_fraction(abs(st), cf)+take_fraction(abs(sf), ct);
  if (sine > 0) 
    {@+sine=take_fraction(sine, fraction_one+unity); /*safety factor*/ 
    if (right_tension(p) < 0) 
     if (ab_vs_cd(abs(sf), fraction_one, rr, sine) < 0) 
      rr=make_fraction(abs(sf), sine);
    if (left_tension(q) < 0) 
     if (ab_vs_cd(abs(st), fraction_one, ss, sine) < 0) 
      ss=make_fraction(abs(st), sine);
    } 
  } 

@ Only the simple cases remain to be handled.

@<Reduce to simple case of two givens and |return|@>=
{@+aa=n_arg(delta_x[0], delta_y[0]);@/
n_sin_cos(right_given(p)-aa);ct=n_cos;st=n_sin;@/
n_sin_cos(left_given(q)-aa);cf=n_cos;sf=-n_sin;@/
set_controls(p, q, 0);return;
} 

@ @<Reduce to simple case of straight line and |return|@>=
{@+right_type(p)=explicit;left_type(q)=explicit;
lt=abs(left_tension(q));rt=abs(right_tension(p));
if (rt==unity) 
  {@+if (delta_x[0] >= 0) right_x(p)=x_coord(p)+((delta_x[0]+1)/3);
  else right_x(p)=x_coord(p)+((delta_x[0]-1)/3);
  if (delta_y[0] >= 0) right_y(p)=y_coord(p)+((delta_y[0]+1)/3);
  else right_y(p)=y_coord(p)+((delta_y[0]-1)/3);
  } 
else{@+ff=make_fraction(unity, 3*rt); /*$\alpha/3$*/ 
  right_x(p)=x_coord(p)+take_fraction(delta_x[0], ff);
  right_y(p)=y_coord(p)+take_fraction(delta_y[0], ff);
  } 
if (lt==unity) 
  {@+if (delta_x[0] >= 0) left_x(q)=x_coord(q)-((delta_x[0]+1)/3);
  else left_x(q)=x_coord(q)-((delta_x[0]-1)/3);
  if (delta_y[0] >= 0) left_y(q)=y_coord(q)-((delta_y[0]+1)/3);
  else left_y(q)=y_coord(q)-((delta_y[0]-1)/3);
  } 
else{@+ff=make_fraction(unity, 3*lt); /*$\beta/3$*/ 
  left_x(q)=x_coord(q)-take_fraction(delta_x[0], ff);
  left_y(q)=y_coord(q)-take_fraction(delta_y[0], ff);
  } 
return;
} 

@* Generating discrete moves.
The purpose of the next part of \MF\ is to compute discrete approximations
to curves described as parametric polynomial functions $z(t)$.
We shall start with the low level first, because an efficient ``engine''
is needed to support the high-level constructions.

Most of the subroutines are based on variations of a single theme,
namely the idea of {\sl bisection}. Given a Bernshte{\u\i}n polynomial
@^Bernshte{\u\i}n, Serge{\u\i} Natanovich@>
$$B(z_0,z_1,\ldots,z_n;t)=\sum_k{n\choose k}t^k(1-t)^{n-k}z_k,$$
we can conveniently bisect its range as follows:

\smallskip
\textindent{1)} Let $z_k^{(0)}=z_k$, for |0 <= k <= n|.

\smallskip
\textindent{2)} Let $z_k^{(j+1)}={1\over2}(z_k^{(j)}+z\k^{(j)})$, for
|0 <= k < n-j|, for |0 <= j < n|.

\smallskip\noindent
Then
$$B(z_0,z_1,\ldots,z_n;t)=B(z_0^{(0)},z_0^{(1)},\ldots,z_0^{(n)};2t)
 =B(z_0^{(n)},z_1^{(n-1)},\ldots,z_n^{(0)};2t-1).$$
This formula gives us the coefficients of polynomials to use over the ranges
$0\L t\L{1\over2}$ and ${1\over2}\L t\L1$.

In our applications it will usually be possible to work indirectly with
numbers that allow us to deduce relevant properties of the polynomials
without actually computing the polynomial values. We will deal with
coefficients $Z_k=2^l(z_k-z_{k-1})$ for |1 <= k <= n|, instead of
the actual numbers $z_0$, $z_1$, \dots,~$z_n$, and the value of~|l| will
increase by~1 at each bisection step. This technique reduces the
amount of calculation needed for bisection and also increases the
accuracy of evaluation (since one bit of precision is gained at each
bisection). Indeed, the bisection process now becomes one level shorter:

\smallskip
\textindent{$1'$)} Let $Z_k^{(1)}=Z_k$, for |1 <= k <= n|.

\smallskip
\textindent{$2'$)} Let $Z_k^{(j+1)}={1\over2}(Z_k^{(j)}+Z\k^{(j)})$, for
|1 <= k <= n-j|, for |1 <= j < n|.

\smallskip\noindent
The relevant coefficients $(Z'_1,\ldots,Z'_n)$ and $(Z''_1,\ldots,Z''_n)$
for the two subintervals after bisection are respectively
$(Z_1^{(1)},Z_1^{(2)},\ldots,Z_1^{(n)})$ and
$(Z_1^{(n)},Z_2^{(n-1)},\ldots,Z_n^{(1)})$.
And the values of $z_0$ appropriate for the bisected interval are $z'_0=z_0$
and $z''_0=z_0+(Z'_1+Z'_2+\cdots+Z'_n)/2^{l+1}$.

Step $2'$ involves division by~2, which introduces computational errors
of at most $1\over2$ at each step; thus after $l$~levels of bisection the
integers $Z_k$ will differ from their true values by at most $(n-1)l/2$.
This error rate is quite acceptable, considering that we have $l$~more
bits of precision in the $Z$'s by comparison with the~$z$'s.  Note also
that the $Z$'s remain bounded; there's no danger of integer overflow, even
though we have the identity $Z_k=2^l(z_k-z_{k-1})$ for arbitrarily large~$l$.

In fact, we can show not only that the $Z$'s remain bounded, but also that
they become nearly equal, since they are control points for a polynomial
of one less degree. If $\vert Z\k-Z_k\vert\L M$ initially, it is possible
to prove that $\vert Z\k-Z_k\vert\L\lceil M/2^l\rceil$ after $l$~levels
of bisection, even in the presence of rounding errors. Here's the
proof [cf.~Lane and Riesenfeld, {\sl IEEE Trans.\ on Pattern Analysis
@^Lane, Jeffrey Michael@>
@^Riesenfeld, Richard Franklin@>
and Machine Intelligence\/ \bf PAMI-2} (1980), 35--46]: Assuming that
$\vert Z\k-Z_k\vert\L M$ before bisection, we want to prove that
$\vert Z\k-Z_k\vert\L\lceil M/2\rceil$ afterward. First we show that
$\vert Z\k^{(j)}-Z_k^{(j)}\vert\L M$ for all $j$ and~$k$, by induction
on~$j$; this follows from the fact that
$$\bigl\vert\\{half}(a+b)-\\{half}(b+c)\bigr\vert\L
 \max\bigl(\vert a-b\vert,\vert b-c\vert\bigr)$$
holds for both of the rounding rules $\\{half}(x)=\lfloor x/2\rfloor$
and $\\{half}(x)={\rm sign}(x)\lfloor\vert x/2\vert\rfloor$.
(If $\vert a-b\vert$ and $\vert b-c\vert$ are equal, then
$a+b$ and $b+c$ are both even or both odd. The rounding errors either
cancel or round the numbers toward each other; hence
$$\eqalign{\bigl\vert\\{half}(a+b)-\\{half}(b+c)\bigr\vert
&\L\textstyle\bigl\vert{1\over2}(a+b)-{1\over2}(b+c)\bigr\vert\cr
&=\textstyle\bigl\vert{1\over2}(a-b)+{1\over2}(b-c)\bigr\vert
\L\max\bigl(\vert a-b\vert,\vert b-c\vert\bigr),\cr}$$
as required. A simpler argument applies if $\vert a-b\vert$ and
$\vert b-c\vert$ are unequal.)  Now it is easy to see that
$\vert Z_1^{(j+1)}-Z_1^{(j)}\vert\L\bigl\lfloor{1\over2}
\vert Z_2^{(j)}-Z_1^{(j)}\vert+{1\over2}\bigr\rfloor
\L\bigl\lfloor{1\over2}(M+1)\bigr\rfloor=\lceil M/2\rceil$.

Another interesting fact about bisection is the identity
$$Z_1'+\cdots+Z_n'+Z_1''+\cdots+Z_n''=2(Z_1+\cdots+Z_n+E),$$
where $E$ is the sum of the rounding errors in all of the halving
operations ($\vert E\vert\L n(n-1)/4$).

@ We will later reduce the problem of digitizing a complex cubic
$z(t)=B(z_0,z_1,z_2,z_3;t)$ to the following simpler problem:
Given two real cubics
$x(t)=B(x_0,x_1,x_2,x_3;t)$
and $y(t)=B(y_0,y_1,y_2,y_3;t)$ that are monotone nondecreasing,
determine the set of integer points
$$P=\bigl\{\bigl(\lfloor x(t)\rfloor,\lfloor y(t)\rfloor\bigr)
\bigm\vert 0\L t\L 1\bigr\}.$$
Well, the problem isn't actually quite so clean as this; when the path
goes very near an integer point $(a,b)$, computational errors may
make us think that $P$ contains $(a-1,b)$ while in reality it should
contain $(a,b-1)$. Furthermore, if the path goes {\sl exactly\/}
through the integer points $(a-1,b-1)$ and
$(a,b)$, we will want $P$ to contain one
of the two points $(a-1,b)$ or $(a,b-1)$, so that $P$ can be described
entirely by ``rook moves'' upwards or to the right; no diagonal
moves from $(a-1,b-1)$ to~$(a,b)$ will be allowed.

Thus, the set $P$ we wish to compute will merely be an approximation
to the set described in the formula above. It will consist of
$\lfloor x(1)\rfloor-\lfloor x(0)\rfloor$ rightward moves and
$\lfloor y(1)\rfloor-\lfloor y(0)\rfloor$ upward moves, intermixed
in some order. Our job will be to figure out a suitable order.

The following recursive strategy suggests itself, when we recall that
$x(0)=x_0$, $x(1)=x_3$, $y(0)=y_0$, and $y(1)=y_3$:

\smallskip
If $\lfloor x_0\rfloor=\lfloor x_3\rfloor$ then take
$\lfloor y_3\rfloor-\lfloor y_0\rfloor$ steps up.

Otherwise if $\lfloor y_0\rfloor=\lfloor y_3\rfloor$ then take
$\lfloor x_3\rfloor-\lfloor x_0\rfloor$ steps to the right.

Otherwise bisect the current cubics and repeat the process on both halves.

\yskip\noindent
This intuitively appealing formulation does not quite solve the problem,
because it may never terminate. For example, it's not hard to see that
no steps will {\sl ever\/} be taken if $(x_0,x_1,x_2,x_3)=(y_0,y_1,y_2,y_3)$!
However, we can surmount this difficulty with a bit of care; so let's
proceed to flesh out the algorithm as stated, before worrying about
such details.

The bisect-and-double strategy discussed above suggests that we represent
$(x_0,x_1,x_2,x_3)$ by $(X_1,X_2,X_3)$, where $X_k=2^l(x_k-x_{k-1})$
for some~$l$. Initially $l=16$, since the $x$'s are |scaled|.
In order to deal with other aspects of the algorithm we will want to
maintain also the quantities $m=\lfloor x_3\rfloor-\lfloor x_0\rfloor$
and $R=2^l(x_0\bmod 1)$. Similarly,
$(y_0,y_1,y_2,y_3)$ will be represented by $(Y_1,Y_2,Y_3)$,
$n=\lfloor y_3\rfloor-\lfloor y_0\rfloor$,
and $S=2^l(y_0\bmod 1)$. The algorithm now takes the following form:

\smallskip
If $m=0$ then take $n$ steps up.

Otherwise if $n=0$ then take $m$ steps to the right.

Otherwise bisect the current cubics and repeat the process on both halves.

\smallskip\noindent
The bisection process for $(X_1,X_2,X_3,m,R,l)$ reduces, in essence,
to the following formulas:
$$\vbox{\halign{$#\hfil$\cr
X_2'=\\{half}(X_1+X_2),\quad
X_2''=\\{half}(X_2+X_3),\quad
X_3'=\\{half}(X_2'+X_2''),\cr
X_1'=X_1,\quad
X_1''=X_3',\quad
X_3''=X_3,\cr
R'=2R,\quad
T=X_1'+X_2'+X_3'+R',\quad
R''=T\bmod 2^{l+1},\cr
m'=\lfloor T/2^{l+1}\rfloor,\quad
m''=m-m'.\cr}}$$

@ When $m=n=1$, the computation can be speeded up because we simply
need to decide between two alternatives, (up,\thinspace right)
versus (right,\thinspace up). There appears to be no simple, direct
way to make the correct decision by looking at the values of
$(X_1,X_2,X_3,R)$ and
$(Y_1,Y_2,Y_3,S)$; but we can streamline the bisection process, and
we can use the fact that only one of the two descendants needs to
be examined after each bisection. Furthermore, we observed earlier
that after several levels of bisection the $X$'s and $Y$'s will be nearly
equal; so we will be justified in assuming that the curve is essentially a
straight line. (This, incidentally, solves the problem of infinite
recursion mentioned earlier.)

It is possible to show that
$$m=\bigl\lfloor(X_1+X_2+X_3+R+E)\,/\,2^l\bigr\rfloor,$$
where $E$ is an accumulated rounding error that is at most
$3\cdot(2^{l-16}-1)$ in absolute value. We will make sure that
the $X$'s are less than $2^{28}$; hence when $l=30$ we must
have |m <= 1|. This proves that the special case $m=n=1$ is
bound to be reached by the time $l=30$. Furthermore $l=30$ is
a suitable time to make the straight line approximation,
if the recursion hasn't already died out, because the maximum
difference between $X$'s will then be $<2^{14}$; this corresponds
to an error of $<1$ with respect to the original scaling.
(Stating this another way, each bisection makes the curve two bits
closer to a straight line, hence 14 bisections are sufficient for
28-bit accuracy.)

In the case of a straight line, the curve goes first right, then up,
if and only if $(T-2^l)(2^l-S)>(U-2^l)(2^l-R)$, where
$T=X_1+X_2+X_3+R$ and $U=Y_1+Y_2+Y_3+S$. For the actual curve
essentially runs from $(R/2^l,S/2^l)$ to $(T/2^l,U/2^l)$, and
we are testing whether or not $(1,1)$ is above the straight
line connecting these two points. (This formula assumes that $(1,1)$
is not exactly on the line.)

@ We have glossed over the problem of tie-breaking in ambiguous
cases when the cubic curve passes exactly through integer points.
\MF\ finesses this problem by assuming that coordinates
$(x,y)$ actually stand for slightly perturbed values $(x+\xi,y+\eta)$,
where $\xi$ and~$\eta$ are infinitesimals whose signs will determine
what to do when $x$ and/or~$y$ are exact integers. The quantities
$\lfloor x\rfloor$ and~$\lfloor y\rfloor$ in the formulas above
should actually read $\lfloor x+\xi\rfloor$ and $\lfloor y+\eta\rfloor$.

If $x$ is a |scaled| value, we have $\lfloor x+\xi\rfloor=\lfloor x\rfloor$
if $\xi>0$, and $\lfloor x+\xi\rfloor=\lfloor x-2^{-16}\rfloor$ if
$\xi<0$. It is convenient to represent $\xi$ by the integer |xi_corr|,
defined to be 0~if $\xi>0$ and 1~if $\xi<0$; then, for example, the
integer $\lfloor x+\xi\rfloor$ can be computed as
|floor_unscaled(x-xi_corr)|. Similarly, $\eta$ is conveniently
represented by~|eta_corr|.

In our applications the sign of $\xi-\eta$ will always be the same as
the sign of $\xi$. Therefore it turns out that the rule for straight
lines, as stated above, should be modified as follows in the case of
ties: The line goes first right, then up, if and only if
$(T-2^l)(2^l-S)+\xi>(U-2^l)(2^l-R)$. And this relation holds iff
$|ab_vs_cd|(T-2^l,2^l-S,U-2^l,2^l-R)-|xi_corr|\ge0$.

These conventions for rounding are symmetrical, in the sense that the
digitized moves obtained from $(x_0,x_1,x_2,x_3,y_0,y_1,y_2,y_3,\xi,\eta)$
will be exactly complementary to the moves that would be obtained from
$(-x_3,-x_2,-x_1,-x_0,-y_3,-y_2,-y_1,-y_0,-\xi,-\eta)$, if arithmetic
is exact. However, truncation errors in the bisection process might
upset the symmetry. We can restore much of the lost symmetry by adding
|xi_corr| or |eta_corr| when halving the data.

@ One further possibility needs to be mentioned: The algorithm
will be applied only to cubic polynomials $B(x_0,x_1,x_2,x_3;t)$ that
are nondecreasing as $t$~varies from 0 to~1; this condition turns
out to hold if and only if $x_0\L x_1$ and $x_2\L x_3$, and either
$x_1\L x_2$ or $(x_1-x_2)^2\L(x_1-x_0)(x_3-x_2)$. If bisection were
carried out with perfect accuracy, these relations would remain
invariant. But rounding errors can creep in, hence the bisection
algorithm can produce non-monotonic subproblems from monotonic
initial conditions. This leads to the potential danger that $m$ or~$n$
could become negative in the algorithm described above.

For example, if we start with $(x_1-x_0,x_2-x_1,x_3-x_2)=
(X_1,X_2,X_3)=(7,-16,39)$, the corresponding polynomial is
monotonic, because $16^2<7\cdot39$. But the bisection algorithm
produces the left descendant $(7,-5,3)$, which is nonmonotonic;
its right descendant is~$(0,-1,3)$.

\def\xt{{\tilde x}}
Fortunately we can prove that such rounding errors will never cause
the algorithm to make a tragic mistake. At every stage we are working
with numbers corresponding to a cubic polynomial $B(\xt_0,
\xt_1,\xt_2,\xt_3)$ that approximates some
monotonic polynomial $B(x_0,x_1,x_2,x_3)$. The accumulated errors are
controlled so that $\vert x_k-\xt_k\vert<\epsilon=3\cdot2^{-16}$.
If bisection is done at some stage of the recursion, we have
$m=\lfloor\xt_3\rfloor-\lfloor\xt_0\rfloor>0$, and the algorithm
computes a bisection value $\bar x$ such that $m'=\lfloor\bar x\rfloor-
\lfloor\xt_0\rfloor$
and $m''=\lfloor\xt_3\rfloor-\lfloor\bar x\rfloor$. We want to prove
that neither $m'$ nor $m''$ can be negative. Since $\bar x$ is an
approximation to a value in the interval $[x_0,x_3]$, we have
$\bar x>x_0-\epsilon$ and $\bar x<x_3+\epsilon$, hence $\bar x>
\xt_0-2\epsilon$ and $\bar x<\xt_3+2\epsilon$.
If $m'$ is negative we must have $\xt_0\bmod 1<2\epsilon$;
if $m''$ is negative we must have $\xt_3\bmod 1>1-2\epsilon$.
In either case the condition $\lfloor\xt_3\rfloor-\lfloor\xt_0\rfloor>0$
implies that $\xt_3-\xt_0>1-2\epsilon$, hence $x_3-x_0>1-4\epsilon$.
But it can be shown that if $B(x_0,x_1,x_2,x_3;t)$ is a monotonic
cubic, then $B(x_0,x_1,x_2,x_3;{1\over2})$ is always between
$.06[x_0,x_3]$ and $.94[x_0,x_3]$; and it is impossible for $\bar x$
to be within~$\epsilon$ of such a number. Contradiction!
(The constant .06 is actually $(2-\sqrt3\,)/4$; the worst case
occurs for polynomials like $B(0,2-\sqrt3,1-\sqrt3,3;t)$.)

@ OK, now that a long theoretical preamble has justified the
bisection-and-doubling algorithm, we are ready to proceed with
its actual coding. But we still haven't discussed the
form of the output.

For reasons to be discussed later, we shall find it convenient to
record the output as follows: Moving one step up is represented by
appending a `1' to a list; moving one step right is represented by
adding unity to the element at the end of the list. Thus, for example,
the net effect of ``(up, right, right, up, right)'' is to append
$(3,2)$.

The list is kept in a global array called |move|. Before starting the
algorithm, \MF\ should check that $\\{move\_ptr}+\lfloor y_3\rfloor
-\lfloor y_0\rfloor\L\\{move\_size}$, so that the list won't exceed
the bounds of this array.

@<Glob...@>=
int @!move[move_size+1]; /*the recorded moves*/ 
uint16_t @!move_ptr; /*the number of items in the |move| list*/ 

@ When bisection occurs, we ``push'' the subproblem corresponding
to the right-hand subinterval onto the |bisect_stack| while
we continue to work on the left-hand subinterval. Thus, the |bisect_stack|
will hold $(X_1,X_2,X_3,R,m,Y_1,Y_2,Y_3,S,n,l)$ values for
subproblems yet to be tackled.

At most 15 subproblems will be on the stack at once (namely, for
$l=15$,~16, \dots,~29); but the stack is bigger than this, because
it is used also for more complicated bisection algorithms.

@d stack_x1	bisect_stack[bisect_ptr] /*stacked value of $X_1$*/ 
@d stack_x2	bisect_stack[bisect_ptr+1] /*stacked value of $X_2$*/ 
@d stack_x3	bisect_stack[bisect_ptr+2] /*stacked value of $X_3$*/ 
@d stack_r	bisect_stack[bisect_ptr+3] /*stacked value of $R$*/ 
@d stack_m	bisect_stack[bisect_ptr+4] /*stacked value of $m$*/ 
@d stack_y1	bisect_stack[bisect_ptr+5] /*stacked value of $Y_1$*/ 
@d stack_y2	bisect_stack[bisect_ptr+6] /*stacked value of $Y_2$*/ 
@d stack_y3	bisect_stack[bisect_ptr+7] /*stacked value of $Y_3$*/ 
@d stack_s	bisect_stack[bisect_ptr+8] /*stacked value of $S$*/ 
@d stack_n	bisect_stack[bisect_ptr+9] /*stacked value of $n$*/ 
@d stack_l	bisect_stack[bisect_ptr+10] /*stacked value of $l$*/ 
@d move_increment	11 /*number of items pushed by |make_moves|*/ 

@<Glob...@>=
int @!bisect_stack[bistack_size+1];
uint16_t @!bisect_ptr;

@ @<Check the ``constant'' values...@>=
if (15*move_increment > bistack_size) bad=31;

@ The |make_moves| subroutine is given |scaled| values $(x_0,x_1,x_2,x_3)$
and $(y_0,y_1,y_2,y_3)$ that represent monotone-nondecreasing polynomials;
it makes $\lfloor x_3+\xi\rfloor-\lfloor x_0+\xi\rfloor$ rightward moves
and $\lfloor y_3+\eta\rfloor-\lfloor y_0+\eta\rfloor$ upward moves, as
explained earlier.  (Here $\lfloor x+\xi\rfloor$ actually stands for
$\lfloor x/2^{16}-|xi_corr|\rfloor$, if $x$ is regarded as an integer
without scaling.) The unscaled integers $x_k$ and~$y_k$ should be less
than $2^{28}$ in magnitude.

It is assumed that $|move_ptr| + \lfloor y_3+\eta\rfloor -
\lfloor y_0+\eta\rfloor < |move_size|$ when this procedure is called,
so that the capacity of the |move| array will not be exceeded.

The variables |r| and |s| in this procedure stand respectively for
$R-|xi_corr|$ and $S-|eta_corr|$ in the theory discussed above.

@p void make_moves(
  scaled @!xx0,
  scaled @!xx1,
  scaled @!xx2,
  scaled @!xx3,
  scaled @!yy0,
  scaled @!yy1,
  scaled @!yy2,
  scaled @!yy3, small_number @!xi_corr, small_number @!eta_corr)
{@+
int @!x1, @!x2, @!x3, @!m, @!r, @!y1, @!y2, @!y3, @!n, @!s, @!l;
   /*bisection variables explained above*/ 
int @!q, @!t, @!u, @!x2a, @!x3a, @!y2a, @!y3a; /*additional temporary registers*/ 
if ((xx3 < xx0)||(yy3 < yy0)) confusion('m');
@:this can't happen m}{\quad m@>
l=16;bisect_ptr=0;@/
x1=xx1-xx0;x2=xx2-xx1;x3=xx3-xx2;
if (xx0 >= xi_corr) r=(xx0-xi_corr)%unity;
else r=unity-1-((-xx0+xi_corr-1)%unity);
m=(xx3-xx0+r)/unity;@/
y1=yy1-yy0;y2=yy2-yy1;y3=yy3-yy2;
if (yy0 >= eta_corr) s=(yy0-eta_corr)%unity;
else s=unity-1-((-yy0+eta_corr-1)%unity);
n=(yy3-yy0+s)/unity;@/
if ((xx3-xx0 >= fraction_one)||(yy3-yy0 >= fraction_one)) 
  @<Divide the variables by two, to avoid overflow problems@>;
loop@+{@+resume: @<Make moves for current subinterval; if bisection is necessary,
push the second subinterval onto the stack, and |goto continue| in order to handle
the first subinterval@>;
  if (bisect_ptr==0) return;
  @<Remove a subproblem for |make_moves| from the stack@>;
  } 
} 

@ @<Remove a subproblem for |make_moves| from the stack@>=
bisect_ptr=bisect_ptr-move_increment;@/
x1=stack_x1;x2=stack_x2;x3=stack_x3;r=stack_r;m=stack_m;@/
y1=stack_y1;y2=stack_y2;y3=stack_y3;s=stack_s;n=stack_n;@/
l=stack_l

@ Our variables |(x1, x2, x3)| correspond to $(X_1,X_2,X_3)$ in the notation
of the theory developed above. We need to keep them less than $2^{28}$
in order to avoid integer overflow in weird circumstances.
For example, data like $x_0=-2^{28}+2^{16}-1$ and $x_1=x_2=x_3=2^{28}-1$
would otherwise be problematical. Hence this part of the code is
needed, if only to thwart malicious users.

@<Divide the variables by two, to avoid overflow problems@>=
{@+x1=half(x1+xi_corr);x2=half(x2+xi_corr);x3=half(x3+xi_corr);
r=half(r+xi_corr);@/
y1=half(y1+eta_corr);y2=half(y2+eta_corr);y3=half(y3+eta_corr);
s=half(s+eta_corr);@/
l=15;
} 

@ @<Make moves...@>=
if (m==0) @<Move upward |n| steps@>@;
else if (n==0) @<Move to the right |m| steps@>;
else if (m+n==2) @<Make one move of each kind@>@;
else{@+incr(l);stack_l=l;@/
  stack_x3=x3;stack_x2=half(x2+x3+xi_corr);x2=half(x1+x2+xi_corr);
  x3=half(x2+stack_x2+xi_corr);stack_x1=x3;@/
  r=r+r+xi_corr;t=x1+x2+x3+r;@/
  q=t/two_to_the[l];stack_r=t%two_to_the[l];@/
  stack_m=m-q;m=q;@/
  stack_y3=y3;stack_y2=half(y2+y3+eta_corr);y2=half(y1+y2+eta_corr);
  y3=half(y2+stack_y2+eta_corr);stack_y1=y3;@/
  s=s+s+eta_corr;u=y1+y2+y3+s;@/
  q=u/two_to_the[l];stack_s=u%two_to_the[l];@/
  stack_n=n-q;n=q;@/
  bisect_ptr=bisect_ptr+move_increment;goto resume;
  } 

@ @<Move upward |n| steps@>=
while (n > 0) 
  {@+incr(move_ptr);move[move_ptr]=1;decr(n);
  } 

@ @<Move to the right |m| steps@>=
move[move_ptr]=move[move_ptr]+m

@ @<Make one move of each kind@>=
{@+r=two_to_the[l]-r;s=two_to_the[l]-s;@/
while (l < 30) 
  {@+x3a=x3;x2a=half(x2+x3+xi_corr);x2=half(x1+x2+xi_corr);
  x3=half(x2+x2a+xi_corr);
  t=x1+x2+x3;r=r+r-xi_corr;@/
  y3a=y3;y2a=half(y2+y3+eta_corr);y2=half(y1+y2+eta_corr);
  y3=half(y2+y2a+eta_corr);
  u=y1+y2+y3;s=s+s-eta_corr;@/
  if (t < r) if (u < s) @<Switch to the right subinterval@>@;
    else{@+@<Move up then right@>;goto done;
      } 
  else if (u < s) 
    {@+@<Move right then up@>;goto done;
    } 
  incr(l);
  } 
r=r-xi_corr;s=s-eta_corr;
if (ab_vs_cd(x1+x2+x3, s, y1+y2+y3, r)-xi_corr >= 0) @<Move right then up@>@;
  else@<Move up then right@>;
done: ;
} 

@ @<Switch to the right subinterval@>=
{@+x1=x3;x2=x2a;x3=x3a;r=r-t;
y1=y3;y2=y2a;y3=y3a;s=s-u;
} 

@ @<Move right then up@>=
{@+incr(move[move_ptr]);incr(move_ptr);move[move_ptr]=1;
} 

@ @<Move up then right@>=
{@+incr(move_ptr);move[move_ptr]=2;
} 

@ After |make_moves| has acted, possibly for several curves that move toward
the same octant, a ``smoothing'' operation might be done on the |move| array.
This removes optical glitches that can arise even when the curve has been
digitized without rounding errors.

The smoothing process replaces the integers $a_0\ldots a_n$ in
|move[b dotdot t]| by ``smoothed'' integers $a_0'\ldots a_n'$ defined as
follows:
$$a_k'=a_k+\delta\k-\delta_k;\qquad
\delta_k=\cases{+1,&if $1<k<n$ and $a_{k-2}\G a_{k-1}\ll a_k\G a\k$;\cr
-1,&if $1<k<n$ and $a_{k-2}\L a_{k-1}\gg a_k\L a\k$;\cr
0,&otherwise.\cr}$$
Here $a\ll b$ means that $a\L b-2$, and $a\gg b$ means that $a\G b+2$.

The smoothing operation is symmetric in the sense that, if $a_0\ldots a_n$
smoothes to $a_0'\ldots a_n'$, then the reverse sequence $a_n\ldots a_0$
smoothes to $a_n'\ldots a_0'$; also the complementary sequence
$(m-a_0)\ldots(m-a_n)$ smoothes to $(m-a_0')\ldots(m-a_n')$.
We have $a_0'+\cdots+a_n'=a_0+\cdots+a_n$ because $\delta_0=\delta_{n+1}=0$.

@p void smooth_moves(int @!b, int @!t)
{@+uint16_t @!k; /*index into |move|*/ 
int @!a, @!aa, @!aaa; /*original values of |move[k], move[k-1], move[k-2]|*/ 
if (t-b >= 3) 
  {@+k=b+2;aa=move[k-1];aaa=move[k-2];
  @/do@+{a=move[k];
  if (abs(a-aa) > 1) 
    @<Increase and decrease |move[k-1]| and |move[k]| by $\delta_k$@>;
  incr(k);aaa=aa;aa=a;
  }@+ while (!(k==t));
  } 
} 

@ @<Increase and decrease |move[k-1]| and |move[k]| by $\delta_k$@>=
if (a > aa) 
  {@+if (aaa >= aa) if (a >= move[k+1]) 
    {@+incr(move[k-1]);move[k]=a-1;
    } 
  } 
else{@+if (aaa <= aa) if (a <= move[k+1]) 
    {@+decr(move[k-1]);move[k]=a+1;
    } 
  } 

@* Edge structures.
Now we come to \MF's internal scheme for representing what the user can
actually ``see,'' the edges between pixels. Each pixel has an integer
weight, obtained by summing the weights on all edges to its left. \MF\
represents only the nonzero edge weights, since most of the edges are
weightless; in this way, the data storage requirements grow only linearly
with respect to the number of pixels per point, even though two-dimensional
data is being represented. (Well, the actual dependence on the underlying
resolution is order $n\log n$, but the the $\log n$ factor is buried in our
implicit restriction on the maximum raster size.) The sum of all edge
weights in each row should be zero.

The data structure for edge weights must be compact and flexible,
yet it should support efficient updating and display operations. We
want to be able to have many different edge structures in memory at
once, and we want the computer to be able to translate them, reflect them,
and/or merge them together with relative ease.

\MF's solution to this problem requires one single-word node per
nonzero edge weight, plus one two-word node for each row in a contiguous
set of rows. There's also a header node that provides global information
about the entire structure.

@ Let's consider the edge-weight nodes first. The |info| field of such
nodes contains both an $m$~value and a weight~$w$, in the form
$8m+w+c$, where $c$ is a constant that depends on data found in the header.
We shall consider $c$ in detail later; for now, it's best just to think
of it as a way to compensate for the fact that $m$ and~$w$ can be negative,
together with the fact that an |info| field must have a value between
|min_halfword| and |max_halfword|. The $m$ value is an unscaled $x$~coordinate,
so it satisfies $\vert m\vert<
4096$; the $w$ value is always in the range $1\L\vert w\vert\L3$. We can
unpack the data in the |info| field by fetching |ho(info(p))==
info(p)-min_halfword| and dividing this nonnegative number by~8;
the constant~$c$ will be chosen so that the remainder of this division
is $4+w$. Thus, for example, a remainder of~3 will correspond to
the edge weight $w=-1$.

Every row of an edge structure contains two lists of such edge-weight
nodes, called the |sorted| and |unsorted| lists, linked together by their
|link| fields in the normal way. The difference between them is that we
always have |info(p) <= info(link(p))| in the |sorted| list, but there's no
such restriction on the elements of the |unsorted| list. The reason for
this distinction is that it would take unnecessarily long to maintain
edge-weight lists in sorted order while they're being updated; but when we
need to process an entire row from left to right in order of the
$m$~values, it's fairly easy and quick to sort a short list of unsorted
elements and to merge them into place among their sorted cohorts.
Furthermore, the fact that the |unsorted| list is empty can sometimes be
used to good advantage, because it allows us to conclude that a particular
row has not changed since the last time we sorted it.

The final |link| of the |sorted| list will be |sentinel|, which points to
a special one-word node whose |info| field is essentially infinite; this
facilitates the sorting and merging operations. The final |link| of the
|unsorted| list will be either |null| or |empty|, where |empty==null+1|
is used to avoid redisplaying data that has not changed:
A |empty| value is stored at the head of the
unsorted list whenever the corresponding row has been displayed.

@d zero_w	4
@d empty	null+1

@<Initialize table entries...@>=
info(sentinel)=max_halfword; /*|link(sentinel)==null|*/ 

@ The rows themselves are represented by row header nodes that
contain four link fields. Two of these four, |sorted| and |unsorted|,
point to the first items of the edge-weight lists just mentioned.
The other two, |link| and |knil|, point to the headers of the two
adjacent rows. If |p| points to the header for row number~|n|, then
|link(p)| points up to the header for row~|n+1|, and |knil(p)| points
down to the header for row~|n-1|. This double linking makes it
convenient to move through consecutive rows either upward or downward;
as usual, we have |link(knil(p))==knil(link(p))==p| for all row headers~|p|.

The row associated with a given value of |n| contains weights for
edges that run between the lattice points |(m, n)| and |(m, n+1)|.

@d knil	info /*inverse of the |link| field, in a doubly linked list*/ 
@d sorted_loc(X)	X+1 /*where the |sorted| link field resides*/ 
@d sorted(X)	link(sorted_loc(X)) /*beginning of the list of sorted edge weights*/ 
@d unsorted(X)	info(X+1) /*beginning of the list of unsorted edge weights*/ 
@d row_node_size	2 /*number of words in a row header node*/ 

@ The main header node |h| for an edge structure has |link| and |knil|
fields that link it above the topmost row and below the bottommost row.
It also has fields called |m_min|, |m_max|, |n_min|, and |n_max| that
bound the current extent of the edge data: All |m| values in edge-weight
nodes should lie between |m_min(h)-4096| and |m_max(h)-4096|, inclusive.
Furthermore the topmost row header, pointed to by |knil(h)|,
is for row number |n_max(h)-4096|; the bottommost row header, pointed to by
|link(h)|, is for row number |n_min(h)-4096|.

The offset constant |c| that's used in all of the edge-weight data is
represented implicitly in |m_offset(h)|; its actual value is
$$\hbox{|c==min_halfword+zero_w+8*m_offset(h)|.}$$
Notice that it's possible to shift an entire edge structure by an
amount $(\Delta m,\Delta n)$ by adding $\Delta n$ to |n_min(h)| and |n_max(h)|,
adding $\Delta m$ to |m_min(h)| and |m_max(h)|, and subtracting
$\Delta m$ from |m_offset(h)|;
none of the other edge data needs to be modified. Initially the |m_offset|
field is~4096, but it will change if the user requests such a shift.
The contents of these five fields should always be positive and less than
8192; |n_max| should, in fact, be less than 8191.  Furthermore
|m_min+m_offset-4096| and |m_max+m_offset-4096| must also lie strictly
between 0 and 8192, so that the |info| fields of edge-weight nodes will
fit in a halfword.

The header node of an edge structure also contains two somewhat unusual
fields that are called |last_window(h)| and |last_window_time(h)|. When this
structure is displayed in window~|k| of the user's screen, after that
window has been updated |t| times, \MF\ sets |last_window(h)=k| and
|last_window_time(h)=t|; it also sets |unsorted(p)=empty| for all row
headers~|p|, after merging any existing unsorted weights with the sorted
ones.  A subsequent display in the same window will be able to avoid
redisplaying rows whose |unsorted| list is still |empty|, if the window
hasn't been used for something else in the meantime.

A pointer to the row header of row |n_pos(h)-4096| is provided in
|n_rover(h)|. Most of the algorithms that update an edge structure
are able to get by without random row references; they usually
access rows that are neighbors of each other or of the current |n_pos| row.
Exception: If |link(h)==h| (so that the edge structure contains
no rows), we have |n_rover(h)==h|, and |n_pos(h)| is irrelevant.

@d zero_field	4096 /*amount added to coordinates to make them positive*/ 
@d n_min(X)	info(X+1) /*minimum row number present, plus |zero_field|*/ 
@d n_max(X)	link(X+1) /*maximum row number present, plus |zero_field|*/ 
@d m_min(X)	info(X+2) /*minimum column number present, plus |zero_field|*/ 
@d m_max(X)	link(X+2) /*maximum column number present, plus |zero_field|*/ 
@d m_offset(X)	info(X+3) /*translation of $m$ data in edge-weight nodes*/ 
@d last_window(X)	link(X+3) /*the last display went into this window*/ 
@d last_window_time(X)	mem[X+4].i /*after this many window updates*/ 
@d n_pos(X)	info(X+5) /*the row currently in |n_rover|, plus |zero_field|*/ 
@d n_rover(X)	link(X+5) /*a row recently referenced*/ 
@d edge_header_size	6 /*number of words in an edge-structure header*/ 
@d valid_range(X)	(abs(X-4096) < 4096) /*is |X| strictly between 0 and 8192?*/ 
@d empty_edges(X)	link(X)==X /*are there no rows in this edge header?*/ 

@p void init_edges(pointer @!h) /*initialize an edge header to null values*/ 
{@+knil(h)=h;link(h)=h;@/
n_min(h)=zero_field+4095;n_max(h)=zero_field-4095;
m_min(h)=zero_field+4095;m_max(h)=zero_field-4095;
m_offset(h)=zero_field;@/
last_window(h)=0;last_window_time(h)=0;@/
n_rover(h)=h;n_pos(h)=0;@/
} 

@ When a lot of work is being done on a particular edge structure, we plant
a pointer to its main header in the global variable |cur_edges|.
This saves us from having to pass this pointer as a parameter over and
over again between subroutines.

Similarly, |cur_wt| is a global weight that is being used by several
procedures at once.

@<Glob...@>=
pointer @!cur_edges; /*the edge structure of current interest*/ 
int @!cur_wt; /*the edge weight of current interest*/ 

@ The |fix_offset| routine goes through all the edge-weight nodes of
|cur_edges| and adds a constant to their |info| fields, so that
|m_offset(cur_edges)| can be brought back to |zero_field|. (This
is necessary only in unusual cases when the offset has gotten too
large or too small.)

@p void fix_offset(void)
{@+pointer @!p, @!q; /*list traversers*/ 
int @!delta; /*the amount of change*/ 
delta=8*(m_offset(cur_edges)-zero_field);
m_offset(cur_edges)=zero_field;
q=link(cur_edges);
while (q!=cur_edges) 
  {@+p=sorted(q);
  while (p!=sentinel) 
    {@+info(p)=info(p)-delta;p=link(p);
    } 
  p=unsorted(q);
  while (p > empty) 
    {@+info(p)=info(p)-delta;p=link(p);
    } 
  q=link(q);
  } 
} 

@ The |edge_prep| routine makes the |cur_edges| structure ready to
accept new data whose coordinates satisfy |ml <= m <= mr| and |nl <= n <= nr-1|,
assuming that |-4096 < ml <= mr < 4096| and |-4096 < nl <= nr < 4096|. It makes
appropriate adjustments to |m_min|, |m_max|, |n_min|, and |n_max|,
adding new empty rows if necessary.

@p void edge_prep(int @!ml, int @!mr, int @!nl, int @!nr)
{@+halfword @!delta; /*amount of change*/ 
pointer @!p, @!q; /*for list manipulation*/ 
ml=ml+zero_field;mr=mr+zero_field;
nl=nl+zero_field;nr=nr-1+zero_field;@/
if (ml < m_min(cur_edges)) m_min(cur_edges)=ml;
if (mr > m_max(cur_edges)) m_max(cur_edges)=mr;
if (!valid_range(m_min(cur_edges)+m_offset(cur_edges)-zero_field)||@|
 !valid_range(m_max(cur_edges)+m_offset(cur_edges)-zero_field)) 
  fix_offset();
if (empty_edges(cur_edges))  /*there are no rows*/ 
  {@+n_min(cur_edges)=nr+1;n_max(cur_edges)=nr;
  } 
if (nl < n_min(cur_edges)) 
  @<Insert exactly |n_min(cur_edges)-nl| empty rows at the bottom@>;
if (nr > n_max(cur_edges)) 
  @<Insert exactly |nr-n_max(cur_edges)| empty rows at the top@>;
} 

@ @<Insert exactly |n_min(cur_edges)-nl| empty rows at the bottom@>=
{@+delta=n_min(cur_edges)-nl;n_min(cur_edges)=nl;
p=link(cur_edges);
@/do@+{q=get_node(row_node_size);sorted(q)=sentinel;unsorted(q)=empty;
knil(p)=q;link(q)=p;p=q;decr(delta);
}@+ while (!(delta==0));
knil(p)=cur_edges;link(cur_edges)=p;
if (n_rover(cur_edges)==cur_edges) n_pos(cur_edges)=nl-1;
} 

@ @<Insert exactly |nr-n_max(cur_edges)| empty rows at the top@>=
{@+delta=nr-n_max(cur_edges);n_max(cur_edges)=nr;
p=knil(cur_edges);
@/do@+{q=get_node(row_node_size);sorted(q)=sentinel;unsorted(q)=empty;
link(p)=q;knil(q)=p;p=q;decr(delta);
}@+ while (!(delta==0));
link(p)=cur_edges;knil(cur_edges)=p;
if (n_rover(cur_edges)==cur_edges) n_pos(cur_edges)=nr+1;
} 

@ The |print_edges| subroutine gives a symbolic rendition of an edge
structure, for use in `\&{show}' commands. A rather terse output
format has been chosen since edge structures can grow quite large.

@<Declare subroutines for printing expressions@>=
@t\4@>@<Declare the procedure called |print_weight|@>@;@/
void print_edges(str_number @!s, bool @!nuline, int @!x_off, int @!y_off)
{@+pointer @!p, @!q, @!r; /*for list traversal*/ 
int @!n; /*row number*/ 
print_diagnostic(@[@<|"Edge structure"|@>@], s, nuline);
p=knil(cur_edges);n=n_max(cur_edges)-zero_field;
while (p!=cur_edges) 
  {@+q=unsorted(p);r=sorted(p);
  if ((q > empty)||(r!=sentinel)) 
    {@+print_nl("row ");print_int(n+y_off);print_char(':');
    while (q > empty) 
      {@+print_weight(q, x_off);q=link(q);
      } 
    print_str(" |");
    while (r!=sentinel) 
      {@+print_weight(r, x_off);r=link(r);
      } 
    } 
  p=knil(p);decr(n);
  } 
end_diagnostic(true);
} 

@ @<Declare the procedure called |print_weight|@>=
void print_weight(pointer @!q, int @!x_off)
{@+int @!w, @!m; /*unpacked weight and coordinate*/ 
int @!d; /*temporary data register*/ 
d=ho(info(q));w=d%8;m=(d/8)-m_offset(cur_edges);
if (file_offset > max_print_line-9) print_nl(" ");
else print_char(' ');
print_int(m+x_off);
while (w > zero_w) 
  {@+print_char('+');decr(w);
  } 
while (w < zero_w) 
  {@+print_char('-');incr(w);
  } 
} 

@ Here's a trivial subroutine that copies an edge structure. (Let's hope
that the given structure isn't too gigantic.)

@p pointer copy_edges(pointer @!h)
{@+pointer @!p, @!r; /*variables that traverse the given structure*/ 
pointer @!hh, @!pp, @!qq, @!rr, @!ss; /*variables that traverse the new structure*/ 
hh=get_node(edge_header_size);
mem[hh+1]=mem[h+1];mem[hh+2]=mem[h+2];
mem[hh+3]=mem[h+3];mem[hh+4]=mem[h+4]; /*we've now copied |n_min|, |n_max|,
  |m_min|, |m_max|, |m_offset|, |last_window|, and |last_window_time|*/ 
n_pos(hh)=n_max(hh)+1;n_rover(hh)=hh;@/
p=link(h);qq=hh;
while (p!=h) 
  {@+pp=get_node(row_node_size);link(qq)=pp;knil(pp)=qq;
  @<Copy both |sorted| and |unsorted| lists of |p| to |pp|@>;
  p=link(p);qq=pp;
  } 
link(qq)=hh;knil(hh)=qq;
return hh;
} 

@ @<Copy both |sorted| and |unsorted|...@>=
r=sorted(p);rr=sorted_loc(pp); /*|link(rr)==sorted(pp)|*/ 
while (r!=sentinel) 
  {@+ss=get_avail();link(rr)=ss;rr=ss;info(rr)=info(r);@/
  r=link(r);
  } 
link(rr)=sentinel;@/
r=unsorted(p);rr=temp_head;
while (r > empty) 
  {@+ss=get_avail();link(rr)=ss;rr=ss;info(rr)=info(r);@/
  r=link(r);
  } 
link(rr)=r;unsorted(pp)=link(temp_head)

@ Another trivial routine flips |cur_edges| about the |x|-axis
(i.e., negates all the |y| coordinates), assuming that at least
one row is present.

@p void y_reflect_edges(void)
{@+pointer @!p, @!q, @!r; /*list manipulation registers*/ 
p=n_min(cur_edges);
n_min(cur_edges)=zero_field+zero_field-1-n_max(cur_edges);
n_max(cur_edges)=zero_field+zero_field-1-p;
n_pos(cur_edges)=zero_field+zero_field-1-n_pos(cur_edges);@/
p=link(cur_edges);q=cur_edges; /*we assume that |p!=q|*/ 
@/do@+{r=link(p);link(p)=q;knil(q)=p;q=p;p=r;
}@+ while (!(q==cur_edges));
last_window_time(cur_edges)=0;
} 

@ It's somewhat more difficult, yet not too hard, to reflect about the |y|-axis.

@p void x_reflect_edges(void)
{@+pointer @!p, @!q, @!r, @!s; /*list manipulation registers*/ 
int @!m; /*|info| fields will be reflected with respect to this number*/ 
p=m_min(cur_edges);
m_min(cur_edges)=zero_field+zero_field-m_max(cur_edges);
m_max(cur_edges)=zero_field+zero_field-p;
m=(zero_field+m_offset(cur_edges))*8+zero_w+min_halfword+zero_w+min_halfword;
m_offset(cur_edges)=zero_field;
p=link(cur_edges);
@/do@+{@<Reflect the edge-and-weight data in |sorted(p)|@>;
@<Reflect the edge-and-weight data in |unsorted(p)|@>;
p=link(p);
}@+ while (!(p==cur_edges));
last_window_time(cur_edges)=0;
} 

@ We want to change the sign of the weight as we change the sign of the
|x|~coordinate. Fortunately, it's easier to do this than to negate
one without the other.

@<Reflect the edge-and-weight data in |unsorted(p)|@>=
q=unsorted(p);
while (q > empty) 
  {@+info(q)=m-info(q);q=link(q);
  } 

@ Reversing the order of a linked list is best thought of as the process of
popping nodes off one stack and pushing them on another. In this case we
pop from stack~|q| and push to stack~|r|.

@<Reflect the edge-and-weight data in |sorted(p)|@>=
q=sorted(p);r=sentinel;
while (q!=sentinel) 
  {@+s=link(q);link(q)=r;r=q;info(r)=m-info(q);q=s;
  } 
sorted(p)=r

@ Now let's multiply all the $y$~coordinates of a nonempty edge structure
by a small integer $s>1$:

@p void y_scale_edges(int @!s)
{@+pointer @!p, @!q, @!pp, @!r, @!rr, @!ss; /*list manipulation registers*/ 
int @!t; /*replication counter*/ 
if ((s*(n_max(cur_edges)+1-zero_field) >= 4096)||@|
 (s*(n_min(cur_edges)-zero_field) <= -4096)) 
  {@+print_err("Scaled picture would be too big");
@.Scaled picture...big@>
  help3("I can't yscale the picture as requested---it would")@/
    ("make some coordinates too large or too small.")@/
    ("Proceed, and I'll omit the transformation.");
  put_get_error();
  } 
else{@+n_max(cur_edges)=s*(n_max(cur_edges)+1-zero_field)-1+zero_field;
  n_min(cur_edges)=s*(n_min(cur_edges)-zero_field)+zero_field;
  @<Replicate every row exactly $s$ times@>;
  last_window_time(cur_edges)=0;
  } 
} 

@ @<Replicate...@>=
p=cur_edges;
@/do@+{q=p;p=link(p);
for (t=2; t<=s; t++) 
  {@+pp=get_node(row_node_size);link(q)=pp;knil(p)=pp;
  link(pp)=p;knil(pp)=q;q=pp;
  @<Copy both |sorted| and |unsorted|...@>;
  } 
}@+ while (!(link(p)==cur_edges))

@ Scaling the $x$~coordinates is, of course, our next task.

@p void x_scale_edges(int @!s)
{@+pointer @!p, @!q; /*list manipulation registers*/ 
uint16_t @!t; /*unpacked |info| field*/ 
uint8_t @!w; /*unpacked weight*/ 
int @!delta; /*amount added to scaled |info|*/ 
if ((s*(m_max(cur_edges)-zero_field) >= 4096)||@|
 (s*(m_min(cur_edges)-zero_field) <= -4096)) 
  {@+print_err("Scaled picture would be too big");
@.Scaled picture...big@>
  help3("I can't xscale the picture as requested---it would")@/
    ("make some coordinates too large or too small.")@/
    ("Proceed, and I'll omit the transformation.");
  put_get_error();
  } 
else if ((m_max(cur_edges)!=zero_field)||(m_min(cur_edges)!=zero_field)) 
  {@+m_max(cur_edges)=s*(m_max(cur_edges)-zero_field)+zero_field;
  m_min(cur_edges)=s*(m_min(cur_edges)-zero_field)+zero_field;
  delta=8*(zero_field-s*m_offset(cur_edges))+min_halfword;
  m_offset(cur_edges)=zero_field;@/
  @<Scale the $x$~coordinates of each row by $s$@>;
  last_window_time(cur_edges)=0;
  } 
} 

@ The multiplications cannot overflow because we know that |s < 4096|.

@<Scale the $x$~coordinates of each row by $s$@>=
q=link(cur_edges);
@/do@+{p=sorted(q);
while (p!=sentinel) 
  {@+t=ho(info(p));w=t%8;info(p)=(t-w)*s+w+delta;p=link(p);
  } 
p=unsorted(q);
while (p > empty) 
  {@+t=ho(info(p));w=t%8;info(p)=(t-w)*s+w+delta;p=link(p);
  } 
q=link(q);
}@+ while (!(q==cur_edges))

@ Here is a routine that changes the signs of all the weights, without
changing anything else.

@p void negate_edges(pointer @!h)
{@+
pointer @!p, @!q, @!r, @!s, @!t, @!u; /*structure traversers*/ 
p=link(h);
while (p!=h) 
  {@+q=unsorted(p);
  while (q > empty) 
    {@+info(q)=8-2*((ho(info(q)))%8)+info(q);q=link(q);
    } 
  q=sorted(p);
  if (q!=sentinel) 
    {@+@/do@+{info(q)=8-2*((ho(info(q)))%8)+info(q);q=link(q);
    }@+ while (!(q==sentinel));
    @<Put the list |sorted(p)| back into sort@>;
    } 
  p=link(p);
  } 
last_window_time(h)=0;
} 

@ \MF\ would work even if the code in this section were omitted, because
a list of edge-and-weight data that is sorted only by
|m| but not~|w| turns out to be good enough for correct operation.
However, the author decided not to make the program even trickier than
it is already, since |negate_edges| isn't needed very often.
The simpler-to-state condition, ``keep the |sorted| list fully sorted,''
is therefore being preserved at the cost of extra computation.

@<Put the list |sorted(p)|...@>=
u=sorted_loc(p);q=link(u);r=q;s=link(r); /*|q==sorted(p)|*/ 
loop@+if (info(s) > info(r)) 
    {@+link(u)=q;
    if (s==sentinel) goto done;
    u=r;q=s;r=q;s=link(r);
    } 
  else{@+t=s;s=link(t);link(t)=q;q=t;
    } 
done: link(r)=sentinel

@ The |unsorted| edges of a row are merged into the |sorted| ones by
a subroutine called |sort_edges|. It uses simple insertion sort,
followed by a merge, because the unsorted list is supposedly quite short.
However, the unsorted list is assumed to be nonempty.

@p void sort_edges(pointer @!h) /*|h| is a row header*/ 
{@+
halfword @!k; /*key register that we compare to |info(q)|*/ 
pointer @!p, @!q, @!r, @!s;
r=unsorted(h);unsorted(h)=null;
p=link(r);link(r)=sentinel;link(temp_head)=r;
while (p > empty)  /*sort node |p| into the list that starts at |temp_head|*/ 
  {@+k=info(p);q=temp_head;
  @/do@+{r=q;q=link(r);
  }@+ while (!(k <= info(q)));
  link(r)=p;r=link(p);link(p)=q;p=r;
  } 
@<Merge the |temp_head| list into |sorted(h)|@>;
} 

@ In this step we use the fact that |sorted(h)==link(sorted_loc(h))|.

@<Merge the |temp_head| list into |sorted(h)|@>=
{@+r=sorted_loc(h);q=link(r);p=link(temp_head);
loop@+{@+k=info(p);
  while (k > info(q)) 
    {@+r=q;q=link(r);
    } 
  link(r)=p;s=link(p);link(p)=q;
  if (s==sentinel) goto done;
  r=p;p=s;
  } 
done: ;} 

@ The |cull_edges| procedure ``optimizes'' an edge structure by making all
the pixel weights either |w_out| or~|w_in|. The weight will be~|w_in| after the
operation if and only if it was in the closed interval |[w_lo, w_hi]|
before, where |w_lo <= w_hi|. Either |w_out| or |w_in| is zero, while the other is
$\pm1$, $\pm2$, or $\pm3$. The parameters will be such that zero-weight
pixels will remain of weight zero.  (This is fortunate,
because there are infinitely many of them.)

The procedure also computes the tightest possible bounds on the resulting
data, by updating |m_min|, |m_max|, |n_min|, and~|n_max|.

@p void cull_edges(int @!w_lo, int @!w_hi, int @!w_out, int @!w_in)
{@+
pointer @!p, @!q, @!r, @!s; /*for list manipulation*/ 
int @!w; /*new weight after culling*/ 
int @!d; /*data register for unpacking*/ 
int @!m; /*the previous column number, including |m_offset|*/ 
int @!mm; /*the next column number, including |m_offset|*/ 
int @!ww; /*accumulated weight before culling*/ 
int @!prev_w; /*value of |w| before column |m|*/ 
pointer @!n, @!min_n, @!max_n; /*current and extreme row numbers*/ 
pointer @!min_d, @!max_d; /*extremes of the new edge-and-weight data*/ 
min_d=max_halfword;max_d=min_halfword;
min_n=max_halfword;max_n=min_halfword;@/
p=link(cur_edges);n=n_min(cur_edges);
while (p!=cur_edges) 
  {@+if (unsorted(p) > empty) sort_edges(p);
  if (sorted(p)!=sentinel) 
    @<Cull superfluous edge-weight entries from |sorted(p)|@>;
  p=link(p);incr(n);
  } 
@<Delete empty rows at the top and/or bottom; update the boundary values in the header@>;
last_window_time(cur_edges)=0;
} 

@ The entire |sorted| list is returned to available memory in this step;
a new list is built starting (temporarily) at |temp_head|.
Since several edges can occur at the same column, we need to be looking
ahead of where the actual culling takes place. This means that it's
slightly tricky to get the iteration started and stopped.

@<Cull superfluous...@>=
{@+r=temp_head;q=sorted(p);ww=0;m=1000000;prev_w=0;
loop@+{@+if (q==sentinel) mm=1000000;
  else{@+d=ho(info(q));mm=d/8;ww=ww+(d%8)-zero_w;
    } 
  if (mm > m) 
    {@+@<Insert an edge-weight for edge |m|, if the new pixel weight has changed@>;
    if (q==sentinel) goto done;
    } 
  m=mm;
  if (ww >= w_lo) if (ww <= w_hi) w=w_in;
    else w=w_out;
  else w=w_out;
  s=link(q);free_avail(q);q=s;
  } 
done: link(r)=sentinel;sorted(p)=link(temp_head);
if (r!=temp_head) @<Update the max/min amounts@>;
} 

@ @<Insert an edge-weight for edge |m|, if...@>=
if (w!=prev_w) 
  {@+s=get_avail();link(r)=s;
  info(s)=8*m+min_halfword+zero_w+w-prev_w;
  r=s;prev_w=w;
  } 

@ @<Update the max/min amounts@>=
{@+if (min_n==max_halfword) min_n=n;
max_n=n;
if (min_d > info(link(temp_head))) min_d=info(link(temp_head));
if (max_d < info(r)) max_d=info(r);
} 

@ @<Delete empty rows at the top and/or bottom...@>=
if (min_n > max_n) @<Delete all the row headers@>@;
else{@+n=n_min(cur_edges);n_min(cur_edges)=min_n;
  while (min_n > n) 
    {@+p=link(cur_edges);link(cur_edges)=link(p);
    knil(link(p))=cur_edges;
    free_node(p, row_node_size);incr(n);
    } 
  n=n_max(cur_edges);n_max(cur_edges)=max_n;
  n_pos(cur_edges)=max_n+1;n_rover(cur_edges)=cur_edges;
  while (max_n < n) 
    {@+p=knil(cur_edges);knil(cur_edges)=knil(p);
    link(knil(p))=cur_edges;
    free_node(p, row_node_size);decr(n);
    } 
  m_min(cur_edges)=((ho(min_d))/8)-m_offset(cur_edges)+zero_field;
  m_max(cur_edges)=((ho(max_d))/8)-m_offset(cur_edges)+zero_field;
  } 

@ We get here if the edges have been entirely culled away.

@<Delete all the row headers@>=
{@+p=link(cur_edges);
while (p!=cur_edges) 
  {@+q=link(p);free_node(p, row_node_size);p=q;
  } 
init_edges(cur_edges);
} 


@ The last and most difficult routine for transforming an edge structure---and
the most interesting one!---is |xy_swap_edges|, which interchanges the
r\^^Doles of rows and columns. Its task can be viewed as the job of
creating an edge structure that contains only horizontal edges, linked
together in columns, given an edge structure that contains only
vertical edges linked together in rows; we must do this without changing
the implied pixel weights.

Given any two adjacent rows of an edge structure, it is not difficult to
determine the horizontal edges that lie ``between'' them: We simply look
for vertically adjacent pixels that have different weight, and insert
a horizontal edge containing the difference in weights. Every horizontal
edge determined in this way should be put into an appropriate linked
list. Since random access to these linked lists is desirable, we use
the |move| array to hold the list heads. If we work through the given
edge structure from top to bottom, the constructed lists will not need
to be sorted, since they will already be in order.

The following algorithm makes use of some ideas suggested by John Hobby.
@^Hobby, John Douglas@>
It assumes that the edge structure is non-null, i.e., that |link(cur_edges)
!=cur_edges|, hence |m_max(cur_edges) >= m_min(cur_edges)|.

@p void xy_swap_edges(void) /*interchange |x| and |y| in |cur_edges|*/ 
{@+
int @!m_magic, @!n_magic; /*special values that account for offsets*/ 
pointer @!p, @!q, @!r, @!s; /*pointers that traverse the given structure*/ 
@<Other local variables for |xy_swap_edges|@>@;
@<Initialize the array of new edge list heads@>;
@<Insert blank rows at the top and bottom, and set |p| to the new top row@>;
@<Compute the magic offset values@>;
@/do@+{q=knil(p);@+if (unsorted(q) > empty) sort_edges(q);
@<Insert the horizontal edges defined by adjacent rows |p,q|, and destroy row~|p|@>;
p=q;n_magic=n_magic-8;
}@+ while (!(knil(p)==cur_edges));
free_node(p, row_node_size); /*now all original rows have been recycled*/ 
@<Adjust the header to reflect the new edges@>;
} 

@ Here we don't bother to keep the |link| entries up to date, since the
procedure looks only at the |knil| fields as it destroys the former
edge structure.

@<Insert blank rows at the top and bottom...@>=
p=get_node(row_node_size);sorted(p)=sentinel;unsorted(p)=null;@/
knil(p)=cur_edges;knil(link(cur_edges))=p; /*the new bottom row*/ 
p=get_node(row_node_size);sorted(p)=sentinel;
knil(p)=knil(cur_edges); /*the new top row*/ 

@ The new lists will become |sorted| lists later, so we initialize
empty lists to |sentinel|.

@<Initialize the array of new edge list heads@>=
m_spread=m_max(cur_edges)-m_min(cur_edges); /*this is | >= 0| by assumption*/ 
if (m_spread > move_size) overflow("move table size", move_size);
@:METAFONT capacity exceeded move table size}{\quad move table size@>
for (j=0; j<=m_spread; j++) move[j]=sentinel

@ @<Other local variables for |xy_swap_edges|@>=
int @!m_spread; /*the difference between |m_max| and |m_min|*/ 
int @!j, @!jj; /*indices into |move|*/ 
int @!m, @!mm; /*|m| values at vertical edges*/ 
int @!pd, @!rd; /*data fields from edge-and-weight nodes*/ 
int @!pm, @!rm; /*|m| values from edge-and-weight nodes*/ 
int @!w; /*the difference in accumulated weight*/ 
int @!ww; /*as much of |w| that can be stored in a single node*/ 
int @!dw; /*an increment to be added to |w|*/ 

@ At the point where we test |w!=0|, variable |w| contains
the accumulated weight from edges already passed in
row~|p| minus the accumulated weight from edges already passed in row~|q|.

@<Insert the horizontal edges defined by adjacent rows |p,q|...@>=
r=sorted(p);free_node(p, row_node_size);p=r;@/
pd=ho(info(p));pm=pd/8;@/
r=sorted(q);rd=ho(info(r));rm=rd/8;w=0;
loop@+{@+if (pm < rm) mm=pm;@+else mm=rm;
  if (w!=0) 
    @<Insert horizontal edges of weight |w| between |m| and~|mm|@>;
  if (pd < rd) 
    {@+dw=(pd%8)-zero_w;
    @<Advance pointer |p| to the next vertical edge, after destroying the previous
one@>;
    } 
  else{@+if (r==sentinel) goto done; /*|rd==pd==ho(max_halfword)|*/ 
    dw=-((rd%8)-zero_w);
    @<Advance pointer |r| to the next vertical edge@>;
    } 
  m=mm;w=w+dw;
  } 
done: 

@ @<Advance pointer |r| to the next vertical edge@>=
r=link(r);rd=ho(info(r));rm=rd/8

@ @<Advance pointer |p| to the next vertical edge...@>=
s=link(p);free_avail(p);p=s;pd=ho(info(p));pm=pd/8

@ Certain ``magic'' values are needed to make the following code work,
because of the various offsets in our data structure. For now, let's not
worry about their precise values; we shall compute |m_magic| and |n_magic|
later, after we see what the code looks like.

@ @<Insert horizontal edges of weight |w| between |m| and~|mm|@>=
if (m!=mm) 
  {@+if (mm-m_magic >= move_size) confusion(@[@<|"xy"|@>@]);
@:this can't happen xy}{\quad xy@>
  extras=(abs(w)-1)/3;
  if (extras > 0) 
    {@+if (w > 0) xw=+3;@+else xw=-3;
    ww=w-extras*xw;
    } 
  else ww=w;
  @/do@+{j=m-m_magic;
  for (k=1; k<=extras; k++) 
    {@+s=get_avail();info(s)=n_magic+xw;
    link(s)=move[j];move[j]=s;
    } 
  s=get_avail();info(s)=n_magic+ww;
  link(s)=move[j];move[j]=s;@/
  incr(m);
  }@+ while (!(m==mm));
  } 

@ @<Other local variables for |xy...@>=
int @!extras; /*the number of additional nodes to make weights | > 3|*/ 
int8_t @!xw; /*the additional weight in extra nodes*/ 
int @!k; /*loop counter for inserting extra nodes*/ 

@ At the beginning of this step, |move[m_spread]==sentinel|, because no
horizontal edges will extend to the right of column |m_max(cur_edges)|.

@<Adjust the header to reflect the new edges@>=
move[m_spread]=0;j=0;
while (move[j]==sentinel) incr(j);
if (j==m_spread) init_edges(cur_edges); /*all edge weights are zero*/ 
else{@+mm=m_min(cur_edges);
  m_min(cur_edges)=n_min(cur_edges);
  m_max(cur_edges)=n_max(cur_edges)+1;
  m_offset(cur_edges)=zero_field;
  jj=m_spread-1;
  while (move[jj]==sentinel) decr(jj);
  n_min(cur_edges)=j+mm;n_max(cur_edges)=jj+mm;q=cur_edges;
  @/do@+{p=get_node(row_node_size);link(q)=p;knil(p)=q;
  sorted(p)=move[j];unsorted(p)=null;incr(j);q=p;
  }@+ while (!(j > jj));
  link(q)=cur_edges;knil(cur_edges)=q;
  n_pos(cur_edges)=n_max(cur_edges)+1;n_rover(cur_edges)=cur_edges;
  last_window_time(cur_edges)=0;
  } 

@ The values of |m_magic| and |n_magic| can be worked out by trying the
code above on a small example; if they work correctly in simple cases,
they should work in general.

@<Compute the magic offset values@>=
m_magic=m_min(cur_edges)+m_offset(cur_edges)-zero_field;
n_magic=8*n_max(cur_edges)+8+zero_w+min_halfword

@ Now let's look at the subroutine that merges the edges from a given
edge structure into |cur_edges|. The given edge structure loses all its
edges.

@p void merge_edges(pointer @!h)
{@+
pointer @!p, @!q, @!r, @!pp, @!qq, @!rr; /*list manipulation registers*/ 
int @!n; /*row number*/ 
halfword @!k; /*key register that we compare to |info(q)|*/ 
int @!delta; /*change to the edge/weight data*/ 
if (link(h)!=h) 
  {@+if ((m_min(h) < m_min(cur_edges))||(m_max(h) > m_max(cur_edges))||@|
    (n_min(h) < n_min(cur_edges))||(n_max(h) > n_max(cur_edges))) 
    edge_prep(m_min(h)-zero_field, m_max(h)-zero_field,
      n_min(h)-zero_field, n_max(h)-zero_field+1);
  if (m_offset(h)!=m_offset(cur_edges)) 
    @<Adjust the data of |h| to account for a difference of offsets@>;
  n=n_min(cur_edges);p=link(cur_edges);pp=link(h);
  while (n < n_min(h)) 
    {@+incr(n);p=link(p);
    } 
  @/do@+{@<Merge row |pp| into row |p|@>;
  pp=link(pp);p=link(p);
  }@+ while (!(pp==h));
  } 
} 

@ @<Adjust the data of |h| to account for a difference of offsets@>=
{@+pp=link(h);delta=8*(m_offset(cur_edges)-m_offset(h));
@/do@+{qq=sorted(pp);
while (qq!=sentinel) 
  {@+info(qq)=info(qq)+delta;qq=link(qq);
  } 
qq=unsorted(pp);
while (qq > empty) 
  {@+info(qq)=info(qq)+delta;qq=link(qq);
  } 
pp=link(pp);
}@+ while (!(pp==h));
} 

@ The |sorted| and |unsorted| lists are merged separately. After this
step, row~|pp| will have no edges remaining, since they will all have
been merged into row~|p|.

@<Merge row |pp|...@>=
qq=unsorted(pp);
if (qq > empty) 
  if (unsorted(p) <= empty) unsorted(p)=qq;
  else{@+while (link(qq) > empty) qq=link(qq);
    link(qq)=unsorted(p);unsorted(p)=unsorted(pp);
    } 
unsorted(pp)=null;qq=sorted(pp);
if (qq!=sentinel) 
  {@+if (unsorted(p)==empty) unsorted(p)=null;
  sorted(pp)=sentinel;r=sorted_loc(p);q=link(r); /*|q==sorted(p)|*/ 
  if (q==sentinel) sorted(p)=qq;
  else loop@+{@+k=info(qq);
    while (k > info(q)) 
      {@+r=q;q=link(r);
      } 
    link(r)=qq;rr=link(qq);link(qq)=q;
    if (rr==sentinel) goto done;
    r=qq;qq=rr;
    } 
  } 
done: 

@ The |total_weight| routine computes the total of all pixel weights
in a given edge structure. It's not difficult to prove that this is
the sum of $(-w)$ times $x$ taken over all edges,
where $w$ and~$x$ are the weight and $x$~coordinates stored in an edge.
It's not necessary to worry that this quantity will overflow the
size of an |int| register, because it will be less than~$2^{31}$
unless the edge structure has more than 174,762 edges. However, we had
better not try to compute it as a |scaled| integer, because a total
weight of almost $12\times 2^{12}$ can be produced by only four edges.

@p int total_weight(pointer @!h) /*|h| is an edge header*/ 
{@+pointer @!p, @!q; /*variables that traverse the given structure*/ 
int @!n; /*accumulated total so far*/ 
uint16_t @!m; /*packed $x$ and $w$ values, including offsets*/ 
n=0;p=link(h);
while (p!=h) 
  {@+q=sorted(p);
  while (q!=sentinel) 
    @<Add the contribution of node |q| to the total weight, and set |q:=link(q)|@>;
  q=unsorted(p);
  while (q > empty) 
    @<Add the contribution of node |q| to the total weight, and set |q:=link(q)|@>;
  p=link(p);
  } 
return n;
} 

@ It's not necessary to add the offsets to the $x$ coordinates, because
an entire edge structure can be shifted without affecting its total weight.
Similarly, we don't need to subtract |zero_field|.

@<Add the contribution of node |q| to the total weight...@>=
{@+m=ho(info(q));n=n-((m%8)-zero_w)*(m/8);
q=link(q);
} 

@ So far we've done lots of things to edge structures assuming that
edges are actually present, but we haven't seen how edges get created
in the first place. Let's turn now to the problem of generating new edges.

\MF\ will display new edges as they are being computed, if |tracing_edges|
is positive. In order to keep such data reasonably compact, only the
points at which the path makes a $90^\circ$ or $180^\circ$ turn are listed.

The tracing algorithm must remember some past history in order to suppress
unnecessary data. Three variables |trace_x|, |trace_y|, and |trace_yy|
provide this history: The last coordinates printed were |(trace_x, trace_y)|,
and the previous edge traced ended at |(trace_x, trace_yy)|. Before anything
at all has been traced, |trace_x==-4096|.

@<Glob...@>=
int @!trace_x; /*$x$~coordinate most recently shown in a trace*/ 
int @!trace_y; /*$y$~coordinate most recently shown in a trace*/ 
int @!trace_yy; /*$y$~coordinate most recently encountered*/ 

@ Edge tracing is initiated by the |begin_edge_tracing| routine,
continued by the |trace_a_corner| routine, and terminated by the
|end_edge_tracing| routine.

@p void begin_edge_tracing(void)
{@+print_diagnostic(@[@<|"Tracing edges"|@>@], empty_string, true);
print_str(" (weight ");print_int(cur_wt);print_char(')');trace_x=-4096;
} 
@#
void trace_a_corner(void)
{@+if (file_offset > max_print_line-13) print_nl("");
print_char('(');print_int(trace_x);print_char(',');print_int(trace_yy);
print_char(')');trace_y=trace_yy;
} 
@#
void end_edge_tracing(void)
{@+if (trace_x==-4096) print_nl("(No new edges added.)");
@.No new edges added@>
else{@+trace_a_corner();print_char('.');
  } 
end_diagnostic(true);
} 

@ Just after a new edge weight has been put into the |info| field of
node~|r|, in row~|n|, the following routine continues an ongoing trace.

@p void trace_new_edge(pointer @!r, int @!n)
{@+int @!d; /*temporary data register*/ 
int8_t @!w; /*weight associated with an edge transition*/ 
int @!m, @!n0, @!n1; /*column and row numbers*/ 
d=ho(info(r));w=(d%8)-zero_w;m=(d/8)-m_offset(cur_edges);
if (w==cur_wt) 
  {@+n0=n+1;n1=n;
  } 
else{@+n0=n;n1=n+1;
  }  /*the edges run from |(m, n0)| to |(m, n1)|*/ 
if (m!=trace_x) 
  {@+if (trace_x==-4096) 
    {@+print_nl("");trace_yy=n0;
    } 
  else if (trace_yy!=n0) print_char('?'); /*shouldn't happen*/ 
  else trace_a_corner();
  trace_x=m;trace_a_corner();
  } 
else{@+if (n0!=trace_yy) print_char('!'); /*shouldn't happen*/ 
  if (((n0 < n1)&&(trace_y > trace_yy))||((n0 > n1)&&(trace_y < trace_yy))) 
    trace_a_corner();
  } 
trace_yy=n1;
} 

@ One way to put new edge weights into an edge structure is to use the
following routine, which simply draws a straight line from |(x0, y0)| to
|(x1, y1)|. More precisely, it introduces weights for the edges of the
discrete path $\bigl(\lfloor t[x_0,x_1]+{1\over2}+\epsilon\rfloor,
\lfloor t[y_0,y_1]+{1\over2}+\epsilon\delta\rfloor\bigr)$,
as $t$ varies from 0 to~1, where $\epsilon$ and $\delta$ are extremely small
positive numbers.

The structure header is assumed to be |cur_edges|; downward edge weights
will be |cur_wt|, while upward ones will be |-cur_wt|.

Of course, this subroutine will be called only in connection with others
that eventually draw a complete cycle, so that the sum of the edge weights
in each row will be zero whenever the row is displayed.

@p void line_edges(scaled @!x0, scaled @!y0, scaled @!x1, scaled @!y1)
{@+
int @!m0, @!n0, @!m1, @!n1; /*rounded and unscaled coordinates*/ 
scaled @!delx, @!dely; /*the coordinate differences of the line*/ 
scaled @!yt; /*smallest |y| coordinate that rounds the same as |y0|*/ 
scaled @!tx; /*tentative change in |x|*/ 
pointer @!p, @!r; /*list manipulation registers*/ 
int @!base; /*amount added to edge-and-weight data*/ 
int @!n; /*current row number*/ 
n0=round_unscaled(y0);
n1=round_unscaled(y1);
if (n0!=n1) 
  {@+m0=round_unscaled(x0);m1=round_unscaled(x1);
  delx=x1-x0;dely=y1-y0;
  yt=n0*unity-half_unit;y0=y0-yt;y1=y1-yt;
  if (n0 < n1) @<Insert upward edges for a line@>@;
  else@<Insert downward edges for a line@>;
  n_rover(cur_edges)=p;n_pos(cur_edges)=n+zero_field;
  } 
} 

@ Here we are careful to cancel any effect of rounding error.

@<Insert upward edges for a line@>=
{@+base=8*m_offset(cur_edges)+min_halfword+zero_w-cur_wt;
if (m0 <= m1) edge_prep(m0, m1, n0, n1);@+else edge_prep(m1, m0, n0, n1);
@<Move to row |n0|, pointed to by |p|@>;
y0=unity-y0;
loop@+{@+r=get_avail();link(r)=unsorted(p);unsorted(p)=r;@/
  tx=take_fraction(delx, make_fraction(y0, dely));
  if (ab_vs_cd(delx, y0, dely, tx) < 0) decr(tx);
     /*now $|tx|=\lfloor|y0|\cdot|delx|/|dely|\rfloor$*/ 
  info(r)=8*round_unscaled(x0+tx)+base;@/
  y1=y1-unity;
  if (internal[tracing_edges] > 0) trace_new_edge(r, n);
  if (y1 < unity) goto done;
  p=link(p);y0=y0+unity;incr(n);
  } 
done: ;} 

@ @<Insert downward edges for a line@>=
{@+base=8*m_offset(cur_edges)+min_halfword+zero_w+cur_wt;
if (m0 <= m1) edge_prep(m0, m1, n1, n0);@+else edge_prep(m1, m0, n1, n0);
decr(n0);@<Move to row |n0|, pointed to by |p|@>;
loop@+{@+r=get_avail();link(r)=unsorted(p);unsorted(p)=r;@/
  tx=take_fraction(delx, make_fraction(y0, dely));
  if (ab_vs_cd(delx, y0, dely, tx) < 0) incr(tx);
     /*now $|tx|=\lceil|y0|\cdot|delx|/|dely|\rceil$, since |dely < 0|*/ 
  info(r)=8*round_unscaled(x0-tx)+base;@/
  y1=y1+unity;
  if (internal[tracing_edges] > 0) trace_new_edge(r, n);
  if (y1 >= 0) goto done1;
  p=knil(p);y0=y0+unity;decr(n);
  } 
done1: ;} 

@ @<Move to row |n0|, pointed to by |p|@>=
n=n_pos(cur_edges)-zero_field;p=n_rover(cur_edges);
if (n!=n0) 
  if (n < n0) 
    @/do@+{incr(n);p=link(p);
    }@+ while (!(n==n0));
  else@/do@+{decr(n);p=knil(p);
    }@+ while (!(n==n0))

@ \MF\ inserts most of its edges into edge structures via the
|move_to_edges| subroutine, which uses the data stored in the |move| array
to specify a sequence of ``rook moves.'' The starting point |(m0, n0)|
and finishing point |(m1, n1)| of these moves, as seen from the standpoint
of the first octant, are supplied as parameters; the moves should, however,
be rotated into a given octant.  (We're going to study octant
transformations in great detail later; the reader may wish to come back to
this part of the program after mastering the mysteries of octants.)

The rook moves themselves are defined as follows, from a |first_octant|
point of view: ``Go right |move[k]| steps, then go up one, for |0 <= k < n1-n0|;
then go right |move[n1-n0]| steps and stop.'' The sum of |move[k]|
for |0 <= k <= n1-n0| will be equal to |m1-m0|.

As in the |line_edges| routine, we use |+cur_wt| as the weight of
all downward edges and |-cur_wt| as the weight of all upward edges,
after the moves have been rotated to the proper octant direction.

There are two main cases to consider: \\{fast\_case} is for moves that
travel in the direction of octants 1, 4, 5, and~8, while \\{slow\_case}
is for moves that travel toward octants 2, 3, 6, and~7. The latter directions
are comparatively cumbersome because they generate more upward or downward
edges; a curve that travels horizontally doesn't produce any edges at all,
but a curve that travels vertically touches lots of rows.

@p void move_to_edges(int @!m0, int @!n0, int @!m1, int @!n1)
{@+
uint16_t @!delta; /*extent of |move| data*/ 
int @!k; /*index into |move|*/ 
pointer @!p, @!r; /*list manipulation registers*/ 
int @!dx; /*change in edge-weight |info| when |x| changes by 1*/ 
int @!edge_and_weight; /*|info| to insert*/ 
int @!j; /*number of consecutive vertical moves*/ 
int @!n; /*the current row pointed to by |p|*/ 
#ifdef @!DEBUG
int @!sum;
#endif
@;@/
delta=n1-n0;
#ifdef @!DEBUG
sum=move[0];for (k=1; k<=delta; k++) sum=sum+abs(move[k]);
if (sum!=m1-m0) confusion('0');
#endif
@;@/
@:this can't happen 0}{\quad 0@>
@<Prepare for and switch to the appropriate case, based on |octant|@>;
fast_case_up: @<Add edges for first or fourth octants, then |goto done|@>;
fast_case_down: @<Add edges for fifth or eighth octants, then |goto done|@>;
slow_case_up: @<Add edges for second or third octants, then |goto done|@>;
slow_case_down: @<Add edges for sixth or seventh octants, then |goto done|@>;
done: n_pos(cur_edges)=n+zero_field;n_rover(cur_edges)=p;
} 

@ The current octant code appears in a global variable. If, for example,
we have |octant==third_octant|, it means that a curve traveling in a north to
north-westerly direction has been rotated for the purposes of internal
calculations so that the |move| data travels in an east to north-easterly
direction. We want to unrotate as we update the edge structure.

@<Glob...@>=
uint8_t @!octant; /*the current octant of interest*/ 

@ @<Prepare for and switch to the appropriate case, based on |octant|@>=
switch (octant) {
case first_octant: {@+dx=8;edge_prep(m0, m1, n0, n1);goto fast_case_up;
  } 
case second_octant: {@+dx=8;edge_prep(n0, n1, m0, m1);goto slow_case_up;
  } 
case third_octant: {@+dx=-8;edge_prep(-n1,-n0, m0, m1);negate(n0);
  goto slow_case_up;
  } 
case fourth_octant: {@+dx=-8;edge_prep(-m1,-m0, n0, n1);negate(m0);
  goto fast_case_up;
  } 
case fifth_octant: {@+dx=-8;edge_prep(-m1,-m0,-n1,-n0);negate(m0);
  goto fast_case_down;
  } 
case sixth_octant: {@+dx=-8;edge_prep(-n1,-n0,-m1,-m0);negate(n0);
  goto slow_case_down;
  } 
case seventh_octant: {@+dx=8;edge_prep(n0, n1,-m1,-m0);goto slow_case_down;
  } 
case eighth_octant: {@+dx=8;edge_prep(m0, m1,-n1,-n0);goto fast_case_down;
  } 
}  /*there are only eight octants*/ 

@ @<Add edges for first or fourth octants, then |goto done|@>=
@<Move to row |n0|, pointed to by |p|@>;
if (delta > 0) 
  {@+k=0;
  edge_and_weight=8*(m0+m_offset(cur_edges))+min_halfword+zero_w-cur_wt;
  @/do@+{edge_and_weight=edge_and_weight+dx*move[k];
  fast_get_avail(r);link(r)=unsorted(p);info(r)=edge_and_weight;
  if (internal[tracing_edges] > 0) trace_new_edge(r, n);
  unsorted(p)=r;p=link(p);incr(k);incr(n);
  }@+ while (!(k==delta));
  } 
goto done

@ @<Add edges for fifth or eighth octants, then |goto done|@>=
n0=-n0-1;@<Move to row |n0|, pointed to by |p|@>;
if (delta > 0) 
  {@+k=0;
  edge_and_weight=8*(m0+m_offset(cur_edges))+min_halfword+zero_w+cur_wt;
  @/do@+{edge_and_weight=edge_and_weight+dx*move[k];
  fast_get_avail(r);link(r)=unsorted(p);info(r)=edge_and_weight;
  if (internal[tracing_edges] > 0) trace_new_edge(r, n);
  unsorted(p)=r;p=knil(p);incr(k);decr(n);
  }@+ while (!(k==delta));
  } 
goto done

@ @<Add edges for second or third octants, then |goto done|@>=
edge_and_weight=8*(n0+m_offset(cur_edges))+min_halfword+zero_w-cur_wt;
n0=m0;k=0;@<Move to row |n0|, pointed to by |p|@>;
@/do@+{j=move[k];
while (j > 0) 
  {@+fast_get_avail(r);link(r)=unsorted(p);info(r)=edge_and_weight;
  if (internal[tracing_edges] > 0) trace_new_edge(r, n);
  unsorted(p)=r;p=link(p);decr(j);incr(n);
  } 
edge_and_weight=edge_and_weight+dx;incr(k);
}@+ while (!(k > delta));
goto done

@ @<Add edges for sixth or seventh octants, then |goto done|@>=
edge_and_weight=8*(n0+m_offset(cur_edges))+min_halfword+zero_w+cur_wt;
n0=-m0-1;k=0;@<Move to row |n0|, pointed to by |p|@>;
@/do@+{j=move[k];
while (j > 0) 
  {@+fast_get_avail(r);link(r)=unsorted(p);info(r)=edge_and_weight;
  if (internal[tracing_edges] > 0) trace_new_edge(r, n);
  unsorted(p)=r;p=knil(p);decr(j);decr(n);
  } 
edge_and_weight=edge_and_weight+dx;incr(k);
}@+ while (!(k > delta));
goto done

@ All the hard work of building an edge structure is undone by the following
subroutine.

@<Declare the recycling subroutines@>=
void toss_edges(pointer @!h)
{@+pointer @!p, @!q; /*for list manipulation*/ 
q=link(h);
while (q!=h) 
  {@+flush_list(sorted(q));
  if (unsorted(q) > empty) flush_list(unsorted(q));
  p=q;q=link(q);free_node(p, row_node_size);
  } 
free_node(h, edge_header_size);
} 

@* Subdivision into octants.
When \MF\ digitizes a path, it reduces the problem to the special
case of paths that travel in ``first octant'' directions; i.e.,
each cubic $z(t)=\bigl(x(t),y(t)\bigr)$ being digitized will have the property
that $0\L y'(t)\L x'(t)$. This assumption makes digitizing simpler
and faster than if the direction of motion has to be tested repeatedly.

When $z(t)$ is cubic, $x'(t)$ and $y'(t)$ are quadratic, hence the four
polynomials $x'(t)$, $y'(t)$, $x'(t)-y'(t)$, and $x'(t)+y'(t)$ cross
through~0 at most twice each. If we subdivide the given cubic at these
places, we get at most nine subintervals in each of which
$x'(t)$, $y'(t)$, $x'(t)-y'(t)$, and $x'(t)+y'(t)$ all have a constant
sign. The curve can be transformed in each of these subintervals so that
it travels entirely in first octant directions, if we reflect $x\swap-x$,
$y\swap-y$, and/or $x\swap y$ as necessary. (Incidentally, it can be
shown that a cubic such that $x'(t)=16(2t-1)^2+2(2t-1)-1$ and
$y'(t)=8(2t-1)^2+4(2t-1)$ does indeed split into nine subintervals.)

@ The transformation that rotates coordinates, so that first octant motion
can be assumed, is defined by the |skew| subroutine, which sets global
variables |cur_x| and |cur_y| to the values that are appropriate in a
given octant.  (Octants are encoded as they were in the |n_arg| subroutine.)

This transformation is ``skewed'' by replacing |(x, y)| by |(x-y, y)|,
once first octant motion has been established. It turns out that
skewed coordinates are somewhat better to work with when curves are
actually digitized.

@d set_two_end(X)	cur_y=X;@+} 
@d set_two(X)	{@+cur_x=X;set_two_end

@p void skew(scaled @!x, scaled @!y, small_number @!octant)
{@+switch (octant) {
case first_octant: set_two(x-y)(y)@;@+break;
case second_octant: set_two(y-x)(x)@;@+break;
case third_octant: set_two(y+x)(-x)@;@+break;
case fourth_octant: set_two(-x-y)(y)@;@+break;
case fifth_octant: set_two(-x+y)(-y)@;@+break;
case sixth_octant: set_two(-y+x)(-x)@;@+break;
case seventh_octant: set_two(-y-x)(x)@;@+break;
case eighth_octant: set_two(x+y)(-y);
}  /*there are no other cases*/ 
} 

@ Conversely, the following subroutine sets |cur_x| and
|cur_y| to the original coordinate values of a point, given an octant
code and the point's coordinates |(x, y)| after they have been mapped into
the first octant and skewed.

@<Declare subroutines for printing expressions@>=
void unskew(scaled @!x, scaled @!y, small_number @!octant)
{@+switch (octant) {
case first_octant: set_two(x+y)(y)@;@+break;
case second_octant: set_two(y)(x+y)@;@+break;
case third_octant: set_two(-y)(x+y)@;@+break;
case fourth_octant: set_two(-x-y)(y)@;@+break;
case fifth_octant: set_two(-x-y)(-y)@;@+break;
case sixth_octant: set_two(-y)(-x-y)@;@+break;
case seventh_octant: set_two(y)(-x-y)@;@+break;
case eighth_octant: set_two(x+y)(-y);
}  /*there are no other cases*/ 
} 

@ @<Glob...@>=
scaled @!cur_x, @!cur_y;
   /*outputs of |skew|, |unskew|, and a few other routines*/ 

@ The conversion to skewed and rotated coordinates takes place in
stages, and at one point in the transformation we will have negated the
$x$ and/or $y$ coordinates so as to make curves travel in the first
{\sl quadrant}. At this point the relevant ``octant'' code will be
either |first_octant| (when no transformation has been done),
or |fourth_octant==first_octant+negate_x| (when $x$ has been negated),
or |fifth_octant==first_octant+negate_x+negate_y| (when both have been
negated), or |eighth_octant==first_octant+negate_y| (when $y$ has been
negated). The |abnegate| routine is sometimes needed to convert
from one of these transformations to another.

@p void abnegate(scaled @!x, scaled @!y,
  small_number @!octant_before, small_number @!octant_after)
{@+if (odd(octant_before)==odd(octant_after)) cur_x=x;
  else cur_x=-x;
if ((octant_before > negate_y)==(octant_after > negate_y)) cur_y=y;
  else cur_y=-y;
} 

@ Now here's a subroutine that's handy for subdivision: Given a
quadratic polynomial $B(a,b,c;t)$, the |crossing_point| function
returns the unique |fraction| value |t| between 0 and~1 at which
$B(a,b,c;t)$ changes from positive to negative, or returns
|t==fraction_one+1| if no such value exists. If |a < 0| (so that $B(a,b,c;t)$
is already negative at |t==0|), |crossing_point| returns the value zero.

@d no_crossing	{@+return fraction_one+1;
  } 
@d one_crossing	{@+return fraction_one;
  } 
@d zero_crossing	{@+return 0;
  } 

@p fraction crossing_point(int @!a, int @!b, int @!c)
{@+
int @!d; /*recursive counter*/ 
int @!x, @!xx, @!x0, @!x1, @!x2; /*temporary registers for bisection*/ 
if (a < 0) zero_crossing;
if (c >= 0) 
  {@+if (b >= 0) 
    if (c > 0) no_crossing@;
    else if ((a==0)&&(b==0)) no_crossing@;
    else one_crossing;
  if (a==0) zero_crossing;
  } 
else if (a==0) if (b <= 0) zero_crossing;
@<Use bisection to find the crossing point, if one exists@>;
} 

@ The general bisection method is quite simple when $n=2$, hence
|crossing_point| does not take much time. At each stage in the
recursion we have a subinterval defined by |l| and~|j| such that
$B(a,b,c;2^{-l}(j+t))=B(x_0,x_1,x_2;t)$, and we want to ``zero in'' on
the subinterval where $x_0\G0$ and $\min(x_1,x_2)<0$.

It is convenient for purposes of calculation to combine the values
of |l| and~|j| in a single variable $d=2^l+j$, because the operation
of bisection then corresponds simply to doubling $d$ and possibly
adding~1. Furthermore it proves to be convenient to modify
our previous conventions for bisection slightly, maintaining the
variables $X_0=2^lx_0$, $X_1=2^l(x_0-x_1)$, and $X_2=2^l(x_1-x_2)$.
With these variables the conditions $x_0\ge0$ and $\min(x_1,x_2)<0$ are
equivalent to $\max(X_1,X_1+X_2)>X_0\ge0$.

The following code maintains the invariant relations
$0\L|x0|<\max(|x1|,|x1|+|x2|)$,
$\vert|x1|\vert<2^{30}$, $\vert|x2|\vert<2^{30}$;
it has been constructed in such a way that no arithmetic overflow
will occur if the inputs satisfy
$a<2^{30}$, $\vert a-b\vert<2^{30}$, and $\vert b-c\vert<2^{30}$.

@<Use bisection to find the crossing point...@>=
d=1;x0=a;x1=a-b;x2=b-c;
@/do@+{x=half(x1+x2);
if (x1-x0 > x0) 
  {@+x2=x;double(x0);double(d);
  } 
else{@+xx=x1+x-x0;
  if (xx > x0) 
    {@+x2=x;double(x0);double(d);
    } 
  else{@+x0=x0-xx;
    if (x <= x0) if (x+x2 <= x0) no_crossing;
    x1=x;d=d+d+1;
    } 
  } 
}@+ while (!(d >= fraction_one));
return d-fraction_one

@ Octant subdivision is applied only to cycles, i.e., to closed paths.
A ``cycle spec'' is a data structure that contains specifications of
@!@^cycle spec@>
cubic curves and octant mappings for the cycle that has been subdivided
into segments belonging to single octants. It is composed entirely of
knot nodes, similar to those in the representation of paths; but the
|explicit| type indications have been replaced by positive numbers
that give further information. Additional |endpoint| data is also
inserted at the octant boundaries.

Recall that a cubic polynomial is represented by four control points
that appear in adjacent nodes |p| and~|q| of a knot list. The |x|~coordinates
are |x_coord(p)|, |right_x(p)|, |left_x(q)|, and |x_coord(q)|; the
|y|~coordinates are similar. We shall call this ``the cubic following~|p|''
or ``the cubic between |p| and~|q|'' or ``the cubic preceding~|q|.''

Cycle specs are circular lists of cubic curves mixed with octant
boundaries. Like cubics, the octant boundaries are represented in
consecutive knot nodes |p| and~|q|. In such cases |right_type(p)==
left_type(q)==endpoint|, and the fields |right_x(p)|, |right_y(p)|,
|left_x(q)|, and |left_y(q)| are replaced by other fields called
|right_octant(p)|, |right_transition(p)|, |left_octant(q)|, and
|left_transition(q)|, respectively. For example, when the curve direction
moves from the third octant to the fourth octant, the boundary nodes say
|right_octant(p)==third_octant|, |left_octant(q)==fourth_octant|,
and |right_transition(p)==left_transition(q)==diagonal|. A |diagonal|
transition occurs when moving between octants 1~\AM~2, 3~\AM~4, 5~\AM~6, or
7~\AM~8; an |axis| transition occurs when moving between octants 8~\AM~1,
2~\AM~3, 4~\AM~5, 6~\AM~7. (Such transition information is redundant
but convenient.) Fields |x_coord(p)| and |y_coord(p)| will contain
coordinates of the transition point after rotation from third octant
to first octant; i.e., if the true coordinates are $(x,y)$, the
coordinates $(y,-x)$ will appear in node~|p|. Similarly, a fourth-octant
transformation will have been applied after the transition, so
we will have |x_coord(q)==@t$-x$@>| and |y_coord(q)==y|.

The cubic between |p| and |q| will contain positive numbers in the
fields |right_type(p)| and |left_type(q)|; this makes cubics
distinguishable from octant boundaries, because |endpoint==0|.
The value of |right_type(p)| will be the current octant code,
during the time that cycle specs are being constructed; it will
refer later to a pen offset position, if the envelope of a cycle is
being computed. A cubic that comes from some subinterval of the $k$th
step in the original cyclic path will have |left_type(q)==k|.

@d right_octant	right_x /*the octant code before a transition*/ 
@d left_octant	left_x /*the octant after a transition*/ 
@d right_transition	right_y /*the type of transition*/ 
@d left_transition	left_y /*ditto, either |axis| or |diagonal|*/ 
@d axis	0 /*a transition across the $x'$- or $y'$-axis*/ 
@d diagonal	1 /*a transition where $y'=\pm x'$*/ 

@ Here's a routine that prints a cycle spec in symbolic form, so that it
is possible to see what subdivision has been made.  The point coordinates
are converted back from \MF's internal ``rotated'' form to the external
``true'' form. The global variable~|cur_spec| should point to a knot just
after the beginning of an octant boundary, i.e., such that
|left_type(cur_spec)==endpoint|.

@d print_two_true(X, Y)	unskew(X, Y, octant);print_two(cur_x, cur_y)

@p void print_spec(str_number @!s)
{@+
pointer @!p, @!q; /*for list traversal*/ 
small_number @!octant; /*the current octant code*/ 
print_diagnostic(@[@<|"Cycle spec"|@>@], s, true);
@.Cycle spec at line...@>
p=cur_spec;octant=left_octant(p);print_ln();
print_two_true(x_coord(cur_spec), y_coord(cur_spec));
print_str(" % beginning in octant `");
loop@+{@+print(octant_dir[octant]);print_char('\'');
  loop@+{@+q=link(p);
    if (right_type(p)==endpoint) goto not_found;
    @<Print the cubic between |p| and |q|@>;
    p=q;
    } 
not_found: if (q==cur_spec) goto done;
  p=q;octant=left_octant(p);print_nl("% entering octant `");
  } 
@.entering the nth octant@>
done: print_nl(" & cycle");end_diagnostic(true);
} 

@ Symbolic octant direction names are kept in the |octant_dir| array.

@<Glob...@>=
str_number @!octant_dir0[sixth_octant-first_octant+1], *const @!octant_dir = @!octant_dir0-first_octant;

@ @<Set init...@>=
octant_dir[first_octant]=@[@<|"ENE"|@>@];
octant_dir[second_octant]=@[@<|"NNE"|@>@];
octant_dir[third_octant]=@[@<|"NNW"|@>@];
octant_dir[fourth_octant]=@[@<|"WNW"|@>@];
octant_dir[fifth_octant]=@[@<|"WSW"|@>@];
octant_dir[sixth_octant]=@[@<|"SSW"|@>@];
octant_dir[seventh_octant]=@[@<|"SSE"|@>@];
octant_dir[eighth_octant]=@[@<|"ESE"|@>@];

@ @<Print the cubic between...@>=
{@+print_nl("   ..controls ");
print_two_true(right_x(p), right_y(p));
print_str(" and ");
print_two_true(left_x(q), left_y(q));
print_nl(" ..");
print_two_true(x_coord(q), y_coord(q));
print_str(" % segment ");print_int(left_type(q)-1);
} 

@ A much more compact version of a spec is printed to help users identify
``strange paths.''

@p void print_strange(str_number @!s)
{@+pointer @!p; /*for list traversal*/ 
pointer @!f; /*starting point in the cycle*/ 
pointer @!q; /*octant boundary to be printed*/ 
int @!t; /*segment number, plus 1*/ 
if (interaction==error_stop_mode) wake_up_terminal;
print_nl(">");
@.>\relax@>
@<Find the starting point, |f|@>;
@<Determine the octant boundary |q| that precedes |f|@>;
t=0;
@/do@+{if (left_type(p)!=endpoint) 
  {@+if (left_type(p)!=t) 
    {@+t=left_type(p);print_char(' ');print_int(t-1);
    } 
  if (q!=null) 
    {@+@<Print the turns, if any, that start at |q|, and advance |q|@>;
    print_char(' ');print(octant_dir[left_octant(q)]);q=null;
    } 
  } 
else if (q==null) q=p;
p=link(p);
}@+ while (!(p==f));
print_char(' ');print_int(left_type(p)-1);
if (q!=null) @<Print the turns...@>;
print_nl("! ");print(s);
} 

@ If the segment numbers on the cycle are $t_1$, $t_2$, \dots, $t_m$,
and if |m <= max_quarterword|,
we have $t_{k-1}\L t_k$ except for at most one value of~$k$. If there are
no exceptions, $f$ will point to $t_1$; otherwise it will point to the
exceptional~$t_k$.

There is at least one segment number (i.e., we always have $m>0$), because
|print_strange| is never called upon to display an entirely ``dead'' cycle.

@<Find the starting point, |f|@>=
p=cur_spec;t=max_quarterword+1;
@/do@+{p=link(p);
if (left_type(p)!=endpoint) 
  {@+if (left_type(p) < t) f=p;
  t=left_type(p);
  } 
}@+ while (!(p==cur_spec))

@ @<Determine the octant boundary...@>=
p=cur_spec;q=p;
@/do@+{p=link(p);
if (left_type(p)==endpoint) q=p;
}@+ while (!(p==f))

@ When two octant boundaries are adjacent, the path is simply changing direction
without moving. Such octant directions are shown in parentheses.

@<Print the turns...@>=
if (left_type(link(q))==endpoint) 
  {@+print_str(" (");print(octant_dir[left_octant(q)]);q=link(q);
  while (left_type(link(q))==endpoint) 
    {@+print_char(' ');print(octant_dir[left_octant(q)]);q=link(q);
    } 
  print_char(')');
  } 

@ The |make_spec| routine is what subdivides paths into octants:
Given a pointer |cur_spec| to a cyclic path, |make_spec| mungs the path data
and returns a pointer to the corresponding cyclic spec.
All ``dead'' cubics (i.e., cubics that don't move at all from
their starting points) will have been removed from the result.
@!@^dead cubics@>

The idea of |make_spec| is fairly simple: Each cubic is first
subdivided, if necessary, into pieces belonging to single octants;
then the octant boundaries are inserted. But some of the details of
this transformation are not quite obvious.

If |autorounding > 0|, the path will be adjusted so that critical tangent
directions occur at ``good'' points with respect to the pen called |cur_pen|.

The resulting spec will have all |x| and |y| coordinates at most
$2^{28}-|half_unit|-1-|safety_margin|$ in absolute value.  The pointer
that is returned will start some octant, as required by |print_spec|.

@p@t\4@>@<Declare subroutines needed by |make_spec|@>@;
pointer make_spec(pointer @!h,
  scaled @!safety_margin, int @!tracing)
   /*converts a path to a cycle spec*/ 
{@+
pointer @!p, @!q, @!r, @!s; /*for traversing the lists*/ 
int @!k; /*serial number of path segment, or octant code*/ 
int @!chopped; /*positive if data truncated,
          negative if data dangerously large*/ 
@<Other local variables for |make_spec|@>@;
cur_spec=h;
if (tracing > 0) 
  print_path(cur_spec,@[@<|", before subdivision into octants"|@>@], true);
max_allowed=fraction_one-half_unit-1-safety_margin;
@<Truncate the values of all coordinates that exceed |max_allowed|, and stamp segment
numbers in each |left_type| field@>;
quadrant_subdivide(); /*subdivide each cubic into pieces belonging to quadrants*/ 
if ((internal[autorounding] > 0)&&(chopped==0)) xy_round();
octant_subdivide(); /*complete the subdivision*/ 
if ((internal[autorounding] > unity)&&(chopped==0)) diag_round();
@<Remove dead cubics@>;
@<Insert octant boundaries and compute the turning number@>;
while (left_type(cur_spec)!=endpoint) cur_spec=link(cur_spec);
if (tracing > 0) 
  if ((internal[autorounding] <= 0)||(chopped!=0)) 
    print_spec(@[@<|", after subdivision"|@>@]);
  else if (internal[autorounding] > unity) 
    print_spec(@[@<|", after subdivision and double autorounding"|@>@]);
  else print_spec(@[@<|", after subdivision and autorounding"|@>@]);
return cur_spec;
} 

@ The |make_spec| routine has an interesting side effect, namely to set
the global variable |turning_number| to the number of times the tangent
vector of the given cyclic path winds around the origin.

Another global variable |cur_spec| points to the specification as it is
being made, since several subroutines must go to work on it.

And there are two global variables that affect the rounding
decisions, as we'll see later; they are called |cur_pen| and |cur_path_type|.
The latter will be |double_path_code| if |make_spec| is being
applied to a double path.

@d double_path_code	0 /*command modifier for `\&{doublepath}'*/ 
@d contour_code	1 /*command modifier for `\&{contour}'*/ 
@d also_code	2 /*command modifier for `\&{also}'*/ 

@<Glob...@>=
pointer @!cur_spec; /*the principal output of |make_spec|*/ 
int @!turning_number; /*another output of |make_spec|*/ 
pointer @!cur_pen; /*an implicit input of |make_spec|, used in autorounding*/ 
uint8_t @!cur_path_type; /*likewise*/ 
scaled @!max_allowed; /*coordinates must be at most this big*/ 

@ First we do a simple preprocessing step. The segment numbers inserted
here will propagate to all descendants of cubics that are split into
subintervals. These numbers must be nonzero, but otherwise they are
present merely for diagnostic purposes. The cubic from |p| to~|q|
that represents ``time interval'' |(t-1)dotdot t| usually has |left_type(q)==t|,
except when |t| is too large to be stored in a quarterword.

@d procrustes(X)	@+if (abs(X) >= dmax) 
  if (abs(X) > max_allowed) 
    {@+chopped=1;
    if (X > 0) X=max_allowed;@+else X=-max_allowed;
    } 
  else if (chopped==0) chopped=-1

@<Truncate the values of all coordinates that exceed...@>=
p=cur_spec;k=1;chopped=0;dmax=half(max_allowed);
@/do@+{procrustes(left_x(p));procrustes(left_y(p));
procrustes(x_coord(p));procrustes(y_coord(p));
procrustes(right_x(p));procrustes(right_y(p));@/
p=link(p);left_type(p)=k;
if (k < max_quarterword) incr(k);@+else k=1;
}@+ while (!(p==cur_spec));
if (chopped > 0) 
  {@+print_err("Curve out of range");
@.Curve out of range@>
  help4("At least one of the coordinates in the path I'm about to")@/
    ("digitize was really huge (potentially bigger than 4095).")@/
    ("So I've cut it back to the maximum size.")@/
    ("The results will probably be pretty wild.");
  put_get_error();
  } 

@ We may need to get rid of constant ``dead'' cubics that clutter up
the data structure and interfere with autorounding.

@<Declare subroutines needed by |make_spec|@>=
void remove_cubic(pointer @!p) /*removes the cubic following~|p|*/ 
{@+pointer @!q; /*the node that disappears*/ 
q=link(p);right_type(p)=right_type(q);link(p)=link(q);@/
x_coord(p)=x_coord(q);y_coord(p)=y_coord(q);@/
right_x(p)=right_x(q);right_y(p)=right_y(q);@/
free_node(q, knot_node_size);
} 

@ The subdivision process proceeds by first swapping $x\swap-x$, if
necessary, to ensure that $x'\G0$; then swapping $y\swap-y$, if necessary,
to ensure that $y'\G0$; and finally swapping $x\swap y$, if necessary,
to ensure that $x'\G y'$.

Recall that the octant codes have been defined in such a way that, for
example, |third_octant==first_octant+negate_x+switch_x_and_y|. The program
uses the fact that |negate_x < negate_y < switch_x_and_y| to handle ``double
negation'': If |c| is an octant code that possibly involves |negate_x|
and/or |negate_y|, but not |switch_x_and_y|, then negating~|y| changes~|c|
either to |c+negate_y| or |c-negate_y|, depending on whether
|c <= negate_y| or |c > negate_y|. Octant codes are always greater than zero.

The first step is to subdivide on |x| and |y| only, so that horizontal
and vertical autorounding can be done before we compare $x'$ to $y'$.

@<Declare subroutines needed by |make_spec|@>=
@t\4@>@<Declare the procedure called |split_cubic|@>@;
void quadrant_subdivide(void)
{@+
pointer @!p, @!q, @!r, @!s, @!pp, @!qq; /*for traversing the lists*/ 
scaled @!first_x, @!first_y; /*unnegated coordinates of node |cur_spec|*/ 
scaled @!del1, @!del2, @!del3, @!del, @!dmax; /*proportional to the control
  points of a quadratic derived from a cubic*/ 
fraction @!t; /*where a quadratic crosses zero*/ 
scaled @!dest_x, @!dest_y; /*final values of |x| and |y| in the current cubic*/ 
bool @!constant_x; /*is |x| constant between |p| and |q|?*/ 
p=cur_spec;first_x=x_coord(cur_spec);first_y=y_coord(cur_spec);
@/do@+{resume: q=link(p);
@<Subdivide the cubic between |p| and |q| so that the results travel toward the right
halfplane@>;
@<Subdivide all cubics between |p| and |q| so that the results travel toward the first
quadrant; but |return| or |goto continue| if the cubic from |p| to |q| was dead@>;
p=q;
}@+ while (!(p==cur_spec));
} 

@ All three subdivision processes are similar, so it's possible to
get the general idea by studying the first one (which is the simplest).
The calculation makes use of the fact that the derivatives of
Bernshte{\u\i}n polynomials satisfy
$B'(z_0,z_1,\ldots,z_n;t)=nB(z_1-z_0,\ldots,z_n-z_{n-1};t)$.

When this routine begins, |right_type(p)| is |explicit|; we should
set |right_type(p)=first_octant|. However, no assignment is made,
because |explicit==first_octant|. The author apologizes for using
such trickery here; it is really hard to do redundant computations
just for the sake of purity.

@<Subdivide the cubic between |p| and |q| so that the results travel toward the right
halfplane...@>=
if (q==cur_spec) 
  {@+dest_x=first_x;dest_y=first_y;
  } 
else{@+dest_x=x_coord(q);dest_y=y_coord(q);
  } 
del1=right_x(p)-x_coord(p);del2=left_x(q)-right_x(p);
del3=dest_x-left_x(q);
@<Scale up |del1|, |del2|, and |del3| for greater accuracy; also set |del| to the
first nonzero element of |(del1,del2,del3)|@>;
if (del==0) constant_x=true;
else{@+constant_x=false;
  if (del < 0) @<Complement the |x| coordinates of the cubic between |p| and~|q|@>;
  t=crossing_point(del1, del2, del3);
  if (t < fraction_one) 
    @<Subdivide the cubic with respect to $x'$, possibly twice@>;
  } 

@ If |del1==del2==del3==0|, it's impossible to obey the title of this
section. We just set |del==0| in that case.
@^inner loop@>

@<Scale up |del1|, |del2|, and |del3| for greater accuracy...@>=
if (del1!=0) del=del1;
else if (del2!=0) del=del2;
else del=del3;
if (del!=0) 
  {@+dmax=abs(del1);
  if (abs(del2) > dmax) dmax=abs(del2);
  if (abs(del3) > dmax) dmax=abs(del3);
  while (dmax < fraction_half) 
    {@+double(dmax);double(del1);double(del2);double(del3);
    } 
  } 

@ During the subdivision phases of |make_spec|, the |x_coord| and |y_coord|
fields of node~|q| are not transformed to agree with the octant
stated in |right_type(p)|; they remain consistent with |right_type(q)|.
But |left_x(q)| and |left_y(q)| are governed by |right_type(p)|.

@<Complement the |x| coordinates...@>=
{@+negate(x_coord(p));negate(right_x(p));
negate(left_x(q));@/
negate(del1);negate(del2);negate(del3);@/
negate(dest_x);
right_type(p)=first_octant+negate_x;
} 

@ When a cubic is split at a |fraction| value |t|, we obtain two cubics
whose B\'ezier control points are obtained by a generalization of the
bisection process: The formula
`$z_k^{(j+1)}={1\over2}(z_k^{(j)}+z\k^{(j)})$' becomes
`$z_k^{(j+1)}=t[z_k^{(j)},z\k^{(j)}]$'.

It is convenient to define a \.{WEB} macro |t_of_the_way| such that
|t_of_the_way(a)(b)| expands to |a-(a-b)*t|, i.e., to |t[a, b]|.

If |0 <= t <= 1|, the quantity |t[a, b]| is always between |a| and~|b|, even in
the presence of rounding errors. Our subroutines
also obey the identity |t[a, b]+t[b, a]==a+b|.

@d t_of_the_way_end(X)	X,t@=)@>
@d t_of_the_way(X)	X-take_fraction@=(@>X-t_of_the_way_end

@<Declare the procedure called |split_cubic|@>=
void split_cubic(pointer @!p, fraction @!t,
  scaled @!xq, scaled @!yq) /*splits the cubic after |p|*/ 
{@+scaled @!v; /*an intermediate value*/ 
pointer @!q, @!r; /*for list manipulation*/ 
q=link(p);r=get_node(knot_node_size);link(p)=r;link(r)=q;@/
left_type(r)=left_type(q);right_type(r)=right_type(p);@#
v=t_of_the_way(right_x(p))(left_x(q));
right_x(p)=t_of_the_way(x_coord(p))(right_x(p));
left_x(q)=t_of_the_way(left_x(q))(xq);
left_x(r)=t_of_the_way(right_x(p))(v);
right_x(r)=t_of_the_way(v)(left_x(q));
x_coord(r)=t_of_the_way(left_x(r))(right_x(r));@#
v=t_of_the_way(right_y(p))(left_y(q));
right_y(p)=t_of_the_way(y_coord(p))(right_y(p));
left_y(q)=t_of_the_way(left_y(q))(yq);
left_y(r)=t_of_the_way(right_y(p))(v);
right_y(r)=t_of_the_way(v)(left_y(q));
y_coord(r)=t_of_the_way(left_y(r))(right_y(r));
} 

@ Since $x'(t)$ is a quadratic equation, it can cross through zero
at~most twice. When it does cross zero, we make doubly sure that the
derivative is really zero at the splitting point, in case rounding errors
have caused the split cubic to have an apparently nonzero derivative.
We also make sure that the split cubic is monotonic.

@<Subdivide the cubic with respect to $x'$, possibly twice@>=
{@+split_cubic(p, t, dest_x, dest_y);r=link(p);
if (right_type(r) > negate_x) right_type(r)=first_octant;
else right_type(r)=first_octant+negate_x;
if (x_coord(r) < x_coord(p)) x_coord(r)=x_coord(p);
left_x(r)=x_coord(r);
if (right_x(p) > x_coord(r)) right_x(p)=x_coord(r);
  /*we always have |x_coord(p) <= right_x(p)|*/ 
negate(x_coord(r));right_x(r)=x_coord(r);
negate(left_x(q));negate(dest_x);@/
del2=t_of_the_way(del2)(del3);
   /*now |0, del2, del3| represent $x'$ on the remaining interval*/ 
if (del2 > 0) del2=0;
t=crossing_point(0,-del2,-del3);
if (t < fraction_one) @<Subdivide the cubic a second time with respect to $x'$@>@;
else{@+if (x_coord(r) > dest_x) 
    {@+x_coord(r)=dest_x;left_x(r)=-x_coord(r);right_x(r)=x_coord(r);
    } 
  if (left_x(q) > dest_x) left_x(q)=dest_x;
  else if (left_x(q) < x_coord(r)) left_x(q)=x_coord(r);
  } 
} 

@ @<Subdivide the cubic a second time with respect to $x'$@>=
{@+split_cubic(r, t, dest_x, dest_y);s=link(r);
if (x_coord(s) < dest_x) x_coord(s)=dest_x;
if (x_coord(s) < x_coord(r)) x_coord(s)=x_coord(r);
right_type(s)=right_type(p);
left_x(s)=x_coord(s); /*now |x_coord(r)==right_x(r) <= left_x(s)|*/ 
if (left_x(q) < dest_x) left_x(q)=-dest_x;
else if (left_x(q) > x_coord(s)) left_x(q)=-x_coord(s);
else negate(left_x(q));
negate(x_coord(s));right_x(s)=x_coord(s);
} 

@ The process of subdivision with respect to $y'$ is like that with respect
to~$x'$, with the slight additional complication that two or three cubics
might now appear between |p| and~|q|.

@<Subdivide all cubics between |p| and |q| so that the results travel toward the first
quadrant...@>=
pp=p;
@/do@+{qq=link(pp);
abnegate(x_coord(qq), y_coord(qq), right_type(qq), right_type(pp));
dest_x=cur_x;dest_y=cur_y;@/
del1=right_y(pp)-y_coord(pp);del2=left_y(qq)-right_y(pp);
del3=dest_y-left_y(qq);
@<Scale up |del1|, |del2|, and |del3| for greater accuracy; also set |del| to the
first nonzero element of |(del1,del2,del3)|@>;
if (del!=0)  /*they weren't all zero*/ 
  {@+if (del < 0) @<Complement the |y| coordinates of the cubic between |pp| and~|qq|@>;
  t=crossing_point(del1, del2, del3);
  if (t < fraction_one) 
    @<Subdivide the cubic with respect to $y'$, possibly twice@>;
  } 
else@<Do any special actions needed when |y| is constant; |return| or |goto continue|
if a dead cubic from |p| to |q| is removed@>;
pp=qq;
}@+ while (!(pp==q));
if (constant_x) @<Correct the octant code in segments with decreasing |y|@>@;

@ @<Complement the |y| coordinates...@>=
{@+negate(y_coord(pp));negate(right_y(pp));
negate(left_y(qq));@/
negate(del1);negate(del2);negate(del3);@/
negate(dest_y);
right_type(pp)=right_type(pp)+negate_y;
} 

@ @<Subdivide the cubic with respect to $y'$, possibly twice@>=
{@+split_cubic(pp, t, dest_x, dest_y);r=link(pp);
if (right_type(r) > negate_y) right_type(r)=right_type(r)-negate_y;
else right_type(r)=right_type(r)+negate_y;
if (y_coord(r) < y_coord(pp)) y_coord(r)=y_coord(pp);
left_y(r)=y_coord(r);
if (right_y(pp) > y_coord(r)) right_y(pp)=y_coord(r);
  /*we always have |y_coord(pp) <= right_y(pp)|*/ 
negate(y_coord(r));right_y(r)=y_coord(r);
negate(left_y(qq));negate(dest_y);@/
if (x_coord(r) < x_coord(pp)) x_coord(r)=x_coord(pp);
else if (x_coord(r) > dest_x) x_coord(r)=dest_x;
if (left_x(r) > x_coord(r)) 
  {@+left_x(r)=x_coord(r);
  if (right_x(pp) > x_coord(r)) right_x(pp)=x_coord(r);
  } 
if (right_x(r) < x_coord(r)) 
  {@+right_x(r)=x_coord(r);
  if (left_x(qq) < x_coord(r)) left_x(qq)=x_coord(r);
  } 
del2=t_of_the_way(del2)(del3);
   /*now |0, del2, del3| represent $y'$ on the remaining interval*/ 
if (del2 > 0) del2=0;
t=crossing_point(0,-del2,-del3);
if (t < fraction_one) @<Subdivide the cubic a second time with respect to $y'$@>@;
else{@+if (y_coord(r) > dest_y) 
    {@+y_coord(r)=dest_y;left_y(r)=-y_coord(r);right_y(r)=y_coord(r);
    } 
  if (left_y(qq) > dest_y) left_y(qq)=dest_y;
  else if (left_y(qq) < y_coord(r)) left_y(qq)=y_coord(r);
  } 
} 

@ @<Subdivide the cubic a second time with respect to $y'$@>=
{@+split_cubic(r, t, dest_x, dest_y);s=link(r);@/
if (y_coord(s) < dest_y) y_coord(s)=dest_y;
if (y_coord(s) < y_coord(r)) y_coord(s)=y_coord(r);
right_type(s)=right_type(pp);
left_y(s)=y_coord(s); /*now |y_coord(r)==right_y(r) <= left_y(s)|*/ 
if (left_y(qq) < dest_y) left_y(qq)=-dest_y;
else if (left_y(qq) > y_coord(s)) left_y(qq)=-y_coord(s);
else negate(left_y(qq));
negate(y_coord(s));right_y(s)=y_coord(s);
if (x_coord(s) < x_coord(r)) x_coord(s)=x_coord(r);
else if (x_coord(s) > dest_x) x_coord(s)=dest_x;
if (left_x(s) > x_coord(s)) 
  {@+left_x(s)=x_coord(s);
  if (right_x(r) > x_coord(s)) right_x(r)=x_coord(s);
  } 
if (right_x(s) < x_coord(s)) 
  {@+right_x(s)=x_coord(s);
  if (left_x(qq) < x_coord(s)) left_x(qq)=x_coord(s);
  } 
} 

@ If the cubic is constant in $y$ and increasing in $x$, we have classified
it as traveling in the first octant. If the cubic is constant
in~$y$ and decreasing in~$x$, it is desirable to classify it as traveling
in the fifth octant (not the fourth), because autorounding will be consistent
with respect to doublepaths only if the octant number changes by four when
the path is reversed. Therefore we negate the $y$~coordinates
when they are constant but the curve is decreasing in~$x$; this gives
the desired result except in pathological paths.

If the cubic is ``dead,'' i.e., constant in both |x| and |y|, we remove
it unless it is the only cubic in the entire path. We |goto resume|
if it wasn't the final cubic, so that the test |p==cur_spec| does not
falsely imply that all cubics have been processed.

@<Do any special actions needed when |y| is constant...@>=
if (constant_x)  /*|p==pp|, |q==qq|, and the cubic is dead*/ 
  {@+if (q!=p) 
    {@+remove_cubic(p); /*remove the dead cycle and recycle node |q|*/ 
    if (cur_spec!=q) goto resume;
    else{@+cur_spec=p;return;
      }  /*the final cubic was dead and is gone*/ 
    } 
  } 
else if (!odd(right_type(pp)))  /*the $x$ coordinates were negated*/ 
  @<Complement the |y| coordinates...@>@;

@ A similar correction to octant codes deserves to be made when |x| is
constant and |y| is decreasing.

@<Correct the octant code in segments with decreasing |y|@>=
{@+pp=p;
@/do@+{qq=link(pp);
if (right_type(pp) > negate_y)  /*the $y$ coordinates were negated*/ 
  {@+right_type(pp)=right_type(pp)+negate_x;
  negate(x_coord(pp));negate(right_x(pp));negate(left_x(qq));
  } 
pp=qq;
}@+ while (!(pp==q));
} 

@ Finally, the process of subdividing to make $x'\G y'$ is like the other
two subdivisions, with a few new twists. We skew the coordinates at this time.

@<Declare subroutines needed by |make_spec|@>=
void octant_subdivide(void)
{@+pointer @!p, @!q, @!r, @!s; /*for traversing the lists*/ 
scaled @!del1, @!del2, @!del3, @!del, @!dmax; /*proportional to the control
  points of a quadratic derived from a cubic*/ 
fraction @!t; /*where a quadratic crosses zero*/ 
scaled @!dest_x, @!dest_y; /*final values of |x| and |y| in the current cubic*/ 
p=cur_spec;
@/do@+{q=link(p);@/
x_coord(p)=x_coord(p)-y_coord(p);
right_x(p)=right_x(p)-right_y(p);
left_x(q)=left_x(q)-left_y(q);@/
@<Subdivide the cubic between |p| and |q| so that the results travel toward the first
octant@>;
p=q;
}@+ while (!(p==cur_spec));
} 

@ @<Subdivide the cubic between |p| and |q| so that the results travel toward the
first octant@>=
@<Set up the variables |(del1,del2,del3)| to represent $x'-y'$@>;
@<Scale up |del1|, |del2|, and |del3| for greater accuracy; also set |del| to the
first nonzero element of |(del1,del2,del3)|@>;
if (del!=0)  /*they weren't all zero*/ 
  {@+if (del < 0) @<Swap the |x| and |y| coordinates of the cubic between |p| and~|q|@>;
  t=crossing_point(del1, del2, del3);
  if (t < fraction_one) 
    @<Subdivide the cubic with respect to $x'-y'$, possibly twice@>;
  } 

@ @<Set up the variables |(del1,del2,del3)| to represent $x'-y'$@>=
if (q==cur_spec) 
  {@+unskew(x_coord(q), y_coord(q), right_type(q));
  skew(cur_x, cur_y, right_type(p));dest_x=cur_x;dest_y=cur_y;
  } 
else{@+abnegate(x_coord(q), y_coord(q), right_type(q), right_type(p));
  dest_x=cur_x-cur_y;dest_y=cur_y;
  } 
del1=right_x(p)-x_coord(p);del2=left_x(q)-right_x(p);
del3=dest_x-left_x(q)

@ The swapping here doesn't simply interchange |x| and |y| values,
because the coordinates are skewed. It turns out that this is easier
than ordinary swapping, because it can be done in two assignment statements
rather than three.

@ @<Swap the |x| and |y| coordinates...@>=
{@+y_coord(p)=x_coord(p)+y_coord(p);negate(x_coord(p));@/
right_y(p)=right_x(p)+right_y(p);negate(right_x(p));@/
left_y(q)=left_x(q)+left_y(q);negate(left_x(q));@/
negate(del1);negate(del2);negate(del3);@/
dest_y=dest_x+dest_y;negate(dest_x);@/
right_type(p)=right_type(p)+switch_x_and_y;
} 

@ A somewhat tedious case analysis is carried out here to make sure that
nasty rounding errors don't destroy our assumptions of monotonicity.

@<Subdivide the cubic with respect to $x'-y'$, possibly twice@>=
{@+split_cubic(p, t, dest_x, dest_y);r=link(p);
if (right_type(r) > switch_x_and_y) right_type(r)=right_type(r)-switch_x_and_y;
else right_type(r)=right_type(r)+switch_x_and_y;
if (y_coord(r) < y_coord(p)) y_coord(r)=y_coord(p);
else if (y_coord(r) > dest_y) y_coord(r)=dest_y;
if (x_coord(p)+y_coord(r) > dest_x+dest_y) 
  y_coord(r)=dest_x+dest_y-x_coord(p);
if (left_y(r) > y_coord(r)) 
  {@+left_y(r)=y_coord(r);
  if (right_y(p) > y_coord(r)) right_y(p)=y_coord(r);
  } 
if (right_y(r) < y_coord(r)) 
  {@+right_y(r)=y_coord(r);
  if (left_y(q) < y_coord(r)) left_y(q)=y_coord(r);
  } 
if (x_coord(r) < x_coord(p)) x_coord(r)=x_coord(p);
else if (x_coord(r)+y_coord(r) > dest_x+dest_y) 
  x_coord(r)=dest_x+dest_y-y_coord(r);
left_x(r)=x_coord(r);
if (right_x(p) > x_coord(r)) right_x(p)=x_coord(r);
  /*we always have |x_coord(p) <= right_x(p)|*/ 
y_coord(r)=y_coord(r)+x_coord(r);right_y(r)=right_y(r)+x_coord(r);@/
negate(x_coord(r));right_x(r)=x_coord(r);@/
left_y(q)=left_y(q)+left_x(q);negate(left_x(q));@/
dest_y=dest_y+dest_x;negate(dest_x);
if (right_y(r) < y_coord(r)) 
  {@+right_y(r)=y_coord(r);
  if (left_y(q) < y_coord(r)) left_y(q)=y_coord(r);
  } 
del2=t_of_the_way(del2)(del3);
   /*now |0, del2, del3| represent $x'-y'$ on the remaining interval*/ 
if (del2 > 0) del2=0;
t=crossing_point(0,-del2,-del3);
if (t < fraction_one) 
  @<Subdivide the cubic a second time with respect to $x'-y'$@>@;
else{@+if (x_coord(r) > dest_x) 
    {@+x_coord(r)=dest_x;left_x(r)=-x_coord(r);right_x(r)=x_coord(r);
    } 
  if (left_x(q) > dest_x) left_x(q)=dest_x;
  else if (left_x(q) < x_coord(r)) left_x(q)=x_coord(r);
  } 
} 

@ @<Subdivide the cubic a second time with respect to $x'-y'$@>=
{@+split_cubic(r, t, dest_x, dest_y);s=link(r);@/
if (y_coord(s) < y_coord(r)) y_coord(s)=y_coord(r);
else if (y_coord(s) > dest_y) y_coord(s)=dest_y;
if (x_coord(r)+y_coord(s) > dest_x+dest_y) 
  y_coord(s)=dest_x+dest_y-x_coord(r);
if (left_y(s) > y_coord(s)) 
  {@+left_y(s)=y_coord(s);
  if (right_y(r) > y_coord(s)) right_y(r)=y_coord(s);
  } 
if (right_y(s) < y_coord(s)) 
  {@+right_y(s)=y_coord(s);
  if (left_y(q) < y_coord(s)) left_y(q)=y_coord(s);
  } 
if (x_coord(s)+y_coord(s) > dest_x+dest_y) x_coord(s)=dest_x+dest_y-y_coord(s);
else{@+if (x_coord(s) < dest_x) x_coord(s)=dest_x;
  if (x_coord(s) < x_coord(r)) x_coord(s)=x_coord(r);
  } 
right_type(s)=right_type(p);
left_x(s)=x_coord(s); /*now |x_coord(r)==right_x(r) <= left_x(s)|*/ 
if (left_x(q) < dest_x) 
  {@+left_y(q)=left_y(q)+dest_x;left_x(q)=-dest_x;@+} 
else if (left_x(q) > x_coord(s)) 
  {@+left_y(q)=left_y(q)+x_coord(s);left_x(q)=-x_coord(s);@+} 
else{@+left_y(q)=left_y(q)+left_x(q);negate(left_x(q));@+} 
y_coord(s)=y_coord(s)+x_coord(s);right_y(s)=right_y(s)+x_coord(s);@/
negate(x_coord(s));right_x(s)=x_coord(s);@/
if (right_y(s) < y_coord(s)) 
  {@+right_y(s)=y_coord(s);
  if (left_y(q) < y_coord(s)) left_y(q)=y_coord(s);
  } 
} 

@ It's time now to consider ``autorounding,'' which tries to make horizontal,
vertical, and diagonal tangents occur at places that will produce appropriate
images after the curve is digitized.

The first job is to fix things so that |x(t)| plus the horizontal pen offset
is an integer multiple of the
current ``granularity'' when the derivative $x'(t)$ crosses through zero.
The given cyclic path contains regions where $x'(t)\G0$ and regions
where $x'(t)\L0$. The |quadrant_subdivide| routine is called into action
before any of the path coordinates have been skewed, but some of them
may have been negated. In regions where $x'(t)\G0$ we have |right_type==
first_octant| or |right_type==eighth_octant|; in regions where $x'(t)\L0$,
we have |right_type==fifth_octant| or |right_type==fourth_octant|.

Within any such region the transformed $x$ values increase monotonically
from, say, $x_0$ to~$x_1$. We want to modify things by applying a linear
transformation to all $x$ coordinates in the region, after which
the $x$ values will increase monotonically from round$(x_0)$ to round$(x_1)$.

This rounding scheme sounds quite simple, and it usually is. But several
complications can arise that might make the task more difficult. In the
first place, autorounding is inappropriate at cusps where $x'$ jumps
discontinuously past zero without ever being zero. In the second place,
the current pen might be unsymmetric in such a way that $x$ coordinates
should round differently in different parts of the curve.
These considerations imply that round$(x_0)$ might be greater
than round$(x_1)$, even though $x_0\L x_1$; in such cases we do not want
to carry out the linear transformation. Furthermore, it's possible to have
round$(x_1)-\hbox{round} (x_0)$ positive but much greater than $x_1-x_0$;
then the transformation might distort the curve drastically, and again we
want to avoid it. Finally, the rounded points must be consistent between
adjacent regions, hence we can't transform one region without knowing
about its neighbors.

To handle all these complications, we must first look at the whole
cycle and choose rounded $x$ values that are ``safe.'' The following
procedure does this: Given $m$~values $(b_0,b_1,\ldots,b_{m-1})$ before
rounding and $m$~corresponding values $(a_0,a_1,\ldots,a_{m-1})$ that would
be desirable after rounding, the |make_safe| routine sets $a$'s to $b$'s
if necessary so that $0\L(a\k-a_k)/(b\k-b_k)\L2$ afterwards. It is
symmetric under cyclic permutation, reversal, and/or negation of the inputs.
(Instead of |a|, |b|, and~|m|, the program uses the names |after|,
|before|, and |cur_rounding_ptr|.)

@<Declare subroutines needed by |make_spec|@>=
void make_safe(void)
{@+int @!k; /*runs through the list of inputs*/ 
bool @!all_safe; /*does everything look OK so far?*/ 
scaled @!next_a; /*|after[k]| before it might have changed*/ 
scaled @!delta_a, @!delta_b; /*|after[k+1]-after[k]| and |before[k+1]-before[k]|*/ 
before[cur_rounding_ptr]=before[0]; /*wrap around*/ 
node_to_round[cur_rounding_ptr]=node_to_round[0];
@/do@+{after[cur_rounding_ptr]=after[0];all_safe=true;next_a=after[0];
for (k=0; k<=cur_rounding_ptr-1; k++) 
  {@+delta_b=before[k+1]-before[k];
  if (delta_b >= 0) delta_a=after[k+1]-next_a;
  else delta_a=next_a-after[k+1];
  next_a=after[k+1];
  if ((delta_a < 0)||(delta_a > abs(delta_b+delta_b))) 
    {@+all_safe=false;after[k]=before[k];
    if (k==cur_rounding_ptr-1) after[0]=before[0];
    else after[k+1]=before[k+1];
    } 
  } 
}@+ while (!(all_safe));
} 

@ The global arrays used by |make_safe| are accompanied by an array of
pointers into the current knot list.

@<Glob...@>=
scaled @!before[max_wiggle+1], @!after[max_wiggle+1]; /*data for |make_safe|*/ 
pointer @!node_to_round[max_wiggle+1]; /*reference back to the path*/ 
uint16_t @!cur_rounding_ptr; /*how many are being used*/ 
uint16_t @!max_rounding_ptr; /*how many have been used*/ 

@ @<Set init...@>=
max_rounding_ptr=0;

@ New entries go into the tables via the |before_and_after| routine:

@<Declare subroutines needed by |make_spec|@>=
void before_and_after(scaled @!b, scaled @!a, pointer @!p)
{@+if (cur_rounding_ptr==max_rounding_ptr) 
  if (max_rounding_ptr < max_wiggle) incr(max_rounding_ptr);
  else overflow("rounding table size", max_wiggle);
@:METAFONT capacity exceeded rounding table size}{\quad rounding table size@>
after[cur_rounding_ptr]=a;before[cur_rounding_ptr]=b;
node_to_round[cur_rounding_ptr]=p;incr(cur_rounding_ptr);
} 

@ A global variable called |cur_gran| is used instead of |internal[
granularity]|, because we want to work with a number that's guaranteed to
be positive.

@<Glob...@>=
scaled @!cur_gran; /*the current granularity (which normally is |unity|)*/ 

@ The |good_val| function computes a number |a| that's as close as
possible to~|b|, with the property that |a+o| is a multiple of
|cur_gran|.

If we assume that |cur_gran| is even (since it will in fact be a multiple
of |unity| in all reasonable applications), we have the identity
|good_val(-b-1,-o)==-good_val(b, o)|.

@<Declare subroutines needed by |make_spec|@>=
scaled good_val(scaled @!b, scaled @!o)
{@+scaled @!a; /*accumulator*/ 
a=b+o;
if (a >= 0) a=a-(a%cur_gran)-o;
else a=a+((-(a+1))%cur_gran)-cur_gran+1-o;
if (b-a < a+cur_gran-b) return a;
else return a+cur_gran;
} 

@ When we're rounding a doublepath, we might need to compromise between
two opposing tendencies, if the pen thickness is not a multiple of the
granularity. The following ``compromise'' adjustment, suggested by
John Hobby, finds the best way out of the dilemma. (Only the value
@^Hobby, John Douglas@>
modulo |cur_gran| is relevant in our applications, so the result turns
out to be essentially symmetric in |u| and~|v|.)

@<Declare subroutines needed by |make_spec|@>=
scaled compromise(scaled @!u, scaled @!v)
{@+return half(good_val(u+u,-u-v));
} 

@ Here, then, is the procedure that rounds $x$ coordinates as described;
it does the same for $y$ coordinates too, independently.

@<Declare subroutines needed by |make_spec|@>=
void xy_round(void)
{@+pointer @!p, @!q; /*list manipulation registers*/ 
scaled @!b, @!a; /*before and after values*/ 
scaled @!pen_edge; /*offset that governs rounding*/ 
fraction @!alpha; /*coefficient of linear transformation*/ 
cur_gran=abs(internal[granularity]);
if (cur_gran==0) cur_gran=unity;
p=cur_spec;cur_rounding_ptr=0;
@/do@+{q=link(p);
@<If node |q| is a transition point for |x| coordinates, compute and save its before-and-after
coordinates@>;
p=q;
}@+ while (!(p==cur_spec));
if (cur_rounding_ptr > 0) @<Transform the |x| coordinates@>;
p=cur_spec;cur_rounding_ptr=0;
@/do@+{q=link(p);
@<If node |q| is a transition point for |y| coordinates, compute and save its before-and-after
coordinates@>;
p=q;
}@+ while (!(p==cur_spec));
if (cur_rounding_ptr > 0) @<Transform the |y| coordinates@>;
} 

@ When |x| has been negated, the |octant| codes are even. We allow
for an error of up to .01 pixel (i.e., 655 |scaled| units) in the
derivative calculations at transition nodes.

@<If node |q| is a transition point for |x| coordinates...@>=
if (odd(right_type(p))!=odd(right_type(q))) 
  {@+if (odd(right_type(q))) b=x_coord(q);@+else b=-x_coord(q);
  if ((abs(x_coord(q)-right_x(q)) < 655)||@|
    (abs(x_coord(q)+left_x(q)) < 655)) 
    @<Compute before-and-after |x| values based on the current pen@>@;
  else a=b;
  if (abs(a) > max_allowed) 
    if (a > 0) a=max_allowed;@+else a=-max_allowed;
  before_and_after(b, a, q);
  } 

@ When we study the data representation for pens, we'll learn that the
|x|~coordinate of the current pen's west edge is
$$\hbox{|y_coord(link(cur_pen+seventh_octant))|},$$
and that there are similar ways to address other important offsets.

@d north_edge(X)	y_coord(link(X+fourth_octant))
@d south_edge(X)	y_coord(link(X+first_octant))
@d east_edge(X)	y_coord(link(X+second_octant))
@d west_edge(X)	y_coord(link(X+seventh_octant))

@<Compute before-and-after |x| values based on the current pen@>=
{@+if (cur_pen==null_pen) pen_edge=0;
else if (cur_path_type==double_path_code) 
  pen_edge=compromise(east_edge(cur_pen), west_edge(cur_pen));
else if (odd(right_type(q))) pen_edge=west_edge(cur_pen);
else pen_edge=east_edge(cur_pen);
a=good_val(b, pen_edge);
} 

@ The monotone transformation computed here with fixed-point arithmetic is
guaranteed to take consecutive |before| values $(b,b')$ into consecutive
|after| values $(a,a')$, even in the presence of rounding errors,
as long as $\vert b-b'\vert<2^{28}$.

@<Transform the |x| coordinates@>=
{@+make_safe();
@/do@+{decr(cur_rounding_ptr);
if ((after[cur_rounding_ptr]!=before[cur_rounding_ptr])||@|
 (after[cur_rounding_ptr+1]!=before[cur_rounding_ptr+1])) 
  {@+p=node_to_round[cur_rounding_ptr];
  if (odd(right_type(p))) 
    {@+b=before[cur_rounding_ptr];a=after[cur_rounding_ptr];
    } 
  else{@+b=-before[cur_rounding_ptr];a=-after[cur_rounding_ptr];
    } 
  if (before[cur_rounding_ptr]==before[cur_rounding_ptr+1]) 
    alpha=fraction_one;
  else alpha=make_fraction(after[cur_rounding_ptr+1]-after[cur_rounding_ptr],@|
    before[cur_rounding_ptr+1]-before[cur_rounding_ptr]);
  @/do@+{x_coord(p)=take_fraction(alpha, x_coord(p)-b)+a;
  right_x(p)=take_fraction(alpha, right_x(p)-b)+a;
  p=link(p);left_x(p)=take_fraction(alpha, left_x(p)-b)+a;
  }@+ while (!(p==node_to_round[cur_rounding_ptr+1]));
  } 
}@+ while (!(cur_rounding_ptr==0));
} 

@ When |y| has been negated, the |octant| codes are | > negate_y|. Otherwise
these routines are essentially identical to the routines for |x| coordinates
that we have just seen.

@<If node |q| is a transition point for |y| coordinates...@>=
if ((right_type(p) > negate_y)!=(right_type(q) > negate_y)) 
  {@+if (right_type(q) <= negate_y) b=y_coord(q);@+else b=-y_coord(q);
  if ((abs(y_coord(q)-right_y(q)) < 655)||@|
    (abs(y_coord(q)+left_y(q)) < 655)) 
    @<Compute before-and-after |y| values based on the current pen@>@;
  else a=b;
  if (abs(a) > max_allowed) 
    if (a > 0) a=max_allowed;@+else a=-max_allowed;
  before_and_after(b, a, q);
  } 

@ @<Compute before-and-after |y| values based on the current pen@>=
{@+if (cur_pen==null_pen) pen_edge=0;
else if (cur_path_type==double_path_code) 
  pen_edge=compromise(north_edge(cur_pen), south_edge(cur_pen));
else if (right_type(q) <= negate_y) pen_edge=south_edge(cur_pen);
else pen_edge=north_edge(cur_pen);
a=good_val(b, pen_edge);
} 

@ @<Transform the |y| coordinates@>=
{@+make_safe();
@/do@+{decr(cur_rounding_ptr);
if ((after[cur_rounding_ptr]!=before[cur_rounding_ptr])||@|
 (after[cur_rounding_ptr+1]!=before[cur_rounding_ptr+1])) 
  {@+p=node_to_round[cur_rounding_ptr];
  if (right_type(p) <= negate_y) 
    {@+b=before[cur_rounding_ptr];a=after[cur_rounding_ptr];
    } 
  else{@+b=-before[cur_rounding_ptr];a=-after[cur_rounding_ptr];
    } 
  if (before[cur_rounding_ptr]==before[cur_rounding_ptr+1]) 
    alpha=fraction_one;
  else alpha=make_fraction(after[cur_rounding_ptr+1]-after[cur_rounding_ptr],@|
    before[cur_rounding_ptr+1]-before[cur_rounding_ptr]);
  @/do@+{y_coord(p)=take_fraction(alpha, y_coord(p)-b)+a;
  right_y(p)=take_fraction(alpha, right_y(p)-b)+a;
  p=link(p);left_y(p)=take_fraction(alpha, left_y(p)-b)+a;
  }@+ while (!(p==node_to_round[cur_rounding_ptr+1]));
  } 
}@+ while (!(cur_rounding_ptr==0));
} 

@ Rounding at diagonal tangents takes place after the subdivision into
octants is complete, hence after the coordinates have been skewed.
The details are somewhat tricky, because we want to round to points
whose skewed coordinates are halfway between integer multiples of
the granularity. Furthermore, both coordinates change when they are
rounded; this means we need a generalization of the |make_safe| routine,
ensuring safety in both |x| and |y|.

In spite of these extra complications, we can take comfort in the fact
that the basic structure of the routine is the same as before.

@<Declare subroutines needed by |make_spec|@>=
void diag_round(void)
{@+pointer @!p, @!q, @!pp; /*list manipulation registers*/ 
scaled @!b, @!a, @!bb, @!aa, @!d, @!c, @!dd, @!cc; /*before and after values*/ 
scaled @!pen_edge; /*offset that governs rounding*/ 
fraction @!alpha, @!beta; /*coefficients of linear transformation*/ 
scaled @!next_a; /*|after[k]| before it might have changed*/ 
bool @!all_safe; /*does everything look OK so far?*/ 
int @!k; /*runs through before-and-after values*/ 
scaled @!first_x, @!first_y; /*coordinates before rounding*/ 
p=cur_spec;cur_rounding_ptr=0;
@/do@+{q=link(p);
@<If node |q| is a transition point between octants, compute and save its before-and-after
coordinates@>;
p=q;
}@+ while (!(p==cur_spec));
if (cur_rounding_ptr > 0) @<Transform the skewed coordinates@>;
} 

@ We negate the skewed |x| coordinates in the before-and-after table when
the octant code is greater than |switch_x_and_y|.

@<If node |q| is a transition point between octants...@>=
if (right_type(p)!=right_type(q)) 
  {@+if (right_type(q) > switch_x_and_y) b=-x_coord(q);
  else b=x_coord(q);
  if (abs(right_type(q)-right_type(p))==switch_x_and_y) 
    if ((abs(x_coord(q)-right_x(q)) < 655)||(abs(x_coord(q)+left_x(q)) < 655)) 
      @<Compute a good coordinate at a diagonal transition@>@;
    else a=b;
  else a=b;
  before_and_after(b, a, q);
  } 

@ In octants whose code number is even, $x$~has been
negated; we want to round ambiguous cases downward instead of upward,
so that the rounding will be consistent with octants whose code
number is odd. This downward bias can be achieved by
subtracting~1 from the first argument of |good_val|.

@d diag_offset(X)	x_coord(knil(link(cur_pen+X)))

@<Compute a good coordinate at a diagonal transition@>=
{@+if (cur_pen==null_pen) pen_edge=0;
else if (cur_path_type==double_path_code) @<Compute a compromise |pen_edge|@>@;
else if (right_type(q) <= switch_x_and_y) pen_edge=diag_offset(right_type(q));
else pen_edge=-diag_offset(right_type(q));
if (odd(right_type(q))) a=good_val(b, pen_edge+half(cur_gran));
else a=good_val(b-1, pen_edge+half(cur_gran));
} 

@ (It seems a shame to compute these compromise offsets repeatedly. The
author would have stored them directly in the pen data structure, if the
granularity had been constant.)

@<Compute a compromise...@>=
switch (right_type(q)) {
case first_octant: case second_octant: pen_edge=compromise(diag_offset(first_octant),@|
    -diag_offset(fifth_octant));@+break;
case fifth_octant: case sixth_octant: pen_edge=-compromise(diag_offset(first_octant),@|
    -diag_offset(fifth_octant));@+break;
case third_octant: case fourth_octant: pen_edge=compromise(diag_offset(fourth_octant),@|
    -diag_offset(eighth_octant));@+break;
case seventh_octant: case eighth_octant: pen_edge=-compromise(diag_offset(fourth_octant),@|
    -diag_offset(eighth_octant));
}  /*there are no other cases*/ 

@ @<Transform the skewed coordinates@>=
{@+p=node_to_round[0];first_x=x_coord(p);first_y=y_coord(p);
@<Make sure that all the diagonal roundings are safe@>;
for (k=0; k<=cur_rounding_ptr-1; k++) 
  {@+a=after[k];b=before[k];
  aa=after[k+1];bb=before[k+1];
  if ((a!=b)||(aa!=bb)) 
    {@+p=node_to_round[k];pp=node_to_round[k+1];
    @<Determine the before-and-after values of both coordinates@>;
    if (b==bb) alpha=fraction_one;
    else alpha=make_fraction(aa-a, bb-b);
    if (d==dd) beta=fraction_one;
    else beta=make_fraction(cc-c, dd-d);
    @/do@+{x_coord(p)=take_fraction(alpha, x_coord(p)-b)+a;
    y_coord(p)=take_fraction(beta, y_coord(p)-d)+c;
    right_x(p)=take_fraction(alpha, right_x(p)-b)+a;
    right_y(p)=take_fraction(beta, right_y(p)-d)+c;
    p=link(p);left_x(p)=take_fraction(alpha, left_x(p)-b)+a;
    left_y(p)=take_fraction(beta, left_y(p)-d)+c;
    }@+ while (!(p==pp));
    } 
  } 
} 

@ In node |p|, the coordinates |(b, d)| will be rounded to |(a, c)|;
in node |pp|, the coordinates |(bb, dd)| will be rounded to |(aa, cc)|.
(We transform the values from node |pp| so that they agree with the
conventions of node |p|.)

If |aa!=bb|, we know that |abs(right_type(p)-right_type(pp))==switch_x_and_y|.

@<Determine the before-and-after values of both coordinates@>=
if (aa==bb) 
  {@+if (pp==node_to_round[0]) 
    unskew(first_x, first_y, right_type(pp));
  else unskew(x_coord(pp), y_coord(pp), right_type(pp));
  skew(cur_x, cur_y, right_type(p));
  bb=cur_x;aa=bb;dd=cur_y;cc=dd;
  if (right_type(p) > switch_x_and_y) 
    {@+b=-b;a=-a;
    } 
  } 
else{@+if (right_type(p) > switch_x_and_y) 
    {@+bb=-bb;aa=-aa;b=-b;a=-a;
    } 
  if (pp==node_to_round[0]) dd=first_y-bb;@+else dd=y_coord(pp)-bb;
  if (odd(aa-bb)) 
    if (right_type(p) > switch_x_and_y) cc=dd-half(aa-bb+1);
    else cc=dd-half(aa-bb-1);
  else cc=dd-half(aa-bb);
  } 
d=y_coord(p);
if (odd(a-b)) 
  if (right_type(p) > switch_x_and_y) c=d-half(a-b-1);
  else c=d-half(a-b+1);
else c=d-half(a-b)

@ @<Make sure that all the diagonal roundings are safe@>=
before[cur_rounding_ptr]=before[0]; /*cf.~|make_safe|*/ 
node_to_round[cur_rounding_ptr]=node_to_round[0];
@/do@+{after[cur_rounding_ptr]=after[0];all_safe=true;next_a=after[0];
for (k=0; k<=cur_rounding_ptr-1; k++) 
  {@+a=next_a;b=before[k];next_a=after[k+1];
  aa=next_a;bb=before[k+1];
  if ((a!=b)||(aa!=bb)) 
    {@+p=node_to_round[k];pp=node_to_round[k+1];
    @<Determine the before-and-after values of both coordinates@>;
    if ((aa < a)||(cc < c)||(aa-a > 2*(bb-b))||(cc-c > 2*(dd-d))) 
      {@+all_safe=false;after[k]=before[k];
      if (k==cur_rounding_ptr-1) after[0]=before[0];
      else after[k+1]=before[k+1];
      } 
    } 
  } 
}@+ while (!(all_safe))

@ Here we get rid of ``dead'' cubics, i.e., polynomials that don't move at
all when |t|~changes, since the subdivision process might have introduced
such things.  If the cycle reduces to a single point, however, we are left
with a single dead cubic that will not be removed until later.

@<Remove dead cubics@>=
p=cur_spec;
@/do@+{resume: q=link(p);
if (p!=q) 
  {@+if (x_coord(p)==right_x(p)) 
   if (y_coord(p)==right_y(p)) 
    if (x_coord(p)==left_x(q)) 
     if (y_coord(p)==left_y(q)) 
    {@+unskew(x_coord(q), y_coord(q), right_type(q));
    skew(cur_x, cur_y, right_type(p));
    if (x_coord(p)==cur_x) if (y_coord(p)==cur_y) 
      {@+remove_cubic(p); /*remove the cubic following |p|*/ 
      if (q!=cur_spec) goto resume;
      cur_spec=p;q=p;
      } 
    } 
  } 
p=q;
}@+ while (!(p==cur_spec));

@ Finally we come to the last steps of |make_spec|, when boundary nodes
are inserted between cubics that move in different octants. The main
complication remaining arises from consecutive cubics whose octants
are not adjacent; we should insert more than one octant boundary
at such sharp turns, so that the envelope-forming routine will work.

For this purpose, conversion tables between numeric and Gray codes for
octants are desirable.

@<Glob...@>=
uint8_t @!octant_number0[sixth_octant-first_octant+1], *const @!octant_number = @!octant_number0-first_octant;
uint8_t @!octant_code0[8], *const @!octant_code = @!octant_code0-1;

@ @<Set init...@>=
octant_code[1]=first_octant;
octant_code[2]=second_octant;
octant_code[3]=third_octant;
octant_code[4]=fourth_octant;
octant_code[5]=fifth_octant;
octant_code[6]=sixth_octant;
octant_code[7]=seventh_octant;
octant_code[8]=eighth_octant;
for (k=1; k<=8; k++) octant_number[octant_code[k]]=k;

@ The main loop for boundary insertion deals with three consecutive
nodes |p, q, r|.

@<Insert octant boundaries and compute the turning number@>=
turning_number=0;
p=cur_spec;q=link(p);
@/do@+{r=link(q);
if ((right_type(p)!=right_type(q))||(q==r)) 
  @<Insert one or more octant boundary nodes just before~|q|@>;
p=q;q=r;
}@+ while (!(p==cur_spec));

@ The |new_boundary| subroutine comes in handy at this point. It inserts
a new boundary node just after a given node |p|, using a given octant code
to transform the new node's coordinates. The ``transition'' fields are
not computed here.

@<Declare subroutines needed by |make_spec|@>=
void new_boundary(pointer @!p, small_number @!octant)
{@+pointer @!q, @!r; /*for list manipulation*/ 
q=link(p); /*we assume that |right_type(q)!=endpoint|*/ 
r=get_node(knot_node_size);link(r)=q;link(p)=r;
left_type(r)=left_type(q); /*but possibly |left_type(q)==endpoint|*/ 
left_x(r)=left_x(q);left_y(r)=left_y(q);
right_type(r)=endpoint;left_type(q)=endpoint;
right_octant(r)=octant;left_octant(q)=right_type(q);
unskew(x_coord(q), y_coord(q), right_type(q));
skew(cur_x, cur_y, octant);x_coord(r)=cur_x;y_coord(r)=cur_y;
} 

@ The case |q==r| occurs if and only if |p==q==r==cur_spec|, when we want to turn
$360^\circ$ in eight steps and then remove a solitary dead cubic.
The program below happens to work in that case, but the reader isn't
expected to understand why.

@<Insert one or more octant boundary nodes just before~|q|@>=
{@+new_boundary(p, right_type(p));s=link(p);
o1=octant_number[right_type(p)];o2=octant_number[right_type(q)];
switch (o2-o1) {
case 1: case -7: case 7: case -1: goto done;
case 2: case -6: clockwise=false;@+break;
case 3: case -5: case 4: case -4: case 5: case -3: @<Decide whether or not to go clockwise@>@;@+break;
case 6: case -2: clockwise=true;@+break;
case 0: clockwise=rev_turns;
}  /*there are no other cases*/ 
@<Insert additional boundary nodes, then |goto done|@>;
done: if (q==r) 
  {@+q=link(q);r=q;p=s;link(s)=q;left_octant(q)=right_octant(q);
  left_type(q)=endpoint;free_node(cur_spec, knot_node_size);cur_spec=q;
  } 
@<Fix up the transition fields and adjust the turning number@>;
} 

@ @<Other local variables for |make_spec|@>=
small_number @!o1, @!o2; /*octant numbers*/ 
bool @!clockwise; /*should we turn clockwise?*/ 
int @!dx1, @!dy1, @!dx2, @!dy2; /*directions of travel at a cusp*/ 
int @!dmax, @!del; /*temporary registers*/ 

@ A tricky question arises when a path jumps four octants. We want the
direction of turning to be counterclockwise if the curve has changed
direction by $180^\circ$, or by something so close to $180^\circ$ that
the difference is probably due to rounding errors; otherwise we want to
turn through an angle of less than $180^\circ$. This decision needs to
be made even when a curve seems to have jumped only three octants, since
a curve may approach direction $(-1,0)$ from the fourth octant, then
it might leave from direction $(+1,0)$ into the first.

The following code solves the problem by analyzing the incoming
direction |(dx1, dy1)| and the outgoing direction |(dx2, dy2)|.

@<Decide whether or not to go clockwise@>=
{@+@<Compute the incoming and outgoing directions@>;
unskew(dx1, dy1, right_type(p));del=pyth_add(cur_x, cur_y);@/
dx1=make_fraction(cur_x, del);dy1=make_fraction(cur_y, del);
   /*$\cos\theta_1$ and $\sin\theta_1$*/ 
unskew(dx2, dy2, right_type(q));del=pyth_add(cur_x, cur_y);@/
dx2=make_fraction(cur_x, del);dy2=make_fraction(cur_y, del);
   /*$\cos\theta_2$ and $\sin\theta_2$*/ 
del=take_fraction(dx1, dy2)-take_fraction(dx2, dy1); /*$\sin(\theta_2-\theta_1)$*/ 
if (del > 4684844) clockwise=false;
else if (del < -4684844) clockwise=true;
   /*$2^{28}\cdot\sin 1^\circ\approx4684844.68$*/ 
else clockwise=rev_turns;
} 

@ Actually the turnarounds just computed will be clockwise,
not counterclockwise, if
the global variable |rev_turns| is |true|; it is usually |false|.

@<Glob...@>=
bool @!rev_turns; /*should we make U-turns in the English manner?*/ 

@ @<Set init...@>=
rev_turns=false;

@ @<Compute the incoming and outgoing directions@>=
dx1=x_coord(s)-left_x(s);dy1=y_coord(s)-left_y(s);
if (dx1==0) if (dy1==0) 
  {@+dx1=x_coord(s)-right_x(p);dy1=y_coord(s)-right_y(p);
  if (dx1==0) if (dy1==0) 
    {@+dx1=x_coord(s)-x_coord(p);dy1=y_coord(s)-y_coord(p);
    }  /*and they {\sl can't} both be zero*/ 
  } 
dmax=abs(dx1);@+if (abs(dy1) > dmax) dmax=abs(dy1);
while (dmax < fraction_one) 
  {@+double(dmax);double(dx1);double(dy1);
  } 
dx2=right_x(q)-x_coord(q);dy2=right_y(q)-y_coord(q);
if (dx2==0) if (dy2==0) 
  {@+dx2=left_x(r)-x_coord(q);dy2=left_y(r)-y_coord(q);
  if (dx2==0) if (dy2==0) 
    {@+if (right_type(r)==endpoint) 
      {@+cur_x=x_coord(r);cur_y=y_coord(r);
      } 
    else{@+unskew(x_coord(r), y_coord(r), right_type(r));
      skew(cur_x, cur_y, right_type(q));
      } 
    dx2=cur_x-x_coord(q);dy2=cur_y-y_coord(q);
    }  /*and they {\sl can't} both be zero*/ 
  } 
dmax=abs(dx2);@+if (abs(dy2) > dmax) dmax=abs(dy2);
while (dmax < fraction_one) 
  {@+double(dmax);double(dx2);double(dy2);
  } 

@ @<Insert additional boundary nodes...@>=
loop@+{@+if (clockwise) 
    if (o1==1) o1=8;@+else decr(o1);
  else if (o1==8) o1=1;@+else incr(o1);
  if (o1==o2) goto done;
  new_boundary(s, octant_code[o1]);
  s=link(s);left_octant(s)=right_octant(s);
  } 

@ Now it remains to insert the redundant
transition information into the |left_transition|
and |right_transition| fields between adjacent octants, in the octant
boundary nodes that have just been inserted between |link(p)| and~|q|.
The turning number is easily computed from these transitions.

@<Fix up the transition fields and adjust the turning number@>=
p=link(p);
@/do@+{s=link(p);
o1=octant_number[right_octant(p)];o2=octant_number[left_octant(s)];
if (abs(o1-o2)==1) 
  {@+if (o2 < o1) o2=o1;
  if (odd(o2)) right_transition(p)=axis;
  else right_transition(p)=diagonal;
  } 
else{@+if (o1==8) incr(turning_number);@+else decr(turning_number);
  right_transition(p)=axis;
  } 
left_transition(s)=right_transition(p);
p=s;
}@+ while (!(p==q))

@* Filling a contour.
Given the low-level machinery for making moves and for transforming a
cyclic path into a cycle spec, we're almost able to fill a digitized path.
All we need is a high-level routine that walks through the cycle spec and
controls the overall process.

Our overall goal is to plot the integer points $\bigl(\round(x(t)),
\round(y(t))\bigr)$ and to connect them by rook moves, assuming that
$\round(x(t))$ and $\round(y(t))$ don't both jump simultaneously from
one integer to another as $t$~varies; these rook moves will be the edge
of the contour that will be filled. We have reduced this problem to the
case of curves that travel in first octant directions, i.e., curves
such that $0\L y'(t)\L x'(t)$, by transforming the original coordinates.

\def\xtilde{{\tilde x}} \def\ytilde{{\tilde y}}
Another transformation makes the problem still simpler. We shall say that
we are working with {\sl biased coordinates\/} when $(x,y)$ has been
replaced by $(\xtilde,\ytilde)=(x-y,y+{1\over2})$. When a curve travels
in first octant directions, the corresponding curve with biased
coordinates travels in first {\sl quadrant\/} directions; the latter
condition is symmetric in $x$ and~$y$, so it has advantages for the
design of algorithms. The |make_spec| routine gives us skewed coordinates
$(x-y,y)$, hence we obtain biased coordinates by simply adding $1\over2$
to the second component.

The most important fact about biased coordinates is that we can determine the
rounded unbiased path $\bigl(\round(x(t)),\round(y(t))\bigr)$ from the
truncated biased path $\bigl(\lfloor\xtilde(t)\rfloor,\lfloor\ytilde(t)\rfloor
\bigr)$ and information about the initial and final endpoints. If the
unrounded and unbiased
path begins at $(x_0,y_0)$ and ends at $(x_1,y_1)$, it's possible to
prove (by induction on the length of the truncated biased path) that the
rounded unbiased path is obtained by the following construction:

\yskip\textindent{1)} Start at $\bigl(\round(x_0),\round(y_0)\bigr)$.

\yskip\textindent{2)} If $(x_0+{1\over2})\bmod1\G(y_0+{1\over2})\bmod1$,
move one step right.

\yskip\textindent{3)} Whenever the path
$\bigl(\lfloor\xtilde(t)\rfloor,\lfloor\ytilde(t)\rfloor\bigr)$
takes an upward step (i.e., when
$\lfloor\xtilde(t+\epsilon)\rfloor=\lfloor\xtilde(t)\rfloor$ and
$\lfloor\ytilde(t+\epsilon)\rfloor=\lfloor\ytilde(t)\rfloor+1$),
move one step up and then one step right.

\yskip\textindent{4)} Whenever the path
$\bigl(\lfloor\xtilde(t)\rfloor,\lfloor\ytilde(t)\rfloor\bigr)$
takes a rightward step (i.e., when
$\lfloor\xtilde(t+\epsilon)\rfloor=\lfloor\xtilde(t)\rfloor+1$ and
$\lfloor\ytilde(t+\epsilon)\rfloor=\lfloor\ytilde(t)\rfloor$),
move one step right.

\yskip\textindent{5)} Finally, if
$(x_1+{1\over2})\bmod1\G(y_1+{1\over2})\bmod1$, move one step left (thereby
cancelling the previous move, which was one step right). You will now be
at the point $\bigl(\round(x_1),\round(y_1)\bigr)$.

@ In order to validate the assumption that $\round(x(t))$ and $\round(y(t))$
don't both jump simultaneously, we shall consider that a coordinate pair
$(x,y)$ actually represents $(x+\epsilon,y+\epsilon\delta)$, where
$\epsilon$ and $\delta$ are extremely small positive numbers---so small
that their precise values never matter.  This convention makes rounding
unambiguous, since there is always a unique integer point nearest to any
given scaled numbers~$(x,y)$.

When coordinates are transformed so that \MF\ needs to work only in ``first
octant'' directions, the transformations involve negating~$x$, negating~$y$,
and/or interchanging $x$ with~$y$. Corresponding adjustments to the
rounding conventions must be made so that consistent values will be
obtained. For example, suppose that we're working with coordinates that
have been transformed so that a third-octant curve travels in first-octant
directions. The skewed coordinates $(x,y)$ in our data structure represent
unskewed coordinates $(-y,x+y)$, which are actually $(-y+\epsilon,
x+y+\epsilon\delta)$. We should therefore round as if our skewed coordinates
were $(x+\epsilon+\epsilon\delta,y-\epsilon)$ instead of $(x,y)$. The following
table shows how the skewed coordinates should be perturbed when rounding
decisions are made:
$$\vcenter{\halign{#\hfil&&\quad$#$\hfil&\hskip4em#\hfil\cr
|first_octant|&(x+\epsilon-\epsilon\delta,y+\epsilon\delta)&
 |fifth_octant|&(x-\epsilon+\epsilon\delta,y-\epsilon\delta)\cr
|second_octant|&(x-\epsilon+\epsilon\delta,y+\epsilon)&
 |sixth_octant|&(x+\epsilon-\epsilon\delta,y-\epsilon)\cr
|third_octant|&(x+\epsilon+\epsilon\delta,y-\epsilon)&
 |seventh_octant|&(x-\epsilon-\epsilon\delta,y+\epsilon)\cr
|fourth_octant|&(x-\epsilon-\epsilon\delta,y+\epsilon\delta)&
 |eighth_octant|&(x+\epsilon+\epsilon\delta,y-\epsilon\delta)\cr}}$$

Four small arrays are set up so that the rounding operations will be
fairly easy in any given octant.

@<Glob...@>=
uint8_t @!y_corr0[sixth_octant-first_octant+1], *const @!y_corr = @!y_corr0-first_octant, @!xy_corr0[sixth_octant-first_octant+1], *const @!xy_corr = @!xy_corr0-first_octant, @!z_corr0[sixth_octant-first_octant+1], *const @!z_corr = @!z_corr0-first_octant;
int8_t @!x_corr0[sixth_octant-first_octant+1], *const @!x_corr = @!x_corr0-first_octant;

@ Here |xy_corr| is 1 if and only if the $x$ component of a skewed coordinate
is to be decreased by an infinitesimal amount; |y_corr| is similar, but for
the $y$ components. The other tables are set up so that the condition
$$(x+y+|half_unit|)\bmod|unity|\G(y+|half_unit|)\bmod|unity|$$
is properly perturbed to the condition
$$(x+y+|half_unit|-|x_corr|-|y_corr|)\bmod|unity|\G
  (y+|half_unit|-|y_corr|)\bmod|unity|+|z_corr|.$$

@<Set init...@>=
x_corr[first_octant]=0;y_corr[first_octant]=0;
xy_corr[first_octant]=0;@/
x_corr[second_octant]=0;y_corr[second_octant]=0;
xy_corr[second_octant]=1;@/
x_corr[third_octant]=-1;y_corr[third_octant]=1;
xy_corr[third_octant]=0;@/
x_corr[fourth_octant]=1;y_corr[fourth_octant]=0;
xy_corr[fourth_octant]=1;@/
x_corr[fifth_octant]=0;y_corr[fifth_octant]=1;
xy_corr[fifth_octant]=1;@/
x_corr[sixth_octant]=0;y_corr[sixth_octant]=1;
xy_corr[sixth_octant]=0;@/
x_corr[seventh_octant]=1;y_corr[seventh_octant]=0;
xy_corr[seventh_octant]=1;@/
x_corr[eighth_octant]=-1;y_corr[eighth_octant]=1;
xy_corr[eighth_octant]=0;@/
for (k=1; k<=8; k++) z_corr[k]=xy_corr[k]-x_corr[k];

@ Here's a procedure that handles the details of rounding at the
endpoints: Given skewed coordinates |(x, y)|, it sets |(m1, n1)|
to the corresponding rounded lattice points, taking the current
|octant| into account. Global variable |d1| is also set to 1 if
$(x+y+{1\over2})\bmod1\G(y+{1\over2})\bmod1$.

@p void end_round(scaled @!x, scaled @!y)
{@+y=y+half_unit-y_corr[octant];
x=x+y-x_corr[octant];
m1=floor_unscaled(x);n1=floor_unscaled(y);
if (x-unity*m1 >= y-unity*n1+z_corr[octant]) d1=1;@+else d1=0;
} 

@ The outputs |(m1, n1, d1)| of |end_round| will sometimes be moved
to |(m0, n0, d0)|.

@<Glob...@>=
int @!m0, @!n0, @!m1, @!n1; /*lattice point coordinates*/ 
uint8_t @!d0, @!d1; /*displacement corrections*/ 

@ We're ready now to fill the pixels enclosed by a given cycle spec~|h|;
the knot list that represents the cycle is destroyed in the process.
The edge structure that gets all the resulting data is |cur_edges|,
and the edges are weighted by |cur_wt|.

@p void fill_spec(pointer @!h)
{@+pointer @!p, @!q, @!r, @!s; /*for list traversal*/ 
if (internal[tracing_edges] > 0) begin_edge_tracing();
p=h; /*we assume that |left_type(h)==endpoint|*/ 
@/do@+{octant=left_octant(p);
@<Set variable |q| to the node at the end of the current octant@>;
if (q!=p) 
  {@+@<Determine the starting and ending lattice points |(m0,n0)| and |(m1,n1)|@>;
  @<Make the moves for the current octant@>;
  move_to_edges(m0, n0, m1, n1);
  } 
p=link(q);
}@+ while (!(p==h));
toss_knot_list(h);
if (internal[tracing_edges] > 0) end_edge_tracing();
} 

@ @<Set variable |q| to the node at the end of the current octant@>=
q=p;
while (right_type(q)!=endpoint) q=link(q)

@ @<Determine the starting and ending lattice points |(m0,n0)| and |(m1,n1)|@>=
end_round(x_coord(p), y_coord(p));m0=m1;n0=n1;d0=d1;@/
end_round(x_coord(q), y_coord(q))

@ Finally we perform the five-step process that was explained at
the very beginning of this part of the program.

@<Make the moves for the current octant@>=
if (n1-n0 >= move_size) overflow("move table size", move_size);
@:METAFONT capacity exceeded move table size}{\quad move table size@>
move[0]=d0;move_ptr=0;r=p;
@/do@+{s=link(r);@/
make_moves(x_coord(r), right_x(r), left_x(s), x_coord(s),@|
  y_coord(r)+half_unit, right_y(r)+half_unit, left_y(s)+half_unit,
  y_coord(s)+half_unit,@|xy_corr[octant], y_corr[octant]);
r=s;
}@+ while (!(r==q));
move[move_ptr]=move[move_ptr]-d1;
if (internal[smoothing] > 0) smooth_moves(0, move_ptr)

@* Polygonal pens.
The next few parts of the program deal with the additional complications
associated with ``envelopes,'' leading up to an algorithm that fills a
contour with respect to a pen whose boundary is a convex polygon. The
mathematics underlying this algorithm is based on simple aspects of the
theory of tracings developed by Leo Guibas, Lyle Ramshaw, and Jorge
Stolfi [``A kinetic framework for computational geometry,''
{\sl Proc.\ IEEE Symp.\ Foundations of Computer Science\/ \bf24} (1983),
100--111].
@^Guibas, Leonidas Ioannis@>
@^Ramshaw, Lyle Harold@>
@^Stolfi, Jorge@>

If the vertices of the polygon are $w_0$, $w_1$, \dots, $w_{n-1}$, $w_n=w_0$,
in counterclockwise order, the convexity condition requires that ``left
turns'' are made at each vertex when a person proceeds from $w_0$ to
$w_1$ to $\cdots$ to~$w_n$. The envelope is obtained if we offset a given
curve $z(t)$ by $w_k$ when that curve is traveling in a direction
$z'(t)$ lying between the directions $w_k-w_{k-1}$ and $w\k-w_k$.
At times~$t$ when the curve direction $z'(t)$ increases past
$w\k-w_k$, we temporarily stop plotting the offset curve and we insert
a straight line from $z(t)+w_k$ to $z(t)+w\k$; notice that this straight
line is tangent to the offset curve. Similarly, when the curve direction
decreases past $w_k-w_{k-1}$, we stop plotting and insert a straight
line from $z(t)+w_k$ to $z(t)+w_{k-1}$; the latter line is actually a
``retrograde'' step, which won't be part of the final envelope under
\MF's assumptions. The result of this construction is a continuous path
that consists of alternating curves and straight line segments. The
segments are usually so short, in practice, that they blend with the
curves; after all, it's possible to represent any digitized path as
a sequence of digitized straight lines.

The nicest feature of this approach to envelopes is that it blends
perfectly with the octant subdivision process we have already developed.
The envelope travels in the same direction as the curve itself, as we
plot it, and we need merely be careful what offset is being added.
Retrograde motion presents a problem, but we will see that there is
a decent way to handle it.

@ We shall represent pens by maintaining eight lists of offsets,
one for each octant direction. The offsets at the boundary points
where a curve turns into a new octant will appear in the lists for
both octants. This means that we can restrict consideration to
segments of the original polygon whose directions aim in the first
octant, as we have done in the simpler case when envelopes were not
required.

An example should help to clarify this situation: Consider the
quadrilateral whose vertices are $w_0=(0,-1)$, $w_1=(3,-1)$,
$w_2=(6,1)$, and $w_3=(1,2)$. A curve that travels in the first octant
will be offset by $w_1$ or $w_2$, unless its slope drops to zero
en route to the eighth octant; in the latter case we should switch to $w_0$ as
we cross the octant boundary. Our list for the first octant will
contain the three offsets $w_0$, $w_1$,~$w_2$. By convention we will
duplicate a boundary offset if the angle between octants doesn't
explicitly appear; in this case there is no explicit line of slope~1
at the end of the list, so the full list is
$$w_0\;w_1\;w_2\;w_2\;=\;(0,-1)\;(3,-1)\;(6,1)\;(6,1).$$
With skewed coordinates $(u-v,v)$ instead of $(u,v)$ we obtain the list
$$w_0\;w_1\;w_2\;w_2\;\mapsto\;(1,-1)\;(4,-1)\;(5,1)\;(5,1),$$
which is what actually appears in the data structure. In the second
octant there's only one offset; we list it twice (with coordinates
interchanged, so as to make the second octant look like the first),
and skew those coordinates, obtaining
$$\tabskip\centering
\halign to\hsize{$\hfil#\;\mapsto\;{}$\tabskip=0pt&
  $#\hfil$&\quad in the #\hfil\tabskip\centering\cr
w_2\;w_2&(-5,6)\;(-5,6)\cr
\noalign{\vskip\belowdisplayskip
\vbox{\noindent\strut as the list of transformed and skewed offsets to use
when curves travel in the second octant. Similarly, we will have\strut}
\vskip\abovedisplayskip}
w_2\;w_2&(7,-6)\;(7,-6)&third;\cr
w_2\;w_2\;w_3\;w_3&(-7,1)\;(-7,1)\;(-3,2)\;(-3,2)&fourth;\cr
w_3\;w_3&(1,-2)\;(1,-2)&fifth;\cr
w_3\;w_3\;w_0\;w_0&(-1,1)\;(-1,1)\;(1,0)\;(1,0)&sixth;\cr
w_0\;w_0&(1,0)\;(1,0)&seventh;\cr
w_0\;w_0&(-1,1)\;(-1,1)&eighth.\cr}$$
Notice that $w_1$ is considered here to be internal to the first octant;
it's not part of the eighth. We could equally well have taken $w_0$ out
of the first octant list and put it into the eighth; then the first octant
list would have been
$$w_1\;w_1\;w_2\;w_2\;\mapsto\;(4,-1)\;(4,-1)\;(5,1)\;(5,1)$$
and the eighth octant list would have been
$$w_0\;w_0\;w_1\;\mapsto\;(-1,1)\;(-1,1)\;(2,1).$$

Actually, there's one more complication: The order of offsets is reversed
in even-numbered octants, because the transformation of coordinates has
reversed counterclockwise and clockwise orientations in those octants.
The offsets in the fourth octant, for example, are really $w_3$, $w_3$,
$w_2$,~$w_2$, not $w_2$, $w_2$, $w_3$,~$w_3$.

@ In general, the list of offsets for an octant will have the form
$$w_0\;\;w_1\;\;\ldots\;\;w_n\;\;w_{n+1}$$
(if we renumber the subscripts in each list), where $w_0$ and $w_{n+1}$
are offsets common to the neighboring lists. We'll often have $w_0=w_1$
and/or $w_n=w_{n+1}$, but the other $w$'s will be distinct. Curves
that travel between slope~0 and direction $w_2-w_1$ will use offset~$w_1$;
curves that travel between directions $w_k-w_{k-1}$ and $w\k-w_k$ will
use offset~$w_k$, for $1<k<n$; curves between direction $w_n-w_{n-1}$
and slope~1 (actually slope~$\infty$ after skewing) will use offset~$w_n$.
In even-numbered octants, the directions are actually $w_k-w\k$ instead
of $w\k-w_k$, because the offsets have been listed in reverse order.

Each offset $w_k$ is represented by skewed coordinates $(u_k-v_k,v_k)$,
where $(u_k,v_k)$ is the representation of $w_k$ after it has been rotated
into a first-octant disguise.

@ The top-level data structure of a pen polygon is a 10-word node containing
a reference count followed by pointers to the eight offset lists, followed
by an indication of the pen's range of values.
@^reference counts@>

If |p|~points to such a node, and if the
offset list for, say, the fourth octant has entries $w_0$, $w_1$, \dots,
$w_n$,~$w_{n+1}$, then |info(p+fourth_octant)| will equal~$n$, and
|link(p+fourth_octant)| will point to the offset node containing~$w_0$.
Memory location |p+fourth_octant| is said to be the {\sl header\/} of
the pen-offset list for the fourth octant. Since this is an even-numbered
octant, $w_0$ is the offset that goes with the fifth octant, and
$w_{n+1}$ goes with the third.

The elements of the offset list themselves are doubly linked 3-word nodes,
containing coordinates in their |x_coord| and |y_coord| fields.
The two link fields are called |link| and |knil|; if |w|~points to
the node for~$w_k$, then |link(w)| and |knil(w)| point respectively
to the nodes for $w\k$ and~$w_{k-1}$. If |h| is the list header,
|link(h)| points to the node for~$w_0$ and |knil(link(h))| to the
node for~$w_{n+1}$.

The tenth word of a pen header node contains the maximum absolute value of
an $x$ or $y$ coordinate among all of the unskewed pen offsets.

The |link| field of a pen header node should be |null| if and only if
the pen is a single point.

@d pen_node_size	10
@d coord_node_size	3
@d max_offset(X)	mem[X+9].sc

@ The |print_pen| subroutine illustrates these conventions by
reconstructing the vertices of a polygon from \MF's complicated
internal offset representation.

@<Declare subroutines for printing expressions@>=
void print_pen(pointer @!p, str_number @!s, bool @!nuline)
{@+bool @!nothing_printed; /*has there been any action yet?*/ 
uint8_t @!k; /*octant number*/ 
pointer @!h; /*offset list head*/ 
int @!m, @!n; /*offset indices*/ 
pointer @!w, @!ww; /*pointers that traverse the offset list*/ 
print_diagnostic(@[@<|"Pen polygon"|@>@], s, nuline);
nothing_printed=true;print_ln();
for (k=1; k<=8; k++) 
  {@+octant=octant_code[k];h=p+octant;n=info(h);w=link(h);
  if (!odd(k)) w=knil(w); /*in even octants, start at $w_{n+1}$*/ 
  for (m=1; m<=n+1; m++) 
    {@+if (odd(k)) ww=link(w);@+else ww=knil(w);
    if ((x_coord(ww)!=x_coord(w))||(y_coord(ww)!=y_coord(w))) 
      @<Print the unskewed and unrotated coordinates of node |ww|@>;
    w=ww;
    } 
  } 
if (nothing_printed) 
  {@+w=link(p+first_octant);print_two(x_coord(w)+y_coord(w), y_coord(w));
  } 
print_nl(" .. cycle");end_diagnostic(true);
} 

@ @<Print the unskewed and unrotated coordinates of node |ww|@>=
{@+if (nothing_printed) nothing_printed=false;
else print_nl(" .. ");
print_two_true(x_coord(ww), y_coord(ww));
} 

@ A null pen polygon, which has just one vertex $(0,0)$, is
predeclared for error recovery. It doesn't need a proper
reference count, because the |toss_pen| procedure below
will never delete it from memory.
@^reference counts@>

@<Initialize table entries...@>=
ref_count(null_pen)=null;link(null_pen)=null;@/
info(null_pen+1)=1;link(null_pen+1)=null_coords;
for (k=null_pen+2; k<=null_pen+8; k++) mem[k]=mem[null_pen+1];
max_offset(null_pen)=0;@/
link(null_coords)=null_coords;
knil(null_coords)=null_coords;@/
x_coord(null_coords)=0;
y_coord(null_coords)=0;

@ Here's a trivial subroutine that inserts a copy of an offset
on the |link| side of its clone in the doubly linked list.

@p void dup_offset(pointer @!w)
{@+pointer @!r; /*the new node*/ 
r=get_node(coord_node_size);
x_coord(r)=x_coord(w);
y_coord(r)=y_coord(w);
link(r)=link(w);knil(link(w))=r;
knil(r)=w;link(w)=r;
} 

@ The following algorithm is somewhat more interesting: It converts a
knot list for a cyclic path into a pen polygon, ignoring everything
but the |x_coord|, |y_coord|, and |link| fields. If the given path
vertices do not define a convex polygon, an error message is issued
and the null pen is returned.

@p pointer make_pen(pointer @!h)
{@+
small_number @!o, @!oo, @!k; /*octant numbers---old, new, and current*/ 
pointer @!p; /*top-level node for the new pen*/ 
pointer @!q, @!r, @!s, @!w, @!hh; /*for list manipulation*/ 
int @!n; /*offset counter*/ 
scaled @!dx, @!dy; /*polygon direction*/ 
scaled @!mc; /*the largest coordinate*/ 
@<Stamp all nodes with an octant code, compute the maximum offset, and set |hh| to
the node that begins the first octant; |goto not_found| if there's a problem@>;
if (mc >= fraction_one-half_unit) goto not_found;
p=get_node(pen_node_size);q=hh;max_offset(p)=mc;ref_count(p)=null;
if (link(q)!=q) link(p)=null+1;
for (k=1; k<=8; k++) @<Construct the offset list for the |k|th octant@>;
goto found;
not_found: p=null_pen;@<Complain about a bad pen path@>;
found: if (internal[tracing_pens] > 0) print_pen(p,@[@<|" (newly created)"|@>@], true);
return p;
} 

@ @<Complain about a bad pen path@>=
if (mc >= fraction_one-half_unit) 
  {@+print_err("Pen too large");
@.Pen too large@>
  help2("The cycle you specified has a coordinate of 4095.5 or more.")@/
  ("So I've replaced it by the trivial path `(0,0)..cycle'.");@/
  } 
else{@+print_err("Pen cycle must be convex");
@.Pen cycle must be convex@>
  help3("The cycle you specified either has consecutive equal points")@/
    ("or turns right or turns through more than 360 degrees.")@/
  ("So I've replaced it by the trivial path `(0,0)..cycle'.");@/
  } 
put_get_error()

@ There should be exactly one node whose octant number is less than its
predecessor in the cycle; that is node~|hh|.

The loop here will terminate in all cases, but the proof is somewhat tricky:
If there are at least two distinct $y$~coordinates in the cycle, we will have
|o > 4| and |o <= 4| at different points of the cycle. Otherwise there are
at least two distinct $x$~coordinates, and we will have |o > 2| somewhere,
|o <= 2| somewhere.

@<Stamp all nodes...@>=
q=h;r=link(q);mc=abs(x_coord(h));
if (q==r) 
  {@+hh=h;right_type(h)=0; /*this trick is explained below*/ 
  if (mc < abs(y_coord(h))) mc=abs(y_coord(h));
  } 
else{@+o=0;hh=null;
  loop@+{@+s=link(r);
    if (mc < abs(x_coord(r))) mc=abs(x_coord(r));
    if (mc < abs(y_coord(r))) mc=abs(y_coord(r));
    dx=x_coord(r)-x_coord(q);dy=y_coord(r)-y_coord(q);
    if (dx==0) if (dy==0) goto not_found; /*double point*/ 
    if (ab_vs_cd(dx, y_coord(s)-y_coord(r), dy, x_coord(s)-x_coord(r)) < 0) 
      goto not_found; /*right turn*/ 
    @<Determine the octant code for direction |(dx,dy)|@>;
    right_type(q)=octant;oo=octant_number[octant];
    if (o > oo) 
      {@+if (hh!=null) goto not_found; /*$>360^\circ$*/ 
      hh=q;
      } 
    o=oo;
    if ((q==h)&&(hh!=null)) goto done;
    q=r;r=s;
    } 
  done: ;} 


@ We want the octant for |(-dx,-dy)| to be
exactly opposite the octant for |(dx, dy)|.

@<Determine the octant code for direction |(dx,dy)|@>=
if (dx > 0) octant=first_octant;
else if (dx==0) 
  if (dy > 0) octant=first_octant;@+else octant=first_octant+negate_x;
else{@+negate(dx);octant=first_octant+negate_x;
  } 
if (dy < 0) 
  {@+negate(dy);octant=octant+negate_y;
  } 
else if (dy==0) 
  if (octant > first_octant) octant=first_octant+negate_x+negate_y;
if (dx < dy) octant=octant+switch_x_and_y

@ Now |q| points to the node that the present octant shares with the previous
octant, and |right_type(q)| is the octant code during which |q|~should advance.
We have set |right_type(q)==0| in the special case that |q| should never advance
(because the pen is degenerate).

The number of offsets |n| must be smaller than |max_quarterword|, because
the |fill_envelope| routine stores |n+1| in the |right_type| field
of a knot node.

@<Construct the offset list...@>=
{@+octant=octant_code[k];n=0;h=p+octant;
loop@+{@+r=get_node(coord_node_size);
  skew(x_coord(q), y_coord(q), octant);x_coord(r)=cur_x;y_coord(r)=cur_y;
  if (n==0) link(h)=r;
  else@<Link node |r| to the previous node@>;
  w=r;
  if (right_type(q)!=octant) goto done1;
  q=link(q);incr(n);
  } 
done1: @<Finish linking the offset nodes, and duplicate the borderline offset nodes
if necessary@>;
if (n >= max_quarterword) overflow("pen polygon size", max_quarterword);
@:METAFONT capacity exceeded pen polygon size}{\quad pen polygon size@>
info(h)=n;
} 

@ Now |w| points to the node that was inserted most recently, and
|k| is the current octant number.

@<Link node |r| to the previous node@>=
if (odd(k)) 
  {@+link(w)=r;knil(r)=w;
  } 
else{@+knil(w)=r;link(r)=w;
  } 

@ We have inserted |n+1| nodes; it remains to duplicate the nodes at the
ends, if slopes 0 and~$\infty$ aren't already represented. At the end of
this section the total number of offset nodes should be |n+2|
(since we call them $w_0$, $w_1$, \dots,~$w_{n+1}$).

@<Finish linking the offset nodes, and duplicate...@>=
r=link(h);
if (odd(k)) 
  {@+link(w)=r;knil(r)=w;
  } 
else{@+knil(w)=r;link(r)=w;link(h)=w;r=w;
  } 
if ((y_coord(r)!=y_coord(link(r)))||(n==0)) 
  {@+dup_offset(r);incr(n);
  } 
r=knil(r);
if (x_coord(r)!=x_coord(knil(r))) dup_offset(r);
else decr(n)

@ Conversely, |make_path| goes back from a pen to a cyclic path that
might have generated it. The structure of this subroutine is essentially
the same as |print_pen|.

@p@t\4@>@<Declare the function called |trivial_knot|@>@;
pointer make_path(pointer @!pen_head)
{@+pointer @!p; /*the most recently copied knot*/ 
uint8_t @!k; /*octant number*/ 
pointer @!h; /*offset list head*/ 
int @!m, @!n; /*offset indices*/ 
pointer @!w, @!ww; /*pointers that traverse the offset list*/ 
p=temp_head;
for (k=1; k<=8; k++) 
  {@+octant=octant_code[k];h=pen_head+octant;n=info(h);w=link(h);
  if (!odd(k)) w=knil(w); /*in even octants, start at $w_{n+1}$*/ 
  for (m=1; m<=n+1; m++) 
    {@+if (odd(k)) ww=link(w);@+else ww=knil(w);
    if ((x_coord(ww)!=x_coord(w))||(y_coord(ww)!=y_coord(w))) 
      @<Copy the unskewed and unrotated coordinates of node |ww|@>;
    w=ww;
    } 
  } 
if (p==temp_head) 
  {@+w=link(pen_head+first_octant);
  p=trivial_knot(x_coord(w)+y_coord(w), y_coord(w));link(temp_head)=p;
  } 
link(p)=link(temp_head);return link(temp_head);
} 

@ @<Copy the unskewed and unrotated coordinates of node |ww|@>=
{@+unskew(x_coord(ww), y_coord(ww), octant);
link(p)=trivial_knot(cur_x, cur_y);p=link(p);
} 

@ @<Declare the function called |trivial_knot|@>=
pointer trivial_knot(scaled @!x, scaled @!y)
{@+pointer @!p; /*a new knot for explicit coordinates |x| and |y|*/ 
p=get_node(knot_node_size);
left_type(p)=explicit;right_type(p)=explicit;@/
x_coord(p)=x;left_x(p)=x;right_x(p)=x;@/
y_coord(p)=y;left_y(p)=y;right_y(p)=y;@/
return p;
} 

@ That which can be created can be destroyed.

@d add_pen_ref(X)	incr(ref_count(X))
@d delete_pen_ref(X)	if (ref_count(X)==null) toss_pen(X);
  else decr(ref_count(X))

@<Declare the recycling subroutines@>=
void toss_pen(pointer @!p)
{@+uint8_t @!k; /*relative header locations*/ 
pointer @!w, @!ww; /*pointers to offset nodes*/ 
if (p!=null_pen) 
  {@+for (k=1; k<=8; k++) 
    {@+w=link(p+k);
    @/do@+{ww=link(w);free_node(w, coord_node_size);w=ww;
    }@+ while (!(w==link(p+k)));
    } 
  free_node(p, pen_node_size);
  } 
} 

@ The |find_offset| procedure sets |(cur_x, cur_y)| to the offset associated
with a given direction~|(x, y)| and a given pen~|p|. If |x==y==0|, the
result is |(0, 0)|. If two different offsets apply, one of them is
chosen arbitrarily.

@p void find_offset(scaled @!x, scaled @!y, pointer @!p)
{@+
uint8_t @!octant; /*octant code for |(x, y)|*/ 
int8_t @!s; /*sign of the octant*/ 
int @!n; /*number of offsets remaining*/ 
pointer @!h, @!w, @!ww; /*list traversal registers*/ 
@<Compute the octant code; skew and rotate the coordinates |(x,y)|@>;
if (odd(octant_number[octant])) s=-1;@+else s=+1;
h=p+octant;w=link(link(h));ww=link(w);n=info(h);
while (n > 1) 
  {@+if (ab_vs_cd(x, y_coord(ww)-y_coord(w),@|
    y, x_coord(ww)-x_coord(w))!=s) goto done;
  w=ww;ww=link(w);decr(n);
  } 
done: unskew(x_coord(w), y_coord(w), octant);
} 

@ @<Compute the octant code; skew and rotate the coordinates |(x,y)|@>=
if (x > 0) octant=first_octant;
else if (x==0) 
  if (y <= 0) 
    if (y==0) 
      {@+cur_x=0;cur_y=0;return;
      } 
    else octant=first_octant+negate_x;
  else octant=first_octant;
else{@+x=-x;
  if (y==0) octant=first_octant+negate_x+negate_y;
  else octant=first_octant+negate_x;
  } 
if (y < 0) 
  {@+octant=octant+negate_y;y=-y;
  } 
if (x >= y) x=x-y;
else{@+octant=octant+switch_x_and_y;x=y-x;y=y-x;
  } 

@* Filling an envelope.
We are about to reach the culmination of \MF's digital plotting routines:
Almost all of the previous algorithms will be brought to bear on \MF's
most difficult task, which is to fill the envelope of a given cyclic path
with respect to a given pen polygon.

But we still must complete some of the preparatory work before taking such
a big plunge.

@ Given a pointer |c| to a nonempty list of cubics,
and a pointer~|h| to the header information of a pen polygon segment,
the |offset_prep| routine changes the list into cubics that are
associated with particular pen offsets. Namely, the cubic between |p|
and~|q| should be associated with the |k|th offset when |right_type(p)==k|.

List |c| is actually part of a cycle spec, so it terminates at the
first node whose |right_type| is |endpoint|. The cubics all have
monotone-nondecreasing $x(t)$ and $y(t)$.

@p@t\4@>@<Declare subroutines needed by |offset_prep|@>@;
void offset_prep(pointer @!c, pointer @!h)
{@+
halfword @!n; /*the number of pen offsets*/ 
pointer @!p, @!q, @!r, @!lh, @!ww; /*for list manipulation*/ 
halfword @!k; /*the current offset index*/ 
pointer @!w; /*a pointer to offset $w_k$*/ 
@<Other local variables for |offset_prep|@>@;
p=c;n=info(h);lh=link(h); /*now |lh| points to $w_0$*/ 
while (right_type(p)!=endpoint) 
  {@+q=link(p);
  @<Split the cubic between |p| and |q|, if necessary, into cubics associated with
single offsets, after which |q| should point to the end of the final such cubic@>;
  @<Advance |p| to node |q|, removing any ``dead'' cubics that might have been introduced
by the splitting process@>;
  } 
} 

@ @<Advance |p| to node |q|, removing any ``dead'' cubics...@>=
@/do@+{r=link(p);
if (x_coord(p)==right_x(p)) if (y_coord(p)==right_y(p)) 
 if (x_coord(p)==left_x(r)) if (y_coord(p)==left_y(r)) 
  if (x_coord(p)==x_coord(r)) if (y_coord(p)==y_coord(r)) 
  {@+remove_cubic(p);
  if (r==q) q=p;
  r=p;
  } 
p=r;
}@+ while (!(p==q))

@ The splitting process uses a subroutine like |split_cubic|, but
(for ``bulletproof'' operation) we check to make sure that the
resulting (skewed) coordinates satisfy $\Delta x\G0$ and $\Delta y\G0$
after splitting; |make_spec| has made sure that these relations hold
before splitting. (This precaution is surely unnecessary, now that
|make_spec| is so much more careful than it used to be. But who
wants to take a chance? Maybe the hardware will fail or something.)

@<Declare subroutines needed by |offset_prep|@>=
void split_for_offset(pointer @!p, fraction @!t)
{@+pointer @!q; /*the successor of |p|*/ 
pointer @!r; /*the new node*/ 
q=link(p);split_cubic(p, t, x_coord(q), y_coord(q));r=link(p);
if (y_coord(r) < y_coord(p)) y_coord(r)=y_coord(p);
else if (y_coord(r) > y_coord(q)) y_coord(r)=y_coord(q);
if (x_coord(r) < x_coord(p)) x_coord(r)=x_coord(p);
else if (x_coord(r) > x_coord(q)) x_coord(r)=x_coord(q);
} 

@ If the pen polygon has |n| offsets, and if $w_k=(u_k,v_k)$ is the $k$th
of these, the $k$th pen slope is defined by the formula
$$s_k={v\k-v_k\over u\k-u_k},\qquad\hbox{for $0<k<n$}.$$
In odd-numbered octants, the numerator and denominator of this fraction
will be nonnegative; in even-numbered octants they will both be nonpositive.
Furthermore we always have $0=s_0\le s_1\le\cdots\le s_n=\infty$. The goal of
|offset_prep| is to find an offset index~|k| to associate with
each cubic, such that the slope $s(t)$ of the cubic satisfies
$$s_{k-1}\le s(t)\le s_k\qquad\hbox{for $0\le t\le 1$.}\eqno(*)$$
We may have to split a cubic into as many as $2n-1$ pieces before each
piece corresponds to a unique offset.

@<Split the cubic between |p| and |q|, if necessary, into cubics...@>=
if (n <= 1) right_type(p)=1; /*this case is easy*/ 
else{@+@<Prepare for derivative computations; |goto not_found| if the current cubic
is dead@>;
  @<Find the initial slope, |dy/dx|@>;
  if (dx==0) @<Handle the special case of infinite slope@>;
  else{@+@<Find the index |k| such that $s_{k-1}\L\\{dy}/\\{dx}<s_k$@>;
    @<Complete the offset splitting process@>;
    } 
not_found: ;} 

@ The slope of a cubic $B(z_0,z_1,z_2,z_3;t)=\bigl(x(t),y(t)\bigr)$ can be
calculated from the quadratic polynomials
${1\over3}x'(t)=B(x_1-x_0,x_2-x_1,x_3-x_2;t)$ and
${1\over3}y'(t)=B(y_1-y_0,y_2-y_1,y_3-y_2;t)$.
Since we may be calculating slopes from several cubics
split from the current one, it is desirable to do these calculations
without losing too much precision. ``Scaled up'' values of the
derivatives, which will be less tainted by accumulated errors than
derivatives found from the cubics themselves, are maintained in
local variables |x0|, |x1|, and |x2|, representing $X_0=2^l(x_1-x_0)$,
$X_1=2^l(x_2-x_1)$, and $X_2=2^l(x_3-x_2)$; similarly |y0|, |y1|, and~|y2|
represent $Y_0=2^l(y_1-y_0)$, $Y_1=2^l(y_2-y_1)$, and $Y_2=2^l(y_3-y_2)$.
To test whether the slope of the cubic is $\ge s$ or $\le s$, we will test
the sign of the quadratic ${1\over3}2^l\bigl(y'(t)-sx'(t)\bigr)$ if $s\le1$,
or ${1\over3}2^l\bigl(y'(t)/s-x'(t)\bigr)$ if $s>1$.

@<Other local variables for |offset_prep|@>=
int @!x0, @!x1, @!x2, @!y0, @!y1, @!y2; /*representatives of derivatives*/ 
int @!t0, @!t1, @!t2; /*coefficients of polynomial for slope testing*/ 
int @!du, @!dv, @!dx, @!dy; /*for slopes of the pen and the curve*/ 
int @!max_coef; /*used while scaling*/ 
int @!x0a, @!x1a, @!x2a, @!y0a, @!y1a, @!y2a; /*intermediate values*/ 
fraction @!t; /*where the derivative passes through zero*/ 
fraction @!s; /*slope or reciprocal slope*/ 

@ @<Prepare for derivative computations...@>=
x0=right_x(p)-x_coord(p); /*should be | >= 0|*/ 
x2=x_coord(q)-left_x(q); /*likewise*/ 
x1=left_x(q)-right_x(p); /*but this might be negative*/ 
y0=right_y(p)-y_coord(p);y2=y_coord(q)-left_y(q);
y1=left_y(q)-right_y(p);
max_coef=abs(x0); /*we take |abs| just to make sure*/ 
if (abs(x1) > max_coef) max_coef=abs(x1);
if (abs(x2) > max_coef) max_coef=abs(x2);
if (abs(y0) > max_coef) max_coef=abs(y0);
if (abs(y1) > max_coef) max_coef=abs(y1);
if (abs(y2) > max_coef) max_coef=abs(y2);
if (max_coef==0) goto not_found;
while (max_coef < fraction_half) 
  {@+double(max_coef);
  double(x0);double(x1);double(x2);
  double(y0);double(y1);double(y2);
  } 

@ Let us first solve a special case of the problem: Suppose we
know an index~$k$ such that either (i)~$s(t)\G s_{k-1}$ for all~$t$
and $s(0)<s_k$, or (ii)~$s(t)\L s_k$ for all~$t$ and $s(0)>s_{k-1}$.
Then, in a sense, we're halfway done, since one of the two inequalities
in $(*)$ is satisfied, and the other couldn't be satisfied for
any other value of~|k|.

The |fin_offset_prep| subroutine solves the stated subproblem.
It has a boolean parameter called |rising| that is |true| in
case~(i), |false| in case~(ii). When |rising==false|, parameters
|x0| through |y2| represent the negative of the derivative of
the cubic following |p|; otherwise they represent the actual derivative.
The |w| parameter should point to offset~$w_k$.

@<Declare subroutines needed by |offset_prep|@>=
void fin_offset_prep(pointer @!p, halfword @!k, pointer @!w,
  int @!x0, int @!x1, int @!x2, int @!y0, int @!y1, int @!y2, bool @!rising, int @!n)
{@+
pointer @!ww; /*for list manipulation*/ 
scaled @!du, @!dv; /*for slope calculation*/ 
int @!t0, @!t1, @!t2; /*test coefficients*/ 
fraction @!t; /*place where the derivative passes a critical slope*/ 
fraction @!s; /*slope or reciprocal slope*/ 
int @!v; /*intermediate value for updating |x0 dotdot y2|*/ 
loop
  {@+right_type(p)=k;
  if (rising) 
    if (k==n) return;
    else ww=link(w); /*a pointer to $w\k$*/ 
  else if (k==1) return;
    else ww=knil(w); /*a pointer to $w_{k-1}$*/ 
  @<Compute test coefficients |(t0,t1,t2)| for $s(t)$ versus $s_k$ or $s_{k-1}$@>;
  t=crossing_point(t0, t1, t2);
  if (t >= fraction_one) return;
  @<Split the cubic at $t$, and split off another cubic if the derivative crosses
back@>;
  if (rising) incr(k);@+else decr(k);
  w=ww;
  } 
} 

@ @<Compute test coefficients |(t0,t1,t2)| for $s(t)$ versus...@>=
du=x_coord(ww)-x_coord(w);dv=y_coord(ww)-y_coord(w);
if (abs(du) >= abs(dv))  /*$s_{k-1}\le1$ or $s_k\le1$*/ 
  {@+s=make_fraction(dv, du);
  t0=take_fraction(x0, s)-y0;
  t1=take_fraction(x1, s)-y1;
  t2=take_fraction(x2, s)-y2;
  } 
else{@+s=make_fraction(du, dv);
  t0=x0-take_fraction(y0, s);
  t1=x1-take_fraction(y1, s);
  t2=x2-take_fraction(y2, s);
  } 

@ The curve has crossed $s_k$ or $s_{k-1}$; its initial segment satisfies
$(*)$, and it might cross again and return towards $s_{k-1}$ or $s_k$,
respectively, yielding another solution of $(*)$.

@<Split the cubic at $t$, and split off another...@>=
{@+split_for_offset(p, t);right_type(p)=k;p=link(p);@/
v=t_of_the_way(x0)(x1);x1=t_of_the_way(x1)(x2);
x0=t_of_the_way(v)(x1);@/
v=t_of_the_way(y0)(y1);y1=t_of_the_way(y1)(y2);
y0=t_of_the_way(v)(y1);@/
t1=t_of_the_way(t1)(t2);
if (t1 > 0) t1=0; /*without rounding error, |t1| would be | <= 0|*/ 
t=crossing_point(0,-t1,-t2);
if (t < fraction_one) 
  {@+split_for_offset(p, t);right_type(link(p))=k;@/
  v=t_of_the_way(x1)(x2);x1=t_of_the_way(x0)(x1);
  x2=t_of_the_way(x1)(v);@/
  v=t_of_the_way(y1)(y2);y1=t_of_the_way(y0)(y1);
  y2=t_of_the_way(y1)(v);
  } 
} 

@ Now we must consider the general problem of |offset_prep|, when
nothing is known about a given cubic. We start by finding its
slope $s(0)$ in the vicinity of |t==0|.

If $z'(t)=0$, the given cubic is numerically unstable, since the
slope direction is probably being influenced primarily by rounding
errors. A user who specifies such cuspy curves should expect to generate
rather wild results. The present code tries its best to believe the
existing data, as if no rounding errors were present.

@ @<Find the initial slope, |dy/dx|@>=
dx=x0;dy=y0;
if (dx==0) if (dy==0) 
  {@+dx=x1;dy=y1;
  if (dx==0) if (dy==0) 
    {@+dx=x2;dy=y2;
    } 
  } 

@ The next step is to bracket the initial slope between consecutive
slopes of the pen polygon. The most important invariant relation in the
following loop is that |dy/(double)dx >= @t$s_{k-1}$@>|.

@<Find the index |k| such that $s_{k-1}\L\\{dy}/\\{dx}<s_k$@>=
k=1;w=link(lh);
loop@+{@+if (k==n) goto done;
  ww=link(w);
  if (ab_vs_cd(dy, abs(x_coord(ww)-x_coord(w)),@|
   dx, abs(y_coord(ww)-y_coord(w))) >= 0) 
    {@+incr(k);w=ww;
    } 
  else goto done;
  } 
done: 

@ Finally we want to reduce the general problem to situations that
|fin_offset_prep| can handle. If |k==1|, we already are in the desired
situation. Otherwise we can split the cubic into at most three parts
with respect to $s_{k-1}$, and apply |fin_offset_prep| to each part.

@<Complete the offset splitting process@>=
if (k==1) t=fraction_one+1;
else{@+ww=knil(w);@<Compute test coeff...@>;
  t=crossing_point(-t0,-t1,-t2);
  } 
if (t >= fraction_one) fin_offset_prep(p, k, w, x0, x1, x2, y0, y1, y2, true, n);
else{@+split_for_offset(p, t);r=link(p);@/
  x1a=t_of_the_way(x0)(x1);x1=t_of_the_way(x1)(x2);
  x2a=t_of_the_way(x1a)(x1);@/
  y1a=t_of_the_way(y0)(y1);y1=t_of_the_way(y1)(y2);
  y2a=t_of_the_way(y1a)(y1);@/
  fin_offset_prep(p, k, w, x0, x1a, x2a, y0, y1a, y2a, true, n);x0=x2a;y0=y2a;
  t1=t_of_the_way(t1)(t2);
  if (t1 < 0) t1=0;
  t=crossing_point(0, t1, t2);
  if (t < fraction_one) 
    @<Split off another |rising| cubic for |fin_offset_prep|@>;
  fin_offset_prep(r, k-1, ww,-x0,-x1,-x2,-y0,-y1,-y2, false, n);
  } 

@ @<Split off another |rising| cubic for |fin_offset_prep|@>=
{@+split_for_offset(r, t);@/
x1a=t_of_the_way(x1)(x2);x1=t_of_the_way(x0)(x1);
x0a=t_of_the_way(x1)(x1a);@/
y1a=t_of_the_way(y1)(y2);y1=t_of_the_way(y0)(y1);
y0a=t_of_the_way(y1)(y1a);@/
fin_offset_prep(link(r), k, w, x0a, x1a, x2, y0a, y1a, y2, true, n);
x2=x0a;y2=y0a;
} 

@ @<Handle the special case of infinite slope@>=
fin_offset_prep(p, n, knil(knil(lh)),-x0,-x1,-x2,-y0,-y1,-y2, false, n)

@ OK, it's time now for the biggie. The |fill_envelope| routine generalizes
|fill_spec| to polygonal envelopes. Its outer structure is essentially the
same as before, except that octants with no cubics do contribute to
the envelope.

@p@t\4@>@<Declare the procedure called |skew_line_edges|@>@;
@t\4@>@<Declare the procedure called |dual_moves|@>@;
void fill_envelope(pointer @!spec_head)
{@+
pointer @!p, @!q, @!r, @!s; /*for list traversal*/ 
pointer @!h; /*head of pen offset list for current octant*/ 
pointer @!www; /*a pen offset of temporary interest*/ 
@<Other local variables for |fill_envelope|@>@;
if (internal[tracing_edges] > 0) begin_edge_tracing();
p=spec_head; /*we assume that |left_type(spec_head)==endpoint|*/ 
@/do@+{octant=left_octant(p);h=cur_pen+octant;
@<Set variable |q| to the node at the end of the current octant@>;
@<Determine the envelope's starting and ending lattice points |(m0,n0)| and |(m1,n1)|@>;
offset_prep(p, h); /*this may clobber node~|q|, if it becomes ``dead''*/ 
@<Set variable |q| to the node at the end of the current octant@>;
@<Make the envelope moves for the current octant and insert them in the pixel data@>;
p=link(q);
}@+ while (!(p==spec_head));
if (internal[tracing_edges] > 0) end_edge_tracing();
toss_knot_list(spec_head);
} 

@ In even-numbered octants we have reflected the coordinates an odd number
of times, hence clockwise and counterclockwise are reversed; this means that
the envelope is being formed in a ``dual'' manner. For the time being, let's
concentrate on odd-numbered octants, since they're easier to understand.
After we have coded the program for odd-numbered octants, the changes needed
to dualize it will not be so mysterious.

It is convenient to assume that we enter an odd-numbered octant with
an |axis| transition (where the skewed slope is zero) and leave at a
|diagonal| one (where the skewed slope is infinite). Then all of the
offset points $z(t)+w(t)$ will lie in a rectangle whose lower left and
upper right corners are the initial and final offset points. If this
assumption doesn't hold we can implicitly change the curve so that it does.
For example, if the entering transition is diagonal, we can draw a
straight line from $z_0+w_{n+1}$ to $z_0+w_0$ and continue as if the
curve were moving rightward. The effect of this on the envelope is simply
to ``doubly color'' the region enveloped by a section of the pen that
goes from $w_0$ to $w_1$ to $\cdots$ to $w_{n+1}$ to~$w_0$. The additional
straight line at the beginning (and a similar one at the end, where it
may be necessary to go from $z_1+w_{n+1}$ to $z_1+w_0$) can be drawn by
the |line_edges| routine; we are thereby saved from the embarrassment that
these lines travel backwards from the current octant direction.

Once we have established the assumption that the curve goes from
$z_0+w_0$ to $z_1+w_{n+1}$, any further retrograde moves that might
occur within the octant can be essentially ignored; we merely need to
keep track of the rightmost edge in each row, in order to compute
the envelope.

Envelope moves consist of offset cubics intermixed with straight line
segments. We record them in a separate |env_move| array, which is
something like |move| but it keeps track of the rightmost position of the
envelope in each row.

@<Glob...@>=
int @!env_move[move_size+1];

@ @<Determine the envelope's starting and ending...@>=
w=link(h);@+if (left_transition(p)==diagonal) w=knil(w);
#ifdef @!STAT
if (internal[tracing_edges] > unity) 
  @<Print a line of diagnostic info to introduce this octant@>;
#endif
@;@/
ww=link(h);www=ww; /*starting and ending offsets*/ 
if (odd(octant_number[octant])) www=knil(www);@+else ww=knil(ww);
if (w!=ww) skew_line_edges(p, w, ww);
end_round(x_coord(p)+x_coord(ww), y_coord(p)+y_coord(ww));
m0=m1;n0=n1;d0=d1;@/
end_round(x_coord(q)+x_coord(www), y_coord(q)+y_coord(www));
if (n1-n0 >= move_size) overflow("move table size", move_size)
@:METAFONT capacity exceeded move table size}{\quad move table size@>

@ @<Print a line of diagnostic info to introduce this octant@>=
{@+print_nl("@@ Octant ");print(octant_dir[octant]);
@:]]]\AT!_Octant}{\.{\AT! Octant...}@>
print_str(" (");print_int(info(h));print_str(" offset");
if (info(h)!=1) print_char('s');
print_str("), from ");
print_two_true(x_coord(p)+x_coord(w), y_coord(p)+y_coord(w));@/
ww=link(h);@+if (right_transition(q)==diagonal) ww=knil(ww);
print_str(" to ");
print_two_true(x_coord(q)+x_coord(ww), y_coord(q)+y_coord(ww));
} 

@ A slight variation of the |line_edges| procedure comes in handy
when we must draw the retrograde lines for nonstandard entry and exit
conditions.

@<Declare the procedure called |skew_line_edges|@>=
void skew_line_edges(pointer @!p, pointer @!w, pointer @!ww)
{@+scaled @!x0, @!y0, @!x1, @!y1; /*from and to*/ 
if ((x_coord(w)!=x_coord(ww))||(y_coord(w)!=y_coord(ww))) 
  {@+x0=x_coord(p)+x_coord(w);y0=y_coord(p)+y_coord(w);@/
  x1=x_coord(p)+x_coord(ww);y1=y_coord(p)+y_coord(ww);@/
  unskew(x0, y0, octant); /*unskew and unrotate the coordinates*/ 
  x0=cur_x;y0=cur_y;@/
  unskew(x1, y1, octant);@/
  
#ifdef @!STAT
if (internal[tracing_edges] > unity) 
    {@+print_nl("@@ retrograde line from ");
@:]]]\AT!_retro_}{\.{\AT! retrograde line...}@>
  @.retrograde line...@>
    print_two(x0, y0);print_str(" to ");print_two(cur_x, cur_y);print_nl("");
    } 
#endif
@;@/
  line_edges(x0, y0, cur_x, cur_y); /*then draw a straight line*/ 
  } 
} 

@ The envelope calculations require more local variables than we needed
in the simpler case of |fill_spec|. At critical points in the computation,
|w| will point to offset $w_k$; |m| and |n| will record the current
lattice positions.  The values of |move_ptr| after the initial and before
the final offset adjustments are stored in |smooth_bot| and |smooth_top|,
respectively.

@<Other local variables for |fill_envelope|@>=
int @!m, @!n; /*current lattice position*/ 
int @!mm0, @!mm1; /*skewed equivalents of |m0| and |m1|*/ 
int @!k; /*current offset number*/ 
pointer @!w, @!ww; /*pointers to the current offset and its neighbor*/ 
uint16_t @!smooth_bot, @!smooth_top; /*boundaries of smoothing*/ 
scaled @!xx, @!yy, @!xp, @!yp, @!delx, @!dely, @!tx, @!ty;
   /*registers for coordinate calculations*/ 

@ @<Make the envelope moves for the current octant...@>=
if (odd(octant_number[octant])) 
  {@+@<Initialize for ordinary envelope moves@>;
  r=p;right_type(q)=info(h)+1;
  loop@+{@+if (r==q) smooth_top=move_ptr;
    while (right_type(r)!=k) 
      @<Insert a line segment to approach the correct offset@>;
    if (r==p) smooth_bot=move_ptr;
    if (r==q) goto done;
    move[move_ptr]=1;n=move_ptr;s=link(r);@/
    make_moves(x_coord(r)+x_coord(w), right_x(r)+x_coord(w),
      left_x(s)+x_coord(w), x_coord(s)+x_coord(w),@|
      y_coord(r)+y_coord(w)+half_unit, right_y(r)+y_coord(w)+half_unit,
      left_y(s)+y_coord(w)+half_unit, y_coord(s)+y_coord(w)+half_unit,@|
      xy_corr[octant], y_corr[octant]);@/
    @<Transfer moves from the |move| array to |env_move|@>;
    r=s;
    } 
done: @<Insert the new envelope moves in the pixel data@>;
  } 
else dual_moves(h, p, q);
right_type(q)=endpoint

@ @<Initialize for ordinary envelope moves@>=
k=0;w=link(h);ww=knil(w);
mm0=floor_unscaled(x_coord(p)+x_coord(w)-xy_corr[octant]);
mm1=floor_unscaled(x_coord(q)+x_coord(ww)-xy_corr[octant]);
for (n=0; n<=n1-n0; n++) env_move[n]=mm0;
env_move[n1-n0]=mm1;move_ptr=0;m=mm0

@ At this point |n| holds the value of |move_ptr| that was current
when |make_moves| began to record its moves.

@<Transfer moves from the |move| array to |env_move|@>=
@/do@+{m=m+move[n]-1;
if (m > env_move[n]) env_move[n]=m;
incr(n);
}@+ while (!(n > move_ptr))

@ Retrograde lines (when |k| decreases) do not need to be recorded in
|env_move| because their edges are not the furthest right in any row.

@<Insert a line segment to approach the correct offset@>=
{@+xx=x_coord(r)+x_coord(w);yy=y_coord(r)+y_coord(w)+half_unit;
#ifdef @!STAT
if (internal[tracing_edges] > unity) 
  {@+print_nl("@@ transition line ");print_int(k);print_str(", from ");
@:]]]\AT!_trans_}{\.{\AT! transition line...}@>
@.transition line...@>
  print_two_true(xx, yy-half_unit);
  } 
#endif
@;@/
if (right_type(r) > k) 
  {@+incr(k);w=link(w);
  xp=x_coord(r)+x_coord(w);yp=y_coord(r)+y_coord(w)+half_unit;
  if (yp!=yy) 
    @<Record a line segment from |(xx,yy)| to |(xp,yp)| in |env_move|@>;
  } 
else{@+decr(k);w=knil(w);
  xp=x_coord(r)+x_coord(w);yp=y_coord(r)+y_coord(w)+half_unit;
  } 
#ifdef @!STAT
if (internal[tracing_edges] > unity) 
  {@+print_str(" to ");
  print_two_true(xp, yp-half_unit);
  print_nl("");
  } 
#endif
@;@/
m=floor_unscaled(xp-xy_corr[octant]);
move_ptr=floor_unscaled(yp-y_corr[octant])-n0;
if (m > env_move[move_ptr]) env_move[move_ptr]=m;
} 

@ In this step we have |xp >= xx| and |yp >= yy|.

@<Record a line segment from |(xx,yy)| to |(xp,yp)| in |env_move|@>=
{@+ty=floor_scaled(yy-y_corr[octant]);dely=yp-yy;yy=yy-ty;
ty=yp-y_corr[octant]-ty;
if (ty >= unity) 
  {@+delx=xp-xx;yy=unity-yy;
  loop@+{@+tx=take_fraction(delx, make_fraction(yy, dely));
    if (ab_vs_cd(tx, dely, delx, yy)+xy_corr[octant] > 0) decr(tx);
    m=floor_unscaled(xx+tx);
    if (m > env_move[move_ptr]) env_move[move_ptr]=m;
    ty=ty-unity;
    if (ty < unity) goto done1;
    yy=yy+unity;incr(move_ptr);
    } 
  done1: ;} 
} 

@ @<Insert the new envelope moves in the pixel data@>=
#ifdef @!DEBUG
if ((m!=mm1)||(move_ptr!=n1-n0)) confusion('1');
#endif
@;@/
@:this can't happen /}{\quad 1@>
move[0]=d0+env_move[0]-mm0;
for (n=1; n<=move_ptr; n++) 
  move[n]=env_move[n]-env_move[n-1]+1;
move[move_ptr]=move[move_ptr]-d1;
if (internal[smoothing] > 0) smooth_moves(smooth_bot, smooth_top);
move_to_edges(m0, n0, m1, n1);
if (right_transition(q)==axis) 
  {@+w=link(h);skew_line_edges(q, knil(w), w);
  } 

@ We've done it all in the odd-octant case; the only thing remaining
is to repeat the same ideas, upside down and/or backwards.

The following code has been split off as a subprocedure of |fill_envelope|,
because some \PASCAL\ compilers cannot handle procedures as large as
|fill_envelope| would otherwise be.

@<Declare the procedure called |dual_moves|@>=
void dual_moves(pointer @!h, pointer @!p, pointer @!q)
{@+
pointer @!r, @!s; /*for list traversal*/ 
@<Other local variables for |fill_envelope|@>@;
@<Initialize for dual envelope moves@>;
r=p; /*recall that |right_type(q)==endpoint==0| now*/ 
loop@+{@+if (r==q) smooth_top=move_ptr;
  while (right_type(r)!=k) 
    @<Insert a line segment dually to approach the correct offset@>;
  if (r==p) smooth_bot=move_ptr;
  if (r==q) goto done;
  move[move_ptr]=1;n=move_ptr;s=link(r);@/
  make_moves(x_coord(r)+x_coord(w), right_x(r)+x_coord(w),
    left_x(s)+x_coord(w), x_coord(s)+x_coord(w),@|
    y_coord(r)+y_coord(w)+half_unit, right_y(r)+y_coord(w)+half_unit,
    left_y(s)+y_coord(w)+half_unit, y_coord(s)+y_coord(w)+half_unit,@|
    xy_corr[octant], y_corr[octant]);
  @<Transfer moves dually from the |move| array to |env_move|@>;
  r=s;
  } 
done: @<Insert the new envelope moves dually in the pixel data@>;
} 

@ In the dual case the normal situation is to arrive with a |diagonal|
transition and to leave at the |axis|. The leftmost edge in each row
is relevant instead of the rightmost one.

@<Initialize for dual envelope moves@>=
k=info(h)+1;ww=link(h);w=knil(ww);@/
mm0=floor_unscaled(x_coord(p)+x_coord(w)-xy_corr[octant]);
mm1=floor_unscaled(x_coord(q)+x_coord(ww)-xy_corr[octant]);
for (n=1; n<=n1-n0+1; n++) env_move[n]=mm1;
env_move[0]=mm0;move_ptr=0;m=mm0

@ @<Transfer moves dually from the |move| array to |env_move|@>=
@/do@+{if (m < env_move[n]) env_move[n]=m;
m=m+move[n]-1;
incr(n);
}@+ while (!(n > move_ptr))

@ Dual retrograde lines occur when |k| increases; the edges of such lines
are not the furthest left in any row.

@<Insert a line segment dually to approach the correct offset@>=
{@+xx=x_coord(r)+x_coord(w);yy=y_coord(r)+y_coord(w)+half_unit;
#ifdef @!STAT
if (internal[tracing_edges] > unity) 
  {@+print_nl("@@ transition line ");print_int(k);print_str(", from ");
@:]]]\AT!_trans_}{\.{\AT! transition line...}@>
@.transition line...@>
  print_two_true(xx, yy-half_unit);
  } 
#endif
@;@/
if (right_type(r) < k) 
  {@+decr(k);w=knil(w);
  xp=x_coord(r)+x_coord(w);yp=y_coord(r)+y_coord(w)+half_unit;
  if (yp!=yy) 
    @<Record a line segment from |(xx,yy)| to |(xp,yp)| dually in |env_move|@>;
  } 
else{@+incr(k);w=link(w);
  xp=x_coord(r)+x_coord(w);yp=y_coord(r)+y_coord(w)+half_unit;
  } 
#ifdef @!STAT
if (internal[tracing_edges] > unity) 
  {@+print_str(" to ");
  print_two_true(xp, yp-half_unit);
  print_nl("");
  } 
#endif
@;@/
m=floor_unscaled(xp-xy_corr[octant]);
move_ptr=floor_unscaled(yp-y_corr[octant])-n0;
if (m < env_move[move_ptr]) env_move[move_ptr]=m;
} 

@ Again, |xp >= xx| and |yp >= yy|; but this time we are interested in the {\sl
smallest\/} |m| that belongs to a given |move_ptr| position, instead of
the largest~|m|.

@<Record a line segment from |(xx,yy)| to |(xp,yp)| dually in |env_move|@>=
{@+ty=floor_scaled(yy-y_corr[octant]);dely=yp-yy;yy=yy-ty;
ty=yp-y_corr[octant]-ty;
if (ty >= unity) 
  {@+delx=xp-xx;yy=unity-yy;
  loop@+{@+if (m < env_move[move_ptr]) env_move[move_ptr]=m;
    tx=take_fraction(delx, make_fraction(yy, dely));
    if (ab_vs_cd(tx, dely, delx, yy)+xy_corr[octant] > 0) decr(tx);
    m=floor_unscaled(xx+tx);
    ty=ty-unity;incr(move_ptr);
    if (ty < unity) goto done1;
    yy=yy+unity;
    } 
done1: if (m < env_move[move_ptr]) env_move[move_ptr]=m;
  } 
} 

@ Since |env_move| contains minimum values instead of maximum values, the
finishing-up process is slightly different in the dual case.

@<Insert the new envelope moves dually in the pixel data@>=
#ifdef @!DEBUG
if ((m!=mm1)||(move_ptr!=n1-n0)) confusion('2');
#endif
@;@/
@:this can't happen /}{\quad 2@>
move[0]=d0+env_move[1]-mm0;
for (n=1; n<=move_ptr; n++) 
  move[n]=env_move[n+1]-env_move[n]+1;
move[move_ptr]=move[move_ptr]-d1;
if (internal[smoothing] > 0) smooth_moves(smooth_bot, smooth_top);
move_to_edges(m0, n0, m1, n1);
if (right_transition(q)==diagonal) 
  {@+w=link(h);skew_line_edges(q, w, knil(w));
  } 

@* Elliptical pens.
To get the envelope of a cyclic path with respect to an ellipse, \MF\
calculates the envelope with respect to a polygonal approximation to
the ellipse, using an approach due to John Hobby (Ph.D. thesis,
Stanford University, 1985).
@^Hobby, John Douglas@>
This has two important advantages over trying to obtain the ``exact''
envelope:

\yskip\textindent{1)}It gives better results, because the polygon has been
designed to counteract problems that arise from digitization; the
polygon includes sub-pixel corrections to an exact ellipse that make
the results essentially independent of where the path falls on the raster.
For example, the exact envelope with respect to a pen of diameter~1
blackens a pixel if and only if the path intersects a circle of diameter~1
inscribed in that pixel; the resulting pattern has ``blots'' when the path
is travelling diagonally in unfortunate raster positions. A much better
result is obtained when pixels are blackened only when the path intersects
an inscribed {\sl diamond\/} of diameter~1. Such a diamond is precisely
the polygon that \MF\ uses in the special case of a circle whose diameter is~1.

\yskip\textindent{2)}Polygonal envelopes of cubic splines are cubic
splines, hence it isn't necessary to introduce completely different
routines. By contrast, exact envelopes of cubic splines with respect
to circles are complicated curves, more difficult to plot than cubics.

@ Hobby's construction involves some interesting number theory.
If $u$ and~$v$ are relatively prime integers, we divide the
set of integer points $(m,n)$ into equivalence classes by saying
that $(m,n)$ belongs to class $um+vn$. Then any two integer points
that lie on a line of slope $-u/v$ belong to the same class, because
such points have the form $(m+tv,n-tu)$. Neighboring lines of slope $-u/v$
that go through integer points are separated by distance $1/\psqrt{u^2+v^2}$
from each other, and these lines are perpendicular to lines of slope~$v/u$.
If we start at the origin and travel a distance $k/\psqrt{u^2+v^2}$ in
direction $(u,v)$, we reach the line of slope~$-u/v$ whose points
belong to class~$k$.

For example, let $u=2$ and $v=3$. Then the points $(0,0)$, $(3,-2)$,
$\ldots$ belong to class~0; the points $(-1,1)$, $(2,-1)$, $\ldots$ belong
to class~1; and the distance between these two lines is $1/\sqrt{13}$.
The point $(2,3)$ itself belongs to class~13, hence its distance from
the origin is $13/\sqrt{13}=\sqrt{13}$ (which we already knew).

Suppose we wish to plot envelopes with respect to polygons with
integer vertices. Then the best polygon for curves that travel in
direction $(v,-u)$ will contain the points of class~$k$ such that
$k/\psqrt{u^2+v^2}$ is as close as possible to~$d$, where $d$ is the
maximum distance of the given ellipse from the line $ux+vy=0$.

The |fillin| correction assumes that a diagonal line has an
apparent thickness $$2f\cdot\min(\vert u\vert,\vert v\vert)/\psqrt{u^2+v^2}$$
greater than would be obtained with truly square pixels. (If a
white pixel at an exterior corner is assumed to have apparent
darkness $f_1$ and a black pixel at an interior corner is assumed
to have apparent darkness $1-f_2$, then $f=f_1-f_2$ is the |fillin|
parameter.) Under this assumption we want to choose $k$ so that
$\bigl(k+2f\cdot\min(\vert u\vert,\vert v\vert)\bigr)\big/\psqrt{u^2+v^2}$
is as close as possible to $d$.

Integer coordinates for the vertices work nicely because the thickness of
the envelope at any given slope is independent of the position of the
path with respect to the raster. It turns out, in fact, that the same
property holds for polygons whose vertices have coordinates that are
integer multiples of~$1\over2$, because ellipses are symmetric about
the origin. It's convenient to double all dimensions and require the
resulting polygon to have vertices with integer coordinates. For example,
to get a circle of {\sl diameter}~$r$, we shall compute integer
coordinates for a circle of {\sl radius}~$r$. The circle of radius~$r$
will want to be represented by a polygon that contains the boundary
points $(0,\pm r)$ and~$(\pm r,0)$; later we will divide everything
by~2 and get a polygon with $(0,\pm{1\over2}r)$ and $(\pm{1\over2}r,0)$
on its boundary.

@ In practice the important slopes are those having small values of
$u$ and~$v$; these make regular patterns in which our eyes quickly
spot irregularities. For example, horizontal and vertical lines
(when $u=0$ and $\vert v\vert=1$, or $\vert u\vert=1$ and $v=0$)
are the most important; diagonal lines (when $\vert u\vert=\vert v\vert=1$)
are next; and then come lines with slope $\pm2$ or $\pm1/2$.

The nicest way to generate all rational directions having small
numerators and denominators is to generalize the Stern--Brocot tree
[cf.~{\sl Concrete Mathematics}, section 4.5]
@^Brocot, Achille@>
@^Stern, Moritz Abraham@>
to a ``Stern--Brocot wreath'' as follows: Begin with four nodes
arranged in a circle, containing the respective directions
$(u,v)=(1,0)$, $(0,1)$, $(-1,0)$, and~$(0,-1)$. Then between pairs of
consecutive terms $(u,v)$ and $(u',v')$ of the wreath, insert the
direction $(u+u',v+v')$; continue doing this until some stopping
criterion is fulfilled.

It is not difficult to verify that, regardless of the stopping
criterion, consecutive directions $(u,v)$ and $(u',v')$ of this
wreath will always satisfy the relation $uv'-u'v=1$. Such pairs
of directions have a nice property with respect to the equivalence
classes described above. Let $l$ be a line of equivalent integer points
$(m+tv,n-tu)$ with respect to~$(u,v)$, and let $l'$ be a line of
equivalent integer points $(m'+tv',n'-tu')$ with respect to~$(u',v')$.
Then $l$ and~$l'$ intersect in an integer point $(m'',n'')$, because
the determinant of the linear equations for intersection is $uv'-u'v=1$.
Notice that the class number of $(m'',n'')$ with respect to $(u+u',v+v')$
is the sum of its class numbers with respect to $(u,v)$ and~$(u',v')$.
Moreover, consecutive points on~$l$ and~$l'$ belong to classes that
differ by exactly~1 with respect to $(u+u',v+v')$.

This leads to a nice algorithm in which we construct a polygon having
``correct'' class numbers for as many small-integer directions $(u,v)$
as possible: Assuming that lines $l$ and~$l'$ contain points of the
correct class for $(u,v)$ and~$(u',v')$, respectively, we determine
the intersection $(m'',n'')$ and compute its class with respect to
$(u+u',v+v')$. If the class is too large to be the best approximation,
we move back the proper number of steps from $(m'',n'')$ toward smaller
class numbers on both $l$ and~$l'$, unless this requires moving to points
that are no longer in the polygon; in this way we arrive at two points that
determine a line~$l''$ having the appropriate class. The process continues
recursively, until it cannot proceed without removing the last remaining
point from the class for $(u,v)$ or the class for $(u',v')$.

@ The |make_ellipse| subroutine produces a pointer to a cyclic path
whose vertices define a polygon suitable for envelopes. The control
points on this path will be ignored; in fact, the fields in knot nodes
that are usually reserved for control points are occupied by other
data that helps |make_ellipse| compute the desired polygon.

Parameters |major_axis| and |minor_axis| define the axes of the ellipse;
and parameter |theta| is an angle by which the ellipse is rotated
counterclockwise. If |theta==0|, the ellipse has the equation
$(x/a)^2+(y/b)^2=1$, where |a==major_axis/(double)2| and |b==minor_axis/(double)2|.
In general, the points of the ellipse are generated in the complex plane
by the formula $e^{i\theta}(a\cos t+ib\sin t)$, as $t$~ranges over all
angles. Notice that if |major_axis==minor_axis==d|, we obtain a circle
of diameter~|d|, regardless of the value of |theta|.

The method sketched above is used to produce the elliptical polygon,
except that the main work is done only in the halfplane obtained from
the three starting directions $(0,-1)$, $(1,0)$,~$(0,1)$. Since the ellipse
has circular symmetry, we use the fact that the last half of the polygon
is simply the negative of the first half. Furthermore, we need to compute only
one quarter of the polygon if the ellipse has axis symmetry.

@p pointer make_ellipse(scaled @!major_axis, scaled @!minor_axis,
  angle @!theta)
{@+
pointer @!p, @!q, @!r, @!s; /*for list manipulation*/ 
pointer @!h; /*head of the constructed knot list*/ 
int @!alpha, @!beta, @!gamma, @!delta; /*special points*/ 
int @!c, @!d; /*class numbers*/ 
int @!u, @!v; /*directions*/ 
bool @!symmetric; /*should the result be symmetric about the axes?*/ 
@<Initialize the ellipse data structure by beginning with directions $(0,-1)$, $(1,0)$,
$(0,1)$@>;
@<Interpolate new vertices in the ellipse data structure until improvement is impossible@>;
if (symmetric) 
  @<Complete the half ellipse by reflecting the quarter already computed@>;
@<Complete the ellipse by copying the negative of the half already computed@>;
return h;
} 

@ A special data structure is used only with |make_ellipse|: The
|right_x|, |left_x|, |right_y|, and |left_y| fields of knot nodes
are renamed |right_u|, |left_v|, |right_class|, and |left_length|,
in order to store information that simplifies the necessary computations.

If |p| and |q| are consecutive knots in this data structure, the
|x_coord| and |y_coord| fields of |p| and~|q| contain current vertices
of the polygon; their values are integer multiples
of |half_unit|. Both of these vertices belong to equivalence class
|right_class(p)| with respect to the direction
$\bigl($|right_u(p), left_v(q)|$\bigr)$. The number of points of this class
on the line from vertex~|p| to vertex~|q| is |1+left_length(q)|.
In particular, |left_length(q)==0| means that |x_coord(p)==x_coord(q)|
and |y_coord(p)==y_coord(q)|; such duplicate vertices will be
discarded during the course of the algorithm.

The contents of |right_u(p)| and |left_v(q)| are integer multiples
of |half_unit|, just like the coordinate fields. Hence, for example,
the point $\bigl($|x_coord(p)-left_v(q), y_coord(p)+right_u(p)|$\bigr)$
also belongs to class number |right_class(p)|. This point is one
step closer to the vertex in node~|q|; it equals that vertex
if and only if |left_length(q)==1|.

The |left_type| and |right_type| fields are not used, but |link|
has its normal meaning.

To start the process, we create four nodes for the three directions
$(0,-1)$, $(1,0)$, and $(0,1)$. The corresponding vertices are
$(-\alpha,-\beta)$, $(\gamma,-\beta)$, $(\gamma,\beta)$, and
$(\alpha,\beta)$, where $(\alpha,\beta)$ is a half-integer approximation
to where the ellipse rises highest above the $x$-axis, and where
$\gamma$ is a half-integer approximation to the maximum $x$~coordinate
of the ellipse. The fourth of these nodes is not actually calculated
if the ellipse has axis symmetry.

@d right_u	right_x /*|u| value for a pen edge*/ 
@d left_v	left_x /*|v| value for a pen edge*/ 
@d right_class	right_y /*equivalence class number of a pen edge*/ 
@d left_length	left_y /*length of a pen edge*/ 

@<Initialize the ellipse data structure...@>=
@<Calculate integers $\alpha$, $\beta$, $\gamma$ for the vertex coordinates@>;
p=get_node(knot_node_size);q=get_node(knot_node_size);
r=get_node(knot_node_size);
if (symmetric) s=null;@+else s=get_node(knot_node_size);
h=p;link(p)=q;link(q)=r;link(r)=s; /*|s==null| or |link(s)==null|*/ 
@<Revise the values of $\alpha$, $\beta$, $\gamma$, if necessary, so that degenerate
lines of length zero will not be obtained@>;
x_coord(p)=-alpha*half_unit;
y_coord(p)=-beta*half_unit;
x_coord(q)=gamma*half_unit;@/
y_coord(q)=y_coord(p);x_coord(r)=x_coord(q);@/
right_u(p)=0;left_v(q)=-half_unit;@/
right_u(q)=half_unit;left_v(r)=0;@/
right_u(r)=0;
right_class(p)=beta;right_class(q)=gamma;right_class(r)=beta;@/
left_length(q)=gamma+alpha;
if (symmetric) 
  {@+y_coord(r)=0;left_length(r)=beta;
  } 
else{@+y_coord(r)=-y_coord(p);left_length(r)=beta+beta;@/
  x_coord(s)=-x_coord(p);y_coord(s)=y_coord(r);@/
  left_v(s)=half_unit;left_length(s)=gamma-alpha;
  } 

@ One of the important invariants of the pen data structure is that
the points are distinct. We may need to correct the pen specification
in order to avoid this. (The result of \&{pencircle} will always be at
least one pixel wide and one pixel tall, although \&{makepen} is
capable of producing smaller pens.)

@<Revise the values of $\alpha$, $\beta$, $\gamma$, if necessary...@>=
if (beta==0) beta=1;
if (gamma==0) gamma=1;
if (gamma <= abs(alpha)) 
  if (alpha > 0) alpha=gamma-1;
  else alpha=1-gamma

@ If $a$ and $b$ are the semi-major and semi-minor axes,
the given ellipse rises highest above the $x$-axis at the point
$\bigl((a^2-b^2)\sin\theta\cos\theta/\rho\bigr)+i\rho$, where
$\rho=\sqrt{(a\sin\theta)^2+(b\cos\theta)^2}$. It reaches
furthest to the right of~the $y$-axis at the point
$\sigma+i(a^2-b^2)\sin\theta\cos\theta/\sigma$, where
$\sigma=\sqrt{(a\cos\theta)^2+(b\sin\theta)^2}$.

@<Calculate integers $\alpha$, $\beta$, $\gamma$...@>=
if ((major_axis==minor_axis)||(theta%ninety_deg==0)) 
  {@+symmetric=true;alpha=0;
  if (odd(theta/ninety_deg)) 
    {@+beta=major_axis;gamma=minor_axis;
    n_sin=fraction_one;n_cos=0; /*|n_sin| and |n_cos| are used later*/ 
    } 
  else{@+beta=minor_axis;gamma=major_axis;theta=0;
    }  /*|n_sin| and |n_cos| aren't needed in this case*/ 
  } 
else{@+symmetric=false;
  n_sin_cos(theta); /*set up $|n_sin|=\sin\theta$ and $|n_cos|=\cos\theta$*/ 
  gamma=take_fraction(major_axis, n_sin);
  delta=take_fraction(minor_axis, n_cos);
  beta=pyth_add(gamma, delta);
  alpha=take_fraction(take_fraction(major_axis,
      make_fraction(gamma, beta)), n_cos)@|
    -take_fraction(take_fraction(minor_axis,
      make_fraction(delta, beta)), n_sin);
  alpha=(alpha+half_unit)/unity;
  gamma=pyth_add(take_fraction(major_axis, n_cos),
    take_fraction(minor_axis, n_sin));
  } 
beta=(beta+half_unit)/unity;
gamma=(gamma+half_unit)/unity

@ Now |p|, |q|, and |r| march through the list, always representing
three consecutive vertices and two consecutive slope directions.
When a new slope is interpolated, we back up slightly, until
further refinement is impossible; then we march forward again.
The somewhat magical operations performed in this part of the
algorithm are justified by the theory sketched earlier.
Complications arise only from the need to keep zero-length lines
out of the final data structure.

@<Interpolate new vertices in the ellipse data structure...@>=
loop@+{@+u=right_u(p)+right_u(q);v=left_v(q)+left_v(r);
  c=right_class(p)+right_class(q);@/
  @<Compute the distance |d| from class~0 to the edge of the ellipse in direction
|(u,v)|, times $\psqrt{u^2+v^2}$, rounded to the nearest integer@>;
  delta=c-d; /*we want to move |delta| steps back
      from the intersection vertex~|q|*/ 
  if (delta > 0) 
    {@+if (delta > left_length(r)) delta=left_length(r);
    if (delta >= left_length(q)) 
      @<Remove the line from |p| to |q|, and adjust vertex~|q| to introduce a new
line@>@;
    else@<Insert a new line for direction |(u,v)| between |p| and~|q|@>;
    } 
  else p=q;
  @<Move to the next remaining triple |(p,q,r)|, removing and skipping past zero-length
lines that might be present; |goto done| if all triples have been processed@>;
  } 
done: 

@ The appearance of a zero-length line means that we should advance |p|
past it. We must not try to straddle a missing direction, because the
algorithm works only on consecutive pairs of directions.

@<Move to the next remaining triple |(p,q,r)|...@>=
loop@+{@+q=link(p);
  if (q==null) goto done;
  if (left_length(q)==0) 
    {@+link(p)=link(q);right_class(p)=right_class(q);
    right_u(p)=right_u(q);free_node(q, knot_node_size);
    } 
  else{@+r=link(q);
    if (r==null) goto done;
    if (left_length(r)==0) 
      {@+link(p)=r;free_node(q, knot_node_size);p=r;
      } 
    else goto found;
    } 
  } 
found: 

@ The `\&{div} 8' near the end of this step comes from
the fact that |delta| is scaled by~$2^{15}$ and $d$~by~$2^{16}$,
while |take_fraction| removes a scale factor of~$2^{28}$.
We also make sure that $d\G\max(\vert u\vert,\vert v\vert)$, so that
the pen will always include a circular pen of diameter~1 as a subset;
then it won't be possible to get disconnected path envelopes.

@<Compute the distance |d| from class~0 to the edge of the ellipse...@>=
delta=pyth_add(u, v);
if (major_axis==minor_axis) d=major_axis; /*circles are easy*/ 
else{@+if (theta==0) 
    {@+alpha=u;beta=v;
    } 
  else{@+alpha=take_fraction(u, n_cos)+take_fraction(v, n_sin);
    beta=take_fraction(v, n_cos)-take_fraction(u, n_sin);
    } 
  alpha=make_fraction(alpha, delta);
  beta=make_fraction(beta, delta);
  d=pyth_add(take_fraction(major_axis, alpha),
    take_fraction(minor_axis, beta));
  } 
alpha=abs(u);beta=abs(v);
if (alpha < beta) 
  {@+alpha=abs(v);beta=abs(u);
  }  /*now $\alpha=\max(\vert u\vert,\vert v\vert)$,
      $\beta=\min(\vert u\vert,\vert v\vert)$*/ 
if (internal[fillin]!=0) 
  d=d-take_fraction(internal[fillin], make_fraction(beta+beta, delta));
d=take_fraction((d+4)/8, delta);alpha=alpha/half_unit;
if (d < alpha) d=alpha

@ At this point there's a line of length | <= delta| from vertex~|p|
to vertex~|q|, orthogonal to direction $\bigl($|right_u(p), left_v(q)|$\bigr)$;
and there's a line of length | >= delta| from vertex~|q| to
to vertex~|r|, orthogonal to direction $\bigl($|right_u(q), left_v(r)|$\bigr)$.
The best line to direction $(u,v)$ should replace the line from
|p| to~|q|; this new line will have the same length as the old.

@<Remove the line from |p| to |q|...@>=
{@+delta=left_length(q);@/
right_class(p)=c-delta;right_u(p)=u;left_v(q)=v;@/
x_coord(q)=x_coord(q)-delta*left_v(r);
y_coord(q)=y_coord(q)+delta*right_u(q);@/
left_length(r)=left_length(r)-delta;
} 

@ Here is the main case, now that we have dealt with the exception:
We insert a new line of length |delta| for direction |(u, v)|, decreasing
each of the adjacent lines by |delta| steps.

@<Insert a new line for direction |(u,v)| between |p| and~|q|@>=
{@+s=get_node(knot_node_size);link(p)=s;link(s)=q;@/
x_coord(s)=x_coord(q)+delta*left_v(q);
y_coord(s)=y_coord(q)-delta*right_u(p);@/
x_coord(q)=x_coord(q)-delta*left_v(r);
y_coord(q)=y_coord(q)+delta*right_u(q);@/
left_v(s)=left_v(q);right_u(s)=u;left_v(q)=v;@/
right_class(s)=c-delta;@/
left_length(s)=left_length(q)-delta;left_length(q)=delta;
left_length(r)=left_length(r)-delta;
} 

@ Only the coordinates need to be copied, not the class numbers and other stuff.
At this point either |link(p)| or |link(link(p))| is |null|.

@<Complete the half ellipse...@>=
{@+s=null;q=h;
loop@+{@+r=get_node(knot_node_size);link(r)=s;s=r;@/
  x_coord(s)=x_coord(q);y_coord(s)=-y_coord(q);
  if (q==p) goto done1;
  q=link(q);
  if (y_coord(q)==0) goto done1;
  } 
done1: if ((link(p)!=null)) free_node(link(p), knot_node_size);
link(p)=s;beta=-y_coord(h);
while (y_coord(p)!=beta) p=link(p);
q=link(p);
} 

@ Now we use a somewhat tricky fact: The pointer |q| will be null if and
only if the line for the final direction $(0,1)$ has been removed. If
that line still survives, it should be combined with a possibly
surviving line in the initial direction $(0,-1)$.

@<Complete the ellipse by copying...@>=
if (q!=null) 
  {@+if (right_u(h)==0) 
    {@+p=h;h=link(h);free_node(p, knot_node_size);@/
    x_coord(q)=-x_coord(h);
    } 
  p=q;
  } 
else q=p;
r=link(h); /*now |p==q|, |x_coord(p)==-x_coord(h)|, |y_coord(p)==-y_coord(h)|*/ 
@/do@+{s=get_node(knot_node_size);link(p)=s;p=s;@/
x_coord(p)=-x_coord(r);y_coord(p)=-y_coord(r);r=link(r);
}@+ while (!(r==q));
link(p)=h

@* Direction and intersection times.
A path of length $n$ is defined parametrically by functions $x(t)$ and
$y(t)$, for |0 <= t <= n|; we can regard $t$ as the ``time'' at which the path
reaches the point $\bigl(x(t),y(t)\bigr)$.  In this section of the program
we shall consider operations that determine special times associated with
given paths: the first time that a path travels in a given direction, and
a pair of times at which two paths cross each other.

@ Let's start with the easier task. The function |find_direction_time| is
given a direction |(x, y)| and a path starting at~|h|. If the path never
travels in direction |(x, y)|, the direction time will be~|-1|; otherwise
it will be nonnegative.

Certain anomalous cases can arise: If |(x, y)==(0, 0)|, so that the given
direction is undefined, the direction time will be~0. If $\bigl(x'(t),
y'(t)\bigr)=(0,0)$, so that the path direction is undefined, it will be
assumed to match any given direction at time~|t|.

The routine solves this problem in nondegenerate cases by rotating the path
and the given direction so that |(x, y)==(1, 0)|; i.e., the main task will be
to find when a given path first travels ``due east.''

@p scaled find_direction_time(scaled @!x, scaled @!y, pointer @!h)
{@+
scaled @!max; /*$\max\bigl(\vert x\vert,\vert y\vert\bigr)$*/ 
pointer @!p, @!q; /*for list traversal*/ 
scaled @!n; /*the direction time at knot |p|*/ 
scaled @!tt; /*the direction time within a cubic*/ 
@<Other local variables for |find_direction_time|@>@;
@<Normalize the given direction for better accuracy; but |return| with zero result
if it's zero@>;
n=0;p=h;
loop@+{@+if (right_type(p)==endpoint) goto not_found;
  q=link(p);
  @<Rotate the cubic between |p| and |q|; then |goto found| if the rotated cubic travels
due east at some time |tt|; but |goto not_found| if an entire cyclic path has been
traversed@>;
  p=q;n=n+unity;
  } 
not_found: return-unity;
found: return n+tt;
} 

@ @<Normalize the given direction for better accuracy...@>=
if (abs(x) < abs(y)) 
  {@+x=make_fraction(x, abs(y));
  if (y > 0) y=fraction_one;@+else y=-fraction_one;
  } 
else if (x==0) 
  {@+return 0;
  } 
else{@+y=make_fraction(y, abs(x));
  if (x > 0) x=fraction_one;@+else x=-fraction_one;
  } 

@ Since we're interested in the tangent directions, we work with the
derivative $${1\over3}B'(x_0,x_1,x_2,x_3;t)=
B(x_1-x_0,x_2-x_1,x_3-x_2;t)$$ instead of
$B(x_0,x_1,x_2,x_3;t)$ itself. The derived coefficients are also scaled up
in order to achieve better accuracy.

The given path may turn abruptly at a knot, and it might pass the critical
tangent direction at such a time. Therefore we remember the direction |phi|
in which the previous rotated cubic was traveling. (The value of |phi| will be
undefined on the first cubic, i.e., when |n==0|.)

@<Rotate the cubic between |p| and |q|; then...@>=
tt=0;
@<Set local variables |x1,x2,x3| and |y1,y2,y3| to multiples of the control points
of the rotated derivatives@>;
if (y1==0) if (x1 >= 0) goto found;
if (n > 0) 
  {@+@<Exit to |found| if an eastward direction occurs at knot |p|@>;
  if (p==h) goto not_found;
  } 
if ((x3!=0)||(y3!=0)) phi=n_arg(x3, y3);
@<Exit to |found| if the curve whose derivatives are specified by |x1,x2,x3,y1,y2,y3|
travels eastward at some time~|tt|@>@;

@ @<Other local variables for |find_direction_time|@>=
scaled @!x1, @!x2, @!x3, @!y1, @!y2, @!y3; /*multiples of rotated derivatives*/ 
angle @!theta, @!phi; /*angles of exit and entry at a knot*/ 
fraction @!t; /*temp storage*/ 

@ @<Set local variables |x1,x2,x3| and |y1,y2,y3| to multiples...@>=
x1=right_x(p)-x_coord(p);x2=left_x(q)-right_x(p);
x3=x_coord(q)-left_x(q);@/
y1=right_y(p)-y_coord(p);y2=left_y(q)-right_y(p);
y3=y_coord(q)-left_y(q);@/
max=abs(x1);
if (abs(x2) > max) max=abs(x2);
if (abs(x3) > max) max=abs(x3);
if (abs(y1) > max) max=abs(y1);
if (abs(y2) > max) max=abs(y2);
if (abs(y3) > max) max=abs(y3);
if (max==0) goto found;
while (max < fraction_half) 
  {@+double(max);double(x1);double(x2);double(x3);
  double(y1);double(y2);double(y3);
  } 
t=x1;x1=take_fraction(x1, x)+take_fraction(y1, y);
y1=take_fraction(y1, x)-take_fraction(t, y);@/
t=x2;x2=take_fraction(x2, x)+take_fraction(y2, y);
y2=take_fraction(y2, x)-take_fraction(t, y);@/
t=x3;x3=take_fraction(x3, x)+take_fraction(y3, y);
y3=take_fraction(y3, x)-take_fraction(t, y)

@ @<Exit to |found| if an eastward direction occurs at knot |p|@>=
theta=n_arg(x1, y1);
if (theta >= 0) if (phi <= 0) if (phi >= theta-one_eighty_deg) goto found;
if (theta <= 0) if (phi >= 0) if (phi <= theta+one_eighty_deg) goto found

@ In this step we want to use the |crossing_point| routine to find the
roots of the quadratic equation $B(y_1,y_2,y_3;t)=0$.
Several complications arise: If the quadratic equation has a double root,
the curve never crosses zero, and |crossing_point| will find nothing;
this case occurs iff $y_1y_3=y_2^2$ and $y_1y_2<0$. If the quadratic
equation has simple roots, or only one root, we may have to negate it
so that $B(y_1,y_2,y_3;t)$ crosses from positive to negative at its first root.
And finally, we need to do special things if $B(y_1,y_2,y_3;t)$ is
identically zero.

@ @<Exit to |found| if the curve whose derivatives are specified by...@>=
if (x1 < 0) if (x2 < 0) if (x3 < 0) goto done;
if (ab_vs_cd(y1, y3, y2, y2)==0) 
  @<Handle the test for eastward directions when $y_1y_3=y_2^2$; either |goto found|
or |goto done|@>;
if (y1 <= 0) 
  if (y1 < 0) 
    {@+y1=-y1;y2=-y2;y3=-y3;
    } 
  else if (y2 > 0) 
    {@+y2=-y2;y3=-y3;
    } 
@<Check the places where $B(y_1,y_2,y_3;t)=0$ to see if $B(x_1,x_2,x_3;t)\ge0$@>;
done: 

@ The quadratic polynomial $B(y_1,y_2,y_3;t)$ begins | >= 0| and has at most
two roots, because we know that it isn't identically zero.

It must be admitted that the |crossing_point| routine is not perfectly accurate;
rounding errors might cause it to find a root when $y_1y_3>y_2^2$, or to
miss the roots when $y_1y_3<y_2^2$. The rotation process is itself
subject to rounding errors. Yet this code optimistically tries to
do the right thing.

@d we_found_it	{@+tt=(t+04000)/010000;goto found;
  } 

@<Check the places where $B(y_1,y_2,y_3;t)=0$...@>=
t=crossing_point(y1, y2, y3);
if (t > fraction_one) goto done;
y2=t_of_the_way(y2)(y3);
x1=t_of_the_way(x1)(x2);
x2=t_of_the_way(x2)(x3);
x1=t_of_the_way(x1)(x2);
if (x1 >= 0) we_found_it;
if (y2 > 0) y2=0;
tt=t;t=crossing_point(0,-y2,-y3);
if (t > fraction_one) goto done;
x1=t_of_the_way(x1)(x2);
x2=t_of_the_way(x2)(x3);
if (t_of_the_way(x1)(x2) >= 0) 
  {@+t=t_of_the_way(tt)(fraction_one);we_found_it;
  } 

@ @<Handle the test for eastward directions when $y_1y_3=y_2^2$; either |goto found|
or |goto done|@>=
{@+if (ab_vs_cd(y1, y2, 0, 0) < 0) 
  {@+t=make_fraction(y1, y1-y2);
  x1=t_of_the_way(x1)(x2);
  x2=t_of_the_way(x2)(x3);
  if (t_of_the_way(x1)(x2) >= 0) we_found_it;
  } 
else if (y3==0) 
  if (y1==0) 
    @<Exit to |found| if the derivative $B(x_1,x_2,x_3;t)$ becomes |>=0|@>@;
  else if (x3 >= 0) 
    {@+tt=unity;goto found;
    } 
goto done;
} 

@ At this point we know that the derivative of |y(t)| is identically zero,
and that |x1 < 0|; but either |x2 >= 0| or |x3 >= 0|, so there's some hope of
traveling east.

@<Exit to |found| if the derivative $B(x_1,x_2,x_3;t)$ becomes |>=0|...@>=
{@+t=crossing_point(-x1,-x2,-x3);
if (t <= fraction_one) we_found_it;
if (ab_vs_cd(x1, x3, x2, x2) <= 0) 
  {@+t=make_fraction(x1, x1-x2);we_found_it;
  } 
} 

@ The intersection of two cubics can be found by an interesting variant
of the general bisection scheme described in the introduction to |make_moves|.\
Given $w(t)=B(w_0,w_1,w_2,w_3;t)$ and $z(t)=B(z_0,z_1,z_2,z_3;t)$,
we wish to find a pair of times $(t_1,t_2)$ such that $w(t_1)=z(t_2)$,
if an intersection exists. First we find the smallest rectangle that
encloses the points $\{w_0,w_1,w_2,w_3\}$ and check that it overlaps
the smallest rectangle that encloses
$\{z_0,z_1,z_2,z_3\}$; if not, the cubics certainly don't intersect.
But if the rectangles do overlap, we bisect the intervals, getting
new cubics $w'$ and~$w''$, $z'$~and~$z''$; the intersection routine first
tries for an intersection between $w'$ and~$z'$, then (if unsuccessful)
between $w'$ and~$z''$, then (if still unsuccessful) between $w''$ and~$z'$,
finally (if thrice unsuccessful) between $w''$ and~$z''$. After $l$~successful
levels of bisection we will have determined the intersection times $t_1$
and~$t_2$ to $l$~bits of accuracy.

\def\submin{_{\rm min}} \def\submax{_{\rm max}}
As before, it is better to work with the numbers $W_k=2^l(w_k-w_{k-1})$
and $Z_k=2^l(z_k-z_{k-1})$ rather than the coefficients $w_k$ and $z_k$
themselves. We also need one other quantity, $\Delta=2^l(w_0-z_0)$,
to determine when the enclosing rectangles overlap. Here's why:
The $x$~coordinates of~$w(t)$ are between $u\submin$ and $u\submax$,
and the $x$~coordinates of~$z(t)$ are between $x\submin$ and $x\submax$,
if we write $w_k=(u_k,v_k)$ and $z_k=(x_k,y_k)$ and $u\submin=
\min(u_0,u_1,u_2,u_3)$, etc. These intervals of $x$~coordinates
overlap if and only if $u\submin\L x\submax$ and
$x\submin\L u\submax$. Letting
$$U\submin=\min(0,U_1,U_1+U_2,U_1+U_2+U_3),\;
  U\submax=\max(0,U_1,U_1+U_2,U_1+U_2+U_3),$$
we have $2^lu\submin=2^lu_0+U\submin$, etc.; the condition for overlap
reduces to
$$X\submin-U\submax\L 2^l(u_0-x_0)\L X\submax-U\submin.$$
Thus we want to maintain the quantity $2^l(u_0-x_0)$; similarly,
the quantity $2^l(v_0-y_0)$ accounts for the $y$~coordinates. The
coordinates of $\Delta=2^l(w_0-z_0)$ must stay bounded as $l$ increases,
because of the overlap condition; i.e., we know that $X\submin$,
$X\submax$, and their relatives are bounded, hence $X\submax-
U\submin$ and $X\submin-U\submax$ are bounded.

@ Incidentally, if the given cubics intersect more than once, the process
just sketched will not necessarily find the lexicographically smallest pair
$(t_1,t_2)$. The solution actually obtained will be smallest in ``shuffled
order''; i.e., if $t_1=(.a_1a_2\ldots a_{16})_2$ and
$t_2=(.b_1b_2\ldots b_{16})_2$, then we will minimize
$a_1b_1a_2b_2\ldots a_{16}b_{16}$, not
$a_1a_2\ldots a_{16}b_1b_2\ldots b_{16}$.
Shuffled order agrees with lexicographic order if all pairs of solutions
$(t_1,t_2)$ and $(t_1',t_2')$ have the property that $t_1<t_1'$ iff
$t_2<t_2'$; but in general, lexicographic order can be quite different,
and the bisection algorithm would be substantially less efficient if it were
constrained by lexicographic order.

For example, suppose that an overlap has been found for $l=3$ and
$(t_1,t_2)= (.101,.011)$ in binary, but that no overlap is produced by
either of the alternatives $(.1010,.0110)$, $(.1010,.0111)$ at level~4.
Then there is probably an intersection in one of the subintervals
$(.1011,.011x)$; but lexicographic order would require us to explore
$(.1010,.1xxx)$ and $(.1011,.00xx)$ and $(.1011,.010x)$ first. We wouldn't
want to store all of the subdivision data for the second path, so the
subdivisions would have to be regenerated many times. Such inefficiencies
would be associated with every `1' in the binary representation of~$t_1$.

@ The subdivision process introduces rounding errors, hence we need to
make a more liberal test for overlap. It is not hard to show that the
computed values of $U_i$ differ from the truth by at most~$l$, on
level~$l$, hence $U\submin$ and $U\submax$ will be at most $3l$ in error.
If $\beta$ is an upper bound on the absolute error in the computed
components of $\Delta=(|delx|,|dely|)$ on level~$l$, we will replace
the test `$X\submin-U\submax\L|delx|$' by the more liberal test
`$X\submin-U\submax\L|delx|+|tol|$', where $|tol|=6l+\beta$.

More accuracy is obtained if we try the algorithm first with |tol==0|;
the more liberal tolerance is used only if an exact approach fails.
It is convenient to do this double-take by letting `3' in the preceding
paragraph be a parameter, which is first 0, then 3.

@<Glob...@>=
uint8_t @!tol_step; /*either 0 or 3, usually*/ 

@ We shall use an explicit stack to implement the recursive bisection
method described above. In fact, the |bisect_stack| array is available for
this purpose. It will contain numerous 5-word packets like
$(U_1,U_2,U_3,U\submin,U\submax)$, as well as 20-word packets comprising
the 5-word packets for $U$, $V$, $X$, and~$Y$.

The following macros define the allocation of stack positions to
the quantities needed for bisection-intersection.

@d stack_1(X)	bisect_stack[X] /*$U_1$, $V_1$, $X_1$, or $Y_1$*/ 
@d stack_2(X)	bisect_stack[X+1] /*$U_2$, $V_2$, $X_2$, or $Y_2$*/ 
@d stack_3(X)	bisect_stack[X+2] /*$U_3$, $V_3$, $X_3$, or $Y_3$*/ 
@d stack_min(X)	bisect_stack[X+3]
   /*$U\submin$, $V\submin$, $X\submin$, or $Y\submin$*/ 
@d stack_max(X)	bisect_stack[X+4]
   /*$U\submax$, $V\submax$, $X\submax$, or $Y\submax$*/ 
@d int_packets	20 /*number of words to represent $U_k$, $V_k$, $X_k$, and $Y_k$*/ 
@#
@d u_packet(X)	X-5
@d v_packet(X)	X-10
@d x_packet(X)	X-15
@d y_packet(X)	X-20
@d l_packets	bisect_ptr-int_packets
@d r_packets	bisect_ptr
@d ul_packet	u_packet(l_packets) /*base of $U'_k$ variables*/ 
@d vl_packet	v_packet(l_packets) /*base of $V'_k$ variables*/ 
@d xl_packet	x_packet(l_packets) /*base of $X'_k$ variables*/ 
@d yl_packet	y_packet(l_packets) /*base of $Y'_k$ variables*/ 
@d ur_packet	u_packet(r_packets) /*base of $U''_k$ variables*/ 
@d vr_packet	v_packet(r_packets) /*base of $V''_k$ variables*/ 
@d xr_packet	x_packet(r_packets) /*base of $X''_k$ variables*/ 
@d yr_packet	y_packet(r_packets) /*base of $Y''_k$ variables*/ 
@#
@d u1l	stack_1(ul_packet) /*$U'_1$*/ 
@d u2l	stack_2(ul_packet) /*$U'_2$*/ 
@d u3l	stack_3(ul_packet) /*$U'_3$*/ 
@d v1l	stack_1(vl_packet) /*$V'_1$*/ 
@d v2l	stack_2(vl_packet) /*$V'_2$*/ 
@d v3l	stack_3(vl_packet) /*$V'_3$*/ 
@d x1l	stack_1(xl_packet) /*$X'_1$*/ 
@d x2l	stack_2(xl_packet) /*$X'_2$*/ 
@d x3l	stack_3(xl_packet) /*$X'_3$*/ 
@d y1l	stack_1(yl_packet) /*$Y'_1$*/ 
@d y2l	stack_2(yl_packet) /*$Y'_2$*/ 
@d y3l	stack_3(yl_packet) /*$Y'_3$*/ 
@d u1r	stack_1(ur_packet) /*$U''_1$*/ 
@d u2r	stack_2(ur_packet) /*$U''_2$*/ 
@d u3r	stack_3(ur_packet) /*$U''_3$*/ 
@d v1r	stack_1(vr_packet) /*$V''_1$*/ 
@d v2r	stack_2(vr_packet) /*$V''_2$*/ 
@d v3r	stack_3(vr_packet) /*$V''_3$*/ 
@d x1r	stack_1(xr_packet) /*$X''_1$*/ 
@d x2r	stack_2(xr_packet) /*$X''_2$*/ 
@d x3r	stack_3(xr_packet) /*$X''_3$*/ 
@d y1r	stack_1(yr_packet) /*$Y''_1$*/ 
@d y2r	stack_2(yr_packet) /*$Y''_2$*/ 
@d y3r	stack_3(yr_packet) /*$Y''_3$*/ 
@#
@d stack_dx	bisect_stack[bisect_ptr] /*stacked value of |delx|*/ 
@d stack_dy	bisect_stack[bisect_ptr+1] /*stacked value of |dely|*/ 
@d stack_tol	bisect_stack[bisect_ptr+2] /*stacked value of |tol|*/ 
@d stack_uv	bisect_stack[bisect_ptr+3] /*stacked value of |uv|*/ 
@d stack_xy	bisect_stack[bisect_ptr+4] /*stacked value of |xy|*/ 
@d int_increment	(int_packets+int_packets+5) /*number of stack words per level*/ 

@<Check the ``constant''...@>=
if (int_packets+17*int_increment > bistack_size) bad=32;

@ Computation of the min and max is a tedious but fairly fast sequence of
instructions; exactly four comparisons are made in each branch.

@d set_min_max(X)	
  if (stack_1(X) < 0) 
    if (stack_3(X) >= 0) 
      {@+if (stack_2(X) < 0) stack_min(X)=stack_1(X)+stack_2(X);
        else stack_min(X)=stack_1(X);
      stack_max(X)=stack_1(X)+stack_2(X)+stack_3(X);
      if (stack_max(X) < 0) stack_max(X)=0;
      } 
    else{@+stack_min(X)=stack_1(X)+stack_2(X)+stack_3(X);
      if (stack_min(X) > stack_1(X)) stack_min(X)=stack_1(X);
      stack_max(X)=stack_1(X)+stack_2(X);
      if (stack_max(X) < 0) stack_max(X)=0;
      } 
  else if (stack_3(X) <= 0) 
    {@+if (stack_2(X) > 0) stack_max(X)=stack_1(X)+stack_2(X);
      else stack_max(X)=stack_1(X);
    stack_min(X)=stack_1(X)+stack_2(X)+stack_3(X);
    if (stack_min(X) > 0) stack_min(X)=0;
    } 
  else{@+stack_max(X)=stack_1(X)+stack_2(X)+stack_3(X);
    if (stack_max(X) < stack_1(X)) stack_max(X)=stack_1(X);
    stack_min(X)=stack_1(X)+stack_2(X);
    if (stack_min(X) > 0) stack_min(X)=0;
    } 

@ It's convenient to keep the current values of $l$, $t_1$, and $t_2$ in
the integer form $2^l+2^lt_1$ and $2^l+2^lt_2$. The |cubic_intersection|
routine uses global variables |cur_t| and |cur_tt| for this purpose;
after successful completion, |cur_t| and |cur_tt| will contain |unity|
plus the |scaled| values of $t_1$ and~$t_2$.

The values of |cur_t| and |cur_tt| will be set to zero if |cubic_intersection|
finds no intersection. The routine gives up and gives an approximate answer
if it has backtracked
more than 5000 times (otherwise there are cases where several minutes
of fruitless computation would be possible).

@d max_patience	5000

@<Glob...@>=
int @!cur_t, @!cur_tt; /*controls and results of |cubic_intersection|*/ 
int @!time_to_go; /*this many backtracks before giving up*/ 
int @!max_t; /*maximum of $2^{l+1}$ so far achieved*/ 

@ The given cubics $B(w_0,w_1,w_2,w_3;t)$ and
$B(z_0,z_1,z_2,z_3;t)$ are specified in adjacent knot nodes |(p, link(p))|
and |(pp, link(pp))|, respectively.

@p void cubic_intersection(pointer @!p, pointer @!pp)
{@+
pointer @!q, @!qq; /*|link(p)|, |link(pp)|*/ 
time_to_go=max_patience;max_t=2;
@<Initialize for intersections at level zero@>;
loop@+{@+resume: 
  if (delx-tol <= stack_max(x_packet(xy))-stack_min(u_packet(uv))) 
   if (delx+tol >= stack_min(x_packet(xy))-stack_max(u_packet(uv))) 
   if (dely-tol <= stack_max(y_packet(xy))-stack_min(v_packet(uv))) 
   if (dely+tol >= stack_min(y_packet(xy))-stack_max(v_packet(uv))) 
    {@+if (cur_t >= max_t) 
      {@+if (max_t==two)  /*we've done 17 bisections*/ 
        {@+cur_t=half(cur_t+1);cur_tt=half(cur_tt+1);return;
        } 
      double(max_t);appr_t=cur_t;appr_tt=cur_tt;
      } 
    @<Subdivide for a new level of intersection@>;
    goto resume;
    } 
  if (time_to_go > 0) decr(time_to_go);
  else{@+while (appr_t < unity) 
      {@+double(appr_t);double(appr_tt);
      } 
    cur_t=appr_t;cur_tt=appr_tt;return;
    } 
  @<Advance to the next pair |(cur_t,cur_tt)|@>;
  } 
} 

@ The following variables are global, although they are used only by
|cubic_intersection|, because it is necessary on some machines to
split |cubic_intersection| up into two procedures.

@<Glob...@>=
int @!delx, @!dely; /*the components of $\Delta=2^l(w_0-z_0)$*/ 
int @!tol; /*bound on the uncertainty in the overlap test*/ 
uint16_t @!uv, @!xy; /*pointers to the current packets of interest*/ 
int @!three_l; /*|tol_step| times the bisection level*/ 
int @!appr_t, @!appr_tt; /*best approximations known to the answers*/ 

@ We shall assume that the coordinates are sufficiently non-extreme that
integer overflow will not occur.
@^overflow in arithmetic@>

@<Initialize for intersections at level zero@>=
q=link(p);qq=link(pp);bisect_ptr=int_packets;@/
u1r=right_x(p)-x_coord(p);u2r=left_x(q)-right_x(p);
u3r=x_coord(q)-left_x(q);set_min_max(ur_packet);@/
v1r=right_y(p)-y_coord(p);v2r=left_y(q)-right_y(p);
v3r=y_coord(q)-left_y(q);set_min_max(vr_packet);@/
x1r=right_x(pp)-x_coord(pp);x2r=left_x(qq)-right_x(pp);
x3r=x_coord(qq)-left_x(qq);set_min_max(xr_packet);@/
y1r=right_y(pp)-y_coord(pp);y2r=left_y(qq)-right_y(pp);
y3r=y_coord(qq)-left_y(qq);set_min_max(yr_packet);@/
delx=x_coord(p)-x_coord(pp);dely=y_coord(p)-y_coord(pp);@/
tol=0;uv=r_packets;xy=r_packets;three_l=0;cur_t=1;cur_tt=1

@ @<Subdivide for a new level of intersection@>=
stack_dx=delx;stack_dy=dely;stack_tol=tol;stack_uv=uv;stack_xy=xy;
bisect_ptr=bisect_ptr+int_increment;@/
double(cur_t);double(cur_tt);@/
u1l=stack_1(u_packet(uv));u3r=stack_3(u_packet(uv));
u2l=half(u1l+stack_2(u_packet(uv)));
u2r=half(u3r+stack_2(u_packet(uv)));
u3l=half(u2l+u2r);u1r=u3l;
set_min_max(ul_packet);set_min_max(ur_packet);@/
v1l=stack_1(v_packet(uv));v3r=stack_3(v_packet(uv));
v2l=half(v1l+stack_2(v_packet(uv)));
v2r=half(v3r+stack_2(v_packet(uv)));
v3l=half(v2l+v2r);v1r=v3l;
set_min_max(vl_packet);set_min_max(vr_packet);@/
x1l=stack_1(x_packet(xy));x3r=stack_3(x_packet(xy));
x2l=half(x1l+stack_2(x_packet(xy)));
x2r=half(x3r+stack_2(x_packet(xy)));
x3l=half(x2l+x2r);x1r=x3l;
set_min_max(xl_packet);set_min_max(xr_packet);@/
y1l=stack_1(y_packet(xy));y3r=stack_3(y_packet(xy));
y2l=half(y1l+stack_2(y_packet(xy)));
y2r=half(y3r+stack_2(y_packet(xy)));
y3l=half(y2l+y2r);y1r=y3l;
set_min_max(yl_packet);set_min_max(yr_packet);@/
uv=l_packets;xy=l_packets;
double(delx);double(dely);@/
tol=tol-three_l+tol_step;double(tol);three_l=three_l+tol_step

@ @<Advance to the next pair |(cur_t,cur_tt)|@>=
not_found: if (odd(cur_tt)) 
  if (odd(cur_t)) @<Descend to the previous level and |goto not_found|@>@;
  else{@+incr(cur_t);
    delx=delx+stack_1(u_packet(uv))+stack_2(u_packet(uv))
      +stack_3(u_packet(uv));
    dely=dely+stack_1(v_packet(uv))+stack_2(v_packet(uv))
      +stack_3(v_packet(uv));
    uv=uv+int_packets; /*switch from |l_packets| to |r_packets|*/ 
    decr(cur_tt);xy=xy-int_packets; /*switch from |r_packets| to |l_packets|*/ 
    delx=delx+stack_1(x_packet(xy))+stack_2(x_packet(xy))
      +stack_3(x_packet(xy));
    dely=dely+stack_1(y_packet(xy))+stack_2(y_packet(xy))
      +stack_3(y_packet(xy));
    } 
else{@+incr(cur_tt);tol=tol+three_l;
  delx=delx-stack_1(x_packet(xy))-stack_2(x_packet(xy))
    -stack_3(x_packet(xy));
  dely=dely-stack_1(y_packet(xy))-stack_2(y_packet(xy))
    -stack_3(y_packet(xy));
  xy=xy+int_packets; /*switch from |l_packets| to |r_packets|*/ 
  } 

@ @<Descend to the previous level...@>=
{@+cur_t=half(cur_t);cur_tt=half(cur_tt);
if (cur_t==0) return;
bisect_ptr=bisect_ptr-int_increment;three_l=three_l-tol_step;
delx=stack_dx;dely=stack_dy;tol=stack_tol;uv=stack_uv;xy=stack_xy;@/
goto not_found;
} 

@ The |path_intersection| procedure is much simpler.
It invokes |cubic_intersection| in lexicographic order until finding a
pair of cubics that intersect. The final intersection times are placed in
|cur_t| and~|cur_tt|.

@p void path_intersection(pointer @!h, pointer @!hh)
{@+
pointer @!p, @!pp; /*link registers that traverse the given paths*/ 
int @!n, @!nn; /*integer parts of intersection times, minus |unity|*/ 
@<Change one-point paths into dead cycles@>;
tol_step=0;
@/do@+{n=-unity;p=h;
  @/do@+{if (right_type(p)!=endpoint) 
    {@+nn=-unity;pp=hh;
    @/do@+{if (right_type(pp)!=endpoint) 
      {@+cubic_intersection(p, pp);
      if (cur_t > 0) 
        {@+cur_t=cur_t+n;cur_tt=cur_tt+nn;return;
        } 
      } 
    nn=nn+unity;pp=link(pp);
    }@+ while (!(pp==hh));
    } 
  n=n+unity;p=link(p);
  }@+ while (!(p==h));
tol_step=tol_step+3;
}@+ while (!(tol_step > 3));
cur_t=-unity;cur_tt=-unity;
} 

@ @<Change one-point paths...@>=
if (right_type(h)==endpoint) 
  {@+right_x(h)=x_coord(h);left_x(h)=x_coord(h);
  right_y(h)=y_coord(h);left_y(h)=y_coord(h);right_type(h)=explicit;
  } 
if (right_type(hh)==endpoint) 
  {@+right_x(hh)=x_coord(hh);left_x(hh)=x_coord(hh);
  right_y(hh)=y_coord(hh);left_y(hh)=y_coord(hh);right_type(hh)=explicit;
  } 

@* Online graphic output.
\MF\ displays images on the user's screen by means of a few primitive
operations that are defined below. These operations have deliberately been
kept simple so that they can be implemented without great difficulty on a
wide variety of machines. Since \PASCAL\ has no traditional standards for
graphic output, some system-dependent code needs to be written in order to
support this aspect of \MF; but the necessary routines are usually quite
easy to write.
@^system dependencies@>

In fact, there are exactly four such routines:

\yskip\hang
|init_screen| does whatever initialization is necessary to
support the other operations; it is a boolean function that returns
|false| if graphic output cannot be supported (e.g., if the other three
routines have not been written, or if the user doesn't have the
right kind of terminal).

\yskip\hang
|blank_rectangle| updates a buffer area in memory so that
all pixels in a specified rectangle will be set to the background color.

\yskip\hang
|paint_row| assigns values to specified pixels in a row of
the buffer just mentioned, based on ``transition'' indices explained below.

\yskip\hang
|update_screen| displays the current screen buffer; the
effects of |blank_rectangle| and |paint_row| commands may or may not
become visible until the next |update_screen| operation is performed.
(Thus, |update_screen| is analogous to |update_terminal|.)

\yskip\noindent
The \PASCAL\ code here is a minimum version of |init_screen| and
|update_screen|, usable on \MF\ installations that don't
support screen output. If |init_screen| is changed to return |true|
instead of |false|, the other routines will simply log the fact
that they have been called; they won't really display anything.
The standard test routines for \MF\ use this log information to check
that \MF\ is working properly, but the |wlog| instructions should be
removed from production versions of \MF.

@p bool init_screen(void)
{@+return false;
} 
@#
void update_screen(void) /*will be called only if |init_screen| returns |true|*/ 
{
#ifdef @!INIT
wlog_ln("Calling UPDATESCREEN");
#endif
 /*for testing only*/ 
} 

@ The user's screen is assumed to be a rectangular area, |screen_width|
pixels wide and |screen_depth| pixels deep. The pixel in the upper left
corner is said to be in column~0 of row~0; the pixel in the lower right
corner is said to be in column |screen_width-1| of row |screen_depth-1|.
Notice that row numbers increase from top to bottom, contrary to \MF's
other coordinates.

Each pixel is assumed to have two states, referred to in this documentation
as |black| and |white|. The background color is called |white| and the
other color is called |black|; but any two distinct pixel values
can actually be used. For example, the author developed \MF\ on a
system for which |white| was black and |black| was bright green.

@d white	0 /*background pixels*/ 
@d black	1 /*visible pixels*/ 

@<Types...@>=
typedef uint16_t screen_row; /*a row number on the screen*/ 
typedef uint16_t screen_col; /*a column number on the screen*/ 
typedef uint8_t pixel_color; /*specifies one of the two pixel values*/ 

@ We'll illustrate the |blank_rectangle| and |paint_row| operations by
pretending to declare a screen buffer called |screen_pixel|. This code
is actually commented out, but it does specify the intended effects.

@<Glob...@>=

@ The |blank_rectangle| routine simply whitens all pixels that lie in
columns |left_col| through |right_col-1|, inclusive, of rows
|top_row| through |bot_row-1|, inclusive, given four parameters that satisfy
the relations
$$\hbox{|0 <= left_col <= right_col <= screen_width|,\quad
  |0 <= top_row <= bot_row <= screen_depth|.}$$
If |left_col==right_col| or |top_row==bot_row|, nothing happens.

The commented-out code in the following procedure is for illustrative
purposes only.
@^system dependencies@>

@p void blank_rectangle(screen_col @!left_col, screen_col @!right_col,
  screen_row @!top_row, screen_row @!bot_row)
{@+screen_row @!r;
screen_col @!c;
@/
#ifdef @!INIT
wlog_cr; /*this will be done only after |init_screen==true|*/ 
wlog_ln("Calling BLANKRECTANGLE(%d,%d,%d,%d)", left_col,
  right_col, top_row, bot_row);
#endif
} 

@ The real work of screen display is done by |paint_row|. But it's not
hard work, because the operation affects only
one of the screen rows, and it affects only a contiguous set of columns
in that row. There are four parameters: |r|~(the row),
|b|~(the initial color),
|a|~(the array of transition specifications),
and |n|~(the number of transitions). The elements of~|a| will satisfy
$$0\L a[0]<a[1]<\cdots<a[n]\L |screen_width|;$$
the value of |r| will satisfy |0 <= r < screen_depth|; and |n| will be positive.

The general idea is to paint blocks of pixels in alternate colors;
the precise details are best conveyed by means of a \PASCAL\
program (see the commented-out code below).
@^system dependencies@>

@p void paint_row(screen_row @!r, pixel_color @!b, screen_col *a,
  screen_col @!n)
{@+int @!k; /*an index into |a|*/ 
screen_col @!c; /*an index into |screen_pixel|*/ 
@/
#ifdef @!INIT
wlog("Calling PAINTROW(%d,%d;", r, b);
   /*this is done only after |init_screen==true|*/ 
for (k=0; k<=n; k++) 
  {@+wlog("%d", a[k]);if (k!=n) wlog(",");
  } 
wlog_ln(")");
#endif
} 

@ The remainder of \MF's screen routines are system-independent calls
on the four primitives just defined.

First we have a global boolean variable that tells if |init_screen|
has been called, and another one that tells if |init_screen| has
given a |true| response.

@<Glob...@>=
bool @!screen_started; /*have the screen primitives been initialized?*/ 
bool @!screen_OK; /*is it legitimate to call |blank_rectangle|,
  |paint_row|, and |update_screen|?*/ 

@ @d start_screen	{@+if (!screen_started) 
    {@+screen_OK=init_screen();screen_started=true;
    } 
  } 

@<Set init...@>=
screen_started=false;screen_OK=false;

@ \MF\ provides the user with 16 ``window'' areas on the screen, in each
of which it is possible to produce independent displays.

It should be noted that \MF's windows aren't really independent
``clickable'' entities in the sense of multi-window graphic workstations;
\MF\ simply maps them into subsets of a single screen image that is
controlled by |init_screen|, |blank_rectangle|, |paint_row|, and
|update_screen| as described above. Implementations of \MF\ on a
multi-window workstation probably therefore make use of only two
windows in the other sense: one for the terminal output and another
for the screen with \MF's 16 areas. Henceforth we shall
use the term window only in \MF's sense.

@<Types...@>=
typedef uint8_t window_number;

@ A user doesn't have to use any of the 16 windows. But when a window is
``opened,'' it is allocated to a specific rectangular portion of the screen
and to a specific rectangle with respect to \MF's coordinates. The relevant
data is stored in global arrays |window_open|, |left_col|, |right_col|,
|top_row|, |bot_row|, |m_window|, and |n_window|.

The |window_open| array is boolean, and its significance is obvious. The
|left_col|, \dots, |bot_row| arrays contain screen coordinates that
can be used to blank the entire window with |blank_rectangle|. And the
other two arrays just mentioned handle the conversion between
actual coordinates and screen coordinates: \MF's pixel in column~$m$
of row~$n$ will appear in screen column |m_window+m| and in screen row
|n_window-n|, provided that these lie inside the boundaries of the window.

Another array |window_time| holds the number of times this window has
been updated.

@<Glob...@>=
bool @!window_open[16];
   /*has this window been opened?*/ 
screen_col @!left_col[16];
   /*leftmost column position on screen*/ 
screen_col @!right_col[16];
   /*rightmost column position, plus~1*/ 
screen_row @!top_row[16];
   /*topmost row position on screen*/ 
screen_row @!bot_row[16];
   /*bottommost row position, plus~1*/ 
int @!m_window[16];
   /*offset between user and screen columns*/ 
int @!n_window[16];
   /*offset between user and screen rows*/ 
int @!window_time[16];
   /*it has been updated this often*/ 

@ @<Set init...@>=
for (k=0; k<=15; k++) 
  {@+window_open[k]=false;window_time[k]=0;
  } 

@ Opening a window isn't like opening a file, because you can open it
as often as you like, and you never have to close it again. The idea is
simply to define special points on the current screen display.

Overlapping window specifications may cause complex effects that can
be understood only by scrutinizing \MF's display algorithms; thus it
has been left undefined in the \MF\ user manual, although the behavior
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
is in fact predictable.

Here is a subroutine that implements the command `\&{openwindow}~|k|
\&{from}~$(\\{r0},\\{c0})$ \&{to}~$(\\{r1},\\{c1})$ \&{at}~$(x,y)$'.

@p void open_a_window(window_number @!k, scaled @!r0, scaled @!c0, scaled @!r1, scaled @!c1,
    scaled @!x, scaled @!y)
{@+int @!m, @!n; /*pixel coordinates*/ 
@<Adjust the coordinates |(r0,c0)| and |(r1,c1)| so that they lie in the proper range@>;
window_open[k]=true;incr(window_time[k]);@/
left_col[k]=c0;right_col[k]=c1;top_row[k]=r0;bot_row[k]=r1;@/
@<Compute the offsets between screen coordinates and actual coordinates@>;
start_screen;
if (screen_OK) 
  {@+blank_rectangle(c0, c1, r0, r1);update_screen();
  } 
} 

@ A window whose coordinates don't fit the existing screen size will be
truncated until they do.

@<Adjust the coordinates |(r0,c0)| and |(r1,c1)|...@>=
if (r0 < 0) r0=0;@+else r0=round_unscaled(r0);
r1=round_unscaled(r1);
if (r1 > screen_depth) r1=screen_depth;
if (r1 < r0) 
  if (r0 > screen_depth) r0=r1;@+else r1=r0;
if (c0 < 0) c0=0;@+else c0=round_unscaled(c0);
c1=round_unscaled(c1);
if (c1 > screen_width) c1=screen_width;
if (c1 < c0) 
  if (c0 > screen_width) c0=c1;@+else c1=c0

@ Three sets of coordinates are rampant, and they must be kept straight!
(i)~\MF's main coordinates refer to the edges between pixels. (ii)~\MF's
pixel coordinates (within edge structures) say that the pixel bounded by
$(m,n)$, $(m,n+1)$, $(m+1,n)$, and~$(m+1,n+1)$ is in pixel row number~$n$
and pixel column number~$m$. (iii)~Screen coordinates, on the other hand,
have rows numbered in increasing order from top to bottom, as mentioned
above.
@^coordinates, explained@>

The program here first computes integers $m$ and $n$ such that
pixel column~$m$ of pixel row~$n$ will be at the upper left corner
of the window. Hence pixel column |m-c0| of pixel row |n+r0|
will be at the upper left corner of the screen.

@<Compute the offsets between screen coordinates and actual coordinates@>=
m=round_unscaled(x);n=round_unscaled(y)-1;@/
m_window[k]=c0-m;n_window[k]=r0+n

@ Now here comes \MF's most complicated operation related to window
display: Given the number~|k| of an open window, the pixels of positive
weight in |cur_edges| will be shown as |black| in the window; all other
pixels will be shown as |white|.

@p void disp_edges(window_number @!k)
{@+
pointer @!p, @!q; /*for list manipulation*/ 
bool @!already_there; /*is a previous incarnation in the window?*/ 
int @!r; /*row number*/ 
@<Other local variables for |disp_edges|@>@;
if (screen_OK) 
 if (left_col[k] < right_col[k]) if (top_row[k] < bot_row[k]) 
  {@+already_there=false;
  if (last_window(cur_edges)==k) 
   if (last_window_time(cur_edges)==window_time[k]) 
    already_there=true;
  if (!already_there) 
    blank_rectangle(left_col[k], right_col[k], top_row[k], bot_row[k]);
  @<Initialize for the display computations@>;
  p=link(cur_edges);r=n_window[k]-(n_min(cur_edges)-zero_field);
  while ((p!=cur_edges)&&(r >= top_row[k])) 
    {@+if (r < bot_row[k]) 
      @<Display the pixels of edge row |p| in screen row |r|@>;
    p=link(p);decr(r);
    } 
  update_screen();
  incr(window_time[k]);
  last_window(cur_edges)=k;last_window_time(cur_edges)=window_time[k];
  } 
} 

@ Since it takes some work to display a row, we try to avoid recomputation
whenever we can.

@<Display the pixels of edge row |p| in screen row |r|@>=
{@+if (unsorted(p) > empty) sort_edges(p);
else if (unsorted(p)==empty) if (already_there) goto done;
unsorted(p)=empty; /*this time we'll paint, but maybe not next time*/ 
@<Set up the parameters needed for |paint_row|; but |goto done| if no painting is
needed after all@>;
paint_row(r, b, row_transition, n);
done: ;} 

@ The transition-specification parameter to |paint_row| is always the same
array.

@<Glob...@>=
screen_col @!row_transition[2000]; /*an array of |black|/|white| transitions*/ 

@ The job remaining is to go through the list |sorted(p)|, unpacking the
|info| fields into |m| and weight, then making |black| the pixels whose
accumulated weight~|w| is positive.

@<Other local variables for |disp_edges|@>=
screen_col @!n; /*the highest active index in |row_transition|*/ 
int @!w, @!ww; /*old and new accumulated weights*/ 
pixel_color @!b; /*status of first pixel in the row transitions*/ 
int @!m, @!mm; /*old and new screen column positions*/ 
int @!d; /*edge-and-weight without |min_halfword| compensation*/ 
int @!m_adjustment; /*conversion between edge and screen coordinates*/ 
int @!right_edge; /*largest edge-and-weight that could affect the window*/ 
screen_col @!min_col; /*the smallest screen column number in the window*/ 

@ Some precomputed constants make the display calculations faster.

@<Initialize for the display computations@>=
m_adjustment=m_window[k]-m_offset(cur_edges);@/
right_edge=8*(right_col[k]-m_adjustment);@/
min_col=left_col[k]

@ @<Set up the parameters needed for |paint_row|...@>=
n=0;ww=0;m=-1;w=0;
q=sorted(p);row_transition[0]=min_col;
loop@+{@+if (q==sentinel) d=right_edge;
  else d=ho(info(q));
  mm=(d/8)+m_adjustment;
  if (mm!=m) 
    {@+@<Record a possible transition in column |m|@>;
    m=mm;w=ww;
    } 
  if (d >= right_edge) goto found;
  ww=ww+(d%8)-zero_w;
  q=link(q);
  } 
found: @<Wind up the |paint_row| parameter calculation by inserting the final transition;
|goto done| if no painting is needed@>;

@ Now |m| is a screen column | < right_col[k]|.

@<Record a possible transition in column |m|@>=
if (w <= 0) 
  {@+if (ww > 0) if (m > min_col) 
    {@+if (n==0) 
      if (already_there) 
        {@+b=white;incr(n);
        } 
      else b=black;
    else incr(n);
    row_transition[n]=m;
    } 
  } 
else if (ww <= 0) if (m > min_col) 
  {@+if (n==0) b=black;
  incr(n);row_transition[n]=m;
  } 

@ If the entire row is |white| in the window area, we can omit painting it
when |already_there| is false, since it has already been blanked out in
that case.

When the following code is invoked, |row_transition[n]| will be
strictly less than |right_col[k]|.

@<Wind up the |paint_row|...@>=
if (already_there||(ww > 0)) 
  {@+if (n==0) 
    if (ww > 0) b=black;
    else b=white;
  incr(n);row_transition[n]=right_col[k];
  } 
else if (n==0) goto done

@* Dynamic linear equations.
\MF\ users define variables implicitly by stating equations that should be
satisfied; the computer is supposed to be smart enough to solve those equations.
And indeed, the computer tries valiantly to do so, by distinguishing five
different types of numeric values:

\smallskip\hang
|type(p)==known| is the nice case, when |value(p)| is the |scaled| value
of the variable whose address is~|p|.

\smallskip\hang
|type(p)==dependent| means that |value(p)| is not present, but |dep_list(p)|
points to a {\sl dependency list\/} that expresses the value of variable~|p|
as a |scaled| number plus a sum of independent variables with |fraction|
coefficients.

\smallskip\hang
|type(p)==independent| means that |value(p)==64 s+m|, where |s > 0| is a ``serial
number'' reflecting the time this variable was first used in an equation;
also |0 <= m < 64|, and each dependent variable
that refers to this one is actually referring to the future value of
this variable times~$2^m$. (Usually |m==0|, but higher degrees of
scaling are sometimes needed to keep the coefficients in dependency lists
from getting too large. The value of~|m| will always be even.)

\smallskip\hang
|type(p)==numeric_type| means that variable |p| hasn't appeared in an
equation before, but it has been explicitly declared to be numeric.

\smallskip\hang
|type(p)==undefined| means that variable |p| hasn't appeared before.

\smallskip\noindent
We have actually discussed these five types in the reverse order of their
history during a computation: Once |known|, a variable never again
becomes |dependent|; once |dependent|, it almost never again becomes
|independent|; once |independent|, it never again becomes |numeric_type|;
and once |numeric_type|, it never again becomes |undefined| (except
of course when the user specifically decides to scrap the old value
and start again). A backward step may, however, take place: Sometimes
a |dependent| variable becomes |independent| again, when one of the
independent variables it depends on is reverting to |undefined|.

@d s_scale	64 /*the serial numbers are multiplied by this factor*/ 
@d new_indep(X)	 /*create a new independent variable*/ 
  {@+if (serial_no > el_gordo-s_scale) 
      overflow("independent variables", serial_no/s_scale);
@:METAFONT capacity exceeded independent variables}{\quad independent variables@>
  type(X)=independent;serial_no=serial_no+s_scale;
  value(X)=serial_no;
  } 

@<Glob...@>=
int @!serial_no; /*the most recent serial number, times |s_scale|*/ 

@ @<Make variable |q+s| newly independent@>=new_indep(q+s)

@ But how are dependency lists represented? It's simple: The linear combination
$\alpha_1v_1+\cdots+\alpha_kv_k+\beta$ appears in |k+1| value nodes. If
|q==dep_list(p)| points to this list, and if |k > 0|, then |value(q)==
@t$\alpha_1$@>| (which is a |fraction|); |info(q)| points to the location
of $v_1$; and |link(p)| points to the dependency list
$\alpha_2v_2+\cdots+\alpha_kv_k+\beta$. On the other hand if |k==0|,
then |value(q)==@t$\beta$@>| (which is |scaled|) and |info(q)==null|.
The independent variables $v_1$, \dots,~$v_k$ have been sorted so that
they appear in decreasing order of their |value| fields (i.e., of
their serial numbers). \ (It is convenient to use decreasing order,
since |value(null)==0|. If the independent variables were not sorted by
serial number but by some other criterion, such as their location in |mem|,
the equation-solving mechanism would be too system-dependent, because
the ordering can affect the computed results.)

The |link| field in the node that contains the constant term $\beta$ is
called the {\sl final link\/} of the dependency list. \MF\ maintains
a doubly-linked master list of all dependency lists, in terms of a permanently
allocated node
in |mem| called |dep_head|. If there are no dependencies, we have
|link(dep_head)==dep_head| and |prev_dep(dep_head)==dep_head|;
otherwise |link(dep_head)| points to the first dependent variable, say~|p|,
and |prev_dep(p)==dep_head|. We have |type(p)==dependent|, and |dep_list(p)|
points to its dependency list. If the final link of that dependency list
occurs in location~|q|, then |link(q)| points to the next dependent
variable (say~|r|); and we have |prev_dep(r)==q|, etc.

@d dep_list(X)	link(value_loc(X))
   /*half of the |value| field in a |dependent| variable*/ 
@d prev_dep(X)	info(value_loc(X))
   /*the other half; makes a doubly linked list*/ 
@d dep_node_size	2 /*the number of words per dependency node*/ 

@<Initialize table entries...@>=serial_no=0;
link(dep_head)=dep_head;prev_dep(dep_head)=dep_head;
info(dep_head)=null;dep_list(dep_head)=null;

@ Actually the description above contains a little white lie. There's
another kind of variable called |proto_dependent|, which is
just like a |dependent| one except that the $\alpha$ coefficients
in its dependency list are |scaled| instead of being fractions.
Proto-dependency lists are mixed with dependency lists in the
nodes reachable from |dep_head|.

@ Here is a procedure that prints a dependency list in symbolic form.
The second parameter should be either |dependent| or |proto_dependent|,
to indicate the scaling of the coefficients.

@<Declare subroutines for printing expressions@>=
void print_dependency(pointer @!p, small_number @!t)
{@+
int @!v; /*a coefficient*/ 
pointer @!pp, @!q; /*for list manipulation*/ 
pp=p;
loop@+{@+v=abs(value(p));q=info(p);
  if (q==null)  /*the constant term*/ 
    {@+if ((v!=0)||(p==pp)) 
      {@+if (value(p) > 0) if (p!=pp) print_char('+');
      print_scaled(value(p));
      } 
    return;
    } 
  @<Print the coefficient, unless it's $\pm1.0$@>;
  if (type(q)!=independent) confusion(@[@<|"dep"|@>@]);
@:this can't happen dep}{\quad dep@>
  print_variable_name(q);v=value(q)%s_scale;
  while (v > 0) 
    {@+print_str("*4");v=v-2;
    } 
  p=link(p);
  } 
} 

@ @<Print the coefficient, unless it's $\pm1.0$@>=
if (value(p) < 0) print_char('-');
else if (p!=pp) print_char('+');
if (t==dependent) v=round_fraction(v);
if (v!=unity) print_scaled(v)

@ The maximum absolute value of a coefficient in a given dependency list
is returned by the following simple function.

@p fraction max_coef(pointer @!p)
{@+fraction @!x; /*the maximum so far*/ 
x=0;
while (info(p)!=null) 
  {@+if (abs(value(p)) > x) x=abs(value(p));
  p=link(p);
  } 
return x;
} 

@ One of the main operations needed on dependency lists is to add a multiple
of one list to the other; we call this |p_plus_fq|, where |p| and~|q| point
to dependency lists and |f| is a fraction.

If the coefficient of any independent variable becomes |coef_bound| or
more, in absolute value, this procedure changes the type of that variable
to `|independent_needing_fix|', and sets the global variable |fix_needed|
to~|true|. The value of $|coef_bound|=\mu$ is chosen so that
$\mu^2+\mu<8$; this means that the numbers we deal with won't
get too large. (Instead of the ``optimum'' $\mu=(\sqrt{33}-1)/2\approx
2.3723$, the safer value 7/3 is taken as the threshold.)

The changes mentioned in the preceding paragraph are actually done only if
the global variable |watch_coefs| is |true|. But it usually is; in fact,
it is |false| only when \MF\ is making a dependency list that will soon
be equated to zero.

Several procedures that act on dependency lists, including |p_plus_fq|,
set the global variable |dep_final| to the final (constant term) node of
the dependency list that they produce.

@d coef_bound	04525252525 /*|fraction| approximation to 7/3*/ 
@d independent_needing_fix	0

@<Glob...@>=
bool @!fix_needed; /*does at least one |independent| variable need scaling?*/ 
bool @!watch_coefs; /*should we scale coefficients that exceed |coef_bound|?*/ 
pointer @!dep_final; /*location of the constant term and final link*/ 

@ @<Set init...@>=
fix_needed=false;watch_coefs=true;

@ The |p_plus_fq| procedure has a fourth parameter, |t|, that should be
set to |proto_dependent| if |p| is a proto-dependency list. In this
case |f| will be |scaled|, not a |fraction|. Similarly, the fifth parameter~|tt|
should be |proto_dependent| if |q| is a proto-dependency list.

List |q| is unchanged by the operation; but list |p| is totally destroyed.

The final link of the dependency list or proto-dependency list returned
by |p_plus_fq| is the same as the original final link of~|p|. Indeed, the
constant term of the result will be located in the same |mem| location
as the original constant term of~|p|.

Coefficients of the result are assumed to be zero if they are less than
a certain threshold. This compensates for inevitable rounding errors,
and tends to make more variables `|known|'. The threshold is approximately
$10^{-5}$ in the case of normal dependency lists, $10^{-4}$ for
proto-dependencies.

@d fraction_threshold	2685 /*a |fraction| coefficient less than this is zeroed*/ 
@d half_fraction_threshold	1342 /*half of |fraction_threshold|*/ 
@d scaled_threshold	8 /*a |scaled| coefficient less than this is zeroed*/ 
@d half_scaled_threshold	4 /*half of |scaled_threshold|*/ 

@<Declare basic dependency-list subroutines@>=
pointer p_plus_fq(pointer @!p, int @!f, pointer @!q,
  small_number @!t, small_number @!tt)
{@+
pointer @!pp, @!qq; /*|info(p)| and |info(q)|, respectively*/ 
pointer @!r, @!s; /*for list manipulation*/ 
int @!threshold; /*defines a neighborhood of zero*/ 
int @!v; /*temporary register*/ 
if (t==dependent) threshold=fraction_threshold;
else threshold=scaled_threshold;
r=temp_head;pp=info(p);qq=info(q);
loop@+if (pp==qq) 
    if (pp==null) goto done;
    else@<Contribute a term from |p|, plus |f| times the corresponding term from |q|@>@;
  else if (value(pp) < value(qq)) 
    @<Contribute a term from |q|, multiplied by~|f|@>@;
  else{@+link(r)=p;r=p;p=link(p);pp=info(p);
    } 
done: if (t==dependent) 
  value(p)=slow_add(value(p), take_fraction(value(q), f));
else value(p)=slow_add(value(p), take_scaled(value(q), f));
link(r)=p;dep_final=p;return link(temp_head);
} 

@ @<Contribute a term from |p|, plus |f|...@>=
{@+if (tt==dependent) v=value(p)+take_fraction(f, value(q));
else v=value(p)+take_scaled(f, value(q));
value(p)=v;s=p;p=link(p);
if (abs(v) < threshold) free_node(s, dep_node_size);
else{@+if (abs(v) >= coef_bound) if (watch_coefs) 
    {@+type(qq)=independent_needing_fix;fix_needed=true;
    } 
  link(r)=s;r=s;
  } 
pp=info(p);q=link(q);qq=info(q);
} 

@ @<Contribute a term from |q|, multiplied by~|f|@>=
{@+if (tt==dependent) v=take_fraction(f, value(q));
else v=take_scaled(f, value(q));
if (abs(v) > half(threshold)) 
  {@+s=get_node(dep_node_size);info(s)=qq;value(s)=v;
  if (abs(v) >= coef_bound) if (watch_coefs) 
    {@+type(qq)=independent_needing_fix;fix_needed=true;
    } 
  link(r)=s;r=s;
  } 
q=link(q);qq=info(q);
} 

@ It is convenient to have another subroutine for the special case
of |p_plus_fq| when |f==1.0|. In this routine lists |p| and |q| are
both of the same type~|t| (either |dependent| or |proto_dependent|).

@p pointer p_plus_q(pointer @!p, pointer @!q, small_number @!t)
{@+
pointer @!pp, @!qq; /*|info(p)| and |info(q)|, respectively*/ 
pointer @!r, @!s; /*for list manipulation*/ 
int @!threshold; /*defines a neighborhood of zero*/ 
int @!v; /*temporary register*/ 
if (t==dependent) threshold=fraction_threshold;
else threshold=scaled_threshold;
r=temp_head;pp=info(p);qq=info(q);
loop@+if (pp==qq) 
    if (pp==null) goto done;
    else@<Contribute a term from |p|, plus the corresponding term from |q|@>@;
  else if (value(pp) < value(qq)) 
    {@+s=get_node(dep_node_size);info(s)=qq;value(s)=value(q);
    q=link(q);qq=info(q);link(r)=s;r=s;
    } 
  else{@+link(r)=p;r=p;p=link(p);pp=info(p);
    } 
done: value(p)=slow_add(value(p), value(q));
link(r)=p;dep_final=p;return link(temp_head);
} 

@ @<Contribute a term from |p|, plus the...@>=
{@+v=value(p)+value(q);
value(p)=v;s=p;p=link(p);pp=info(p);
if (abs(v) < threshold) free_node(s, dep_node_size);
else{@+if (abs(v) >= coef_bound) if (watch_coefs) 
    {@+type(qq)=independent_needing_fix;fix_needed=true;
    } 
  link(r)=s;r=s;
  } 
q=link(q);qq=info(q);
} 

@ A somewhat simpler routine will multiply a dependency list
by a given constant~|v|. The constant is either a |fraction| less than
|fraction_one|, or it is |scaled|. In the latter case we might be forced to
convert a dependency list to a proto-dependency list.
Parameters |t0| and |t1| are the list types before and after;
they should agree unless |t0==dependent| and |t1==proto_dependent|
and |v_is_scaled==true|.

@p pointer p_times_v(pointer @!p, int @!v,
  small_number @!t0, small_number @!t1, bool @!v_is_scaled)
{@+pointer @!r, @!s; /*for list manipulation*/ 
int @!w; /*tentative coefficient*/ 
int @!threshold;
bool @!scaling_down;
if (t0!=t1) scaling_down=true;@+else scaling_down=!v_is_scaled;
if (t1==dependent) threshold=half_fraction_threshold;
else threshold=half_scaled_threshold;
r=temp_head;
while (info(p)!=null) 
  {@+if (scaling_down) w=take_fraction(v, value(p));
  else w=take_scaled(v, value(p));
  if (abs(w) <= threshold) 
    {@+s=link(p);free_node(p, dep_node_size);p=s;
    } 
  else{@+if (abs(w) >= coef_bound) 
      {@+fix_needed=true;type(info(p))=independent_needing_fix;
      } 
    link(r)=p;r=p;value(p)=w;p=link(p);
    } 
  } 
link(r)=p;
if (v_is_scaled) value(p)=take_scaled(value(p), v);
else value(p)=take_fraction(value(p), v);
return link(temp_head);
} 

@ Similarly, we sometimes need to divide a dependency list
by a given |scaled| constant.

@<Declare basic dependency-list subroutines@>=
pointer p_over_v(pointer @!p, scaled @!v,
  small_number @!t0, small_number @!t1)
{@+pointer @!r, @!s; /*for list manipulation*/ 
int @!w; /*tentative coefficient*/ 
int @!threshold;
bool @!scaling_down;
if (t0!=t1) scaling_down=true;@+else scaling_down=false;
if (t1==dependent) threshold=half_fraction_threshold;
else threshold=half_scaled_threshold;
r=temp_head;
while (info(p)!=null) 
  {@+if (scaling_down) 
    if (abs(v) < 02000000) w=make_scaled(value(p), v*010000);
    else w=make_scaled(round_fraction(value(p)), v);
  else w=make_scaled(value(p), v);
  if (abs(w) <= threshold) 
    {@+s=link(p);free_node(p, dep_node_size);p=s;
    } 
  else{@+if (abs(w) >= coef_bound) 
      {@+fix_needed=true;type(info(p))=independent_needing_fix;
      } 
    link(r)=p;r=p;value(p)=w;p=link(p);
    } 
  } 
link(r)=p;value(p)=make_scaled(value(p), v);
return link(temp_head);
} 

@ Here's another utility routine for dependency lists. When an independent
variable becomes dependent, we want to remove it from all existing
dependencies. The |p_with_x_becoming_q| function computes the
dependency list of~|p| after variable~|x| has been replaced by~|q|.

This procedure has basically the same calling conventions as |p_plus_fq|:
List~|q| is unchanged; list~|p| is destroyed; the constant node and the
final link are inherited from~|p|; and the fourth parameter tells whether
or not |p| is |proto_dependent|. However, the global variable |dep_final|
is not altered if |x| does not occur in list~|p|.

@p pointer p_with_x_becoming_q(pointer @!p, pointer @!x, pointer @!q, small_number @!t)
{@+pointer @!r, @!s; /*for list manipulation*/ 
int @!v; /*coefficient of |x|*/ 
int @!sx; /*serial number of |x|*/ 
s=p;r=temp_head;sx=value(x);
while (value(info(s)) > sx) 
  {@+r=s;s=link(s);
  } 
if (info(s)!=x) return p;
else{@+link(temp_head)=p;link(r)=link(s);v=value(s);
  free_node(s, dep_node_size);
  return p_plus_fq(link(temp_head), v, q, t, dependent);
  } 
} 

@ Here's a simple procedure that reports an error when a variable
has just received a known value that's out of the required range.

@<Declare basic dependency-list subroutines@>=
void val_too_big(scaled @!x)
{@+if (internal[warning_check] > 0) 
  {@+print_err("Value is too large (");print_scaled(x);print_char(')');
@.Value is too large@>
  help4("The equation I just processed has given some variable")@/
    ("a value of 4096 or more. Continue and I'll try to cope")@/
    ("with that big value; but it might be dangerous.")@/
    ("(Set warningcheck:=0 to suppress this message.)");
  error();
  } 
} 

@ When a dependent variable becomes known, the following routine
removes its dependency list. Here |p| points to the variable, and
|q| points to the dependency list (which is one node long).

@<Declare basic dependency-list subroutines@>=
void make_known(pointer @!p, pointer @!q)
{@+uint8_t @!t; /*the previous type*/ 
prev_dep(link(q))=prev_dep(p);
link(prev_dep(p))=link(q);t=type(p);
type(p)=known;value(p)=value(q);free_node(q, dep_node_size);
if (abs(value(p)) >= fraction_one) val_too_big(value(p));
if (internal[tracing_equations] > 0) if (interesting(p)) 
  {@+begin_diagnostic();print_nl("#### ");
@:]]]\#\#\#\#_}{\.{\#\#\#\#}@>
  print_variable_name(p);print_char('=');print_scaled(value(p));
  end_diagnostic(false);
  } 
if (cur_exp==p) if (cur_type==t) 
  {@+cur_type=known;cur_exp=value(p);
  free_node(p, value_node_size);
  } 
} 

@ The |fix_dependencies| routine is called into action when |fix_needed|
has been triggered. The program keeps a list~|s| of independent variables
whose coefficients must be divided by~4.

In unusual cases, this fixup process might reduce one or more coefficients
to zero, so that a variable will become known more or less by default.

@<Declare basic dependency-list subroutines@>=
void fix_dependencies(void)
{@+
pointer @!p, @!q, @!r, @!s, @!t; /*list manipulation registers*/ 
pointer @!x; /*an independent variable*/ 
r=link(dep_head);s=null;
while (r!=dep_head) 
  {@+t=r;
  @<Run through the dependency list for variable |t|, fixing all nodes, and ending
with final link~|q|@>;
  r=link(q);
  if (q==dep_list(t)) make_known(t, q);
  } 
while (s!=null) 
  {@+p=link(s);x=info(s);free_avail(s);s=p;
  type(x)=independent;value(x)=value(x)+2;
  } 
fix_needed=false;
} 

@ @d independent_being_fixed	1 /*this variable already appears in |s|*/ 

@<Run through the dependency list for variable |t|...@>=
r=value_loc(t); /*|link(r)==dep_list(t)|*/ 
loop@+{@+q=link(r);x=info(q);
  if (x==null) goto done;
  if (type(x) <= independent_being_fixed) 
    {@+if (type(x) < independent_being_fixed) 
      {@+p=get_avail();link(p)=s;s=p;
      info(s)=x;type(x)=independent_being_fixed;
      } 
    value(q)=value(q)/4;
    if (value(q)==0) 
      {@+link(r)=link(q);free_node(q, dep_node_size);q=r;
      } 
    } 
  r=q;
  } 
done: 

@ The |new_dep| routine installs a dependency list~|p| into the value node~|q|,
linking it into the list of all known dependencies. We assume that
|dep_final| points to the final node of list~|p|.

@p void new_dep(pointer @!q, pointer @!p)
{@+pointer @!r; /*what used to be the first dependency*/ 
dep_list(q)=p;prev_dep(q)=dep_head;
r=link(dep_head);link(dep_final)=r;prev_dep(r)=dep_final;
link(dep_head)=q;
} 

@ Here is one of the ways a dependency list gets started.
The |const_dependency| routine produces a list that has nothing but
a constant term.

@p pointer const_dependency(scaled @!v)
{@+dep_final=get_node(dep_node_size);
value(dep_final)=v;info(dep_final)=null;
return dep_final;
} 

@ And here's a more interesting way to start a dependency list from scratch:
The parameter to |single_dependency| is the location of an
independent variable~|x|, and the result is the simple dependency list
`|x+0|'.

In the unlikely event that the given independent variable has been doubled so
often that we can't refer to it with a nonzero coefficient,
|single_dependency| returns the simple list `0'.  This case can be
recognized by testing that the returned list pointer is equal to
|dep_final|.

@p pointer single_dependency(pointer @!p)
{@+pointer @!q; /*the new dependency list*/ 
int @!m; /*the number of doublings*/ 
m=value(p)%s_scale;
if (m > 28) return const_dependency(0);
else{@+q=get_node(dep_node_size);
  value(q)=two_to_the[28-m];info(q)=p;@/
  link(q)=const_dependency(0);return q;
  } 
} 

@ We sometimes need to make an exact copy of a dependency list.

@p pointer copy_dep_list(pointer @!p)
{@+
pointer @!q; /*the new dependency list*/ 
q=get_node(dep_node_size);dep_final=q;
loop@+{@+info(dep_final)=info(p);value(dep_final)=value(p);
  if (info(dep_final)==null) goto done;
  link(dep_final)=get_node(dep_node_size);
  dep_final=link(dep_final);p=link(p);
  } 
done: return q;
} 

@ But how do variables normally become known? Ah, now we get to the heart of the
equation-solving mechanism. The |linear_eq| procedure is given a |dependent|
or |proto_dependent| list,~|p|, in which at least one independent variable
appears. It equates this list to zero, by choosing an independent variable
with the largest coefficient and making it dependent on the others. The
newly dependent variable is eliminated from all current dependencies,
thereby possibly making other dependent variables known.

The given list |p| is, of course, totally destroyed by all this processing.

@p void linear_eq(pointer @!p, small_number @!t)
{@+pointer @!q, @!r, @!s; /*for link manipulation*/ 
pointer @!x; /*the variable that loses its independence*/ 
int @!n; /*the number of times |x| had been halved*/ 
int @!v; /*the coefficient of |x| in list |p|*/ 
pointer @!prev_r; /*lags one step behind |r|*/ 
pointer @!final_node; /*the constant term of the new dependency list*/ 
int @!w; /*a tentative coefficient*/ 
@<Find a node |q| in list |p| whose coefficient |v| is largest@>;
x=info(q);n=value(x)%s_scale;@/
@<Divide list |p| by |-v|, removing node |q|@>;
if (internal[tracing_equations] > 0) @<Display the new dependency@>;
@<Simplify all existing dependencies by substituting for |x|@>;
@<Change variable |x| from |independent| to |dependent| or |known|@>;
if (fix_needed) fix_dependencies();
} 

@ @<Find a node |q| in list |p| whose coefficient |v| is largest@>=
q=p;r=link(p);v=value(q);
while (info(r)!=null) 
  {@+if (abs(value(r)) > abs(v)) 
    {@+q=r;v=value(r);
    } 
  r=link(r);
  } 

@ Here we want to change the coefficients from |scaled| to |fraction|,
except in the constant term. In the common case of a trivial equation
like `\.{x=3.14}', we will have |v==-fraction_one|, |q==p|, and |t==dependent|.

@<Divide list |p| by |-v|, removing node |q|@>=
s=temp_head;link(s)=p;r=p;
@/do@+{if (r==q) 
  {@+link(s)=link(r);free_node(r, dep_node_size);
  } 
else{@+w=make_fraction(value(r), v);
  if (abs(w) <= half_fraction_threshold) 
    {@+link(s)=link(r);free_node(r, dep_node_size);
    } 
  else{@+value(r)=-w;s=r;
    } 
  } 
r=link(s);
}@+ while (!(info(r)==null));
if (t==proto_dependent) value(r)=-make_scaled(value(r), v);
else if (v!=-fraction_one) value(r)=-make_fraction(value(r), v);
final_node=r;p=link(temp_head)

@ @<Display the new dependency@>=
if (interesting(x)) 
  {@+begin_diagnostic();print_nl("## ");print_variable_name(x);
@:]]]\#\#_}{\.{\#\#}@>
  w=n;
  while (w > 0) 
    {@+print_str("*4");w=w-2;
    } 
  print_char('=');print_dependency(p, dependent);end_diagnostic(false);
  } 

@ @<Simplify all existing dependencies by substituting for |x|@>=
prev_r=dep_head;r=link(dep_head);
while (r!=dep_head) 
  {@+s=dep_list(r);q=p_with_x_becoming_q(s, x, p, type(r));
  if (info(q)==null) make_known(r, q);
  else{@+dep_list(r)=q;
    @/do@+{q=link(q);
    }@+ while (!(info(q)==null));
    prev_r=q;
    } 
  r=link(prev_r);
  } 

@ @<Change variable |x| from |independent| to |dependent| or |known|@>=
if (n > 0) @<Divide list |p| by $2^n$@>;
if (info(p)==null) 
  {@+type(x)=known;
  value(x)=value(p);
  if (abs(value(x)) >= fraction_one) val_too_big(value(x));
  free_node(p, dep_node_size);
  if (cur_exp==x) if (cur_type==independent) 
    {@+cur_exp=value(x);cur_type=known;
    free_node(x, value_node_size);
    } 
  } 
else{@+type(x)=dependent;dep_final=final_node;new_dep(x, p);
  if (cur_exp==x) if (cur_type==independent) cur_type=dependent;
  } 

@ @<Divide list |p| by $2^n$@>=
{@+s=temp_head;link(temp_head)=p;r=p;
@/do@+{if (n > 30) w=0;
else w=value(r)/two_to_the[n];
if ((abs(w) <= half_fraction_threshold)&&(info(r)!=null)) 
  {@+link(s)=link(r);
  free_node(r, dep_node_size);
  } 
else{@+value(r)=w;s=r;
  } 
r=link(s);
}@+ while (!(info(s)==null));
p=link(temp_head);
} 

@ The |check_mem| procedure, which is used only when \MF\ is being
debugged, makes sure that the current dependency lists are well formed.

@<Check the list of linear dependencies@>=
q=dep_head;p=link(q);
while (p!=dep_head) 
  {@+if (prev_dep(p)!=q) 
    {@+print_nl("Bad PREVDEP at ");print_int(p);
@.Bad PREVDEP...@>
    } 
  p=dep_list(p);r=inf_val;
  @/do@+{if (value(info(p)) >= value(r)) 
    {@+print_nl("Out of order at ");print_int(p);
@.Out of order...@>
    } 
  r=info(p);q=p;p=link(q);
  }@+ while (!(r==null));
  } 

@* Dynamic nonlinear equations.
Variables of numeric type are maintained by the general scheme of
independent, dependent, and known values that we have just studied;
and the components of pair and transform variables are handled in the
same way. But \MF\ also has five other types of values: \&{boolean},
\&{string}, \&{pen}, \&{path}, and \&{picture}; what about them?

Equations are allowed between nonlinear quantities, but only in a
simple form. Two variables that haven't yet been assigned values are
either equal to each other, or they're not.

Before a boolean variable has received a value, its type is |unknown_boolean|;
similarly, there are variables whose type is |unknown_string|, |unknown_pen|,
|unknown_path|, and |unknown_picture|. In such cases the value is either
|null| (which means that no other variables are equivalent to this one), or
it points to another variable of the same undefined type. The pointers in the
latter case form a cycle of nodes, which we shall call a ``ring.''
Rings of undefined variables may include capsules, which arise as
intermediate results within expressions or as \&{expr} parameters to macros.

When one member of a ring receives a value, the same value is given to
all the other members. In the case of paths and pictures, this implies
making separate copies of a potentially large data structure; users should
restrain their enthusiasm for such generality, unless they have lots and
lots of memory space.

@ The following procedure is called when a capsule node is being
added to a ring (e.g., when an unknown variable is mentioned in an expression).

@p pointer new_ring_entry(pointer @!p)
{@+pointer q; /*the new capsule node*/ 
q=get_node(value_node_size);name_type(q)=capsule;
type(q)=type(p);
if (value(p)==null) value(q)=p;@+else value(q)=value(p);
value(p)=q;
return q;
} 

@ Conversely, we might delete a capsule or a variable before it becomes known.
The following procedure simply detaches a quantity from its ring,
without recycling the storage.

@<Declare the recycling subroutines@>=
void ring_delete(pointer @!p)
{@+pointer @!q;
q=value(p);
if (q!=null) if (q!=p) 
  {@+while (value(q)!=p) q=value(q);
  value(q)=value(p);
  } 
} 

@ Eventually there might be an equation that assigns values to all of the
variables in a ring. The |nonlinear_eq| subroutine does the necessary
propagation of values.

If the parameter |flush_p| is |true|, node |p| itself needn't receive a
value; it will soon be recycled.

@p void nonlinear_eq(int @!v, pointer @!p, bool @!flush_p)
{@+small_number @!t; /*the type of ring |p|*/ 
pointer @!q, @!r; /*link manipulation registers*/ 
t=type(p)-unknown_tag;q=value(p);
if (flush_p) type(p)=vacuous;@+else p=q;
@/do@+{r=value(q);type(q)=t;
switch (t) {
case boolean_type: value(q)=v;@+break;
case string_type: {@+value(q)=v;add_str_ref(v);
  } @+break;
case pen_type: {@+value(q)=v;add_pen_ref(v);
  } @+break;
case path_type: value(q)=copy_path(v);@+break;
case picture_type: value(q)=copy_edges(v);
}  /*there ain't no more cases*/ 
q=r;
}@+ while (!(q==p));
} 

@ If two members of rings are equated, and if they have the same type,
the |ring_merge| procedure is called on to make them equivalent.

@p void ring_merge(pointer @!p, pointer @!q)
{@+
pointer @!r; /*traverses one list*/ 
r=value(p);
while (r!=p) 
  {@+if (r==q) 
    {@+@<Exclaim about a redundant equation@>;
    return;
    } 
  r=value(r);
  } 
r=value(p);value(p)=value(q);value(q)=r;
} 

@ @<Exclaim about a redundant equation@>=
{@+print_err("Redundant equation");@/
@.Redundant equation@>
help2("I already knew that this equation was true.")@/
  ("But perhaps no harm has been done; let's continue.");@/
put_get_error();
} 

@* Introduction to the syntactic routines.
Let's pause a moment now and try to look at the Big Picture.
The \MF\ program consists of three main parts: syntactic routines,
semantic routines, and output routines. The chief purpose of the
syntactic routines is to deliver the user's input to the semantic routines,
while parsing expressions and locating operators and operands. The
semantic routines act as an interpreter responding to these operators,
which may be regarded as commands. And the output routines are
periodically called on to produce compact font descriptions that can be
used for typesetting or for making interim proof drawings. We have
discussed the basic data structures and many of the details of semantic
operations, so we are good and ready to plunge into the part of \MF\ that
actually controls the activities.

Our current goal is to come to grips with the |get_next| procedure,
which is the keystone of \MF's input mechanism. Each call of |get_next|
sets the value of three variables |cur_cmd|, |cur_mod|, and |cur_sym|,
representing the next input token.
$$\vbox{\halign{#\hfil\cr
  \hbox{|cur_cmd| denotes a command code from the long list of codes
   given earlier;}\cr
  \hbox{|cur_mod| denotes a modifier of the command code;}\cr
  \hbox{|cur_sym| is the hash address of the symbolic token that was
   just scanned,}\cr
  \hbox{\qquad or zero in the case of a numeric or string
   or capsule token.}\cr}}$$
Underlying this external behavior of |get_next| is all the machinery
necessary to convert from character files to tokens. At a given time we
may be only partially finished with the reading of several files (for
which \&{input} was specified), and partially finished with the expansion
of some user-defined macros and/or some macro parameters, and partially
finished reading some text that the user has inserted online,
and so on. When reading a character file, the characters must be
converted to tokens; comments and blank spaces must
be removed, numeric and string tokens must be evaluated.

To handle these situations, which might all be present simultaneously,
\MF\ uses various stacks that hold information about the incomplete
activities, and there is a finite state control for each level of the
input mechanism. These stacks record the current state of an implicitly
recursive process, but the |get_next| procedure is not recursive.

@<Glob...@>=
eight_bits @!cur_cmd; /*current command set by |get_next|*/ 
int @!cur_mod; /*operand of current command*/ 
halfword @!cur_sym; /*hash address of current symbol*/ 

@ The |print_cmd_mod| routine prints a symbolic interpretation of a
command code and its modifier.
It consists of a rather tedious sequence of print
commands, and most of it is essentially an inverse to the |primitive|
routine that enters a \MF\ primitive into |hash| and |eqtb|. Therefore almost
all of this procedure appears elsewhere in the program, together with the
corresponding |primitive| calls.

@<Declare the procedure called |print_cmd_mod|@>=
void print_cmd_mod(int @!c, int @!m)
{@+switch (c) {
@t\4@>@<Cases of |print_cmd_mod| for symbolic printing of primitives@>@;
default:print_str("[unknown command code!]");
} 
} 

@ Here is a procedure that displays a given command in braces, in the
user's transcript file.

@d show_cur_cmd_mod	show_cmd_mod(cur_cmd, cur_mod)

@p void show_cmd_mod(int @!c, int @!m)
{@+begin_diagnostic();print_nl("{");
print_cmd_mod(c, m);print_char('}');
end_diagnostic(false);
} 

@* Input stacks and states.
The state of \MF's input mechanism appears in the input stack, whose
entries are records with five fields, called |index|, |start|, |loc|,
|limit|, and |name|. The top element of this stack is maintained in a
global variable for which no subscripting needs to be done; the other
elements of the stack appear in an array. Hence the stack is declared thus:

@<Types...@>=
typedef struct { 
  quarterword @!index_field;
  halfword @!start_field, @!loc_field, @!limit_field, @!name_field;
  } in_state_record;

@ @<Glob...@>=
in_state_record @!input_stack[stack_size+1];
uint8_t @!input_ptr; /*first unused location of |input_stack|*/ 
uint8_t @!max_in_stack; /*largest value of |input_ptr| when pushing*/ 
in_state_record @!cur_input; /*the ``top'' input state*/ 

@ We've already defined the special variable |@!loc====cur_input.loc_field|
in our discussion of basic input-output routines. The other components of
|cur_input| are defined in the same way:

@d index	cur_input.index_field /*reference for buffer information*/ 
@d start	cur_input.start_field /*starting position in |buffer|*/ 
@d limit	cur_input.limit_field /*end of current line in |buffer|*/ 
@d name	cur_input.name_field /*name of the current file*/ 

@ Let's look more closely now at the five control variables
(|index|,~|start|,~|loc|,~|limit|,~|name|),
assuming that \MF\ is reading a line of characters that have been input
from some file or from the user's terminal. There is an array called
|buffer| that acts as a stack of all lines of characters that are
currently being read from files, including all lines on subsidiary
levels of the input stack that are not yet completed. \MF\ will return to
the other lines when it is finished with the present input file.

(Incidentally, on a machine with byte-oriented addressing, it would be
appropriate to combine |buffer| with the |str_pool| array,
letting the buffer entries grow downward from the top of the string pool
and checking that these two tables don't bump into each other.)

The line we are currently working on begins in position |start| of the
buffer; the next character we are about to read is |buffer[loc]|; and
|limit| is the location of the last character present. We always have
|loc <= limit|. For convenience, |buffer[limit]| has been set to |'%'|, so
that the end of a line is easily sensed.

The |name| variable is a string number that designates the name of
the current file, if we are reading a text file. It is 0 if we
are reading from the terminal for normal input, or 1 if we are executing a
\&{readstring} command, or 2 if we are reading a string that was
moved into the buffer by \&{scantokens}.

@ Additional information about the current line is available via the
|index| variable, which counts how many lines of characters are present
in the buffer below the current level. We have |index==0| when reading
from the terminal and prompting the user for each line; then if the user types,
e.g., `\.{input font}', we will have |index==1| while reading
the file \.{font.mf}. However, it does not follow that |index| is the
same as the input stack pointer, since many of the levels on the input
stack may come from token lists.

The global variable |in_open| is equal to the |index|
value of the highest non-token-list level. Thus, the number of partially read
lines in the buffer is |in_open+1|, and we have |in_open==index|
when we are not reading a token list.

If we are not currently reading from the terminal,
we are reading from the file variable |input_file[index]|. We use
the notation |terminal_input| as a convenient abbreviation for |name==0|,
and |cur_file| as an abbreviation for |input_file[index]|.

The global variable |line| contains the line number in the topmost
open file, for use in error messages. If we are not reading from
the terminal, |line_stack[index]| holds the line number for the
enclosing level, so that |line| can be restored when the current
file has been read.

If more information about the input state is needed, it can be
included in small arrays like those shown here. For example,
the current page or segment number in the input file might be
put into a variable |@!page|, maintained for enclosing levels in
`\ignorespaces|@!page_stack: array[1 dotdot max_in_open]int|\unskip'
by analogy with |line_stack|.
@^system dependencies@>

@d terminal_input	(name==0) /*are we reading from the terminal?*/ 
@d cur_file	input_file[index] /*the current |alpha_file| variable*/ 

@<Glob...@>=
uint8_t @!in_open; /*the number of lines in the buffer, less one*/ 
uint8_t @!open_parens; /*the number of open text files*/ 
alpha_file @!input_file0[max_in_open], *const @!input_file = @!input_file0-1;
int @!line; /*current line number in the current source file*/ 
int @!line_stack0[max_in_open], *const @!line_stack = @!line_stack0-1;

@ However, all this discussion about input state really applies only to the
case that we are inputting from a file. There is another important case,
namely when we are currently getting input from a token list. In this case
|index > max_in_open|, and the conventions about the other state variables
are different:

\yskip\hang|loc| is a pointer to the current node in the token list, i.e.,
the node that will be read next. If |loc==null|, the token list has been
fully read.

\yskip\hang|start| points to the first node of the token list; this node
may or may not contain a reference count, depending on the type of token
list involved.

\yskip\hang|token_type|, which takes the place of |index| in the
discussion above, is a code number that explains what kind of token list
is being scanned.

\yskip\hang|name| points to the |eqtb| address of the control sequence
being expanded, if the current token list is a macro not defined by
\&{vardef}. Macros defined by \&{vardef} have |name==null|; their name
can be deduced by looking at their first two parameters.

\yskip\hang|param_start|, which takes the place of |limit|, tells where
the parameters of the current macro or loop text begin in the |param_stack|.

\yskip\noindent The |token_type| can take several values, depending on
where the current token list came from:

\yskip
\indent|forever_text|, if the token list being scanned is the body of
a \&{forever} loop;

\indent|loop_text|, if the token list being scanned is the body of
a \&{for} or \&{forsuffixes} loop;

\indent|parameter|, if a \&{text} or \&{suffix} parameter is being scanned;

\indent|backed_up|, if the token list being scanned has been inserted as
`to be read again'.

\indent|inserted|, if the token list being scanned has been inserted as
part of error recovery;

\indent|macro|, if the expansion of a user-defined symbolic token is being
scanned.

\yskip\noindent
The token list begins with a reference count if and only if |token_type==
macro|.
@^reference counts@>

@d token_type	index /*type of current token list*/ 
@d token_state	(index > max_in_open) /*are we scanning a token list?*/ 
@d file_state	(index <= max_in_open) /*are we scanning a file line?*/ 
@d param_start	limit /*base of macro parameters in |param_stack|*/ 
@d forever_text	(max_in_open+1) /*|token_type| code for loop texts*/ 
@d loop_text	(max_in_open+2) /*|token_type| code for loop texts*/ 
@d parameter	(max_in_open+3) /*|token_type| code for parameter texts*/ 
@d backed_up	(max_in_open+4) /*|token_type| code for texts to be reread*/ 
@d inserted	(max_in_open+5) /*|token_type| code for inserted texts*/ 
@d macro	(max_in_open+6) /*|token_type| code for macro replacement texts*/ 

@ The |param_stack| is an auxiliary array used to hold pointers to the token
lists for parameters at the current level and subsidiary levels of input.
This stack grows at a different rate from the others.

@<Glob...@>=
pointer @!param_stack[param_size+1];
   /*token list pointers for parameters*/ 
uint8_t @!param_ptr; /*first unused entry in |param_stack|*/ 
int @!max_param_stack;
   /*largest value of |param_ptr|*/ 

@ Thus, the ``current input state'' can be very complicated indeed; there
can be many levels and each level can arise in a variety of ways. The
|show_context| procedure, which is used by \MF's error-reporting routine to
print out the current input state on all levels down to the most recent
line of characters from an input file, illustrates most of these conventions.
The global variable |file_ptr| contains the lowest level that was
displayed by this procedure.

@<Glob...@>=
uint8_t @!file_ptr; /*shallowest level shown by |show_context|*/ 

@ The status at each level is indicated by printing two lines, where the first
line indicates what was read so far and the second line shows what remains
to be read. The context is cropped, if necessary, so that the first line
contains at most |half_error_line| characters, and the second contains
at most |error_line|. Non-current input levels whose |token_type| is
`|backed_up|' are shown only if they have not been fully read.

@p void show_context(void) /*prints where the scanner is*/ 
{@+
uint8_t @!old_setting; /*saved |selector| setting*/ 
@<Local variables for formatting calculations@>@;
file_ptr=input_ptr;input_stack[file_ptr]=cur_input;
   /*store current state*/ 
loop@+{@+cur_input=input_stack[file_ptr]; /*enter into the context*/ 
  @<Display the current context@>;
  if (file_state) 
    if ((name > 2)||(file_ptr==0)) goto done;
  decr(file_ptr);
  } 
done: cur_input=input_stack[input_ptr]; /*restore original state*/ 
} 

@ @<Display the current context@>=
if ((file_ptr==input_ptr)||file_state||
   (token_type!=backed_up)||(loc!=null)) 
     /*we omit backed-up token lists that have already been read*/ 
  {@+tally=0; /*get ready to count characters*/ 
  old_setting=selector;
  if (file_state) 
    {@+@<Print location of current line@>;
    @<Pseudoprint the line@>;
    } 
  else{@+@<Print type of token list@>;
    @<Pseudoprint the token list@>;
    } 
  selector=old_setting; /*stop pseudoprinting*/ 
  @<Print two lines using the tricky pseudoprinted information@>;
  } 

@ This routine should be changed, if necessary, to give the best possible
indication of where the current line resides in the input file.
For example, on some systems it is best to print both a page and line number.
@^system dependencies@>

@<Print location of current line@>=
if (name <= 1) 
  if (terminal_input&&(file_ptr==0)) print_nl("<*>");
  else print_nl("<insert>");
else if (name==2) print_nl("<scantokens>");
else{@+print_nl("l.");print_int(line);
  } 
print_char(' ')

@ @<Print type of token list@>=
switch (token_type) {
case forever_text: print_nl("<forever> ");@+break;
case loop_text: @<Print the current loop value@>@;@+break;
case parameter: print_nl("<argument> ");@+break;
case backed_up: if (loc==null) print_nl("<recently read> ");
  else print_nl("<to be read again> ");@+break;
case inserted: print_nl("<inserted text> ");@+break;
case macro: {@+print_ln();
  if (name!=null) slow_print(text(name));
  else@<Print the name of a \&{vardef}'d macro@>;
  print_str("->");
  } @+break;
default:print_nl("?"); /*this should never happen*/ 
@.?\relax@>
} 

@ The parameter that corresponds to a loop text is either a token list
(in the case of \&{forsuffixes}) or a ``capsule'' (in the case of \&{for}).
We'll discuss capsules later; for now, all we need to know is that
the |link| field in a capsule parameter is |empty| and that
|print_exp(p, 0)| displays the value of capsule~|p| in abbreviated form.

@<Print the current loop value@>=
{@+print_nl("<for(");p=param_stack[param_start];
if (p!=null) 
  if (link(p)==empty) print_exp(p, 0); /*we're in a \&{for} loop*/ 
  else show_token_list(p, null, 20, tally);
print_str(")> ");
} 

@ The first two parameters of a macro defined by \&{vardef} will be token
lists representing the macro's prefix and ``at point.'' By putting these
together, we get the macro's full name.

@<Print the name of a \&{vardef}'d macro@>=
{@+p=param_stack[param_start];
if (p==null) show_token_list(param_stack[param_start+1], null, 20, tally);
else{@+q=p;
  while (link(q)!=null) q=link(q);
  link(q)=param_stack[param_start+1];
  show_token_list(p, null, 20, tally);
  link(q)=null;
  } 
} 

@ Now it is necessary to explain a little trick. We don't want to store a long
string that corresponds to a token list, because that string might take up
lots of memory; and we are printing during a time when an error message is
being given, so we dare not do anything that might overflow one of \MF's
tables. So `pseudoprinting' is the answer: We enter a mode of printing
that stores characters into a buffer of length |error_line|, where character
$k+1$ is placed into \hbox{|trick_buf[k%error_line]|} if
|k < trick_count|, otherwise character |k| is dropped. Initially we set
|tally=0| and |trick_count=1000000|; then when we reach the
point where transition from line 1 to line 2 should occur, we
set |first_count=tally| and |trick_count=@tmax@>(error_line,
tally+1+error_line-half_error_line)|. At the end of the
pseudoprinting, the values of |first_count|, |tally|, and
|trick_count| give us all the information we need to print the two lines,
and all of the necessary text is in |trick_buf|.

Namely, let |l| be the length of the descriptive information that appears
on the first line. The length of the context information gathered for that
line is |k==first_count|, and the length of the context information
gathered for line~2 is $m=\min(|tally|, |trick_count|)-k$. If |l+k <= h|,
where |h==half_error_line|, we print |trick_buf[0 dotdot k-1]| after the
descriptive information on line~1, and set |n=l+k|; here |n| is the
length of line~1. If $l+k>h$, some cropping is necessary, so we set |n=h|
and print `\.{...}' followed by
$$\hbox{|trick_buf[(l+k-h+3)dotdot k-1]|,}$$
where subscripts of |trick_buf| are circular modulo |error_line|. The
second line consists of |n|~spaces followed by |trick_buf[k dotdot(k+m-1)]|,
unless |n+m > error_line|; in the latter case, further cropping is done.
This is easier to program than to explain.

@<Local variables for formatting...@>=
int @!i; /*index into |buffer|*/ 
int @!l; /*length of descriptive information on line 1*/ 
int @!m; /*context information gathered for line 2*/ 
uint8_t @!n; /*length of line 1*/ 
int @!p; /*starting or ending place in |trick_buf|*/ 
int @!q; /*temporary index*/ 

@ The following code tells the print routines to gather
the desired information.

@d begin_pseudoprint	
  {@+l=tally;tally=0;selector=pseudo;
  trick_count=1000000;
  } 
@d set_trick_count	
  {@+first_count=tally;
  trick_count=tally+1+error_line-half_error_line;
  if (trick_count < error_line) trick_count=error_line;
  } 

@ And the following code uses the information after it has been gathered.

@<Print two lines using the tricky pseudoprinted information@>=
if (trick_count==1000000) set_trick_count;
   /*|set_trick_count| must be performed*/ 
if (tally < trick_count) m=tally-first_count;
else m=trick_count-first_count; /*context on line 2*/ 
if (l+first_count <= half_error_line) 
  {@+p=0;n=l+first_count;
  } 
else{@+print_str("...");p=l+first_count-half_error_line+3;
  n=half_error_line;
  } 
for (q=p; q<=first_count-1; q++) print_char(trick_buf[q%error_line]);
print_ln();
for (q=1; q<=n; q++) print_char(' '); /*print |n| spaces to begin line~2*/ 
if (m+n <= error_line) p=first_count+m;else p=first_count+(error_line-n-3);
for (q=first_count; q<=p-1; q++) print_char(trick_buf[q%error_line]);
if (m+n > error_line) print_str("...")

@ But the trick is distracting us from our current goal, which is to
understand the input state. So let's concentrate on the data structures that
are being pseudoprinted as we finish up the |show_context| procedure.

@<Pseudoprint the line@>=
begin_pseudoprint;
if (limit > 0) for (i=start; i<=limit-1; i++) 
  {@+if (i==loc) set_trick_count;
  print(buffer[i]);
  } 

@ @<Pseudoprint the token list@>=
begin_pseudoprint;
if (token_type!=macro) show_token_list(start, loc, 100000, 0);
else show_macro(start, loc, 100000)

@ Here is the missing piece of |show_token_list| that is activated when the
token beginning line~2 is about to be shown:

@<Do magic computation@>=set_trick_count

@* Maintaining the input stacks.
The following subroutines change the input status in commonly needed ways.

First comes |push_input|, which stores the current state and creates a
new level (having, initially, the same properties as the old).

@d push_input	@t@> /*enter a new input level, save the old*/ 
  {@+if (input_ptr > max_in_stack) 
    {@+max_in_stack=input_ptr;
    if (input_ptr==stack_size) overflow("input stack size", stack_size);
@:METAFONT capacity exceeded input stack size}{\quad input stack size@>
    } 
  input_stack[input_ptr]=cur_input; /*stack the record*/ 
  incr(input_ptr);
  } 

@ And of course what goes up must come down.

@d pop_input	@t@> /*leave an input level, re-enter the old*/ 
  {@+decr(input_ptr);cur_input=input_stack[input_ptr];
  } 

@ Here is a procedure that starts a new level of token-list input, given
a token list |p| and its type |t|. If |t==macro|, the calling routine should
set |name|, reset~|loc|, and increase the macro's reference count.

@d back_list(X)	begin_token_list(X, backed_up) /*backs up a simple token list*/ 

@p void begin_token_list(pointer @!p, quarterword @!t)
{@+push_input;start=p;token_type=t;
param_start=param_ptr;loc=p;
} 

@ When a token list has been fully scanned, the following computations
should be done as we leave that level of input.
@^inner loop@>

@p void end_token_list(void) /*leave a token-list input level*/ 
{@+
pointer @!p; /*temporary register*/ 
if (token_type >= backed_up)  /*token list to be deleted*/ 
  if (token_type <= inserted) 
    {@+flush_token_list(start);goto done;
    } 
  else delete_mac_ref(start); /*update reference count*/ 
while (param_ptr > param_start)  /*parameters must be flushed*/ 
  {@+decr(param_ptr);
  p=param_stack[param_ptr];
  if (p!=null) 
    if (link(p)==empty)  /*it's an \&{expr} parameter*/ 
      {@+recycle_value(p);free_node(p, value_node_size);
      } 
    else flush_token_list(p); /*it's a \&{suffix} or \&{text} parameter*/ 
  } 
done: pop_input;check_interrupt;
} 

@ The contents of |cur_cmd, cur_mod, cur_sym| are placed into an equivalent
token by the |cur_tok| routine.
@^inner loop@>

@p@t\4@>@<Declare the procedure called |make_exp_copy|@>@;@/
pointer cur_tok(void)
{@+pointer @!p; /*a new token node*/ 
small_number @!save_type; /*|cur_type| to be restored*/ 
int @!save_exp; /*|cur_exp| to be restored*/ 
if (cur_sym==0) 
  if (cur_cmd==capsule_token) 
    {@+save_type=cur_type;save_exp=cur_exp;
    make_exp_copy(cur_mod);p=stash_cur_exp();link(p)=null;
    cur_type=save_type;cur_exp=save_exp;
    } 
  else{@+p=get_node(token_node_size);
    value(p)=cur_mod;name_type(p)=token;
    if (cur_cmd==numeric_token) type(p)=known;
    else type(p)=string_type;
    } 
else{@+fast_get_avail(p);info(p)=cur_sym;
  } 
return p;
} 

@ Sometimes \MF\ has read too far and wants to ``unscan'' what it has
seen. The |back_input| procedure takes care of this by putting the token
just scanned back into the input stream, ready to be read again.
If |cur_sym!=0|, the values of |cur_cmd| and |cur_mod| are irrelevant.

@p void back_input(void) /*undoes one token of input*/ 
{@+pointer @!p; /*a token list of length one*/ 
p=cur_tok();
while (token_state&&(loc==null)) end_token_list(); /*conserve stack space*/ 
back_list(p);
} 

@ The |back_error| routine is used when we want to restore or replace an
offending token just before issuing an error message.  We disable interrupts
during the call of |back_input| so that the help message won't be lost.

@p void back_error(void) /*back up one token and call |error|*/ 
{@+OK_to_interrupt=false;back_input();OK_to_interrupt=true;error();
} 
@#
void ins_error(void) /*back up one inserted token and call |error|*/ 
{@+OK_to_interrupt=false;back_input();token_type=inserted;
OK_to_interrupt=true;error();
} 

@ The |begin_file_reading| procedure starts a new level of input for lines
of characters to be read from a file, or as an insertion from the
terminal. It does not take care of opening the file, nor does it set |loc|
or |limit| or |line|.
@^system dependencies@>

@p void begin_file_reading(void)
{@+if (in_open==max_in_open) overflow("text input levels", max_in_open);
@:METAFONT capacity exceeded text input levels}{\quad text input levels@>
if (first==buf_size) overflow("buffer size", buf_size);
@:METAFONT capacity exceeded buffer size}{\quad buffer size@>
incr(in_open);push_input;index=in_open;
line_stack[index]=line;start=first;
name=0; /*|terminal_input| is now |true|*/ 
} 

@ Conversely, the variables must be downdated when such a level of input
is finished:

@p void end_file_reading(void)
{@+first=start;line=line_stack[index];
if (index!=in_open) confusion(@[@<|"endinput"|@>@]);
@:this can't happen endinput}{\quad endinput@>
if (name > 2) a_close(&cur_file); /*forget it*/ 
pop_input;decr(in_open);
} 

@ In order to keep the stack from overflowing during a long sequence of
inserted `\.{show}' commands, the following routine removes completed
error-inserted lines from memory.

@p void clear_for_error_prompt(void)
{@+while (file_state&&terminal_input&&@|
  (input_ptr > 0)&&(loc==limit)) end_file_reading();
print_ln();clear_terminal;
} 

@ To get \MF's whole input mechanism going, we perform the following
actions.

@<Initialize the input routines@>=
{@+input_ptr=0;max_in_stack=0;
in_open=0;open_parens=0;max_buf_stack=0;
param_ptr=0;max_param_stack=0;
first=1;
start=1;index=0;line=0;name=0;
force_eof=false;
if (!init_terminal()) exit(0);
limit=last;first=last+1; /*|init_terminal| has set |loc| and |last|*/ 
} 

@* Getting the next token.
The heart of \MF's input mechanism is the |get_next| procedure, which
we shall develop in the next few sections of the program. Perhaps we
shouldn't actually call it the ``heart,'' however; it really acts as \MF's
eyes and mouth, reading the source files and gobbling them up. And it also
helps \MF\ to regurgitate stored token lists that are to be processed again.

The main duty of |get_next| is to input one token and to set |cur_cmd|
and |cur_mod| to that token's command code and modifier. Furthermore, if
the input token is a symbolic token, that token's |hash| address
is stored in |cur_sym|; otherwise |cur_sym| is set to zero.

Underlying this simple description is a certain amount of complexity
because of all the cases that need to be handled.
However, the inner loop of |get_next| is reasonably short and fast.

@ Before getting into |get_next|, we need to consider a mechanism by which
\MF\ helps keep errors from propagating too far. Whenever the program goes
into a mode where it keeps calling |get_next| repeatedly until a certain
condition is met, it sets |scanner_status| to some value other than |normal|.
Then if an input file ends, or if an `\&{outer}' symbol appears,
an appropriate error recovery will be possible.

The global variable |warning_info| helps in this error recovery by providing
additional information. For example, |warning_info| might indicate the
name of a macro whose replacement text is being scanned.

@d normal	0 /*|scanner_status| at ``quiet times''*/ 
@d skipping	1 /*|scanner_status| when false conditional text is being skipped*/ 
@d flushing	2 /*|scanner_status| when junk after a statement is being ignored*/ 
@d absorbing	3 /*|scanner_status| when a \&{text} parameter is being scanned*/ 
@d var_defining	4 /*|scanner_status| when a \&{vardef} is being scanned*/ 
@d op_defining	5 /*|scanner_status| when a macro \&{def} is being scanned*/ 
@d loop_defining	6 /*|scanner_status| when a \&{for} loop is being scanned*/ 

@<Glob...@>=
uint8_t @!scanner_status; /*are we scanning at high speed?*/ 
int @!warning_info; /*if so, what else do we need to know,
    in case an error occurs?*/ 

@ @<Initialize the input routines@>=
scanner_status=normal;

@ The following subroutine
is called when an `\&{outer}' symbolic token has been scanned or
when the end of a file has been reached. These two cases are distinguished
by |cur_sym|, which is zero at the end of a file.

@p bool check_outer_validity(void)
{@+pointer @!p; /*points to inserted token list*/ 
if (scanner_status==normal) return true;
else{@+deletions_allowed=false;
  @<Back up an outer symbolic token so that it can be reread@>;
  if (scanner_status > skipping) 
    @<Tell the user what has run away and try to recover@>@;
  else{@+print_err("Incomplete if; all text was ignored after line ");
@.Incomplete if...@>
    print_int(warning_info);@/
    help3("A forbidden `outer' token occurred in skipped text.")@/
    ("This kind of error happens when you say `if...' and forget")@/
    ("the matching `fi'. I've inserted a `fi'; this might work.");
    if (cur_sym==0) help_line[2]=@|
      "The file ended while I was skipping conditional text.";
    cur_sym=frozen_fi;ins_error();
    } 
  deletions_allowed=true;return false;
  } 
} 

@ @<Back up an outer symbolic token so that it can be reread@>=
if (cur_sym!=0) 
  {@+p=get_avail();info(p)=cur_sym;
  back_list(p); /*prepare to read the symbolic token again*/ 
  } 

@ @<Tell the user what has run away...@>=
{@+runaway(); /*print the definition-so-far*/ 
if (cur_sym==0) print_err("File ended")@;
@.File ended while scanning...@>
else{@+print_err("Forbidden token found");
@.Forbidden token found...@>
  } 
print_str(" while scanning ");
help4("I suspect you have forgotten an `enddef',")@/
("causing me to read past where you wanted me to stop.")@/
("I'll try to recover; but if the error is serious,")@/
("you'd better type `E' or `X' now and fix your file.");@/
switch (scanner_status) {
@t\4@>@<Complete the error message, and set |cur_sym| to a token that might help recover
from the error@>@;
}  /*there are no other cases*/ 
ins_error();
} 

@ As we consider various kinds of errors, it is also appropriate to
change the first line of the help message just given; |help_line[3]|
points to the string that might be changed.

@<Complete the error message,...@>=
case flushing: {@+print_str("to the end of the statement");
  help_line[3]="A previous error seems to have propagated,";
  cur_sym=frozen_semicolon;
  } @+break;
case absorbing: {@+print_str("a text argument");
  help_line[3]="It seems that a right delimiter was left out,";
  if (warning_info==0) cur_sym=frozen_end_group;
  else{@+cur_sym=frozen_right_delimiter;
    equiv(frozen_right_delimiter)=warning_info;
    } 
  } @+break;
case var_defining: case op_defining: {@+print_str("the definition of ");
  if (scanner_status==op_defining) slow_print(text(warning_info));
  else print_variable_name(warning_info);
  cur_sym=frozen_end_def;
  } @+break;
case loop_defining: {@+print_str("the text of a ");slow_print(text(warning_info));
  print_str(" loop");
  help_line[3]="I suspect you have forgotten an `endfor',";
  cur_sym=frozen_end_for;
  } 

@ The |runaway| procedure displays the first part of the text that occurred
when \MF\ began its special |scanner_status|, if that text has been saved.

@<Declare the procedure called |runaway|@>=
void runaway(void)
{@+if (scanner_status > flushing) 
  {@+print_nl("Runaway ");
  switch (scanner_status) {
  case absorbing: print_str("text?");@+break;
  case var_defining: case op_defining: print_str("definition?");@+break;
  case loop_defining: print_str("loop?");
  }  /*there are no other cases*/ 
  print_ln();show_token_list(link(hold_head), null, error_line-10, 0);
  } 
} 

@ We need to mention a procedure that may be called by |get_next|.

@p void firm_up_the_line(void);

@ And now we're ready to take the plunge into |get_next| itself.

@p void get_next(void) /*sets |cur_cmd|, |cur_mod|, |cur_sym| to next token*/ 
@^inner loop@>
{@+ /*go here to get the next input token*/ 
   /*go here when the next input token has been got*/ 
   /*go here when the end of a symbolic token has been found*/ 
   /*go here to branch on the class of an input character*/ 
  
     /*go here at crucial stages when scanning a number*/ 
uint16_t @!k; /*an index into |buffer|*/ 
ASCII_code @!c; /*the current character in the buffer*/ 
ASCII_code @!class; /*its class number*/ 
int @!n, @!f; /*registers for decimal-to-binary conversion*/ 
restart: cur_sym=0;
if (file_state) 
@<Input from external file; |goto restart| if no input found, or |return| if a non-symbolic
token is found@>@;
else@<Input from token list; |goto restart| if end of list or if a parameter needs
to be expanded, or |return| if a non-symbolic token is found@>;
@<Finish getting the symbolic token in |cur_sym|; |goto restart| if it is illegal@>;
} 

@ When a symbolic token is declared to be `\&{outer}', its command code
is increased by |outer_tag|.
@^inner loop@>

@<Finish getting the symbolic token in |cur_sym|...@>=
cur_cmd=eq_type(cur_sym);cur_mod=equiv(cur_sym);
if (cur_cmd >= outer_tag) 
  if (check_outer_validity()) cur_cmd=cur_cmd-outer_tag;
  else goto restart

@ A percent sign appears in |buffer[limit]|; this makes it unnecessary
to have a special test for end-of-line.
@^inner loop@>

@<Input from external file;...@>=
{@+get_cur_chr: c=buffer[loc];incr(loc);class=char_class[c];
switch (class) {
case digit_class: goto start_numeric_token;
case period_class: {@+class=char_class[buffer[loc]];
  if (class > period_class) goto get_cur_chr;
  else if (class < period_class)  /*|class==digit_class|*/ 
    {@+n=0;goto start_decimal_token;
    } 
@:. }{\..\ token@>
  } @+break;
case space_class: goto get_cur_chr;
case percent_class: {@+@<Move to next line of file, or |goto restart| if there is
no next line@>;
  check_interrupt;
  goto get_cur_chr;
  } 
case string_class: @<Get a string token and |return|@>@;
isolated_classes: {@+k=loc-1;goto found;
  } 
case invalid_class: @<Decry the invalid character and |goto restart|@>@;
default:do_nothing; /*letters, etc.*/ 
} @/
k=loc-1;
while (char_class[buffer[loc]]==class) incr(loc);
goto found;
start_numeric_token: @<Get the integer part |n| of a numeric token; set |f:=0| and
|goto fin_numeric_token| if there is no decimal point@>;
start_decimal_token: @<Get the fraction part |f| of a numeric token@>;
fin_numeric_token: @<Pack the numeric and fraction parts of a numeric token and |return|@>;
found: cur_sym=id_lookup(k, loc-k);
} 

@ We go to |restart| instead of to |get_cur_chr|, because we might enter
|token_state| after the error has been dealt with
(cf.\ |clear_for_error_prompt|).

@<Decry the invalid...@>=
{@+print_err("Text line contains an invalid character");
@.Text line contains...@>
help2("A funny symbol that I can't read has just been input.")@/
("Continue, and I'll forget that it ever happened.");@/
deletions_allowed=false;error();deletions_allowed=true;
goto restart;
} 

@ @<Get a string token and |return|@>=
{@+if (buffer[loc]=='"') cur_mod=empty_string;
else{@+k=loc;buffer[limit+1]='"';
  @/do@+{incr(loc);
  }@+ while (!(buffer[loc]=='"'));
  if (loc > limit) @<Decry the missing string delimiter and |goto restart|@>;
  if ((loc==k+1)&&(length(buffer[k])==1)) cur_mod=buffer[k];
  else{@+str_room(loc-k);
    @/do@+{append_char(buffer[k]);incr(k);
    }@+ while (!(k==loc));
    cur_mod=make_string();
    } 
  } 
incr(loc);cur_cmd=string_token;return;
} 

@ We go to |restart| after this error message, not to |get_cur_chr|,
because the |clear_for_error_prompt| routine might have reinstated
|token_state| after |error| has finished.

@<Decry the missing string delimiter and |goto restart|@>=
{@+loc=limit; /*the next character to be read on this line will be |'%'|*/ 
print_err("Incomplete string token has been flushed");
@.Incomplete string token...@>
help3("Strings should finish on the same line as they began.")@/
  ("I've deleted the partial string; you might want to")@/
  ("insert another by typing, e.g., `I\"new string\"'.");@/
deletions_allowed=false;error();deletions_allowed=true;goto restart;
} 

@ @<Get the integer part |n| of a numeric token...@>=
n=c-'0';
while (char_class[buffer[loc]]==digit_class) 
  {@+if (n < 4096) n=10*n+buffer[loc]-'0';
  incr(loc);
  } 
if (buffer[loc]=='.') if (char_class[buffer[loc+1]]==digit_class) goto done;
f=0;goto fin_numeric_token;
done: incr(loc)

@ @<Get the fraction part |f| of a numeric token@>=
k=0;
@/do@+{if (k < 17)  /*digits for |k >= 17| cannot affect the result*/ 
  {@+dig[k]=buffer[loc]-'0';incr(k);
  } 
incr(loc);
}@+ while (!(char_class[buffer[loc]]!=digit_class));
f=round_decimals(k);
if (f==unity) 
  {@+incr(n);f=0;
  } 

@ @<Pack the numeric and fraction parts of a numeric token and |return|@>=
if (n < 4096) cur_mod=n*unity+f;
else{@+print_err("Enormous number has been reduced");
@.Enormous number...@>
  help2("I can't handle numbers bigger than about 4095.99998;")@/
  ("so I've changed your constant to that maximum amount.");@/
  deletions_allowed=false;error();deletions_allowed=true;
  cur_mod=01777777777;
  } 
cur_cmd=numeric_token;return

@ Let's consider now what happens when |get_next| is looking at a token list.
@^inner loop@>

@<Input from token list;...@>=
if (loc >= hi_mem_min)  /*one-word token*/ 
  {@+cur_sym=info(loc);loc=link(loc); /*move to next*/ 
  if (cur_sym >= expr_base) 
    if (cur_sym >= suffix_base) 
      @<Insert a suffix or text parameter and |goto restart|@>@;
    else{@+cur_cmd=capsule_token;
      cur_mod=param_stack[param_start+cur_sym-(expr_base)];
      cur_sym=0;return;
      } 
  } 
else if (loc > null) 
  @<Get a stored numeric or string or capsule token and |return|@>@;
else{@+ /*we are done with this token list*/ 
  end_token_list();goto restart; /*resume previous level*/ 
  } 

@ @<Insert a suffix or text parameter...@>=
{@+if (cur_sym >= text_base) cur_sym=cur_sym-param_size;
   /*|param_size==text_base-suffix_base|*/ 
begin_token_list(param_stack[param_start+cur_sym-(suffix_base)], parameter);
goto restart;
} 

@ @<Get a stored numeric or string or capsule token...@>=
{@+if (name_type(loc)==token) 
  {@+cur_mod=value(loc);
  if (type(loc)==known) cur_cmd=numeric_token;
  else{@+cur_cmd=string_token;add_str_ref(cur_mod);
    } 
  } 
else{@+cur_mod=loc;cur_cmd=capsule_token;
  } 
loc=link(loc);return;
} 

@ All of the easy branches of |get_next| have now been taken care of.
There is one more branch.

@<Move to next line of file, or |goto restart|...@>=
if (name > 2) @<Read next line of file into |buffer|, or |goto restart| if the file
has ended@>@;
else{@+if (input_ptr > 0) 
      /*text was inserted during error recovery or by \&{scantokens}*/ 
    {@+end_file_reading();goto restart; /*resume previous level*/ 
    } 
  if (selector < log_only) open_log_file();
  if (interaction > nonstop_mode) 
    {@+if (limit==start)  /*previous line was empty*/ 
      print_nl("(Please type a command or say `end')");
@.Please type...@>
    print_ln();first=start;
    prompt_input("*"); /*input on-line into |buffer|*/ 
@.*\relax@>
    limit=last;buffer[limit]='%';
    first=limit+1;loc=start;
    } 
  else fatal_error("*** (job aborted, no legal end found)");
@.job aborted@>
     /*nonstop mode, which is intended for overnight batch processing,
    never waits for on-line input*/ 
  } 

@ The global variable |force_eof| is normally |false|; it is set |true|
by an \&{endinput} command.

@<Glob...@>=
bool @!force_eof; /*should the next \&{input} be aborted early?*/ 

@ @<Read next line of file into |buffer|, or |goto restart| if the file has ended@>=
{@+incr(line);first=start;
if (!force_eof) 
  {@+if (input_ln(&cur_file, true))  /*not end of file*/ 
    firm_up_the_line(); /*this sets |limit|*/ 
  else force_eof=true;
  } 
if (force_eof) 
  {@+print_char(')');decr(open_parens);
  update_terminal; /*show user that file has been read*/ 
  force_eof=false;
  end_file_reading(); /*resume previous level*/ 
  if (check_outer_validity()) goto restart;@+else goto restart;
  } 
buffer[limit]='%';first=limit+1;loc=start; /*ready to read*/ 
} 

@ If the user has set the |pausing| parameter to some positive value,
and if nonstop mode has not been selected, each line of input is displayed
on the terminal and the transcript file, followed by `\.{=>}'.
\MF\ waits for a response. If the response is null (i.e., if nothing is
typed except perhaps a few blank spaces), the original
line is accepted as it stands; otherwise the line typed is
used instead of the line in the file.

@p void firm_up_the_line(void)
{@+int @!k; /*an index into |buffer|*/ 
limit=last;
if (internal[pausing] > 0) if (interaction > nonstop_mode) 
  {@+wake_up_terminal;print_ln();
  if (start < limit) for (k=start; k<=limit-1; k++) print(buffer[k]);
  first=limit;prompt_input("=>"); /*wait for user response*/ 
@.=>@>
  if (last > first) 
    {@+for (k=first; k<=last-1; k++)  /*move line down in buffer*/ 
      buffer[k+start-first]=buffer[k];
    limit=start+last-first;
    } 
  } 
} 

@* Scanning macro definitions.
\MF\ has a variety of ways to tuck tokens away into token lists for later
use: Macros can be defined with \&{def}, \&{vardef}, \&{primarydef}, etc.;
repeatable code can be defined with \&{for}, \&{forever}, \&{forsuffixes}.
All such operations are handled by the routines in this part of the program.

The modifier part of each command code is zero for the ``ending delimiters''
like \&{enddef} and \&{endfor}.

@d start_def	1 /*command modifier for \&{def}*/ 
@d var_def	2 /*command modifier for \&{vardef}*/ 
@d end_def	0 /*command modifier for \&{enddef}*/ 
@d start_forever	1 /*command modifier for \&{forever}*/ 
@d end_for	0 /*command modifier for \&{endfor}*/ 

@<Put each...@>=
primitive(@[@<|"def"|@>@], macro_def, start_def);@/
@!@:def_}{\&{def} primitive@>
primitive(@[@<|"vardef"|@>@], macro_def, var_def);@/
@!@:var_def_}{\&{vardef} primitive@>
primitive(@[@<|"primarydef"|@>@], macro_def, secondary_primary_macro);@/
@!@:primary_def_}{\&{primarydef} primitive@>
primitive(@[@<|"secondarydef"|@>@], macro_def, tertiary_secondary_macro);@/
@!@:secondary_def_}{\&{secondarydef} primitive@>
primitive(@[@<|"tertiarydef"|@>@], macro_def, expression_tertiary_macro);@/
@!@:tertiary_def_}{\&{tertiarydef} primitive@>
primitive(@[@<|"enddef"|@>@], macro_def, end_def);eqtb[frozen_end_def]=eqtb[cur_sym];@/
@!@:end_def_}{\&{enddef} primitive@>
@#
primitive(@[@<|"for"|@>@], iteration, expr_base);@/
@!@:for_}{\&{for} primitive@>
primitive(@[@<|"forsuffixes"|@>@], iteration, suffix_base);@/
@!@:for_suffixes_}{\&{forsuffixes} primitive@>
primitive(@[@<|"forever"|@>@], iteration, start_forever);@/
@!@:forever_}{\&{forever} primitive@>
primitive(@[@<|"endfor"|@>@], iteration, end_for);eqtb[frozen_end_for]=eqtb[cur_sym];@/
@!@:end_for_}{\&{endfor} primitive@>

@ @<Cases of |print_cmd...@>=
case macro_def: if (m <= var_def) 
    if (m==start_def) print_str("def");
    else if (m < start_def) print_str("enddef");
    else print_str("vardef");
  else if (m==secondary_primary_macro) print_str("primarydef");
  else if (m==tertiary_secondary_macro) print_str("secondarydef");
  else print_str("tertiarydef");@+break;
case iteration: if (m <= start_forever) 
    if (m==start_forever) print_str("forever");@+else print_str("endfor");
  else if (m==expr_base) print_str("for");@+else print_str("forsuffixes");@+break;

@ Different macro-absorbing operations have different syntaxes, but they
also have a lot in common. There is a list of special symbols that are to
be replaced by parameter tokens; there is a special command code that
ends the definition; the quotation conventions are identical.  Therefore
it makes sense to have most of the work done by a single subroutine. That
subroutine is called |scan_toks|.

The first parameter to |scan_toks| is the command code that will
terminate scanning (either |macro_def| or |iteration|).

The second parameter, |subst_list|, points to a (possibly empty) list
of two-word nodes whose |info| and |value| fields specify symbol tokens
before and after replacement. The list will be returned to free storage
by |scan_toks|.

The third parameter is simply appended to the token list that is built.
And the final parameter tells how many of the special operations
\.{\#\AT!}, \.{\AT!}, and \.{\AT!\#} are to be replaced by suffix parameters.
When such parameters are present, they are called \.{(SUFFIX0)},
\.{(SUFFIX1)}, and \.{(SUFFIX2)}.

@p pointer scan_toks(command_code @!terminator,
  pointer @!subst_list, pointer @!tail_end, small_number @!suffix_count)
{@+
pointer @!p; /*tail of the token list being built*/ 
pointer @!q; /*temporary for link management*/ 
int @!balance; /*left delimiters minus right delimiters*/ 
p=hold_head;balance=1;link(hold_head)=null;
loop@+{@+get_next();
  if (cur_sym > 0) 
    {@+@<Substitute for |cur_sym|, if it's on the |subst_list|@>;
    if (cur_cmd==terminator) 
      @<Adjust the balance; |goto done| if it's zero@>@;
    else if (cur_cmd==macro_special) 
      @<Handle quoted symbols, \.{\#\AT!}, \.{\AT!}, or \.{\AT!\#}@>;
    } 
  link(p)=cur_tok();p=link(p);
  } 
done: link(p)=tail_end;flush_node_list(subst_list);
return link(hold_head);
} 

@ @<Substitute for |cur_sym|...@>=
{@+q=subst_list;
while (q!=null) 
  {@+if (info(q)==cur_sym) 
    {@+cur_sym=value(q);cur_cmd=relax;goto found;
    } 
  q=link(q);
  } 
found: ;} 

@ @<Adjust the balance; |goto done| if it's zero@>=
if (cur_mod > 0) incr(balance);
else{@+decr(balance);
  if (balance==0) goto done;
  } 

@ Four commands are intended to be used only within macro texts: \&{quote},
\.{\#\AT!}, \.{\AT!}, and \.{\AT!\#}. They are variants of a single command
code called |macro_special|.

@d quote	0 /*|macro_special| modifier for \&{quote}*/ 
@d macro_prefix	1 /*|macro_special| modifier for \.{\#\AT!}*/ 
@d macro_at	2 /*|macro_special| modifier for \.{\AT!}*/ 
@d macro_suffix	3 /*|macro_special| modifier for \.{\AT!\#}*/ 

@<Put each...@>=
primitive(@[@<|"quote"|@>@], macro_special, quote);@/
@!@:quote_}{\&{quote} primitive@>
primitive(@[@<|"#@@"|@>@], macro_special, macro_prefix);@/
@!@:]]]\#\AT!_}{\.{\#\AT!} primitive@>
primitive('@@', macro_special, macro_at);@/
@!@:]]]\AT!_}{\.{\AT!} primitive@>
primitive(@[@<|"@@#"|@>@], macro_special, macro_suffix);@/
@!@:]]]\AT!\#_}{\.{\AT!\#} primitive@>

@ @<Cases of |print_cmd...@>=
case macro_special: switch (m) {
  case macro_prefix: print_str("#@@");@+break;
  case macro_at: print_char('@@');@+break;
  case macro_suffix: print_str("@@#");@+break;
  default:print_str("quote");
  } @+break;

@ @<Handle quoted...@>=
{@+if (cur_mod==quote) get_next();
else if (cur_mod <= suffix_count) cur_sym=suffix_base-1+cur_mod;
} 

@ Here is a routine that's used whenever a token will be redefined. If
the user's token is unredefinable, the `|frozen_inaccessible|' token is
substituted; the latter is redefinable but essentially impossible to use,
hence \MF's tables won't get fouled up.

@p void get_symbol(void) /*sets |cur_sym| to a safe symbol*/ 
{@+
restart: get_next();
if ((cur_sym==0)||(cur_sym > frozen_inaccessible)) 
  {@+print_err("Missing symbolic token inserted");
@.Missing symbolic token...@>
  help3("Sorry: You can't redefine a number, string, or expr.")@/
    ("I've inserted an inaccessible symbol so that your")@/
    ("definition will be completed without mixing me up too badly.");
  if (cur_sym > 0) 
    help_line[2]="Sorry: You can't redefine my error-recovery tokens.";
  else if (cur_cmd==string_token) delete_str_ref(cur_mod);
  cur_sym=frozen_inaccessible;ins_error();goto restart;
  } 
} 

@ Before we actually redefine a symbolic token, we need to clear away its
former value, if it was a variable. The following stronger version of
|get_symbol| does that.

@p void get_clear_symbol(void)
{@+get_symbol();clear_symbol(cur_sym, false);
} 

@ Here's another little subroutine; it checks that an equals sign
or assignment sign comes along at the proper place in a macro definition.

@p void check_equals(void)
{@+if (cur_cmd!=equals) if (cur_cmd!=assignment) 
  {@+missing_err('=');@/
@.Missing `='@>
  help5("The next thing in this `def' should have been `=',")@/
    ("because I've already looked at the definition heading.")@/
    ("But don't worry; I'll pretend that an equals sign")@/
    ("was present. Everything from here to `enddef'")@/
    ("will be the replacement text of this macro.");
  back_error();
  } 
} 

@ A \&{primarydef}, \&{secondarydef}, or \&{tertiarydef} is rather easily
handled now that we have |scan_toks|.  In this case there are
two parameters, which will be \.{EXPR0} and \.{EXPR1} (i.e.,
|expr_base| and |expr_base+1|).

@p void make_op_def(void)
{@+command_code @!m; /*the type of definition*/ 
pointer @!p, @!q, @!r; /*for list manipulation*/ 
m=cur_mod;@/
get_symbol();q=get_node(token_node_size);
info(q)=cur_sym;value(q)=expr_base;@/
get_clear_symbol();warning_info=cur_sym;@/
get_symbol();p=get_node(token_node_size);
info(p)=cur_sym;value(p)=expr_base+1;link(p)=q;@/
get_next();check_equals();@/
scanner_status=op_defining;q=get_avail();ref_count(q)=null;
r=get_avail();link(q)=r;info(r)=general_macro;
link(r)=scan_toks(macro_def, p, null, 0);
scanner_status=normal;eq_type(warning_info)=m;
equiv(warning_info)=q;get_x_next();
} 

@ Parameters to macros are introduced by the keywords \&{expr},
\&{suffix}, \&{text}, \&{primary}, \&{secondary}, and \&{tertiary}.

@<Put each...@>=
primitive(@[@<|"expr"|@>@], param_type, expr_base);@/
@!@:expr_}{\&{expr} primitive@>
primitive(@[@<|"suffix"|@>@], param_type, suffix_base);@/
@!@:suffix_}{\&{suffix} primitive@>
primitive(@[@<|"text"|@>@], param_type, text_base);@/
@!@:text_}{\&{text} primitive@>
primitive(@[@<|"primary"|@>@], param_type, primary_macro);@/
@!@:primary_}{\&{primary} primitive@>
primitive(@[@<|"secondary"|@>@], param_type, secondary_macro);@/
@!@:secondary_}{\&{secondary} primitive@>
primitive(@[@<|"tertiary"|@>@], param_type, tertiary_macro);@/
@!@:tertiary_}{\&{tertiary} primitive@>

@ @<Cases of |print_cmd...@>=
case param_type: if (m >= expr_base) 
    if (m==expr_base) print_str("expr");
    else if (m==suffix_base) print_str("suffix");
    else print_str("text");
  else if (m < secondary_macro) print_str("primary");
  else if (m==secondary_macro) print_str("secondary");
  else print_str("tertiary");@+break;

@ Let's turn next to the more complex processing associated with \&{def}
and \&{vardef}. When the following procedure is called, |cur_mod|
should be either |start_def| or |var_def|.

@p@t\4@>@<Declare the procedure called |check_delimiter|@>@;
@t\4@>@<Declare the function called |scan_declared_variable|@>@;
void scan_def(void)
{@+uint8_t @!m; /*the type of definition*/ 
uint8_t @!n; /*the number of special suffix parameters*/ 
uint8_t @!k; /*the total number of parameters*/ 
uint8_t @!c; /*the kind of macro we're defining*/ 
pointer @!r; /*parameter-substitution list*/ 
pointer @!q; /*tail of the macro token list*/ 
pointer @!p; /*temporary storage*/ 
halfword @!base; /*|expr_base|, |suffix_base|, or |text_base|*/ 
pointer @!l_delim, @!r_delim; /*matching delimiters*/ 
m=cur_mod;c=general_macro;link(hold_head)=null;@/
q=get_avail();ref_count(q)=null;r=null;@/
@<Scan the token or variable to be defined; set |n|, |scanner_status|, and |warning_info|@>;
k=n;
if (cur_cmd==left_delimiter) 
  @<Absorb delimited parameters, putting them into lists |q| and |r|@>;
if (cur_cmd==param_type) 
  @<Absorb undelimited parameters, putting them into list |r|@>;
check_equals();
p=get_avail();info(p)=c;link(q)=p;
@<Attach the replacement text to the tail of node |p|@>;
scanner_status=normal;get_x_next();
} 

@ We don't put `|frozen_end_group|' into the replacement text of
a \&{vardef}, because the user may want to redefine `\.{endgroup}'.

@<Attach the replacement text to the tail of node |p|@>=
if (m==start_def) link(p)=scan_toks(macro_def, r, null, n);
else{@+q=get_avail();info(q)=bg_loc;link(p)=q;
  p=get_avail();info(p)=eg_loc;
  link(q)=scan_toks(macro_def, r, p, n);
  } 
if (warning_info==bad_vardef) flush_token_list(value(bad_vardef))

@ @<Glob...@>=
uint16_t @!bg_loc, @!eg_loc;
   /*hash addresses of `\.{begingroup}' and `\.{endgroup}'*/ 

@ @<Scan the token or variable to be defined;...@>=
if (m==start_def) 
  {@+get_clear_symbol();warning_info=cur_sym;get_next();
  scanner_status=op_defining;n=0;
  eq_type(warning_info)=defined_macro;equiv(warning_info)=q;
  } 
else{@+p=scan_declared_variable();
  flush_variable(equiv(info(p)), link(p), true);
  warning_info=find_variable(p);flush_list(p);
  if (warning_info==null) @<Change to `\.{a bad variable}'@>;
  scanner_status=var_defining;n=2;
  if (cur_cmd==macro_special) if (cur_mod==macro_suffix)  /*\.{\AT!\#}*/ 
    {@+n=3;get_next();
    } 
  type(warning_info)=unsuffixed_macro-2+n;value(warning_info)=q;
  }  /*|suffixed_macro==unsuffixed_macro+1|*/ 

@ @<Change to `\.{a bad variable}'@>=
{@+print_err("This variable already starts with a macro");
@.This variable already...@>
help2("After `vardef a' you can't say `vardef a.b'.")@/
  ("So I'll have to discard this definition.");
error();warning_info=bad_vardef;
} 

@ @<Initialize table entries...@>=
name_type(bad_vardef)=root;link(bad_vardef)=frozen_bad_vardef;
equiv(frozen_bad_vardef)=bad_vardef;eq_type(frozen_bad_vardef)=tag_token;

@ @<Absorb delimited parameters, putting them into lists |q| and |r|@>=
@/do@+{l_delim=cur_sym;r_delim=cur_mod;get_next();
if ((cur_cmd==param_type)&&(cur_mod >= expr_base)) base=cur_mod;
else{@+print_err("Missing parameter type; `expr' will be assumed");
@.Missing parameter type@>
  help1("You should've had `expr' or `suffix' or `text' here.");
  back_error();base=expr_base;
  } 
@<Absorb parameter tokens for type |base|@>;
check_delimiter(l_delim, r_delim);
get_next();
}@+ while (!(cur_cmd!=left_delimiter))

@ @<Absorb parameter tokens for type |base|@>=
@/do@+{link(q)=get_avail();q=link(q);info(q)=base+k;@/
get_symbol();p=get_node(token_node_size);value(p)=base+k;info(p)=cur_sym;
if (k==param_size) overflow("parameter stack size", param_size);
@:METAFONT capacity exceeded parameter stack size}{\quad parameter stack size@>
incr(k);link(p)=r;r=p;get_next();
}@+ while (!(cur_cmd!=comma))

@ @<Absorb undelimited parameters, putting them into list |r|@>=
{@+p=get_node(token_node_size);
if (cur_mod < expr_base) 
  {@+c=cur_mod;value(p)=expr_base+k;
  } 
else{@+value(p)=cur_mod+k;
  if (cur_mod==expr_base) c=expr_macro;
  else if (cur_mod==suffix_base) c=suffix_macro;
  else c=text_macro;
  } 
if (k==param_size) overflow("parameter stack size", param_size);
incr(k);get_symbol();info(p)=cur_sym;link(p)=r;r=p;get_next();
if (c==expr_macro) if (cur_cmd==of_token) 
  {@+c=of_macro;p=get_node(token_node_size);
  if (k==param_size) overflow("parameter stack size", param_size);
  value(p)=expr_base+k;get_symbol();info(p)=cur_sym;
  link(p)=r;r=p;get_next();
  } 
} 

@* Expanding the next token.
Only a few command codes | < min_command| can possibly be returned by
|get_next|; in increasing order, they are
|if_test|, |fi_or_else|, |input|, |iteration|, |repeat_loop|,
|exit_test|, |relax|, |scan_tokens|, |expand_after|, and |defined_macro|.

\MF\ usually gets the next token of input by saying |get_x_next|. This is
like |get_next| except that it keeps getting more tokens until
finding |cur_cmd >= min_command|. In other words, |get_x_next| expands
macros and removes conditionals or iterations or input instructions that
might be present.

It follows that |get_x_next| might invoke itself recursively. In fact,
there is massive recursion, since macro expansion can involve the
scanning of arbitrarily complex expressions, which in turn involve
macro expansion and conditionals, etc.
@^recursion@>

Therefore it's necessary to declare a whole bunch of |forward|
procedures at this point, and to insert some other procedures
that will be invoked by |get_x_next|.

@p void scan_primary(void);
void scan_secondary(void);
void scan_tertiary(void);
void scan_expression(void);
void scan_suffix(void);@/
@t\4@>@<Declare the procedure called |macro_call|@>@;@/
void get_boolean(void);
void pass_text(void);
void conditional(void);
void start_input(void);
void begin_iteration(void);
void resume_iteration(void);
void stop_iteration(void);

@ An auxiliary subroutine called |expand| is used by |get_x_next|
when it has to do exotic expansion commands.

@p void expand(void)
{@+pointer @!p; /*for list manipulation*/ 
int @!k; /*something that we hope is | <= buf_size|*/ 
pool_pointer @!j; /*index into |str_pool|*/ 
if (internal[tracing_commands] > unity) if (cur_cmd!=defined_macro) 
  show_cur_cmd_mod;
switch (cur_cmd) {
case if_test: conditional();@+break; /*this procedure is discussed in Part 36 below*/ 
case fi_or_else: @<Terminate the current conditional and skip to \&{fi}@>@;@+break;
case input: @<Initiate or terminate input from a file@>;@+break;
case iteration: if (cur_mod==end_for) 
    @<Scold the user for having an extra \&{endfor}@>@;
  else begin_iteration();@+break; /*this procedure is discussed in Part 37 below*/ 
case repeat_loop: @<Repeat a loop@>@;@+break;
case exit_test: @<Exit a loop if the proper time has come@>@;@+break;
case relax: do_nothing;@+break;
case expand_after: @<Expand the token after the next token@>@;@+break;
case scan_tokens: @<Put a string into the input buffer@>@;@+break;
case defined_macro: macro_call(cur_mod, null, cur_sym);
}  /*there are no other cases*/ 
} 

@ @<Scold the user...@>=
{@+print_err("Extra `endfor'");
@.Extra `endfor'@>
help2("I'm not currently working on a for loop,")@/
  ("so I had better not try to end anything.");@/
error();
} 

@ The processing of \&{input} involves the |start_input| subroutine,
which will be declared later; the processing of \&{endinput} is trivial.

@<Put each...@>=
primitive(@[@<|"input"|@>@], input, 0);@/
@!@:input_}{\&{input} primitive@>
primitive(@[@<|"endinput"|@>@], input, 1);@/
@!@:end_input_}{\&{endinput} primitive@>

@ @<Cases of |print_cmd_mod|...@>=
case input: if (m==0) print_str("input");@+else print_str("endinput");@+break;

@ @<Initiate or terminate input...@>=
if (cur_mod > 0) force_eof=true;
else start_input()

@ We'll discuss the complicated parts of loop operations later. For now
it suffices to know that there's a global variable called |loop_ptr|
that will be |null| if no loop is in progress.

@<Repeat a loop@>=
{@+while (token_state&&(loc==null)) end_token_list(); /*conserve stack space*/ 
if (loop_ptr==null) 
  {@+print_err("Lost loop");
@.Lost loop@>
  help2("I'm confused; after exiting from a loop, I still seem")@/
    ("to want to repeat it. I'll try to forget the problem.");@/
  error();
  } 
else resume_iteration(); /*this procedure is in Part 37 below*/ 
} 

@ @<Exit a loop if the proper time has come@>=
{@+get_boolean();
if (internal[tracing_commands] > unity) show_cmd_mod(nullary, cur_exp);
if (cur_exp==true_code) 
  if (loop_ptr==null) 
    {@+print_err("No loop is in progress");
@.No loop is in progress@>
    help1("Why say `exitif' when there's nothing to exit from?");
    if (cur_cmd==semicolon) error();@+else back_error();
    } 
  else@<Exit prematurely from an iteration@>@;
else if (cur_cmd!=semicolon) 
  {@+missing_err(';');@/
@.Missing `;'@>
  help2("After `exitif <boolean exp>' I expect to see a semicolon.")@/
  ("I shall pretend that one was there.");back_error();
  } 
} 

@ Here we use the fact that |forever_text| is the only |token_type| that
is less than |loop_text|.

@<Exit prematurely...@>=
{@+p=null;
@/do@+{if (file_state) end_file_reading();
else{@+if (token_type <= loop_text) p=start;
  end_token_list();
  } 
}@+ while (!(p!=null));
if (p!=info(loop_ptr)) fatal_error("*** (loop confusion)");
@.loop confusion@>
stop_iteration(); /*this procedure is in Part 37 below*/ 
} 

@ @<Expand the token after the next token@>=
{@+get_next();
p=cur_tok();get_next();
if (cur_cmd < min_command) expand();else back_input();
back_list(p);
} 

@ @<Put a string into the input buffer@>=
{@+get_x_next();scan_primary();
if (cur_type!=string_type) 
  {@+disp_err(null,@[@<|"Not a string"|@>@]);
@.Not a string@>
  help2("I'm going to flush this expression, since")@/
    ("scantokens should be followed by a known string.");
  put_get_flush_error(0);
  } 
else{@+back_input();
  if (length(cur_exp) > 0) @<Pretend we're reading a new one-line file@>;
  } 
} 

@ @<Pretend we're reading a new one-line file@>=
{@+begin_file_reading();name=2;
k=first+length(cur_exp);
if (k >= max_buf_stack) 
  {@+if (k >= buf_size) 
    {@+max_buf_stack=buf_size;
    overflow("buffer size", buf_size);
@:METAFONT capacity exceeded buffer size}{\quad buffer size@>
    } 
  max_buf_stack=k+1;
  } 
j=str_start[cur_exp];limit=k;
while (first < limit) 
  {@+buffer[first]=so(str_pool[j]);incr(j);incr(first);
  } 
buffer[limit]='%';first=limit+1;loc=start;flush_cur_exp(0);
} 

@ Here finally is |get_x_next|.

The expression scanning routines to be considered later
communicate via the global quantities |cur_type| and |cur_exp|;
we must be very careful to save and restore these quantities while
macros are being expanded.
@^inner loop@>

@p void get_x_next(void)
{@+pointer @!save_exp; /*a capsule to save |cur_type| and |cur_exp|*/ 
get_next();
if (cur_cmd < min_command) 
  {@+save_exp=stash_cur_exp();
  @/do@+{if (cur_cmd==defined_macro) macro_call(cur_mod, null, cur_sym);
  else expand();
  get_next();
  }@+ while (!(cur_cmd >= min_command));
  unstash_cur_exp(save_exp); /*that restores |cur_type| and |cur_exp|*/ 
  } 
} 

@ Now let's consider the |macro_call| procedure, which is used to start up
all user-defined macros. Since the arguments to a macro might be expressions,
|macro_call| is recursive.
@^recursion@>

The first parameter to |macro_call| points to the reference count of the
token list that defines the macro. The second parameter contains any
arguments that have already been parsed (see below).  The third parameter
points to the symbolic token that names the macro. If the third parameter
is |null|, the macro was defined by \&{vardef}, so its name can be
reconstructed from the prefix and ``at'' arguments found within the
second parameter.

What is this second parameter? It's simply a linked list of one-word items,
whose |info| fields point to the arguments. In other words, if |arg_list==null|,
no arguments have been scanned yet; otherwise |info(arg_list)| points to
the first scanned argument, and |link(arg_list)| points to the list of
further arguments (if any).

Arguments of type \&{expr} are so-called capsules, which we will
discuss later when we concentrate on expressions; they can be
recognized easily because their |link| field is |empty|. Arguments of type
\&{suffix} and \&{text} are token lists without reference counts.

@ After argument scanning is complete, the arguments are moved to the
|param_stack|. (They can't be put on that stack any sooner, because
the stack is growing and shrinking in unpredictable ways as more arguments
are being acquired.)  Then the macro body is fed to the scanner; i.e.,
the replacement text of the macro is placed at the top of the \MF's
input stack, so that |get_next| will proceed to read it next.

@<Declare the procedure called |macro_call|@>=
@t\4@>@<Declare the procedure called |print_macro_name|@>@;
@t\4@>@<Declare the procedure called |print_arg|@>@;
@t\4@>@<Declare the procedure called |scan_text_arg|@>@;
void macro_call(pointer @!def_ref, pointer @!arg_list, pointer @!macro_name)
   /*invokes a user-defined control sequence*/ 
{@+
pointer @!r; /*current node in the macro's token list*/ 
pointer @!p, @!q; /*for list manipulation*/ 
int @!n; /*the number of arguments*/ 
pointer @!l_delim, @!r_delim; /*a delimiter pair*/ 
pointer @!tail; /*tail of the argument list*/ 
r=link(def_ref);add_mac_ref(def_ref);
if (arg_list==null) n=0;
else@<Determine the number |n| of arguments already supplied, and set |tail| to the
tail of |arg_list|@>;
if (internal[tracing_macros] > 0) 
  @<Show the text of the macro being expanded, and the existing arguments@>;
@<Scan the remaining arguments, if any; set |r| to the first token of the replacement
text@>;
@<Feed the arguments and replacement text to the scanner@>;
} 

@ @<Show the text of the macro...@>=
{@+begin_diagnostic();print_ln();print_macro_name(arg_list, macro_name);
if (n==3) print_str("@@#"); /*indicate a suffixed macro*/ 
show_macro(def_ref, null, 100000);
if (arg_list!=null) 
  {@+n=0;p=arg_list;
  @/do@+{q=info(p);
  print_arg(q, n, 0);
  incr(n);p=link(p);
  }@+ while (!(p==null));
  } 
end_diagnostic(false);
} 

@ @<Declare the procedure called |print_macro_name|@>=
void print_macro_name(pointer @!a, pointer @!n)
{@+pointer @!p, @!q; /*they traverse the first part of |a|*/ 
if (n!=null) slow_print(text(n));
else{@+p=info(a);
  if (p==null) slow_print(text(info(info(link(a)))));
  else{@+q=p;
    while (link(q)!=null) q=link(q);
    link(q)=info(link(a));
    show_token_list(p, null, 1000, 0);
    link(q)=null;
    } 
  } 
} 

@ @<Declare the procedure called |print_arg|@>=
void print_arg(pointer @!q, int @!n, pointer @!b)
{@+if (link(q)==empty) print_nl("(EXPR");
else if ((b < text_base)&&(b!=text_macro)) print_nl("(SUFFIX");
else print_nl("(TEXT");
print_int(n);print_str(")<-");
if (link(q)==empty) print_exp(q, 1);
else show_token_list(q, null, 1000, 0);
} 

@ @<Determine the number |n| of arguments already supplied...@>=
{@+n=1;tail=arg_list;
while (link(tail)!=null) 
  {@+incr(n);tail=link(tail);
  } 
} 

@ @<Scan the remaining arguments, if any; set |r|...@>=
cur_cmd=comma+1; /*anything |!=comma| will do*/ 
while (info(r) >= expr_base) 
  {@+@<Scan the delimited argument represented by |info(r)|@>;
  r=link(r);
  } 
if (cur_cmd==comma) 
  {@+print_err("Too many arguments to ");
@.Too many arguments...@>
  print_macro_name(arg_list, macro_name);print_char(';');
  print_nl("  Missing `");slow_print(text(r_delim));
@.Missing `)'...@>
  print_str("' has been inserted");
  help3("I'm going to assume that the comma I just read was a")@/
   ("right delimiter, and then I'll begin expanding the macro.")@/
   ("You might want to delete some tokens before continuing.");
  error();
  } 
if (info(r)!=general_macro) @<Scan undelimited argument(s)@>;
r=link(r)

@ At this point, the reader will find it advisable to review the explanation
of token list format that was presented earlier, paying special attention to
the conventions that apply only at the beginning of a macro's token list.

On the other hand, the reader will have to take the expression-parsing
aspects of the following program on faith; we will explain |cur_type|
and |cur_exp| later. (Several things in this program depend on each other,
and it's necessary to jump into the circle somewhere.)

@<Scan the delimited argument represented by |info(r)|@>=
if (cur_cmd!=comma) 
  {@+get_x_next();
  if (cur_cmd!=left_delimiter) 
    {@+print_err("Missing argument to ");
@.Missing argument...@>
    print_macro_name(arg_list, macro_name);
    help3("That macro has more parameters than you thought.")@/
     ("I'll continue by pretending that each missing argument")@/
     ("is either zero or null.");
    if (info(r) >= suffix_base) 
      {@+cur_exp=null;cur_type=token_list;
      } 
    else{@+cur_exp=0;cur_type=known;
      } 
    back_error();cur_cmd=right_delimiter;goto found;
    } 
  l_delim=cur_sym;r_delim=cur_mod;
  } 
@<Scan the argument represented by |info(r)|@>;
if (cur_cmd!=comma) @<Check that the proper right delimiter was present@>;
found: @<Append the current expression to |arg_list|@>@;

@ @<Check that the proper right delim...@>=
if ((cur_cmd!=right_delimiter)||(cur_mod!=l_delim)) 
  if (info(link(r)) >= expr_base) 
    {@+missing_err(',');
@.Missing `,'@>
    help3("I've finished reading a macro argument and am about to")@/
      ("read another; the arguments weren't delimited correctly.")@/
       ("You might want to delete some tokens before continuing.");
    back_error();cur_cmd=comma;
    } 
  else{@+missing_err(text(r_delim));
@.Missing `)'@>
    help2("I've gotten to the end of the macro parameter list.")@/
       ("You might want to delete some tokens before continuing.");
    back_error();
    } 

@ A \&{suffix} or \&{text} parameter will have been scanned as
a token list pointed to by |cur_exp|, in which case we will have
|cur_type==token_list|.

@<Append the current expression to |arg_list|@>=
{@+p=get_avail();
if (cur_type==token_list) info(p)=cur_exp;
else info(p)=stash_cur_exp();
if (internal[tracing_macros] > 0) 
  {@+begin_diagnostic();print_arg(info(p), n, info(r));end_diagnostic(false);
  } 
if (arg_list==null) arg_list=p;
else link(tail)=p;
tail=p;incr(n);
} 

@ @<Scan the argument represented by |info(r)|@>=
if (info(r) >= text_base) scan_text_arg(l_delim, r_delim);
else{@+get_x_next();
  if (info(r) >= suffix_base) scan_suffix();
  else scan_expression();
  } 

@ The parameters to |scan_text_arg| are either a pair of delimiters
or zero; the latter case is for undelimited text arguments, which
end with the first semicolon or \&{endgroup} or \&{end} that is not
contained in a group.

@<Declare the procedure called |scan_text_arg|@>=
void scan_text_arg(pointer @!l_delim, pointer @!r_delim)
{@+
int @!balance; /*excess of |l_delim| over |r_delim|*/ 
pointer @!p; /*list tail*/ 
warning_info=l_delim;scanner_status=absorbing;
p=hold_head;balance=1;link(hold_head)=null;
loop@+{@+get_next();
  if (l_delim==0) @<Adjust the balance for an undelimited argument; |goto done| if
done@>@;
  else@<Adjust the balance for a delimited argument; |goto done| if done@>;
  link(p)=cur_tok();p=link(p);
  } 
done: cur_exp=link(hold_head);cur_type=token_list;
scanner_status=normal;
} 

@ @<Adjust the balance for a delimited argument...@>=
{@+if (cur_cmd==right_delimiter) 
  {@+if (cur_mod==l_delim) 
    {@+decr(balance);
    if (balance==0) goto done;
    } 
  } 
else if (cur_cmd==left_delimiter) if (cur_mod==r_delim) incr(balance);
} 

@ @<Adjust the balance for an undelimited...@>=
{@+if (end_of_statement)  /*|cur_cmd==semicolon|, |end_group|, or |stop|*/ 
  {@+if (balance==1) goto done;
  else if (cur_cmd==end_group) decr(balance);
  } 
else if (cur_cmd==begin_group) incr(balance);
} 

@ @<Scan undelimited argument(s)@>=
{@+if (info(r) < text_macro) 
  {@+get_x_next();
  if (info(r)!=suffix_macro) 
    if ((cur_cmd==equals)||(cur_cmd==assignment)) get_x_next();
  } 
switch (info(r)) {
case primary_macro: scan_primary();@+break;
case secondary_macro: scan_secondary();@+break;
case tertiary_macro: scan_tertiary();@+break;
case expr_macro: scan_expression();@+break;
case of_macro: @<Scan an expression followed by `\&{of} $\langle$primary$\rangle$'@>@;@+break;
case suffix_macro: @<Scan a suffix with optional delimiters@>@;@+break;
case text_macro: scan_text_arg(0, 0);
}  /*there are no other cases*/ 
back_input();@<Append the current expression to |arg_list|@>;
} 

@ @<Scan an expression followed by `\&{of} $\langle$primary$\rangle$'@>=
{@+scan_expression();p=get_avail();info(p)=stash_cur_exp();
if (internal[tracing_macros] > 0) 
  {@+begin_diagnostic();print_arg(info(p), n, 0);end_diagnostic(false);
  } 
if (arg_list==null) arg_list=p;@+else link(tail)=p;
tail=p;incr(n);
if (cur_cmd!=of_token) 
  {@+missing_err(@[@<|"of"|@>@]);print_str(" for ");
@.Missing `of'@>
  print_macro_name(arg_list, macro_name);
  help1("I've got the first argument; will look now for the other.");
  back_error();
  } 
get_x_next();scan_primary();
} 

@ @<Scan a suffix with optional delimiters@>=
{@+if (cur_cmd!=left_delimiter) l_delim=null;
else{@+l_delim=cur_sym;r_delim=cur_mod;get_x_next();
  } 
scan_suffix();
if (l_delim!=null) 
  {@+if ((cur_cmd!=right_delimiter)||(cur_mod!=l_delim)) 
    {@+missing_err(text(r_delim));
@.Missing `)'@>
    help2("I've gotten to the end of the macro parameter list.")@/
       ("You might want to delete some tokens before continuing.");
    back_error();
    } 
  get_x_next();
  } 
} 

@ Before we put a new token list on the input stack, it is wise to clean off
all token lists that have recently been depleted. Then a user macro that ends
with a call to itself will not require unbounded stack space.

@<Feed the arguments and replacement text to the scanner@>=
while (token_state&&(loc==null)) end_token_list(); /*conserve stack space*/ 
if (param_ptr+n > max_param_stack) 
  {@+max_param_stack=param_ptr+n;
  if (max_param_stack > param_size) 
    overflow("parameter stack size", param_size);
@:METAFONT capacity exceeded parameter stack size}{\quad parameter stack size@>
  } 
begin_token_list(def_ref, macro);name=macro_name;loc=r;
if (n > 0) 
  {@+p=arg_list;
  @/do@+{param_stack[param_ptr]=info(p);incr(param_ptr);p=link(p);
  }@+ while (!(p==null));
  flush_list(arg_list);
  } 

@ It's sometimes necessary to put a single argument onto |param_stack|.
The |stack_argument| subroutine does this.

@p void stack_argument(pointer @!p)
{@+if (param_ptr==max_param_stack) 
  {@+incr(max_param_stack);
  if (max_param_stack > param_size) 
    overflow("parameter stack size", param_size);
@:METAFONT capacity exceeded parameter stack size}{\quad parameter stack size@>
  } 
param_stack[param_ptr]=p;incr(param_ptr);
} 

@* Conditional processing.
Let's consider now the way \&{if} commands are handled.

Conditions can be inside conditions, and this nesting has a stack
that is independent of other stacks.
Four global variables represent the top of the condition stack:
|cond_ptr| points to pushed-down entries, if~any; |cur_if| tells whether
we are processing \&{if} or \&{elseif}; |if_limit| specifies
the largest code of a |fi_or_else| command that is syntactically legal;
and |if_line| is the line number at which the current conditional began.

If no conditions are currently in progress, the condition stack has the
special state |cond_ptr==null|, |if_limit==normal|, |cur_if==0|, |if_line==0|.
Otherwise |cond_ptr| points to a two-word node; the |type|, |name_type|, and
|link| fields of the first word contain |if_limit|, |cur_if|, and
|cond_ptr| at the next level, and the second word contains the
corresponding |if_line|.

@d if_node_size	2 /*number of words in stack entry for conditionals*/ 
@d if_line_field(X)	mem[X+1].i
@d if_code	1 /*code for \&{if} being evaluated*/ 
@d fi_code	2 /*code for \&{fi}*/ 
@d else_code	3 /*code for \&{else}*/ 
@d else_if_code	4 /*code for \&{elseif}*/ 

@<Glob...@>=
pointer @!cond_ptr; /*top of the condition stack*/ 
uint8_t @!if_limit; /*upper bound on |fi_or_else| codes*/ 
small_number @!cur_if; /*type of conditional being worked on*/ 
int @!if_line; /*line where that conditional began*/ 

@ @<Set init...@>=
cond_ptr=null;if_limit=normal;cur_if=0;if_line=0;

@ @<Put each...@>=
primitive(@[@<|"if"|@>@], if_test, if_code);@/
@!@:if_}{\&{if} primitive@>
primitive(@[@<|"fi"|@>@], fi_or_else, fi_code);eqtb[frozen_fi]=eqtb[cur_sym];@/
@!@:fi_}{\&{fi} primitive@>
primitive(@[@<|"else"|@>@], fi_or_else, else_code);@/
@!@:else_}{\&{else} primitive@>
primitive(@[@<|"elseif"|@>@], fi_or_else, else_if_code);@/
@!@:else_if_}{\&{elseif} primitive@>

@ @<Cases of |print_cmd_mod|...@>=
case if_test: case fi_or_else: switch (m) {
  case if_code: print_str("if");@+break;
  case fi_code: print_str("fi");@+break;
  case else_code: print_str("else");@+break;
  default:print_str("elseif");
  } @+break;

@ Here is a procedure that ignores text until coming to an \&{elseif},
\&{else}, or \&{fi} at level zero of $\&{if}\ldots\&{fi}$
nesting. After it has acted, |cur_mod| will indicate the token that
was found.

\MF's smallest two command codes are |if_test| and |fi_or_else|; this
makes the skipping process a bit simpler.

@p void pass_text(void)
{@+
int l;
scanner_status=skipping;l=0;warning_info=line;
loop@+{@+get_next();
  if (cur_cmd <= fi_or_else) 
    if (cur_cmd < fi_or_else) incr(l);
    else{@+if (l==0) goto done;
      if (cur_mod==fi_code) decr(l);
      } 
  else@<Decrease the string reference count, if the current token is a string@>;
  } 
done: scanner_status=normal;
} 

@ @<Decrease the string reference count...@>=
if (cur_cmd==string_token) delete_str_ref(cur_mod)

@ When we begin to process a new \&{if}, we set |if_limit=if_code|; then
if \&{elseif} or \&{else} or \&{fi} occurs before the current \&{if}
condition has been evaluated, a colon will be inserted.
A construction like `\.{if fi}' would otherwise get \MF\ confused.

@<Push the condition stack@>=
{@+p=get_node(if_node_size);link(p)=cond_ptr;type(p)=if_limit;
name_type(p)=cur_if;if_line_field(p)=if_line;
cond_ptr=p;if_limit=if_code;if_line=line;cur_if=if_code;
} 

@ @<Pop the condition stack@>=
{@+p=cond_ptr;if_line=if_line_field(p);
cur_if=name_type(p);if_limit=type(p);cond_ptr=link(p);
free_node(p, if_node_size);
} 

@ Here's a procedure that changes the |if_limit| code corresponding to
a given value of |cond_ptr|.

@p void change_if_limit(small_number @!l, pointer @!p)
{@+
pointer q;
if (p==cond_ptr) if_limit=l; /*that's the easy case*/ 
else{@+q=cond_ptr;
  loop@+{@+if (q==null) confusion(@[@<|"if"|@>@]);
@:this can't happen if}{\quad if@>
    if (link(q)==p) 
      {@+type(q)=l;return;
      } 
    q=link(q);
    } 
  } 
} 

@ The user is supposed to put colons into the proper parts of conditional
statements. Therefore, \MF\ has to check for their presence.

@p void check_colon(void)
{@+if (cur_cmd!=colon) 
  {@+missing_err(':');@/
@.Missing `:'@>
  help2("There should've been a colon after the condition.")@/
    ("I shall pretend that one was there.");@;
  back_error();
  } 
} 

@ A condition is started when the |get_x_next| procedure encounters
an |if_test| command; in that case |get_x_next| calls |conditional|,
which is a recursive procedure.
@^recursion@>

@p void conditional(void)
{@+
pointer @!save_cond_ptr; /*|cond_ptr| corresponding to this conditional*/ 
uint8_t @!new_if_limit; /*future value of |if_limit|*/ 
pointer @!p; /*temporary register*/ 
@<Push the condition stack@>;@+save_cond_ptr=cond_ptr;
reswitch: get_boolean();new_if_limit=else_if_code;
if (internal[tracing_commands] > unity) 
  @<Display the boolean value of |cur_exp|@>;
found: check_colon();
if (cur_exp==true_code) 
  {@+change_if_limit(new_if_limit, save_cond_ptr);
  return; /*wait for \&{elseif}, \&{else}, or \&{fi}*/ 
  } 
@<Skip to \&{elseif} or \&{else} or \&{fi}, then |goto done|@>;
done: cur_if=cur_mod;if_line=line;
if (cur_mod==fi_code) @<Pop the condition stack@>@;
else if (cur_mod==else_if_code) goto reswitch;
else{@+cur_exp=true_code;new_if_limit=fi_code;get_x_next();goto found;
  } 
} 

@ In a construction like `\&{if} \&{if} \&{true}: $0=1$: \\{foo}
\&{else}: \\{bar} \&{fi}', the first \&{else}
that we come to after learning that the \&{if} is false is not the
\&{else} we're looking for. Hence the following curious logic is needed.

@<Skip to \&{elseif}...@>=
loop@+{@+pass_text();
  if (cond_ptr==save_cond_ptr) goto done;
  else if (cur_mod==fi_code) @<Pop the condition stack@>;
  } 


@ @<Display the boolean value...@>=
{@+begin_diagnostic();
if (cur_exp==true_code) print_str("{true}");@+else print_str("{false}");
end_diagnostic(false);
} 

@ The processing of conditionals is complete except for the following
code, which is actually part of |get_x_next|. It comes into play when
\&{elseif}, \&{else}, or \&{fi} is scanned.

@<Terminate the current conditional and skip to \&{fi}@>=
if (cur_mod > if_limit) 
  if (if_limit==if_code)  /*condition not yet evaluated*/ 
    {@+missing_err(':');
@.Missing `:'@>
    back_input();cur_sym=frozen_colon;ins_error();
    } 
  else{@+print_err("Extra ");print_cmd_mod(fi_or_else, cur_mod);
@.Extra else@>
@.Extra elseif@>
@.Extra fi@>
    help1("I'm ignoring this; it doesn't match any if.");
    error();
    } 
else{@+while (cur_mod!=fi_code) pass_text(); /*skip to \&{fi}*/ 
  @<Pop the condition stack@>;
  } 

@* Iterations.
To bring our treatment of |get_x_next| to a close, we need to consider what
\MF\ does when it sees \&{for}, \&{forsuffixes}, and \&{forever}.

There's a global variable |loop_ptr| that keeps track of the \&{for} loops
that are currently active. If |loop_ptr==null|, no loops are in progress;
otherwise |info(loop_ptr)| points to the iterative text of the current
(innermost) loop, and |link(loop_ptr)| points to the data for any other
loops that enclose the current one.

A loop-control node also has two other fields, called |loop_type| and
|loop_list|, whose contents depend on the type of loop:

\yskip\indent|loop_type(loop_ptr)==null| means that |loop_list(loop_ptr)|
points to a list of one-word nodes whose |info| fields point to the
remaining argument values of a suffix list and expression list.

\yskip\indent|loop_type(loop_ptr)==empty| means that the current loop is
`\&{forever}'.

\yskip\indent|loop_type(loop_ptr)==p > empty| means that |value(p)|,
|step_size(p)|, and |final_value(p)| contain the data for an arithmetic
progression.

\yskip\noindent In the latter case, |p| points to a ``progression node''
whose first word is not used. (No value could be stored there because the
link field of words in the dynamic memory area cannot be arbitrary.)

@d loop_list_loc(X)	X+1 /*where the |loop_list| field resides*/ 
@d loop_type(X)	info(loop_list_loc(X)) /*the type of \&{for} loop*/ 
@d loop_list(X)	link(loop_list_loc(X)) /*the remaining list elements*/ 
@d loop_node_size	2 /*the number of words in a loop control node*/ 
@d progression_node_size	4 /*the number of words in a progression node*/ 
@d step_size(X)	mem[X+2].sc /*the step size in an arithmetic progression*/ 
@d final_value(X)	mem[X+3].sc /*the final value in an arithmetic progression*/ 

@<Glob...@>=
pointer @!loop_ptr; /*top of the loop-control-node stack*/ 

@ @<Set init...@>=
loop_ptr=null;

@ If the expressions that define an arithmetic progression in
a \&{for} loop don't have known numeric values, the |bad_for|
subroutine screams at the user.

@p void bad_for(str_number @!s)
{@+disp_err(null,@[@<|"Improper "|@>@]); /*show the bad expression above the message*/ 
@.Improper...replaced by 0@>
print(s);print_str(" has been replaced by 0");
help4("When you say `for x=a step b until c',")@/
  ("the initial value `a' and the step size `b'")@/
  ("and the final value `c' must have known numeric values.")@/
  ("I'm zeroing this one. Proceed, with fingers crossed.");
put_get_flush_error(0);
} 

@ Here's what \MF\ does when \&{for}, \&{forsuffixes}, or \&{forever}
has just been scanned. (This code requires slight familiarity with
expression-parsing routines that we have not yet discussed; but it seems
to belong in the present part of the program, even though the author
didn't write it until later. The reader may wish to come back to it.)

@p void begin_iteration(void)
{@+
halfword @!m; /*|expr_base| (\&{for}) or |suffix_base| (\&{forsuffixes})*/ 
halfword @!n; /*hash address of the current symbol*/ 
pointer @!p, @!q, @!s, @!pp; /*link manipulation registers*/ 
m=cur_mod;n=cur_sym;s=get_node(loop_node_size);
if (m==start_forever) 
  {@+loop_type(s)=empty;p=null;get_x_next();goto found;
  } 
get_symbol();p=get_node(token_node_size);info(p)=cur_sym;value(p)=m;@/
get_x_next();
if ((cur_cmd!=equals)&&(cur_cmd!=assignment)) 
  {@+missing_err('=');@/
@.Missing `='@>
  help3("The next thing in this loop should have been `=' or `:='.")@/
    ("But don't worry; I'll pretend that an equals sign")@/
    ("was present, and I'll look for the values next.");@/
  back_error();
  } 
@<Scan the values to be used in the loop@>;
found: @<Check for the presence of a colon@>;
@<Scan the loop text and put it on the loop control stack@>;
resume_iteration();
} 

@ @<Check for the presence of a colon@>=
if (cur_cmd!=colon) 
  {@+missing_err(':');@/
@.Missing `:'@>
  help3("The next thing in this loop should have been a `:'.")@/
    ("So I'll pretend that a colon was present;")@/
    ("everything from here to `endfor' will be iterated.");
  back_error();
  } 

@ We append a special |frozen_repeat_loop| token in place of the
`\&{endfor}' at the end of the loop. This will come through \MF's scanner
at the proper time to cause the loop to be repeated.

(If the user tries some shenanigan like `\&{for} $\ldots$ \&{let} \&{endfor}',
he will be foiled by the |get_symbol| routine, which keeps frozen
tokens unchanged. Furthermore the |frozen_repeat_loop| is an \&{outer}
token, so it won't be lost accidentally.)

@ @<Scan the loop text...@>=
q=get_avail();info(q)=frozen_repeat_loop;
scanner_status=loop_defining;warning_info=n;
info(s)=scan_toks(iteration, p, q, 0);scanner_status=normal;@/
link(s)=loop_ptr;loop_ptr=s

@ @<Initialize table...@>=
eq_type(frozen_repeat_loop)=repeat_loop+outer_tag;
text(frozen_repeat_loop)=@[@<|" ENDFOR"|@>@];

@ The loop text is inserted into \MF's scanning apparatus by the
|resume_iteration| routine.

@p void resume_iteration(void)
{@+
pointer @!p, @!q; /*link registers*/ 
p=loop_type(loop_ptr);
if (p > empty)  /*|p| points to a progression node*/ 
  {@+cur_exp=value(p);
  if (@<The arithmetic progression has ended@>) goto not_found;
  cur_type=known;q=stash_cur_exp(); /*make |q| an \&{expr} argument*/ 
  value(p)=cur_exp+step_size(p); /*set |value(p)| for the next iteration*/ 
  } 
else if (p < empty) 
  {@+p=loop_list(loop_ptr);
  if (p==null) goto not_found;
  loop_list(loop_ptr)=link(p);q=info(p);free_avail(p);
  } 
else{@+begin_token_list(info(loop_ptr), forever_text);return;
  } 
begin_token_list(info(loop_ptr), loop_text);
stack_argument(q);
if (internal[tracing_commands] > unity) @<Trace the start of a loop@>;
return;
not_found: stop_iteration();
} 

@ @<The arithmetic progression has ended@>=
((step_size(p) > 0)&&(cur_exp > final_value(p)))||@|
 ((step_size(p) < 0)&&(cur_exp < final_value(p)))

@ @<Trace the start of a loop@>=
{@+begin_diagnostic();print_nl("{loop value=");
@.loop value=n@>
if ((q!=null)&&(link(q)==empty)) print_exp(q, 1);
else show_token_list(q, null, 50, 0);
print_char('}');end_diagnostic(false);
} 

@ A level of loop control disappears when |resume_iteration| has decided
not to resume, or when an \&{exitif} construction has removed the loop text
from the input stack.

@p void stop_iteration(void)
{@+pointer @!p, @!q; /*the usual*/ 
p=loop_type(loop_ptr);
if (p > empty) free_node(p, progression_node_size);
else if (p < empty) 
  {@+q=loop_list(loop_ptr);
  while (q!=null) 
    {@+p=info(q);
    if (p!=null) 
      if (link(p)==empty)  /*it's an \&{expr} parameter*/ 
        {@+recycle_value(p);free_node(p, value_node_size);
        } 
      else flush_token_list(p); /*it's a \&{suffix} or \&{text} parameter*/ 
    p=q;q=link(q);free_avail(p);
    } 
  } 
p=loop_ptr;loop_ptr=link(p);flush_token_list(info(p));
free_node(p, loop_node_size);
} 

@ Now that we know all about loop control, we can finish up
the missing portion of |begin_iteration| and we'll be done.

The following code is performed after the `\.=' has been scanned in
a \&{for} construction (if |m==expr_base|) or a \&{forsuffixes} construction
(if |m==suffix_base|).

@<Scan the values to be used in the loop@>=
loop_type(s)=null;q=loop_list_loc(s);link(q)=null; /*|link(q)==loop_list(s)|*/ 
@/do@+{get_x_next();
if (m!=expr_base) scan_suffix();
else{@+if (cur_cmd >= colon) if (cur_cmd <= comma) goto resume;
  scan_expression();
  if (cur_cmd==step_token) if (q==loop_list_loc(s)) 
    @<Prepare for step-until construction and |goto done|@>;
  cur_exp=stash_cur_exp();
  } 
link(q)=get_avail();q=link(q);info(q)=cur_exp;cur_type=vacuous;
resume: ;}@+ while (!(cur_cmd!=comma));
done: 

@ @<Prepare for step-until construction and |goto done|@>=
{@+if (cur_type!=known) bad_for(@[@<|"initial value"|@>@]);
pp=get_node(progression_node_size);value(pp)=cur_exp;@/
get_x_next();scan_expression();
if (cur_type!=known) bad_for(@[@<|"step size"|@>@]);
step_size(pp)=cur_exp;
if (cur_cmd!=until_token) 
  {@+missing_err(@[@<|"until"|@>@]);@/
@.Missing `until'@>
  help2("I assume you meant to say `until' after `step'.")@/
    ("So I'll look for the final value and colon next.");
  back_error();
  } 
get_x_next();scan_expression();
if (cur_type!=known) bad_for(@[@<|"final value"|@>@]);
final_value(pp)=cur_exp;loop_type(s)=pp;goto done;
} 

@* File names.
It's time now to fret about file names.  Besides the fact that different
operating systems treat files in different ways, we must cope with the
fact that completely different naming conventions are used by different
groups of people. The following programs show what is required for one
particular operating system; similar routines for other systems are not
difficult to devise.
@^system dependencies@>

\MF\ assumes that a file name has three parts: the name proper; its
``extension''; and a ``file area'' where it is found in an external file
system.  The extension of an input file is assumed to be
`\.{.mf}' unless otherwise specified; it is `\.{.log}' on the
transcript file that records each run of \MF; it is `\.{.tfm}' on the font
metric files that describe characters in the fonts \MF\ creates; it is
`\.{.gf}' on the output files that specify generic font information; and it
is `\.{.base}' on the base files written by \.{INIMF} to initialize \MF.
The file area can be arbitrary on input files, but files are usually
output to the user's current area.  If an input file cannot be
found on the specified area, \MF\ will look for it on a special system
area; this special area is intended for commonly used input files.

Simple uses of \MF\ refer only to file names that have no explicit
extension or area. For example, a person usually says `\.{input} \.{cmr10}'
instead of `\.{input} \.{cmr10.new}'. Simple file
names are best, because they make the \MF\ source files portable;
whenever a file name consists entirely of letters and digits, it should be
treated in the same way by all implementations of \MF. However, users
need the ability to refer to other files in their environment, especially
when responding to error messages concerning unopenable files; therefore
we want to let them use the syntax that appears in their favorite
operating system.

@ \MF\ uses the same conventions that have proved to be satisfactory for
\TeX. In order to isolate the system-dependent aspects of file names, the
@^system dependencies@>
system-independent parts of \MF\ are expressed in terms
of three system-dependent
procedures called |begin_name|, |more_name|, and |end_name|. In
essence, if the user-specified characters of the file name are $c_1\ldots c_n$,
the system-independent driver program does the operations
$$|begin_name|;\,|more_name|(c_1);\,\ldots\,;\,|more_name|(c_n);
\,|end_name|.$$
These three procedures communicate with each other via global variables.
Afterwards the file name will appear in the string pool as three strings
called |cur_name|\penalty10000\hskip-.05em,
|cur_area|, and |cur_ext|; the latter two are null (i.e.,
|empty_string|), unless they were explicitly specified by the user.

Actually the situation is slightly more complicated, because \MF\ needs
to know when the file name ends. The |more_name| routine is a function
(with side effects) that returns |true| on the calls |more_name|$(c_1)$,
\dots, |more_name|$(c_{n-1})$. The final call |more_name|$(c_n)$
returns |false|; or, it returns |true| and $c_n$ is the last character
on the current input line. In other words,
|more_name| is supposed to return |true| unless it is sure that the
file name has been completely scanned; and |end_name| is supposed to be able
to finish the assembly of |cur_name|, |cur_area|, and |cur_ext| regardless of
whether $|more_name|(c_n)$ returned |true| or |false|.

@<Glob...@>=
str_number @!cur_name; /*name of file just scanned*/ 
str_number @!cur_area; /*file area just scanned, or \.{""}*/ 
str_number @!cur_ext; /*file extension just scanned, or \.{""}*/ 

@ The file names we shall deal with for illustrative purposes have the
following structure:  If the name contains `\.>' or `\.:', the file area
consists of all characters up to and including the final such character;
otherwise the file area is null.  If the remaining file name contains
`\..', the file extension consists of all such characters from the first
remaining `\..' to the end, otherwise the file extension is null.
@^system dependencies@>

We can scan such file names easily by using two global variables that keep track
of the occurrences of area and extension delimiters:

@<Glob...@>=
pool_pointer @!area_delimiter; /*the most recent `\.>' or `\.:', if any*/ 
pool_pointer @!ext_delimiter; /*the relevant `\..', if any*/ 

@ Input files that can't be found in the user's area may appear in a standard
system area called |MF_area|.
This system area name will, of course, vary from place to place.
@^system dependencies@>
@.MFinputs@>

@ Here now is the first of the system-dependent routines for file name scanning.
@^system dependencies@>

@p void begin_name(void)
{@+area_delimiter=0;ext_delimiter=0;
} 

@ And here's the second.
@^system dependencies@>

@p bool more_name(ASCII_code @!c)
{@+if (c==' ') return false;
else{@+if ((c=='>')||(c==':')) 
    {@+area_delimiter=pool_ptr;ext_delimiter=0;
    } 
  else if ((c=='.')&&(ext_delimiter==0)) ext_delimiter=pool_ptr;
  str_room(1);append_char(c); /*contribute |c| to the current string*/ 
  return true;
  } 
} 

@ The third.
@^system dependencies@>

@p void end_name(void)
{@+if (str_ptr+3 > max_str_ptr) 
  {@+if (str_ptr+3 > max_strings) 
    overflow("number of strings", max_strings-init_str_ptr);
@:METAFONT capacity exceeded number of strings}{\quad number of strings@>
  max_str_ptr=str_ptr+3;
  } 
if (area_delimiter==0) cur_area=empty_string;
else{@+cur_area=str_ptr;incr(str_ptr);
  str_start[str_ptr]=area_delimiter+1;
  } 
if (ext_delimiter==0) 
  {@+cur_ext=empty_string;cur_name=make_string();
  } 
else{@+cur_name=str_ptr;incr(str_ptr);
  str_start[str_ptr]=ext_delimiter;cur_ext=make_string();
  } 
} 

@ Conversely, here is a routine that takes three strings and prints a file
name that might have produced them. (The routine is system dependent, because
some operating systems put the file area last instead of first.)
@^system dependencies@>

@<Basic printing...@>=
void print_file_name(int @!n, int @!a, int @!e)
{@+slow_print(a);slow_print(n);slow_print(e);
} 

@ Another system-dependent routine is needed to convert three internal
\MF\ strings
to the |name_of_file| value that is used to open files. The present code
allows both lowercase and uppercase letters in the file name.
@^system dependencies@>

@d append_to_name(X)	{@+c=X;incr(k);
  if (k <= file_name_size) name_of_file[k]=xchr[c];
  } 

@p void pack_file_name(str_number @!n, str_number @!a, str_number @!e)
{@+int @!k; /*number of positions filled in |name_of_file|*/ 
ASCII_code @!c; /*character being packed*/ 
int @!j; /*index into |str_pool|*/ 
k=0;
for (j=str_start[a]; j<=str_start[a+1]-1; j++) append_to_name(so(str_pool[j]));
for (j=str_start[n]; j<=str_start[n+1]-1; j++) append_to_name(so(str_pool[j]));
for (j=str_start[e]; j<=str_start[e+1]-1; j++) append_to_name(so(str_pool[j]));
if (k <= file_name_size) name_length=k;@+else name_length=file_name_size;
name_of_file[name_length+1]=0;
} 

@ A messier routine is also needed, since base file names must be scanned
before \MF's string mechanism has been initialized. We shall use the
global variable |MF_base_default| to supply the text for default system areas
and extensions related to base files.
@^system dependencies@>

@d base_default_length	18 /*length of the |MF_base_default| string*/ 
@d base_area_length	8 /*length of its area part*/ 
@d base_ext_length	5 /*length of its `\.{.base}' part*/ 
@d base_extension_str	".base" /*the extension, as a \.{WEB} constant*/ 

@<Glob...@>=
char @!MF_base_default[]=" MFbases/plain.base";
@.MFbases@>
@.plain@>
@^system dependencies@>

@ @<Check the ``constant'' values for consistency@>=
if (base_default_length > file_name_size) bad=41;

@ Here is the messy routine that was just mentioned. It sets |name_of_file|
from the first |n| characters of |MF_base_default|, followed by
|buffer[a dotdot b]|, followed by the last |base_ext_length| characters of
|MF_base_default|.

We dare not give error messages here, since \MF\ calls this routine before
the |error| routine is ready to roll. Instead, we simply drop excess characters,
since the error will be detected in another way when a strange file name
isn't found.
@^system dependencies@>

@p void pack_buffered_name(small_number @!n, int @!a, int @!b)
{@+int @!k; /*number of positions filled in |name_of_file|*/ 
ASCII_code @!c; /*character being packed*/ 
int @!j; /*index into |buffer| or |MF_base_default|*/ 
if (n+b-a+1+base_ext_length > file_name_size) 
  b=a+file_name_size-n-1-base_ext_length;
k=0;
for (j=1; j<=n; j++) append_to_name(xord[MF_base_default[j]]);
for (j=a; j<=b; j++) append_to_name(buffer[j]);
for (j=base_default_length-base_ext_length+1; j<=base_default_length; j++) 
  append_to_name(xord[MF_base_default[j]]);
if (k <= file_name_size) name_length=k;@+else name_length=file_name_size;
name_of_file[name_length+1]=0;
} 

@ Here is the only place we use |pack_buffered_name|. This part of the program
becomes active when a ``virgin'' \MF\ is trying to get going, just after
the preliminary initialization, or when the user is substituting another
base file by typing `\.\&' after the initial `\.{**}' prompt.  The buffer
contains the first line of input in |buffer[loc dotdot(last-1)]|, where
|loc < last| and |buffer[loc]!=' '|.

@<Declare the function called |open_base_file|@>=
bool open_base_file(void)
{@+
uint16_t @!j; /*the first space after the file name*/ 
j=loc;
if (buffer[loc]=='&') 
  {@+incr(loc);j=loc;buffer[last]=' ';
  while (buffer[j]!=' ') incr(j);
  pack_buffered_name(0, loc, j-1); /*try first without the system file area*/ 
  if (w_open_in(&base_file)) goto found;
  pack_buffered_name(base_area_length, loc, j-1);
     /*now try the system base file area*/ 
  if (w_open_in(&base_file)) goto found;
  wake_up_terminal;
  wterm_ln("Sorry, I can't find that base; will try PLAIN.");

@.Sorry, I can't find...@>
  update_terminal;
  } 
   /*now pull out all the stops: try for the system \.{plain} file*/ 
pack_buffered_name(base_default_length-base_ext_length, 1, 0);
if (!w_open_in(&base_file)) 
  {@+wake_up_terminal;
  wterm_ln("I can't find the PLAIN base file!");
@.I can't find PLAIN...@>
@.plain@>
  return false;
  } 
found: loc=j;return true;
} 

@ Operating systems often make it possible to determine the exact name (and
possible version number) of a file that has been opened. The following routine,
which simply makes a \MF\ string from the value of |name_of_file|, should
ideally be changed to deduce the full name of file~|f|, which is the file
most recently opened, if it is possible to do this in a \PASCAL\ program.
@^system dependencies@>

This routine might be called after string memory has overflowed, hence
we dare not use `|str_room|'.

@p str_number make_name_string(void)
{@+int @!k; /*index into |name_of_file|*/ 
if ((pool_ptr+name_length > pool_size)||(str_ptr==max_strings)) 
  return'?';
else{@+for (k=1; k<=name_length; k++) append_char(xord[name_of_file[k]]);
  return make_string();
  } 
} 
str_number a_make_name_string(@!alpha_file *@!f)
{@+return make_name_string();
} 
str_number b_make_name_string(@!byte_file *@!f)
{@+return make_name_string();
} 
str_number w_make_name_string(@!word_file *@!f)
{@+return make_name_string();
} 

@ Now let's consider the ``driver''
routines by which \MF\ deals with file names
in a system-independent manner.  First comes a procedure that looks for a
file name in the input by taking the information from the input buffer.
(We can't use |get_next|, because the conversion to tokens would
destroy necessary information.)

This procedure doesn't allow semicolons or percent signs to be part of
file names, because of other conventions of \MF. The manual doesn't
use semicolons or percents immediately after file names, but some users
no doubt will find it natural to do so; therefore system-dependent
changes to allow such characters in file names should probably
be made with reluctance, and only when an entire file name that
includes special characters is ``quoted'' somehow.
@^system dependencies@>

@p void scan_file_name(void)
{@+
begin_name();
while (buffer[loc]==' ') incr(loc);
loop@+{@+if ((buffer[loc]==';')||(buffer[loc]=='%')) goto done;
  if (!more_name(buffer[loc])) goto done;
  incr(loc);
  } 
done: end_name();
} 

@ The global variable |job_name| contains the file name that was first
\&{input} by the user. This name is extended by `\.{.log}' and `\.{.gf}' and
`\.{.base}' and `\.{.tfm}' in the names of \MF's output files.

@<Glob...@>=
str_number @!job_name; /*principal file name*/ 
bool @!log_opened; /*has the transcript file been opened?*/ 
str_number @!log_name; /*full name of the log file*/ 

@ Initially |job_name==0|; it becomes nonzero as soon as the true name is known.
We have |job_name==0| if and only if the `\.{log}' file has not been opened,
except of course for a short time just after |job_name| has become nonzero.

@<Initialize the output...@>=job_name=0;log_opened=false;

@ Here is a routine that manufactures the output file names, assuming that
|job_name!=0|. It ignores and changes the current settings of |cur_area|
and |cur_ext|.

@d pack_cur_name	pack_file_name(cur_name, cur_area, cur_ext)

@p void pack_job_name(str_number @!s) /*|s==@[@<|".log"|@>@]|, |@[@<|".gf"|@>@]|,
  |@[@<|".tfm"|@>@]|, or |base_extension|*/ 
{@+cur_area=empty_string;cur_ext=s;
cur_name=job_name;pack_cur_name;
} 

@ Actually the main output file extension is usually something like
|@[@<|".300gf"|@>@]| instead of just |@[@<|".gf"|@>@]|; the additional number indicates the
resolution in pixels per inch, based on the setting of |hppp| when
the file is opened.

@<Glob...@>=
str_number @!gf_ext; /*default extension for the output file*/ 

@ If some trouble arises when \MF\ tries to open a file, the following
routine calls upon the user to supply another file name. Parameter~|s|
is used in the error message to identify the type of file; parameter~|e|
is the default extension if none is given. Upon exit from the routine,
variables |cur_name|, |cur_area|, |cur_ext|, and |name_of_file| are
ready for another attempt at file opening.

@p void prompt_file_name(char *@!s, str_number @!e)
{@+
uint16_t @!k; /*index into |buffer|*/ 
if (interaction==scroll_mode) wake_up_terminal;
if (strcmp(s,"input file name")==0) print_err("I can't find file `")@;
@.I can't find file x@>
else print_err("I can't write on file `");
@.I can't write on file x@>
print_file_name(cur_name, cur_area, cur_ext);print_str("'.");
if (e==@[@<|".mf"|@>@]) show_context();
print_nl("Please type another ");print_str(s);
@.Please type...@>
if (interaction < scroll_mode) 
  fatal_error("*** (job aborted, file error in nonstop mode)");
@.job aborted, file error...@>
clear_terminal;prompt_input(": ");@<Scan file name in the buffer@>;
if (cur_ext==empty_string) cur_ext=e;
pack_cur_name;
} 

@ @<Scan file name in the buffer@>=
{@+begin_name();k=first;
while ((buffer[k]==' ')&&(k < last)) incr(k);
loop@+{@+if (k==last) goto done;
  if (!more_name(buffer[k])) goto done;
  incr(k);
  } 
done: end_name();
} 

@ The |open_log_file| routine is used to open the transcript file and to help
it catch up to what has previously been printed on the terminal.

@p void open_log_file(void)
{@+uint8_t @!old_setting; /*previous |selector| setting*/ 
int @!k; /*index into |months| and |buffer|*/ 
uint16_t @!l; /*end of first input line*/ 
int @!m; /*the current month*/ 
char @!months[]=" JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC"; /*abbreviations of month names*/ 
old_setting=selector;
if (job_name==0) job_name=@[@<|"mfput"|@>@];
@.mfput@>
pack_job_name(@[@<|".log"|@>@]);
while (!a_open_out(&log_file)) @<Try to get a different log file name@>;
log_name=a_make_name_string(&log_file);
selector=log_only;log_opened=true;
@<Print the banner line, including the date and time@>;
input_stack[input_ptr]=cur_input; /*make sure bottom level is in memory*/ 
print_nl("**");
@.**@>
l=input_stack[0].limit_field-1; /*last position of first line*/ 
for (k=1; k<=l; k++) print(buffer[k]);
print_ln(); /*now the transcript file contains the first line of input*/ 
selector=old_setting+2; /*|log_only| or |term_and_log|*/ 
} 

@ Sometimes |open_log_file| is called at awkward moments when \MF\ is
unable to print error messages or even to |show_context|.
The |prompt_file_name| routine can result in a |fatal_error|, but the |error|
routine will not be invoked because |log_opened| will be false.

The normal idea of |batch_mode| is that nothing at all should be written
on the terminal. However, in the unusual case that
no log file could be opened, we make an exception and allow
an explanatory message to be seen.

Incidentally, the program always refers to the log file as a `\.{transcript
file}', because some systems cannot use the extension `\.{.log}' for
this file.

@<Try to get a different log file name@>=
{@+selector=term_only;
prompt_file_name("transcript file name",@[@<|".log"|@>@]);
} 

@ @<Print the banner...@>=
{@+wlog("%s",banner);
slow_print(base_ident);print_str("  ");
print_int(round_unscaled(internal[day]));print_char(' ');
m=round_unscaled(internal[month]);
for (k=3*m-2; k<=3*m; k++) wlog("%c",months[k]);
print_char(' ');print_int(round_unscaled(internal[year]));print_char(' ');
m=round_unscaled(internal[time]);
print_dd(m/60);print_char(':');print_dd(m%60);
} 

@ Here's an example of how these file-name-parsing routines work in practice.
We shall use the macro |set_output_file_name| when it is time to
crank up the output file.

@d set_output_file_name	
  {@+if (job_name==0) open_log_file();
  pack_job_name(gf_ext);
  while (!b_open_out(&gf_file)) 
    prompt_file_name("file name for output", gf_ext);
  output_file_name=b_make_name_string(&gf_file);
  } 

@<Glob...@>=
byte_file @!gf_file; /*the generic font output goes here*/ 
str_number @!output_file_name; /*full name of the output file*/ 

@ @<Initialize the output...@>=output_file_name=0;

@ Let's turn now to the procedure that is used to initiate file reading
when an `\.{input}' command is being processed.

@p void start_input(void) /*\MF\ will \.{input} something*/ 
{@+
@<Put the desired file name in |(cur_name,cur_ext,cur_area)|@>;
if (cur_ext==empty_string) cur_ext=@[@<|".mf"|@>@];
pack_cur_name;
loop@+{@+begin_file_reading(); /*set up |cur_file| and new level of input*/ 
  if (a_open_in(&cur_file)) goto done;
  if (cur_area==empty_string) 
    {@+pack_file_name(cur_name, MF_area, cur_ext);
    if (a_open_in(&cur_file)) goto done;
    } 
  end_file_reading(); /*remove the level that didn't work*/ 
  prompt_file_name("input file name",@[@<|".mf"|@>@]);
  } 
done: name=a_make_name_string(&cur_file);str_ref[cur_name]=max_str_ref;
if (job_name==0) 
  {@+job_name=cur_name;open_log_file();
  }  /*|open_log_file| doesn't |show_context|, so |limit|
    and |loc| needn't be set to meaningful values yet*/ 
if (term_offset+length(name) > max_print_line-2) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('(');incr(open_parens);slow_print(name);update_terminal;
if (name==str_ptr-1)  /*we can conserve string pool space now*/ 
  {@+flush_string(name);name=cur_name;
  } 
@<Read the first line of the new file@>;
} 

@ Here we have to remember to tell the |input_ln| routine not to
start with a |get|. If the file is empty, it is considered to
contain a single blank line.
@^system dependencies@>

@<Read the first line...@>=
{@+line=1;
if (input_ln(&cur_file, false)) do_nothing;
firm_up_the_line();
buffer[limit]='%';first=limit+1;loc=start;
} 

@ @<Put the desired file name in |(cur_name,cur_ext,cur_area)|@>=
while (token_state&&(loc==null)) end_token_list();
if (token_state) 
  {@+print_err("File names can't appear within macros");
@.File names can't...@>
  help3("Sorry...I've converted what follows to tokens,")@/
    ("possibly garbaging the name you gave.")@/
    ("Please delete the tokens and insert the name again.");@/
  error();
  } 
if (file_state) scan_file_name();
else{@+cur_name=empty_string;cur_ext=empty_string;cur_area=empty_string;
  } 

@* Introduction to the parsing routines.
We come now to the central nervous system that sparks many of \MF's activities.
By evaluating expressions, from their primary constituents to ever larger
subexpressions, \MF\ builds the structures that ultimately define fonts of type.

Four mutually recursive subroutines are involved in this process: We call them
$$\hbox{|scan_primary|, |scan_secondary|, |scan_tertiary|,
and |scan_expression|.}$$
@^recursion@>
Each of them is parameterless and begins with the first token to be scanned
already represented in |cur_cmd|, |cur_mod|, and |cur_sym|. After execution,
the value of the primary or secondary or tertiary or expression that was
found will appear in the global variables |cur_type| and |cur_exp|. The
token following the expression will be represented in |cur_cmd|, |cur_mod|,
and |cur_sym|.

Technically speaking, the parsing algorithms are ``LL(1),'' more or less;
backup mechanisms have been added in order to provide reasonable error
recovery.

@<Glob...@>=
small_number @!cur_type; /*the type of the expression just found*/ 
int @!cur_exp; /*the value of the expression just found*/ 

@ @<Set init...@>=
cur_exp=0;

@ Many different kinds of expressions are possible, so it is wise to have
precise descriptions of what |cur_type| and |cur_exp| mean in all cases:

\smallskip\hang
|cur_type==vacuous| means that this expression didn't turn out to have a
value at all, because it arose from a \&{begingroup}$\,\ldots\,$\&{endgroup}
construction in which there was no expression before the \&{endgroup}.
In this case |cur_exp| has some irrelevant value.

\smallskip\hang
|cur_type==boolean_type| means that |cur_exp| is either |true_code|
or |false_code|.

\smallskip\hang
|cur_type==unknown_boolean| means that |cur_exp| points to a capsule
node that is in
a ring of equivalent booleans whose value has not yet been defined.

\smallskip\hang
|cur_type==string_type| means that |cur_exp| is a string number (i.e., an
integer in the range |0 <= cur_exp < str_ptr|). That string's reference count
includes this particular reference.

\smallskip\hang
|cur_type==unknown_string| means that |cur_exp| points to a capsule
node that is in
a ring of equivalent strings whose value has not yet been defined.

\smallskip\hang
|cur_type==pen_type| means that |cur_exp| points to a pen header node. This
node contains a reference count, which takes account of this particular
reference.

\smallskip\hang
|cur_type==unknown_pen| means that |cur_exp| points to a capsule
node that is in
a ring of equivalent pens whose value has not yet been defined.

\smallskip\hang
|cur_type==future_pen| means that |cur_exp| points to a knot list that
should eventually be made into a pen. Nobody else points to this particular
knot list. The |future_pen| option occurs only as an output of |scan_primary|
and |scan_secondary|, not as an output of |scan_tertiary| or |scan_expression|.

\smallskip\hang
|cur_type==path_type| means that |cur_exp| points to a the first node of
a path; nobody else points to this particular path. The control points of
the path will have been chosen.

\smallskip\hang
|cur_type==unknown_path| means that |cur_exp| points to a capsule
node that is in
a ring of equivalent paths whose value has not yet been defined.

\smallskip\hang
|cur_type==picture_type| means that |cur_exp| points to an edges header node.
Nobody else points to this particular set of edges.

\smallskip\hang
|cur_type==unknown_picture| means that |cur_exp| points to a capsule
node that is in
a ring of equivalent pictures whose value has not yet been defined.

\smallskip\hang
|cur_type==transform_type| means that |cur_exp| points to a |transform_type|
capsule node. The |value| part of this capsule
points to a transform node that contains six numeric values,
each of which is |independent|, |dependent|, |proto_dependent|, or |known|.

\smallskip\hang
|cur_type==pair_type| means that |cur_exp| points to a capsule
node whose type is |pair_type|. The |value| part of this capsule
points to a pair node that contains two numeric values,
each of which is |independent|, |dependent|, |proto_dependent|, or |known|.

\smallskip\hang
|cur_type==known| means that |cur_exp| is a |scaled| value.

\smallskip\hang
|cur_type==dependent| means that |cur_exp| points to a capsule node whose type
is |dependent|. The |dep_list| field in this capsule points to the associated
dependency list.

\smallskip\hang
|cur_type==proto_dependent| means that |cur_exp| points to a |proto_dependent|
capsule node . The |dep_list| field in this capsule
points to the associated dependency list.

\smallskip\hang
|cur_type==independent| means that |cur_exp| points to a capsule node
whose type is |independent|. This somewhat unusual case can arise, for
example, in the expression
`$x+\&{begingroup}\penalty0\,\&{string}\,x; 0\,\&{endgroup}$'.

\smallskip\hang
|cur_type==token_list| means that |cur_exp| points to a linked list of
tokens.

\smallskip\noindent
The possible settings of |cur_type| have been listed here in increasing
numerical order. Notice that |cur_type| will never be |numeric_type| or
|suffixed_macro| or |unsuffixed_macro|, although variables of those types
are allowed.  Conversely, \MF\ has no variables of type |vacuous| or
|token_list|.

@ Capsules are two-word nodes that have a similar meaning
to |cur_type| and |cur_exp|. Such nodes have |name_type==capsule|,
and their |type| field is one of the possibilities for |cur_type| listed above.
Also |link <= empty| in capsules that aren't part of a token list.

The |value| field of a capsule is, in most cases, the value that
corresponds to its |type|, as |cur_exp| corresponds to |cur_type|.
However, when |cur_exp| would point to a capsule,
no extra layer of indirection is present; the |value|
field is what would have been called |value(cur_exp)| if it had not been
encapsulated.  Furthermore, if the type is |dependent| or
|proto_dependent|, the |value| field of a capsule is replaced by
|dep_list| and |prev_dep| fields, since dependency lists in capsules are
always part of the general |dep_list| structure.

The |get_x_next| routine is careful not to change the values of |cur_type|
and |cur_exp| when it gets an expanded token. However, |get_x_next| might
call a macro, which might parse an expression, which might execute lots of
commands in a group; hence it's possible that |cur_type| might change
from, say, |unknown_boolean| to |boolean_type|, or from |dependent| to
|known| or |independent|, during the time |get_x_next| is called. The
programs below are careful to stash sensitive intermediate results in
capsules, so that \MF's generality doesn't cause trouble.

Here's a procedure that illustrates these conventions. It takes
the contents of $(|cur_type|\kern-.3pt,|cur_exp|\kern-.3pt)$
and stashes them away in a
capsule. It is not used when |cur_type==token_list|.
After the operation, |cur_type==vacuous|; hence there is no need to
copy path lists or to update reference counts, etc.

The special link |empty| is put on the capsule returned by
|stash_cur_exp|, because this procedure is used to store macro parameters
that must be easily distinguishable from token lists.

@<Declare the stashing/unstashing routines@>=
pointer stash_cur_exp(void)
{@+pointer @!p; /*the capsule that will be returned*/ 
switch (cur_type) {
unknown_types: case transform_type: case pair_type: case dependent: case proto_dependent: 
  case independent: p=cur_exp;@+break;
default:{@+p=get_node(value_node_size);name_type(p)=capsule;
  type(p)=cur_type;value(p)=cur_exp;
  } 
} @/
cur_type=vacuous;link(p)=empty;return p;
} 

@ The inverse of |stash_cur_exp| is the following procedure, which
deletes an unnecessary capsule and puts its contents into |cur_type|
and |cur_exp|.

The program steps of \MF\ can be divided into two categories: those in
which |cur_type| and |cur_exp| are ``alive'' and those in which they are
``dead,'' in the sense that |cur_type| and |cur_exp| contain relevant
information or not. It's important not to ignore them when they're alive,
and it's important not to pay attention to them when they're dead.

There's also an intermediate category: If |cur_type==vacuous|, then
|cur_exp| is irrelevant, hence we can proceed without caring if |cur_type|
and |cur_exp| are alive or dead. In such cases we say that |cur_type|
and |cur_exp| are {\sl dormant}. It is permissible to call |get_x_next|
only when they are alive or dormant.

The \\{stash} procedure above assumes that |cur_type| and |cur_exp|
are alive or dormant. The \\{unstash} procedure assumes that they are
dead or dormant; it resuscitates them.

@<Declare the stashing/unstashing...@>=
void unstash_cur_exp(pointer @!p)
{@+cur_type=type(p);
switch (cur_type) {
unknown_types: case transform_type: case pair_type: case dependent: case proto_dependent: 
  case independent: cur_exp=p;@+break;
default:{@+cur_exp=value(p);
  free_node(p, value_node_size);
  } 
} @/
} 

@ The following procedure prints the values of expressions in an
abbreviated format. If its first parameter |p| is null, the value of
|(cur_type, cur_exp)| is displayed; otherwise |p| should be a capsule
containing the desired value. The second parameter controls the amount of
output. If it is~0, dependency lists will be abbreviated to
`\.{linearform}' unless they consist of a single term.  If it is greater
than~1, complicated structures (pens, pictures, and paths) will be displayed
in full.
@.linearform@>

@<Declare subroutines for printing expressions@>=
@t\4@>@<Declare the procedure called |print_dp|@>@;
@t\4@>@<Declare the stashing/unstashing routines@>@;
void print_exp(pointer @!p, small_number @!verbosity)
{@+bool @!restore_cur_exp; /*should |cur_exp| be restored?*/ 
small_number @!t; /*the type of the expression*/ 
int @!v; /*the value of the expression*/ 
pointer @!q; /*a big node being displayed*/ 
if (p!=null) restore_cur_exp=false;
else{@+p=stash_cur_exp();restore_cur_exp=true;
  } 
t=type(p);
if (t < dependent) v=value(p);@+else if (t < independent) v=dep_list(p);
@<Print an abbreviated value of |v| with format depending on |t|@>;
if (restore_cur_exp) unstash_cur_exp(p);
} 

@ @<Print an abbreviated value of |v| with format depending on |t|@>=
switch (t) {
case vacuous: print_str("vacuous");@+break;
case boolean_type: if (v==true_code) print_str("true");@+else print_str("false");@+break;
unknown_types: case numeric_type: @<Display a variable that's been declared but not
defined@>@;@+break;
case string_type: {@+print_char('"');slow_print(v);print_char('"');
  } @+break;
case pen_type: case future_pen: case path_type: case picture_type: @<Display a complex
type@>@;@+break;
case transform_type: case pair_type: if (v==null) print_type(t);
  else@<Display a big node@>@;@+break;
case known: print_scaled(v);@+break;
case dependent: case proto_dependent: print_dp(t, v, verbosity);@+break;
case independent: print_variable_name(p);@+break;
default:confusion(@[@<|"exp"|@>@]);
@:this can't happen exp}{\quad exp@>
} 

@ @<Display a big node@>=
{@+print_char('(');q=v+big_node_size[t];
@/do@+{if (type(v)==known) print_scaled(value(v));
else if (type(v)==independent) print_variable_name(v);
else print_dp(type(v), dep_list(v), verbosity);
v=v+2;
if (v!=q) print_char(',');
}@+ while (!(v==q));
print_char(')');
} 

@ Values of type \&{picture}, \&{path}, and \&{pen} are displayed verbosely
in the log file only, unless the user has given a positive value to
\\{tracingonline}.

@<Display a complex type@>=
if (verbosity <= 1) print_type(t);
else{@+if (selector==term_and_log) 
   if (internal[tracing_online] <= 0) 
    {@+selector=term_only;
    print_type(t);print_str(" (see the transcript file)");
    selector=term_and_log;
    } 
  switch (t) {
  case pen_type: print_pen(v, empty_string, false);@+break;
  case future_pen: print_path(v,@[@<|" (future pen)"|@>@], false);@+break;
  case path_type: print_path(v, empty_string, false);@+break;
  case picture_type: {@+cur_edges=v;print_edges(empty_string, false, 0, 0);
    } 
  }  /*there are no other cases*/ 
  } 

@ @<Declare the procedure called |print_dp|@>=
void print_dp(small_number @!t, pointer @!p, small_number @!verbosity)
{@+pointer @!q; /*the node following |p|*/ 
q=link(p);
if ((info(q)==null)||(verbosity > 0)) print_dependency(p, t);
else print_str("linearform");
@.linearform@>
} 

@ The displayed name of a variable in a ring will not be a capsule unless
the ring consists entirely of capsules.

@<Display a variable that's been declared but not defined@>=
{@+print_type(t);
if (v!=null) 
  {@+print_char(' ');
  while ((name_type(v)==capsule)&&(v!=p)) v=value(v);
  print_variable_name(v);
  } 
} 

@ When errors are detected during parsing, it is often helpful to
display an expression just above the error message, using |exp_err|
or |disp_err| instead of |print_err|.

@d exp_err(X)	disp_err(null, X) /*displays the current expression*/ 

@<Declare subroutines for printing expressions@>=
void disp_err(pointer @!p, str_number @!s)
{@+if (interaction==error_stop_mode) wake_up_terminal;
print_nl(">> ");
@.>>@>
print_exp(p, 1); /*``medium verbose'' printing of the expression*/ 
if (s!=empty_string) 
  {@+print_nl("! ");print(s);
@.!\relax@>
  } 
} 

@ If |cur_type| and |cur_exp| contain relevant information that should
be recycled, we will use the following procedure, which changes |cur_type|
to |known| and stores a given value in |cur_exp|. We can think of |cur_type|
and |cur_exp| as either alive or dormant after this has been done,
because |cur_exp| will not contain a pointer value.

@<Declare the procedure called |flush_cur_exp|@>=
void flush_cur_exp(scaled @!v)
{@+switch (cur_type) {
unknown_types: case transform_type: case pair_type: @|case dependent: case proto_dependent: case independent: 
  {@+recycle_value(cur_exp);free_node(cur_exp, value_node_size);
  } @+break;
case pen_type: delete_pen_ref(cur_exp);@+break;
case string_type: delete_str_ref(cur_exp)@;@+break;
case future_pen: case path_type: toss_knot_list(cur_exp);@+break;
case picture_type: toss_edges(cur_exp);@+break;
default:do_nothing;
} @/
cur_type=known;cur_exp=v;
} 

@ There's a much more general procedure that is capable of releasing
the storage associated with any two-word value packet.

@<Declare the recycling subroutines@>=
void recycle_value(pointer @!p)
{@+
small_number @!t; /*a type code*/ 
int @!v; /*a value*/ 
int @!vv; /*another value*/ 
pointer @!q, @!r, @!s, @!pp; /*link manipulation registers*/ 
t=type(p);
if (t < dependent) v=value(p);
switch (t) {
case undefined: case vacuous: case boolean_type: case known: case numeric_type: do_nothing;@+break;
unknown_types: ring_delete(p);@+break;
case string_type: delete_str_ref(v)@;@+break;
case pen_type: delete_pen_ref(v);@+break;
case path_type: case future_pen: toss_knot_list(v);@+break;
case picture_type: toss_edges(v);@+break;
case pair_type: case transform_type: @<Recycle a big node@>@;@+break;
case dependent: case proto_dependent: @<Recycle a dependency list@>@;@+break;
case independent: @<Recycle an independent variable@>@;@+break;
case token_list: case structured: confusion(@[@<|"recycle"|@>@]);@+break;
@:this can't happen recycle}{\quad recycle@>
case unsuffixed_macro: case suffixed_macro: delete_mac_ref(value(p));
}  /*there are no other cases*/ 
type(p)=undefined;
} 

@ @<Recycle a big node@>=
if (v!=null) 
  {@+q=v+big_node_size[t];
  @/do@+{q=q-2;recycle_value(q);
  }@+ while (!(q==v));
  free_node(v, big_node_size[t]);
  } 

@ @<Recycle a dependency list@>=
{@+q=dep_list(p);
while (info(q)!=null) q=link(q);
link(prev_dep(p))=link(q);
prev_dep(link(q))=prev_dep(p);
link(q)=null;flush_node_list(dep_list(p));
} 

@ When an independent variable disappears, it simply fades away, unless
something depends on it. In the latter case, a dependent variable whose
coefficient of dependence is maximal will take its place.
The relevant algorithm is due to Ignacio~A. Zabala, who implemented it
as part of his Ph.D. thesis (Stanford University, December 1982).
@^Zabala Salelles, Ignacio Andr\'es@>

For example, suppose that variable $x$ is being recycled, and that the
only variables depending on~$x$ are $y=2x+a$ and $z=x+b$. In this case
we want to make $y$ independent and $z=.5y-.5a+b$; no other variables
will depend on~$y$. If $\\{tracingequations}>0$ in this situation,
we will print `\.{\#\#\# -2x=-y+a}'.

There's a slight complication, however: An independent variable $x$
can occur both in dependency lists and in proto-dependency lists.
This makes it necessary to be careful when deciding which coefficient
is maximal.

Furthermore, this complication is not so slight when
a proto-dependent variable is chosen to become independent. For example,
suppose that $y=2x+100a$ is proto-dependent while $z=x+b$ is dependent;
then we must change $z=.5y-50a+b$ to a proto-dependency, because of the
large coefficient `50'.

In order to deal with these complications without wasting too much time,
we shall link together the occurrences of~$x$ among all the linear
dependencies, maintaining separate lists for the dependent and
proto-dependent cases.

@<Recycle an independent variable@>=
{@+max_c[dependent]=0;max_c[proto_dependent]=0;@/
max_link[dependent]=null;max_link[proto_dependent]=null;@/
q=link(dep_head);
while (q!=dep_head) 
  {@+s=value_loc(q); /*now |link(s)==dep_list(q)|*/ 
  loop@+{@+r=link(s);
    if (info(r)==null) goto done;
    if (info(r)!=p) s=r;
    else{@+t=type(q);link(s)=link(r);info(r)=q;
      if (abs(value(r)) > max_c[t]) 
        @<Record a new maximum coefficient of type |t|@>@;
      else{@+link(r)=max_link[t];max_link[t]=r;
        } 
      } 
    } 
done: q=link(r);
  } 
if ((max_c[dependent] > 0)||(max_c[proto_dependent] > 0)) 
  @<Choose a dependent variable to take the place of the disappearing independent
variable, and change all remaining dependencies accordingly@>;
} 

@ The code for independency removal makes use of three two-word arrays.

@<Glob...@>=
int @!max_c0[proto_dependent-dependent+1], *const @!max_c = @!max_c0-dependent;
   /*max coefficient magnitude*/ 
pointer @!max_ptr0[proto_dependent-dependent+1], *const @!max_ptr = @!max_ptr0-dependent;
   /*where |p| occurs with |max_c|*/ 
pointer @!max_link0[proto_dependent-dependent+1], *const @!max_link = @!max_link0-dependent;
   /*other occurrences of |p|*/ 

@ @<Record a new maximum coefficient...@>=
{@+if (max_c[t] > 0) 
  {@+link(max_ptr[t])=max_link[t];max_link[t]=max_ptr[t];
  } 
max_c[t]=abs(value(r));max_ptr[t]=r;
} 

@ @<Choose a dependent...@>=
{@+if ((max_c[dependent]/010000 >= 
          max_c[proto_dependent])) 
  t=dependent;
else t=proto_dependent;
@<Determine the dependency list |s| to substitute for the independent variable~|p|@>;
t=dependent+proto_dependent-t; /*complement |t|*/ 
if (max_c[t] > 0)  /*we need to pick up an unchosen dependency*/ 
  {@+link(max_ptr[t])=max_link[t];max_link[t]=max_ptr[t];
  } 
if (t!=dependent) @<Substitute new dependencies in place of |p|@>@;
else@<Substitute new proto-dependencies in place of |p|@>;
flush_node_list(s);
if (fix_needed) fix_dependencies();
check_arith;
} 

@ Let |s==max_ptr[t]|. At this point we have $|value|(s)=\pm|max_c|[t]$,
and |info(s)| points to the dependent variable~|pp| of type~|t| from
whose dependency list we have removed node~|s|. We must reinsert
node~|s| into the dependency list, with coefficient $-1.0$, and with
|pp| as the new independent variable. Since |pp| will have a larger serial
number than any other variable, we can put node |s| at the head of the
list.

@<Determine the dep...@>=
s=max_ptr[t];pp=info(s);v=value(s);
if (t==dependent) value(s)=-fraction_one;@+else value(s)=-unity;
r=dep_list(pp);link(s)=r;
while (info(r)!=null) r=link(r);
q=link(r);link(r)=null;
prev_dep(q)=prev_dep(pp);link(prev_dep(pp))=q;
new_indep(pp);
if (cur_exp==pp) if (cur_type==t) cur_type=independent;
if (internal[tracing_equations] > 0) @<Show the transformed dependency@>@;

@ Now $(-v)$ times the formerly independent variable~|p| is being replaced
by the dependency list~|s|.

@<Show the transformed...@>=
if (interesting(p)) 
  {@+begin_diagnostic();print_nl("### ");
@:]]]\#\#\#_}{\.{\#\#\#}@>
  if (v > 0) print_char('-');
  if (t==dependent) vv=round_fraction(max_c[dependent]);
  else vv=max_c[proto_dependent];
  if (vv!=unity) print_scaled(vv);
  print_variable_name(p);
  while (value(p)%s_scale > 0) 
    {@+print_str("*4");value(p)=value(p)-2;
    } 
  if (t==dependent) print_char('=');@+else print_str(" = ");
  print_dependency(s, t);
  end_diagnostic(false);
  } 

@ Finally, there are dependent and proto-dependent variables whose
dependency lists must be brought up to date.

@<Substitute new dependencies...@>=
for (t=dependent; t<=proto_dependent; t++) 
  {@+r=max_link[t];
  while (r!=null) 
    {@+q=info(r);
    dep_list(q)=p_plus_fq(dep_list(q),@|
     make_fraction(value(r),-v), s, t, dependent);
    if (dep_list(q)==dep_final) make_known(q, dep_final);
    q=r;r=link(r);free_node(q, dep_node_size);
    } 
  } 

@ @<Substitute new proto...@>=
for (t=dependent; t<=proto_dependent; t++) 
  {@+r=max_link[t];
  while (r!=null) 
    {@+q=info(r);
    if (t==dependent)  /*for safety's sake, we change |q| to |proto_dependent|*/ 
      {@+if (cur_exp==q) if (cur_type==dependent) 
        cur_type=proto_dependent;
      dep_list(q)=p_over_v(dep_list(q), unity, dependent, proto_dependent);
      type(q)=proto_dependent;value(r)=round_fraction(value(r));
      } 
    dep_list(q)=p_plus_fq(dep_list(q),@|
     make_scaled(value(r),-v), s, proto_dependent, proto_dependent);
    if (dep_list(q)==dep_final) make_known(q, dep_final);
    q=r;r=link(r);free_node(q, dep_node_size);
    } 
  } 

@ Here are some routines that provide handy combinations of actions
that are often needed during error recovery. For example,
`|flush_error|' flushes the current expression, replaces it by
a given value, and calls |error|.

Errors often are detected after an extra token has already been scanned.
The `\\{put\_get}' routines put that token back before calling |error|;
then they get it back again. (Or perhaps they get another token, if
the user has changed things.)

@<Declare the procedure called |flush_cur_exp|@>=
void flush_error(scaled @!v)@+{@+error();flush_cur_exp(v);@+} 
@#
void back_error(void);@/
void get_x_next(void);@/
@#
void put_get_error(void)@+{@+back_error();get_x_next();@+} 
@#
void put_get_flush_error(scaled @!v)@+{@+put_get_error();
 flush_cur_exp(v);@+} 

@ A global variable called |var_flag| is set to a special command code
just before \MF\ calls |scan_expression|, if the expression should be
treated as a variable when this command code immediately follows. For
example, |var_flag| is set to |assignment| at the beginning of a
statement, because we want to know the {\sl location\/} of a variable at
the left of `\.{:=}', not the {\sl value\/} of that variable.

The |scan_expression| subroutine calls |scan_tertiary|,
which calls |scan_secondary|, which calls |scan_primary|, which sets
|var_flag=0|. In this way each of the scanning routines ``knows''
when it has been called with a special |var_flag|, but |var_flag| is
usually zero.

A variable preceding a command that equals |var_flag| is converted to a
token list rather than a value. Furthermore, an `\.{=}' sign following an
expression with |var_flag==assignment| is not considered to be a relation
that produces boolean expressions.


@<Glob...@>=
uint8_t @!var_flag; /*command that wants a variable*/ 

@ @<Set init...@>=
var_flag=0;

@* Parsing primary expressions.
The first parsing routine, |scan_primary|, is also the most complicated one,
since it involves so many different cases. But each case---with one
exception---is fairly simple by itself.

When |scan_primary| begins, the first token of the primary to be scanned
should already appear in |cur_cmd|, |cur_mod|, and |cur_sym|. The values
of |cur_type| and |cur_exp| should be either dead or dormant, as explained
earlier. If |cur_cmd| is not between |min_primary_command| and
|max_primary_command|, inclusive, a syntax error will be signalled.

@<Declare the basic parsing subroutines@>=
void scan_primary(void)
{@+
pointer @!p, @!q, @!r; /*for list manipulation*/ 
quarterword @!c; /*a primitive operation code*/ 
uint8_t @!my_var_flag; /*initial value of |var_flag|*/ 
pointer @!l_delim, @!r_delim; /*hash addresses of a delimiter pair*/ 
@<Other local variables for |scan_primary|@>@;
my_var_flag=var_flag;var_flag=0;
restart: check_arith;
@<Supply diagnostic information, if requested@>;
switch (cur_cmd) {
case left_delimiter: @<Scan a delimited primary@>@;@+break;
case begin_group: @<Scan a grouped primary@>@;@+break;
case string_token: @<Scan a string constant@>@;@+break;
case numeric_token: @<Scan a primary that starts with a numeric token@>@;
case nullary: @<Scan a nullary operation@>;@+break;
case unary: case type_name: case cycle: case plus_or_minus: @<Scan a unary operation@>@;
case primary_binary: @<Scan a binary operation with `\&{of}' between its operands@>@;
case str_op: @<Convert a suffix to a string@>@;
case internal_quantity: @<Scan an internal numeric quantity@>@;@+break;
case capsule_token: make_exp_copy(cur_mod);@+break;
case tag_token: @<Scan a variable primary; |goto restart| if it turns out to be a
macro@>@;
default:{@+bad_exp(@[@<|"A primary"|@>@]);goto restart;
@.A primary expression...@>
  } 
} @/
get_x_next(); /*the routines |goto done| if they don't want this*/ 
done: if (cur_cmd==left_bracket) 
  if (cur_type >= known) @<Scan a mediation construction@>;
} 

@ Errors at the beginning of expressions are flagged by |bad_exp|.

@p void bad_exp(str_number @!s)
{@+uint8_t save_flag;
print_nl("! ");print(s);print_str(" expression can't begin with `");
print_cmd_mod(cur_cmd, cur_mod);print_char('\'');
help4("I'm afraid I need some sort of value in order to continue,")@/
  ("so I've tentatively inserted `0'. You may want to")@/
  ("delete this zero and insert something else;")@/
  ("see Chapter 27 of The METAFONTbook for an example.");
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
back_input();cur_sym=0;cur_cmd=numeric_token;cur_mod=0;ins_error();@/
save_flag=var_flag;var_flag=0;get_x_next();
var_flag=save_flag;
} 

@ @<Supply diagnostic information, if requested@>=
#ifdef @!DEBUG
if (panicking) check_mem(false);
#endif
@;@/
if (interrupt!=0) if (OK_to_interrupt) 
  {@+back_input();check_interrupt;get_x_next();
  } 

@ @<Scan a delimited primary@>=
{@+l_delim=cur_sym;r_delim=cur_mod;get_x_next();scan_expression();
if ((cur_cmd==comma)&&(cur_type >= known)) 
  @<Scan the second of a pair of numerics@>@;
else check_delimiter(l_delim, r_delim);
} 

@ The |stash_in| subroutine puts the current (numeric) expression into a field
within a ``big node.''

@p void stash_in(pointer @!p)
{@+pointer @!q; /*temporary register*/ 
type(p)=cur_type;
if (cur_type==known) value(p)=cur_exp;
else{@+if (cur_type==independent) 
    @<Stash an independent |cur_exp| into a big node@>@;
  else{@+mem[value_loc(p)]=mem[value_loc(cur_exp)];
      /*|dep_list(p)=dep_list(cur_exp)| and |prev_dep(p)=prev_dep(cur_exp)|*/ 
    link(prev_dep(p))=p;
    } 
  free_node(cur_exp, value_node_size);
  } 
cur_type=vacuous;
} 

@ In rare cases the current expression can become |independent|. There
may be many dependency lists pointing to such an independent capsule,
so we can't simply move it into place within a big node. Instead,
we copy it, then recycle it.

@ @<Stash an independent |cur_exp|...@>=
{@+q=single_dependency(cur_exp);
if (q==dep_final) 
  {@+type(p)=known;value(p)=0;free_node(q, dep_node_size);
  } 
else{@+type(p)=dependent;new_dep(p, q);
  } 
recycle_value(cur_exp);
} 

@ @<Scan the second of a pair of numerics@>=
{@+p=get_node(value_node_size);type(p)=pair_type;name_type(p)=capsule;
init_big_node(p);q=value(p);stash_in(x_part_loc(q));@/
get_x_next();scan_expression();
if (cur_type < known) 
  {@+exp_err(@[@<|"Nonnumeric ypart has been replaced by 0"|@>@]);
@.Nonnumeric...replaced by 0@>
  help4("I thought you were giving me a pair `(x,y)'; but")@/
    ("after finding a nice xpart `x' I found a ypart `y'")@/
    ("that isn't of numeric type. So I've changed y to zero.")@/
    ("(The y that I didn't like appears above the error message.)");
  put_get_flush_error(0);
  } 
stash_in(y_part_loc(q));
check_delimiter(l_delim, r_delim);
cur_type=pair_type;cur_exp=p;
} 

@ The local variable |group_line| keeps track of the line
where a \&{begingroup} command occurred; this will be useful
in an error message if the group doesn't actually end.

@<Other local variables for |scan_primary|@>=
int @!group_line; /*where a group began*/ 

@ @<Scan a grouped primary@>=
{@+group_line=line;
if (internal[tracing_commands] > 0) show_cur_cmd_mod;
save_boundary_item(p);
@/do@+{do_statement(); /*ends with |cur_cmd >= semicolon|*/ 
}@+ while (!(cur_cmd!=semicolon));
if (cur_cmd!=end_group) 
  {@+print_err("A group begun on line ");
@.A group...never ended@>
  print_int(group_line);
  print_str(" never ended");
  help2("I saw a `begingroup' back there that hasn't been matched")@/
    ("by `endgroup'. So I've inserted `endgroup' now.");
  back_error();cur_cmd=end_group;
  } 
unsave(); /*this might change |cur_type|, if independent variables are recycled*/ 
if (internal[tracing_commands] > 0) show_cur_cmd_mod;
} 

@ @<Scan a string constant@>=
{@+cur_type=string_type;cur_exp=cur_mod;
} 

@ Later we'll come to procedures that perform actual operations like
addition, square root, and so on; our purpose now is to do the parsing.
But we might as well mention those future procedures now, so that the
suspense won't be too bad:

\smallskip
|do_nullary(c)| does primitive operations that have no operands (e.g.,
`\&{true}' or `\&{pencircle}');

\smallskip
|do_unary(c)| applies a primitive operation to the current expression;

\smallskip
|do_binary(p, c)| applies a primitive operation to the capsule~|p|
and the current expression.

@<Scan a nullary operation@>=do_nullary(cur_mod)

@ @<Scan a unary operation@>=
{@+c=cur_mod;get_x_next();scan_primary();do_unary(c);goto done;
} 

@ A numeric token might be a primary by itself, or it might be the
numerator of a fraction composed solely of numeric tokens, or it might
multiply the primary that follows (provided that the primary doesn't begin
with a plus sign or a minus sign). The code here uses the facts that
|max_primary_command==plus_or_minus| and
|max_primary_command-1==numeric_token|. If a fraction is found that is less
than unity, we try to retain higher precision when we use it in scalar
multiplication.

@<Other local variables for |scan_primary|@>=
scaled @!num, @!denom; /*for primaries that are fractions, like `1/2'*/ 

@ @<Scan a primary that starts with a numeric token@>=
{@+cur_exp=cur_mod;cur_type=known;get_x_next();
if (cur_cmd!=slash) 
  {@+num=0;denom=0;
  } 
else{@+get_x_next();
  if (cur_cmd!=numeric_token) 
    {@+back_input();
    cur_cmd=slash;cur_mod=over;cur_sym=frozen_slash;
    goto done;
    } 
  num=cur_exp;denom=cur_mod;
  if (denom==0) @<Protest division by zero@>@;
  else cur_exp=make_scaled(num, denom);
  check_arith;get_x_next();
  } 
if (cur_cmd >= min_primary_command) 
 if (cur_cmd < numeric_token)  /*in particular, |cur_cmd!=plus_or_minus|*/ 
  {@+p=stash_cur_exp();scan_primary();
  if ((abs(num) >= abs(denom))||(cur_type < pair_type)) do_binary(p, times);
  else{@+frac_mult(num, denom);
    free_node(p, value_node_size);
    } 
  } 
goto done;
} 

@ @<Protest division...@>=
{@+print_err("Division by zero");
@.Division by zero@>
help1("I'll pretend that you meant to divide by 1.");error();
} 

@ @<Scan a binary operation with `\&{of}' between its operands@>=
{@+c=cur_mod;get_x_next();scan_expression();
if (cur_cmd!=of_token) 
  {@+missing_err(@[@<|"of"|@>@]);print_str(" for ");print_cmd_mod(primary_binary, c);
@.Missing `of'@>
  help1("I've got the first argument; will look now for the other.");
  back_error();
  } 
p=stash_cur_exp();get_x_next();scan_primary();do_binary(p, c);goto done;
} 

@ @<Convert a suffix to a string@>=
{@+get_x_next();scan_suffix();old_setting=selector;selector=new_string;
show_token_list(cur_exp, null, 100000, 0);flush_token_list(cur_exp);
cur_exp=make_string();selector=old_setting;cur_type=string_type;
goto done;
} 

@ If an internal quantity appears all by itself on the left of an
assignment, we return a token list of length one, containing the address
of the internal quantity plus |hash_end|. (This accords with the conventions
of the save stack, as described earlier.)

@<Scan an internal...@>=
{@+q=cur_mod;
if (my_var_flag==assignment) 
  {@+get_x_next();
  if (cur_cmd==assignment) 
    {@+cur_exp=get_avail();
    info(cur_exp)=q+hash_end;cur_type=token_list;goto done;
    } 
  back_input();
  } 
cur_type=known;cur_exp=internal[q];
} 

@ The most difficult part of |scan_primary| has been saved for last, since
it was necessary to build up some confidence first. We can now face the task
of scanning a variable.

As we scan a variable, we build a token list containing the relevant
names and subscript values, simultaneously following along in the
``collective'' structure to see if we are actually dealing with a macro
instead of a value.

The local variables |pre_head| and |post_head| will point to the beginning
of the prefix and suffix lists; |tail| will point to the end of the list
that is currently growing.

Another local variable, |tt|, contains partial information about the
declared type of the variable-so-far. If |tt >= unsuffixed_macro|, the
relation |tt==type(q)| will always hold. If |tt==undefined|, the routine
doesn't bother to update its information about type. And if
|undefined < tt < unsuffixed_macro|, the precise value of |tt| isn't critical.

@ @<Other local variables for |scan_primary|@>=
pointer @!pre_head, @!post_head, @!tail;
   /*prefix and suffix list variables*/ 
small_number @!tt; /*approximation to the type of the variable-so-far*/ 
pointer @!t; /*a token*/ 
pointer @!macro_ref; /*reference count for a suffixed macro*/ 

@ @<Scan a variable primary...@>=
{@+fast_get_avail(pre_head);tail=pre_head;post_head=null;tt=vacuous;
loop@+{@+t=cur_tok();link(tail)=t;
  if (tt!=undefined) 
    {@+@<Find the approximate type |tt| and corresponding~|q|@>;
    if (tt >= unsuffixed_macro) 
      @<Either begin an unsuffixed macro call or prepare for a suffixed one@>;
    } 
  get_x_next();tail=t;
  if (cur_cmd==left_bracket) 
    @<Scan for a subscript; replace |cur_cmd| by |numeric_token| if found@>;
  if (cur_cmd > max_suffix_token) goto done1;
  if (cur_cmd < min_suffix_token) goto done1;
  }  /*now |cur_cmd| is |internal_quantity|, |tag_token|, or |numeric_token|*/ 
done1: @<Handle unusual cases that masquerade as variables, and |goto restart| or
|goto done| if appropriate; otherwise make a copy of the variable and |goto done|@>;
} 

@ @<Either begin an unsuffixed macro call or...@>=
{@+link(tail)=null;
if (tt > unsuffixed_macro)  /*|tt==suffixed_macro|*/ 
  {@+post_head=get_avail();tail=post_head;link(tail)=t;@/
  tt=undefined;macro_ref=value(q);add_mac_ref(macro_ref);
  } 
else@<Set up unsuffixed macro call and |goto restart|@>;
} 

@ @<Scan for a subscript; replace |cur_cmd| by |numeric_token| if found@>=
{@+get_x_next();scan_expression();
if (cur_cmd!=right_bracket) 
  @<Put the left bracket and the expression back to be rescanned@>@;
else{@+if (cur_type!=known) bad_subscript();
  cur_cmd=numeric_token;cur_mod=cur_exp;cur_sym=0;
  } 
} 

@ The left bracket that we thought was introducing a subscript might have
actually been the left bracket in a mediation construction like `\.{x[a,b]}'.
So we don't issue an error message at this point; but we do want to back up
so as to avoid any embarrassment about our incorrect assumption.

@<Put the left bracket and the expression back to be rescanned@>=
{@+back_input(); /*that was the token following the current expression*/ 
back_expr();cur_cmd=left_bracket;cur_mod=0;cur_sym=frozen_left_bracket;
} 

@ Here's a routine that puts the current expression back to be read again.

@p void back_expr(void)
{@+pointer @!p; /*capsule token*/ 
p=stash_cur_exp();link(p)=null;back_list(p);
} 

@ Unknown subscripts lead to the following error message.

@p void bad_subscript(void)
{@+exp_err(@[@<|"Improper subscript has been replaced by zero"|@>@]);
@.Improper subscript...@>
help3("A bracketed subscript must have a known numeric value;")@/
  ("unfortunately, what I found was the value that appears just")@/
  ("above this error message. So I'll try a zero subscript.");
flush_error(0);
} 

@ Every time we call |get_x_next|, there's a chance that the variable we've
been looking at will disappear. Thus, we cannot safely keep |q| pointing
into the variable structure; we need to start searching from the root each time.

@<Find the approximate type |tt| and corresponding~|q|@>=
@^inner loop@>
{@+p=link(pre_head);q=info(p);tt=undefined;
if (eq_type(q)%outer_tag==tag_token) 
  {@+q=equiv(q);
  if (q==null) goto done2;
  loop@+{@+p=link(p);
    if (p==null) 
      {@+tt=type(q);goto done2;
      } 
    if (type(q)!=structured) goto done2;
    q=link(attr_head(q)); /*the |collective_subscript| attribute*/ 
    if (p >= hi_mem_min)  /*it's not a subscript*/ 
      {@+@/do@+{q=link(q);
      }@+ while (!(attr_loc(q) >= info(p)));
      if (attr_loc(q) > info(p)) goto done2;
      } 
    } 
  } 
done2: ;} 

@ How do things stand now? Well, we have scanned an entire variable name,
including possible subscripts and/or attributes; |cur_cmd|, |cur_mod|, and
|cur_sym| represent the token that follows. If |post_head==null|, a
token list for this variable name starts at |link(pre_head)|, with all
subscripts evaluated. But if |post_head!=null|, the variable turned out
to be a suffixed macro; |pre_head| is the head of the prefix list, while
|post_head| is the head of a token list containing both `\.{\AT!}' and
the suffix.

Our immediate problem is to see if this variable still exists. (Variable
structures can change drastically whenever we call |get_x_next|; users
aren't supposed to do this, but the fact that it is possible means that
we must be cautious.)

The following procedure prints an error message when a variable
unexpectedly disappears. Its help message isn't quite right for
our present purposes, but we'll be able to fix that up.

@p void obliterated(pointer @!q)
{@+print_err("Variable ");show_token_list(q, null, 1000, 0);
print_str(" has been obliterated");
@.Variable...obliterated@>
help5("It seems you did a nasty thing---probably by accident,")@/
  ("but nevertheless you nearly hornswoggled me...")@/
  ("While I was evaluating the right-hand side of this")@/
  ("command, something happened, and the left-hand side")@/
  ("is no longer a variable! So I won't change anything.");
} 

@ If the variable does exist, we also need to check
for a few other special cases before deciding that a plain old ordinary
variable has, indeed, been scanned.

@<Handle unusual cases that masquerade as variables...@>=
if (post_head!=null) @<Set up suffixed macro call and |goto restart|@>;
q=link(pre_head);free_avail(pre_head);
if (cur_cmd==my_var_flag) 
  {@+cur_type=token_list;cur_exp=q;goto done;
  } 
p=find_variable(q);
if (p!=null) make_exp_copy(p);
else{@+obliterated(q);@/
  help_line[2]="While I was evaluating the suffix of this variable,";
  help_line[1]="something was redefined, and it's no longer a variable!";
  help_line[0]="In order to get back on my feet, I've inserted `0' instead.";
  put_get_flush_error(0);
  } 
flush_node_list(q);goto done

@ The only complication associated with macro calling is that the prefix
and ``at'' parameters must be packaged in an appropriate list of lists.

@<Set up unsuffixed macro call and |goto restart|@>=
{@+p=get_avail();info(pre_head)=link(pre_head);link(pre_head)=p;
info(p)=t;macro_call(value(q), pre_head, null);get_x_next();goto restart;
} 

@ If the ``variable'' that turned out to be a suffixed macro no longer exists,
we don't care, because we have reserved a pointer (|macro_ref|) to its
token list.

@<Set up suffixed macro call and |goto restart|@>=
{@+back_input();p=get_avail();q=link(post_head);
info(pre_head)=link(pre_head);link(pre_head)=post_head;
info(post_head)=q;link(post_head)=p;info(p)=link(q);link(q)=null;
macro_call(macro_ref, pre_head, null);decr(ref_count(macro_ref));
get_x_next();goto restart;
} 

@ Our remaining job is simply to make a copy of the value that has been
found. Some cases are harder than others, but complexity arises solely
because of the multiplicity of possible cases.

@<Declare the procedure called |make_exp_copy|@>=
@t\4@>@<Declare subroutines needed by |make_exp_copy|@>@;
void make_exp_copy(pointer @!p)
{@+
pointer @!q, @!r, @!t; /*registers for list manipulation*/ 
restart: cur_type=type(p);
switch (cur_type) {
case vacuous: case boolean_type: case known: cur_exp=value(p);@+break;
unknown_types: cur_exp=new_ring_entry(p);@+break;
case string_type: {@+cur_exp=value(p);add_str_ref(cur_exp);
  } @+break;
case pen_type: {@+cur_exp=value(p);add_pen_ref(cur_exp);
  } @+break;
case picture_type: cur_exp=copy_edges(value(p));@+break;
case path_type: case future_pen: cur_exp=copy_path(value(p));@+break;
case transform_type: case pair_type: @<Copy the big node |p|@>@;@+break;
case dependent: case proto_dependent: encapsulate(copy_dep_list(dep_list(p)));@+break;
case numeric_type: {@+new_indep(p);goto restart;
  } 
case independent: {@+q=single_dependency(p);
  if (q==dep_final) 
    {@+cur_type=known;cur_exp=0;free_node(q, dep_node_size);
    } 
  else{@+cur_type=dependent;encapsulate(q);
    } 
  } @+break;
default:confusion(@[@<|"copy"|@>@]);
@:this can't happen copy}{\quad copy@>
} 
} 

@ The |encapsulate| subroutine assumes that |dep_final| is the
tail of dependency list~|p|.

@<Declare subroutines needed by |make_exp_copy|@>=
void encapsulate(pointer @!p)
{@+cur_exp=get_node(value_node_size);type(cur_exp)=cur_type;
name_type(cur_exp)=capsule;new_dep(cur_exp, p);
} 

@ The most tedious case arises when the user refers to a
\&{pair} or \&{transform} variable; we must copy several fields,
each of which can be |independent|, |dependent|, |proto_dependent|,
or |known|.

@<Copy the big node |p|@>=
{@+if (value(p)==null) init_big_node(p);
t=get_node(value_node_size);name_type(t)=capsule;type(t)=cur_type;
init_big_node(t);@/
q=value(p)+big_node_size[cur_type];r=value(t)+big_node_size[cur_type];
@/do@+{q=q-2;r=r-2;install(r, q);
}@+ while (!(q==value(p)));
cur_exp=t;
} 

@ The |install| procedure copies a numeric field~|q| into field~|r| of
a big node that will be part of a capsule.

@<Declare subroutines needed by |make_exp_copy|@>=
void install(pointer @!r, pointer @!q)
{@+pointer p; /*temporary register*/ 
if (type(q)==known) 
  {@+value(r)=value(q);type(r)=known;
  } 
else if (type(q)==independent) 
    {@+p=single_dependency(q);
    if (p==dep_final) 
      {@+type(r)=known;value(r)=0;free_node(p, dep_node_size);
      } 
    else{@+type(r)=dependent;new_dep(r, p);
      } 
    } 
  else{@+type(r)=type(q);new_dep(r, copy_dep_list(dep_list(q)));
    } 
} 

@ Expressions of the form `\.{a[b,c]}' are converted into
`\.{b+a*(c-b)}', without checking the types of \.b~or~\.c,
provided that \.a is numeric.

@<Scan a mediation...@>=
{@+p=stash_cur_exp();get_x_next();scan_expression();
if (cur_cmd!=comma) 
  {@+@<Put the left bracket and the expression back...@>;
  unstash_cur_exp(p);
  } 
else{@+q=stash_cur_exp();get_x_next();scan_expression();
  if (cur_cmd!=right_bracket) 
    {@+missing_err(']');@/
@.Missing `]'@>
    help3("I've scanned an expression of the form `a[b,c',")@/
      ("so a right bracket should have come next.")@/
      ("I shall pretend that one was there.");@/
    back_error();
    } 
  r=stash_cur_exp();make_exp_copy(q);@/
  do_binary(r, minus);do_binary(p, times);do_binary(q, plus);get_x_next();
  } 
} 

@ Here is a comparatively simple routine that is used to scan the
\&{suffix} parameters of a macro.

@<Declare the basic parsing subroutines@>=
void scan_suffix(void)
{@+
pointer @!h, @!t; /*head and tail of the list being built*/ 
pointer @!p; /*temporary register*/ 
h=get_avail();t=h;
loop@+{@+if (cur_cmd==left_bracket) 
    @<Scan a bracketed subscript and set |cur_cmd:=numeric_token|@>;
  if (cur_cmd==numeric_token) p=new_num_tok(cur_mod);
  else if ((cur_cmd==tag_token)||(cur_cmd==internal_quantity)) 
    {@+p=get_avail();info(p)=cur_sym;
    } 
  else goto done;
  link(t)=p;t=p;get_x_next();
  } 
done: cur_exp=link(h);free_avail(h);cur_type=token_list;
} 

@ @<Scan a bracketed subscript and set |cur_cmd:=numeric_token|@>=
{@+get_x_next();scan_expression();
if (cur_type!=known) bad_subscript();
if (cur_cmd!=right_bracket) 
  {@+missing_err(']');@/
@.Missing `]'@>
  help3("I've seen a `[' and a subscript value, in a suffix,")@/
    ("so a right bracket should have come next.")@/
    ("I shall pretend that one was there.");@/
  back_error();
  } 
cur_cmd=numeric_token;cur_mod=cur_exp;
} 

@* Parsing secondary and higher expressions.
After the intricacies of |scan_primary|\kern-1pt,
the |scan_secondary| routine is
refreshingly simple. It's not trivial, but the operations are relatively
straightforward; the main difficulty is, again, that expressions and data
structures might change drastically every time we call |get_x_next|, so a
cautious approach is mandatory. For example, a macro defined by
\&{primarydef} might have disappeared by the time its second argument has
been scanned; we solve this by increasing the reference count of its token
list, so that the macro can be called even after it has been clobbered.

@<Declare the basic parsing subroutines@>=
void scan_secondary(void)
{@+
pointer @!p; /*for list manipulation*/ 
halfword @!c, @!d; /*operation codes or modifiers*/ 
pointer @!mac_name; /*token defined with \&{primarydef}*/ 
restart: if ((cur_cmd < min_primary_command)||@|
 (cur_cmd > max_primary_command)) 
  bad_exp(@[@<|"A secondary"|@>@]);
@.A secondary expression...@>
scan_primary();
resume: if (cur_cmd <= max_secondary_command) 
 if (cur_cmd >= min_secondary_command) 
  {@+p=stash_cur_exp();c=cur_mod;d=cur_cmd;
  if (d==secondary_primary_macro) 
    {@+mac_name=cur_sym;add_mac_ref(c);
    } 
  get_x_next();scan_primary();
  if (d!=secondary_primary_macro) do_binary(p, c);
  else{@+back_input();binary_mac(p, c, mac_name);
    decr(ref_count(c));get_x_next();goto restart;
    } 
  goto resume;
  } 
} 

@ The following procedure calls a macro that has two parameters,
|p| and |cur_exp|.

@p void binary_mac(pointer @!p, pointer @!c, pointer @!n)
{@+pointer @!q, @!r; /*nodes in the parameter list*/ 
q=get_avail();r=get_avail();link(q)=r;@/
info(q)=p;info(r)=stash_cur_exp();@/
macro_call(c, q, n);
} 

@ The next procedure, |scan_tertiary|, is pretty much the same deal.

@<Declare the basic parsing subroutines@>=
void scan_tertiary(void)
{@+
pointer @!p; /*for list manipulation*/ 
halfword @!c, @!d; /*operation codes or modifiers*/ 
pointer @!mac_name; /*token defined with \&{secondarydef}*/ 
restart: if ((cur_cmd < min_primary_command)||@|
 (cur_cmd > max_primary_command)) 
  bad_exp(@[@<|"A tertiary"|@>@]);
@.A tertiary expression...@>
scan_secondary();
if (cur_type==future_pen) materialize_pen();
resume: if (cur_cmd <= max_tertiary_command) 
 if (cur_cmd >= min_tertiary_command) 
  {@+p=stash_cur_exp();c=cur_mod;d=cur_cmd;
  if (d==tertiary_secondary_macro) 
    {@+mac_name=cur_sym;add_mac_ref(c);
    } 
  get_x_next();scan_secondary();
  if (d!=tertiary_secondary_macro) do_binary(p, c);
  else{@+back_input();binary_mac(p, c, mac_name);
    decr(ref_count(c));get_x_next();goto restart;
    } 
  goto resume;
  } 
} 

@ A |future_pen| becomes a full-fledged pen here.

@p void materialize_pen(void)
{@+
scaled @!a_minus_b, @!a_plus_b, @!major_axis, @!minor_axis; /*ellipse variables*/ 
angle @!theta; /*amount by which the ellipse has been rotated*/ 
pointer @!p; /*path traverser*/ 
pointer @!q; /*the knot list to be made into a pen*/ 
q=cur_exp;
if (left_type(q)==endpoint) 
  {@+print_err("Pen path must be a cycle");
@.Pen path must be a cycle@>
  help2("I can't make a pen from the given path.")@/
  ("So I've replaced it by the trivial path `(0,0)..cycle'.");
  put_get_error();cur_exp=null_pen;goto common_ending;
  } 
else if (left_type(q)==open) 
  @<Change node |q| to a path for an elliptical pen@>;
cur_exp=make_pen(q);
common_ending: toss_knot_list(q);cur_type=pen_type;
} 

@ We placed the three points $(0,0)$, $(1,0)$, $(0,1)$ into a \&{pencircle},
and they have now been transformed to $(u,v)$, $(A+u,B+v)$, $(C+u,D+v)$;
this gives us enough information to deduce the transformation
$(x,y)\mapsto(Ax+Cy+u,Bx+Dy+v)$.

Given ($A,B,C,D)$ we can always find $(a,b,\theta,\phi)$ such that
$$\eqalign{A&=a\cos\phi\cos\theta-b\sin\phi\sin\theta;\cr
B&=a\cos\phi\sin\theta+b\sin\phi\cos\theta;\cr
C&=-a\sin\phi\cos\theta-b\cos\phi\sin\theta;\cr
D&=-a\sin\phi\sin\theta+b\cos\phi\cos\theta.\cr}$$
In this notation, the unit circle $(\cos t,\sin t)$ is transformed into
$$\bigl(a\cos(\phi+t)\cos\theta-b\sin(\phi+t)\sin\theta,\;
a\cos(\phi+t)\sin\theta+b\sin(\phi+t)\cos\theta\bigr)\;+\;(u,v),$$
which is an ellipse with semi-axes~$(a,b)$, rotated by~$\theta$ and
shifted by~$(u,v)$. To solve the stated equations, we note that it is
necessary and sufficient to solve
$$\eqalign{A-D&=(a-b)\cos(\theta-\phi),\cr
B+C&=(a-b)\sin(\theta-\phi),\cr}
\qquad
\eqalign{A+D&=(a+b)\cos(\theta+\phi),\cr
B-C&=(a+b)\sin(\theta+\phi);\cr}$$
and it is easy to find $a-b$, $a+b$, $\theta-\phi$, and $\theta+\phi$
from these formulas.

The code below uses |(txx, tyx, txy, tyy, tx, ty)| to stand for
$(A,B,C,D,u,v)$.

@<Change node |q|...@>=
{@+tx=x_coord(q);ty=y_coord(q);
txx=left_x(q)-tx;tyx=left_y(q)-ty;
txy=right_x(q)-tx;tyy=right_y(q)-ty;
a_minus_b=pyth_add(txx-tyy, tyx+txy);a_plus_b=pyth_add(txx+tyy, tyx-txy);
major_axis=half(a_minus_b+a_plus_b);minor_axis=half(abs(a_plus_b-a_minus_b));
if (major_axis==minor_axis) theta=0; /*circle*/ 
else theta=half(n_arg(txx-tyy, tyx+txy)+n_arg(txx+tyy, tyx-txy));
free_node(q, knot_node_size);
q=make_ellipse(major_axis, minor_axis, theta);
if ((tx!=0)||(ty!=0)) @<Shift the coordinates of path |q|@>;
} 

@ @<Shift the coordinates of path |q|@>=
{@+p=q;
@/do@+{x_coord(p)=x_coord(p)+tx;y_coord(p)=y_coord(p)+ty;p=link(p);
}@+ while (!(p==q));
} 

@ Finally we reach the deepest level in our quartet of parsing routines.
This one is much like the others; but it has an extra complication from
paths, which materialize here.

@<Declare the basic parsing subroutines@>=
void scan_expression(void)
{@+
pointer @!p, @!q, @!r, @!pp, @!qq; /*for list manipulation*/ 
halfword @!c, @!d; /*operation codes or modifiers*/ 
uint8_t @!my_var_flag; /*initial value of |var_flag|*/ 
pointer @!mac_name; /*token defined with \&{tertiarydef}*/ 
bool @!cycle_hit; /*did a path expression just end with `\&{cycle}'?*/ 
scaled @!x, @!y; /*explicit coordinates or tension at a path join*/ 
uint8_t @!t; /*knot type following a path join*/ 
my_var_flag=var_flag;
restart: if ((cur_cmd < min_primary_command)||@|
 (cur_cmd > max_primary_command)) 
  bad_exp(@[@<|"An"|@>@]);
@.An expression...@>
scan_tertiary();
resume: if (cur_cmd <= max_expression_command) 
 if (cur_cmd >= min_expression_command) 
  if ((cur_cmd!=equals)||(my_var_flag!=assignment)) 
  {@+p=stash_cur_exp();c=cur_mod;d=cur_cmd;
  if (d==expression_tertiary_macro) 
    {@+mac_name=cur_sym;add_mac_ref(c);
    } 
  if ((d < ampersand)||((d==ampersand)&&@|
   ((type(p)==pair_type)||(type(p)==path_type)))) 
    @<Scan a path construction operation; but |return| if |p| has the wrong type@>@;
  else{@+get_x_next();scan_tertiary();
    if (d!=expression_tertiary_macro) do_binary(p, c);
    else{@+back_input();binary_mac(p, c, mac_name);
      decr(ref_count(c));get_x_next();goto restart;
      } 
    } 
  goto resume;
  } 
} 

@ The reader should review the data structure conventions for paths before
hoping to understand the next part of this code.

@<Scan a path construction operation...@>=
{@+cycle_hit=false;
@<Convert the left operand, |p|, into a partial path ending at~|q|; but |return| if
|p| doesn't have a suitable type@>;
continue_path: @<Determine the path join parameters; but |goto finish_path| if there's
only a direction specifier@>;
if (cur_cmd==cycle) @<Get ready to close a cycle@>@;
else{@+scan_tertiary();
  @<Convert the right operand, |cur_exp|, into a partial path from |pp| to~|qq|@>;
  } 
@<Join the partial paths and reset |p| and |q| to the head and tail of the result@>;
if (cur_cmd >= min_expression_command) 
 if (cur_cmd <= ampersand) if (!cycle_hit) goto continue_path;
finish_path: 
@<Choose control points for the path and put the result into |cur_exp|@>;
} 

@ @<Convert the left operand, |p|, into a partial path ending at~|q|...@>=
{@+unstash_cur_exp(p);
if (cur_type==pair_type) p=new_knot();
else if (cur_type==path_type) p=cur_exp;
else return;
q=p;
while (link(q)!=p) q=link(q);
if (left_type(p)!=endpoint)  /*open up a cycle*/ 
  {@+r=copy_knot(p);link(q)=r;q=r;
  } 
left_type(p)=open;right_type(q)=open;
} 

@ A pair of numeric values is changed into a knot node for a one-point path
when \MF\ discovers that the pair is part of a path.

@p@t\4@>@<Declare the procedure called |known_pair|@>@;
pointer new_knot(void) /*convert a pair to a knot with two endpoints*/ 
{@+pointer @!q; /*the new node*/ 
q=get_node(knot_node_size);left_type(q)=endpoint;
right_type(q)=endpoint;link(q)=q;@/
known_pair();x_coord(q)=cur_x;y_coord(q)=cur_y;
return q;
} 

@ The |known_pair| subroutine sets |cur_x| and |cur_y| to the components
of the current expression, assuming that the current expression is a
pair of known numerics. Unknown components are zeroed, and the
current expression is flushed.

@<Declare the procedure called |known_pair|@>=
void known_pair(void)
{@+pointer @!p; /*the pair node*/ 
if (cur_type!=pair_type) 
  {@+exp_err(@[@<|"Undefined coordinates have been replaced by (0,0)"|@>@]);
@.Undefined coordinates...@>
  help5("I need x and y numbers for this part of the path.")@/
    ("The value I found (see above) was no good;")@/
    ("so I'll try to keep going by using zero instead.")@/
    ("(Chapter 27 of The METAFONTbook explains that")@/
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
    ("you might want to type `I ?\?\?' now.)");
  put_get_flush_error(0);cur_x=0;cur_y=0;
  } 
else{@+p=value(cur_exp);
  @<Make sure that both |x| and |y| parts of |p| are known; copy them into |cur_x|
and |cur_y|@>;
  flush_cur_exp(0);
  } 
} 

@ @<Make sure that both |x| and |y| parts of |p| are known...@>=
if (type(x_part_loc(p))==known) cur_x=value(x_part_loc(p));
else{@+disp_err(x_part_loc(p),
    @[@<|"Undefined x coordinate has been replaced by 0"|@>@]);
@.Undefined coordinates...@>
  help5("I need a `known' x value for this part of the path.")@/
    ("The value I found (see above) was no good;")@/
    ("so I'll try to keep going by using zero instead.")@/
    ("(Chapter 27 of The METAFONTbook explains that")@/
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
    ("you might want to type `I ?\?\?' now.)");
  put_get_error();recycle_value(x_part_loc(p));cur_x=0;
  } 
if (type(y_part_loc(p))==known) cur_y=value(y_part_loc(p));
else{@+disp_err(y_part_loc(p),
    @[@<|"Undefined y coordinate has been replaced by 0"|@>@]);
  help5("I need a `known' y value for this part of the path.")@/
    ("The value I found (see above) was no good;")@/
    ("so I'll try to keep going by using zero instead.")@/
    ("(Chapter 27 of The METAFONTbook explains that")@/
    ("you might want to type `I ?\?\?' now.)");
  put_get_error();recycle_value(y_part_loc(p));cur_y=0;
  } 

@ At this point |cur_cmd| is either |ampersand|, |left_brace|, or |path_join|.

@<Determine the path join parameters...@>=
if (cur_cmd==left_brace) 
  @<Put the pre-join direction information into node |q|@>;
d=cur_cmd;
if (d==path_join) @<Determine the tension and/or control points@>@;
else if (d!=ampersand) goto finish_path;
get_x_next();
if (cur_cmd==left_brace) 
  @<Put the post-join direction information into |x| and |t|@>@;
else if (right_type(q)!=explicit) 
  {@+t=open;x=0;
  } 

@ The |scan_direction| subroutine looks at the directional information
that is enclosed in braces, and also scans ahead to the following character.
A type code is returned, either |open| (if the direction was $(0,0)$),
or |curl| (if the direction was a curl of known value |cur_exp|), or
|given| (if the direction is given by the |angle| value that now
appears in |cur_exp|).

There's nothing difficult about this subroutine, but the program is rather
lengthy because a variety of potential errors need to be nipped in the bud.

@p small_number scan_direction(void)
{@+uint8_t @!t; /*the type of information found*/ 
scaled @!x; /*an |x| coordinate*/ 
get_x_next();
if (cur_cmd==curl_command) @<Scan a curl specification@>@;
else@<Scan a given direction@>;
if (cur_cmd!=right_brace) 
  {@+missing_err('}');@/
@.Missing `\char`\}'@>
  help3("I've scanned a direction spec for part of a path,")@/
    ("so a right brace should have come next.")@/
    ("I shall pretend that one was there.");@/
  back_error();
  } 
get_x_next();return t;
} 

@ @<Scan a curl specification@>=
{@+get_x_next();scan_expression();
if ((cur_type!=known)||(cur_exp < 0)) 
  {@+exp_err(@[@<|"Improper curl has been replaced by 1"|@>@]);
@.Improper curl@>
  help1("A curl must be a known, nonnegative number.");
  put_get_flush_error(unity);
  } 
t=curl;
} 

@ @<Scan a given direction@>=
{@+scan_expression();
if (cur_type > pair_type) @<Get given directions separated by commas@>@;
else known_pair();
if ((cur_x==0)&&(cur_y==0)) t=open;
else{@+t=given;cur_exp=n_arg(cur_x, cur_y);
  } 
} 

@ @<Get given directions separated by commas@>=
{@+if (cur_type!=known) 
  {@+exp_err(@[@<|"Undefined x coordinate has been replaced by 0"|@>@]);
@.Undefined coordinates...@>
  help5("I need a `known' x value for this part of the path.")@/
    ("The value I found (see above) was no good;")@/
    ("so I'll try to keep going by using zero instead.")@/
    ("(Chapter 27 of The METAFONTbook explains that")@/
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
    ("you might want to type `I ?\?\?' now.)");
  put_get_flush_error(0);
  } 
x=cur_exp;
if (cur_cmd!=comma) 
  {@+missing_err(',');@/
@.Missing `,'@>
  help2("I've got the x coordinate of a path direction;")@/
    ("will look for the y coordinate next.");
  back_error();
  } 
get_x_next();scan_expression();
if (cur_type!=known) 
  {@+exp_err(@[@<|"Undefined y coordinate has been replaced by 0"|@>@]);
  help5("I need a `known' y value for this part of the path.")@/
    ("The value I found (see above) was no good;")@/
    ("so I'll try to keep going by using zero instead.")@/
    ("(Chapter 27 of The METAFONTbook explains that")@/
    ("you might want to type `I ?\?\?' now.)");
  put_get_flush_error(0);
  } 
cur_y=cur_exp;cur_x=x;
} 

@ At this point |right_type(q)| is usually |open|, but it may have been
set to some other value by a previous operation. We must maintain
the value of |right_type(q)| in cases such as
`\.{..\{curl2\}z\{0,0\}..}'.

@<Put the pre-join...@>=
{@+t=scan_direction();
if (t!=open) 
  {@+right_type(q)=t;right_given(q)=cur_exp;
  if (left_type(q)==open) 
    {@+left_type(q)=t;left_given(q)=cur_exp;
    }  /*note that |left_given(q)==left_curl(q)|*/ 
  } 
} 

@ Since |left_tension| and |left_y| share the same position in knot nodes,
and since |left_given| is similarly equivalent to |left_x|, we use
|x| and |y| to hold the given direction and tension information when
there are no explicit control points.

@<Put the post-join...@>=
{@+t=scan_direction();
if (right_type(q)!=explicit) x=cur_exp;
else t=explicit; /*the direction information is superfluous*/ 
} 

@ @<Determine the tension and/or...@>=
{@+get_x_next();
if (cur_cmd==tension) @<Set explicit tensions@>@;
else if (cur_cmd==controls) @<Set explicit control points@>@;
else{@+right_tension(q)=unity;y=unity;back_input(); /*default tension*/ 
  goto done;
  } 
if (cur_cmd!=path_join) 
  {@+missing_err(@[@<|".."|@>@]);@/
@.Missing `..'@>
  help1("A path join command should end with two dots.");
  back_error();
  } 
done: ;} 

@ @<Set explicit tensions@>=
{@+get_x_next();y=cur_cmd;
if (cur_cmd==at_least) get_x_next();
scan_primary();
@<Make sure that the current expression is a valid tension setting@>;
if (y==at_least) negate(cur_exp);
right_tension(q)=cur_exp;
if (cur_cmd==and_command) 
  {@+get_x_next();y=cur_cmd;
  if (cur_cmd==at_least) get_x_next();
  scan_primary();
  @<Make sure that the current expression is a valid tension setting@>;
  if (y==at_least) negate(cur_exp);
  } 
y=cur_exp;
} 

@ @d min_tension	three_quarter_unit

@<Make sure that the current expression is a valid tension setting@>=
if ((cur_type!=known)||(cur_exp < min_tension)) 
  {@+exp_err(@[@<|"Improper tension has been set to 1"|@>@]);
@.Improper tension@>
  help1("The expression above should have been a number >=3/4.");
  put_get_flush_error(unity);
  } 

@ @<Set explicit control points@>=
{@+right_type(q)=explicit;t=explicit;get_x_next();scan_primary();@/
known_pair();right_x(q)=cur_x;right_y(q)=cur_y;
if (cur_cmd!=and_command) 
  {@+x=right_x(q);y=right_y(q);
  } 
else{@+get_x_next();scan_primary();@/
  known_pair();x=cur_x;y=cur_y;
  } 
} 

@ @<Convert the right operand, |cur_exp|, into a partial path...@>=
{@+if (cur_type!=path_type) pp=new_knot();
else pp=cur_exp;
qq=pp;
while (link(qq)!=pp) qq=link(qq);
if (left_type(pp)!=endpoint)  /*open up a cycle*/ 
  {@+r=copy_knot(pp);link(qq)=r;qq=r;
  } 
left_type(pp)=open;right_type(qq)=open;
} 

@ If a person tries to define an entire path by saying `\.{(x,y)\&cycle}',
we silently change the specification to `\.{(x,y)..cycle}', since a cycle
shouldn't have length zero.

@<Get ready to close a cycle@>=
{@+cycle_hit=true;get_x_next();pp=p;qq=p;
if (d==ampersand) if (p==q) 
  {@+d=path_join;right_tension(q)=unity;y=unity;
  } 
} 

@ @<Join the partial paths and reset |p| and |q|...@>=
{@+if (d==ampersand) 
 if ((x_coord(q)!=x_coord(pp))||(y_coord(q)!=y_coord(pp))) 
  {@+print_err("Paths don't touch; `&' will be changed to `..'");
@.Paths don't touch@>
  help3("When you join paths `p&q', the ending point of p")@/
    ("must be exactly equal to the starting point of q.")@/
    ("So I'm going to pretend that you said `p..q' instead.");
  put_get_error();d=path_join;right_tension(q)=unity;y=unity;
  } 
@<Plug an opening in |right_type(pp)|, if possible@>;
if (d==ampersand) @<Splice independent paths together@>@;
else{@+@<Plug an opening in |right_type(q)|, if possible@>;
  link(q)=pp;left_y(pp)=y;
  if (t!=open) 
    {@+left_x(pp)=x;left_type(pp)=t;
    } 
  } 
q=qq;
} 

@ @<Plug an opening in |right_type(q)|...@>=
if (right_type(q)==open) 
  if ((left_type(q)==curl)||(left_type(q)==given)) 
    {@+right_type(q)=left_type(q);right_given(q)=left_given(q);
    } 

@ @<Plug an opening in |right_type(pp)|...@>=
if (right_type(pp)==open) 
  if ((t==curl)||(t==given)) 
    {@+right_type(pp)=t;right_given(pp)=x;
    } 

@ @<Splice independent paths together@>=
{@+if (left_type(q)==open) if (right_type(q)==open) 
    {@+left_type(q)=curl;left_curl(q)=unity;
    } 
if (right_type(pp)==open) if (t==open) 
  {@+right_type(pp)=curl;right_curl(pp)=unity;
  } 
right_type(q)=right_type(pp);link(q)=link(pp);@/
right_x(q)=right_x(pp);right_y(q)=right_y(pp);
free_node(pp, knot_node_size);
if (qq==pp) qq=q;
} 

@ @<Choose control points for the path...@>=
if (cycle_hit) 
  {@+if (d==ampersand) p=q;
  } 
else{@+left_type(p)=endpoint;
  if (right_type(p)==open) 
    {@+right_type(p)=curl;right_curl(p)=unity;
    } 
  right_type(q)=endpoint;
  if (left_type(q)==open) 
    {@+left_type(q)=curl;left_curl(q)=unity;
    } 
  link(q)=p;
  } 
make_choices(p);
cur_type=path_type;cur_exp=p

@ Finally, we sometimes need to scan an expression whose value is
supposed to be either |true_code| or |false_code|.

@<Declare the basic parsing subroutines@>=
void get_boolean(void)
{@+get_x_next();scan_expression();
if (cur_type!=boolean_type) 
  {@+exp_err(@[@<|"Undefined condition will be treated as `false'"|@>@]);
@.Undefined condition...@>
  help2("The expression shown above should have had a definite")@/
    ("true-or-false value. I'm changing it to `false'.");@/
  put_get_flush_error(false_code);cur_type=boolean_type;
  } 
} 

@* Doing the operations.
The purpose of parsing is primarily to permit people to avoid piles of
parentheses. But the real work is done after the structure of an expression
has been recognized; that's when new expressions are generated. We
turn now to the guts of \MF, which handles individual operators that
have come through the parsing mechanism.

We'll start with the easy ones that take no operands, then work our way
up to operators with one and ultimately two arguments. In other words,
we will write the three procedures |do_nullary|, |do_unary|, and |do_binary|
that are invoked periodically by the expression scanners.

First let's make sure that all of the primitive operators are in the
hash table. Although |scan_primary| and its relatives made use of the
\\{cmd} code for these operators, the \\{do} routines base everything
on the \\{mod} code. For example, |do_binary| doesn't care whether the
operation it performs is a |primary_binary| or |secondary_binary|, etc.

@<Put each...@>=
primitive(@[@<|"true"|@>@], nullary, true_code);@/
@!@:true_}{\&{true} primitive@>
primitive(@[@<|"false"|@>@], nullary, false_code);@/
@!@:false_}{\&{false} primitive@>
primitive(@[@<|"nullpicture"|@>@], nullary, null_picture_code);@/
@!@:null_picture_}{\&{nullpicture} primitive@>
primitive(@[@<|"nullpen"|@>@], nullary, null_pen_code);@/
@!@:null_pen_}{\&{nullpen} primitive@>
primitive(@[@<|"jobname"|@>@], nullary, job_name_op);@/
@!@:job_name_}{\&{jobname} primitive@>
primitive(@[@<|"readstring"|@>@], nullary, read_string_op);@/
@!@:read_string_}{\&{readstring} primitive@>
primitive(@[@<|"pencircle"|@>@], nullary, pen_circle);@/
@!@:pen_circle_}{\&{pencircle} primitive@>
primitive(@[@<|"normaldeviate"|@>@], nullary, normal_deviate);@/
@!@:normal_deviate_}{\&{normaldeviate} primitive@>
primitive(@[@<|"odd"|@>@], unary, odd_op);@/
@!@:odd_}{\&{odd} primitive@>
primitive(@[@<|"known"|@>@], unary, known_op);@/
@!@:known_}{\&{known} primitive@>
primitive(@[@<|"unknown"|@>@], unary, unknown_op);@/
@!@:unknown_}{\&{unknown} primitive@>
primitive(@[@<|"not"|@>@], unary, not_op);@/
@!@:not_}{\&{not} primitive@>
primitive(@[@<|"decimal"|@>@], unary, decimal);@/
@!@:decimal_}{\&{decimal} primitive@>
primitive(@[@<|"reverse"|@>@], unary, reverse);@/
@!@:reverse_}{\&{reverse} primitive@>
primitive(@[@<|"makepath"|@>@], unary, make_path_op);@/
@!@:make_path_}{\&{makepath} primitive@>
primitive(@[@<|"makepen"|@>@], unary, make_pen_op);@/
@!@:make_pen_}{\&{makepen} primitive@>
primitive(@[@<|"totalweight"|@>@], unary, total_weight_op);@/
@!@:total_weight_}{\&{totalweight} primitive@>
primitive(@[@<|"oct"|@>@], unary, oct_op);@/
@!@:oct_}{\&{oct} primitive@>
primitive(@[@<|"hex"|@>@], unary, hex_op);@/
@!@:hex_}{\&{hex} primitive@>
primitive(@[@<|"ASCII"|@>@], unary, ASCII_op);@/
@!@:ASCII_}{\&{ASCII} primitive@>
primitive(@[@<|"char"|@>@], unary, char_op);@/
@!@:char_}{\&{char} primitive@>
primitive(@[@<|"length"|@>@], unary, length_op);@/
@!@:length_}{\&{length} primitive@>
primitive(@[@<|"turningnumber"|@>@], unary, turning_op);@/
@!@:turning_number_}{\&{turningnumber} primitive@>
primitive(@[@<|"xpart"|@>@], unary, x_part);@/
@!@:x_part_}{\&{xpart} primitive@>
primitive(@[@<|"ypart"|@>@], unary, y_part);@/
@!@:y_part_}{\&{ypart} primitive@>
primitive(@[@<|"xxpart"|@>@], unary, xx_part);@/
@!@:xx_part_}{\&{xxpart} primitive@>
primitive(@[@<|"xypart"|@>@], unary, xy_part);@/
@!@:xy_part_}{\&{xypart} primitive@>
primitive(@[@<|"yxpart"|@>@], unary, yx_part);@/
@!@:yx_part_}{\&{yxpart} primitive@>
primitive(@[@<|"yypart"|@>@], unary, yy_part);@/
@!@:yy_part_}{\&{yypart} primitive@>
primitive(@[@<|"sqrt"|@>@], unary, sqrt_op);@/
@!@:sqrt_}{\&{sqrt} primitive@>
primitive(@[@<|"mexp"|@>@], unary, m_exp_op);@/
@!@:m_exp_}{\&{mexp} primitive@>
primitive(@[@<|"mlog"|@>@], unary, m_log_op);@/
@!@:m_log_}{\&{mlog} primitive@>
primitive(@[@<|"sind"|@>@], unary, sin_d_op);@/
@!@:sin_d_}{\&{sind} primitive@>
primitive(@[@<|"cosd"|@>@], unary, cos_d_op);@/
@!@:cos_d_}{\&{cosd} primitive@>
primitive(@[@<|"floor"|@>@], unary, floor_op);@/
@!@:floor_}{\&{floor} primitive@>
primitive(@[@<|"uniformdeviate"|@>@], unary, uniform_deviate);@/
@!@:uniform_deviate_}{\&{uniformdeviate} primitive@>
primitive(@[@<|"charexists"|@>@], unary, char_exists_op);@/
@!@:char_exists_}{\&{charexists} primitive@>
primitive(@[@<|"angle"|@>@], unary, angle_op);@/
@!@:angle_}{\&{angle} primitive@>
primitive(@[@<|"cycle"|@>@], cycle, cycle_op);@/
@!@:cycle_}{\&{cycle} primitive@>
primitive('+', plus_or_minus, plus);@/
@!@:+ }{\.{+} primitive@>
primitive('-', plus_or_minus, minus);@/
@!@:- }{\.{-} primitive@>
primitive('*', secondary_binary, times);@/
@!@:* }{\.{*} primitive@>
primitive('/', slash, over);eqtb[frozen_slash]=eqtb[cur_sym];@/
@!@:/ }{\.{/} primitive@>
primitive(@[@<|"++"|@>@], tertiary_binary, pythag_add);@/
@!@:++_}{\.{++} primitive@>
primitive(@[@<|"+-+"|@>@], tertiary_binary, pythag_sub);@/
@!@:+-+_}{\.{+-+} primitive@>
primitive(@[@<|"and"|@>@], and_command, and_op);@/
@!@:and_}{\&{and} primitive@>
primitive(@[@<|"or"|@>@], tertiary_binary, or_op);@/
@!@:or_}{\&{or} primitive@>
primitive('<', expression_binary, less_than);@/
@!@:< }{\.{<} primitive@>
primitive(@[@<|"<="|@>@], expression_binary, less_or_equal);@/
@!@:<=_}{\.{<=} primitive@>
primitive('>', expression_binary, greater_than);@/
@!@:> }{\.{>} primitive@>
primitive(@[@<|">="|@>@], expression_binary, greater_or_equal);@/
@!@:>=_}{\.{>=} primitive@>
primitive('=', equals, equal_to);@/
@!@:= }{\.{=} primitive@>
primitive(@[@<|"<>"|@>@], expression_binary, unequal_to);@/
@!@:<>_}{\.{<>} primitive@>
primitive(@[@<|"substring"|@>@], primary_binary, substring_of);@/
@!@:substring_}{\&{substring} primitive@>
primitive(@[@<|"subpath"|@>@], primary_binary, subpath_of);@/
@!@:subpath_}{\&{subpath} primitive@>
primitive(@[@<|"directiontime"|@>@], primary_binary, direction_time_of);@/
@!@:direction_time_}{\&{directiontime} primitive@>
primitive(@[@<|"point"|@>@], primary_binary, point_of);@/
@!@:point_}{\&{point} primitive@>
primitive(@[@<|"precontrol"|@>@], primary_binary, precontrol_of);@/
@!@:precontrol_}{\&{precontrol} primitive@>
primitive(@[@<|"postcontrol"|@>@], primary_binary, postcontrol_of);@/
@!@:postcontrol_}{\&{postcontrol} primitive@>
primitive(@[@<|"penoffset"|@>@], primary_binary, pen_offset_of);@/
@!@:pen_offset_}{\&{penoffset} primitive@>
primitive('&', ampersand, concatenate);@/
@!@:!!!}{\.{\&} primitive@>
primitive(@[@<|"rotated"|@>@], secondary_binary, rotated_by);@/
@!@:rotated_}{\&{rotated} primitive@>
primitive(@[@<|"slanted"|@>@], secondary_binary, slanted_by);@/
@!@:slanted_}{\&{slanted} primitive@>
primitive(@[@<|"scaled"|@>@], secondary_binary, scaled_by);@/
@!@:scaled_}{\&{scaled} primitive@>
primitive(@[@<|"shifted"|@>@], secondary_binary, shifted_by);@/
@!@:shifted_}{\&{shifted} primitive@>
primitive(@[@<|"transformed"|@>@], secondary_binary, transformed_by);@/
@!@:transformed_}{\&{transformed} primitive@>
primitive(@[@<|"xscaled"|@>@], secondary_binary, x_scaled);@/
@!@:x_scaled_}{\&{xscaled} primitive@>
primitive(@[@<|"yscaled"|@>@], secondary_binary, y_scaled);@/
@!@:y_scaled_}{\&{yscaled} primitive@>
primitive(@[@<|"zscaled"|@>@], secondary_binary, z_scaled);@/
@!@:z_scaled_}{\&{zscaled} primitive@>
primitive(@[@<|"intersectiontimes"|@>@], tertiary_binary, intersect);@/
@!@:intersection_times_}{\&{intersectiontimes} primitive@>

@ @<Cases of |print_cmd...@>=
case nullary: case unary: case primary_binary: case secondary_binary: case tertiary_binary: 
 case expression_binary: case cycle: case plus_or_minus: case slash: case ampersand: case equals: case and_command: 
  print_op(m);@+break;

@ OK, let's look at the simplest \\{do} procedure first.

@p void do_nullary(quarterword @!c)
{@+int @!k; /*all-purpose loop index*/ 
check_arith;
if (internal[tracing_commands] > two) 
  show_cmd_mod(nullary, c);
switch (c) {
case true_code: case false_code: {@+cur_type=boolean_type;cur_exp=c;
  } @+break;
case null_picture_code: {@+cur_type=picture_type;
  cur_exp=get_node(edge_header_size);init_edges(cur_exp);
  } @+break;
case null_pen_code: {@+cur_type=pen_type;cur_exp=null_pen;
  } @+break;
case normal_deviate: {@+cur_type=known;cur_exp=norm_rand();
  } @+break;
case pen_circle: @<Make a special knot node for \&{pencircle}@>@;@+break;
case job_name_op: {@+if (job_name==0) open_log_file();
  cur_type=string_type;cur_exp=job_name;
  } @+break;
case read_string_op: @<Read a string from the terminal@>;
}  /*there are no other cases*/ 
check_arith;
} 

@ @<Make a special knot node for \&{pencircle}@>=
{@+cur_type=future_pen;cur_exp=get_node(knot_node_size);
left_type(cur_exp)=open;right_type(cur_exp)=open;
link(cur_exp)=cur_exp;@/
x_coord(cur_exp)=0;y_coord(cur_exp)=0;@/
left_x(cur_exp)=unity;left_y(cur_exp)=0;@/
right_x(cur_exp)=0;right_y(cur_exp)=unity;@/
} 

@ @<Read a string...@>=
{@+if (interaction <= nonstop_mode) 
  fatal_error("*** (cannot readstring in nonstop modes)");
begin_file_reading();name=1;prompt_input("");
str_room(last-start);
for (k=start; k<=last-1; k++) append_char(buffer[k]);
end_file_reading();cur_type=string_type;cur_exp=make_string();
} 

@ Things get a bit more interesting when there's an operand. The
operand to |do_unary| appears in |cur_type| and |cur_exp|.

@p@t\4@>@<Declare unary action procedures@>@;
void do_unary(quarterword @!c)
{@+pointer @!p, @!q; /*for list manipulation*/ 
int @!x; /*a temporary register*/ 
check_arith;
if (internal[tracing_commands] > two) 
  @<Trace the current unary operation@>;
switch (c) {
case plus: if (cur_type < pair_type) 
  if (cur_type!=picture_type) bad_unary(plus);@+break;
case minus: @<Negate the current expression@>@;@+break;
@t\4@>@<Additional cases of unary operators@>@;
}  /*there are no other cases*/ 
check_arith;
} 

@ The |nice_pair| function returns |true| if both components of a pair
are known.

@<Declare unary action procedures@>=
bool nice_pair(int @!p, quarterword @!t)
{@+
if (t==pair_type) 
  {@+p=value(p);
  if (type(x_part_loc(p))==known) 
   if (type(y_part_loc(p))==known) 
    {@+return true;
    } 
  } 
return false;
} 

@ @<Declare unary action...@>=
void print_known_or_unknown_type(small_number @!t, int @!v)
{@+print_char('(');
if (t < dependent) 
  if (t!=pair_type) print_type(t);
  else if (nice_pair(v, pair_type)) print_str("pair");
  else print_str("unknown pair");
else print_str("unknown numeric");
print_char(')');
} 

@ @<Declare unary action...@>=
void bad_unary(quarterword @!c)
{@+exp_err(@[@<|"Not implemented: "|@>@]);print_op(c);
@.Not implemented...@>
print_known_or_unknown_type(cur_type, cur_exp);
help3("I'm afraid I don't know how to apply that operation to that")@/
  ("particular type. Continue, and I'll simply return the")@/
  ("argument (shown above) as the result of the operation.");
put_get_error();
} 

@ @<Trace the current unary operation@>=
{@+begin_diagnostic();print_nl("{");print_op(c);print_char('(');@/
print_exp(null, 0); /*show the operand, but not verbosely*/ 
print_str(")}");end_diagnostic(false);
} 

@ Negation is easy except when the current expression
is of type |independent|, or when it is a pair with one or more
|independent| components.

It is tempting to argue that the negative of an independent variable
is an independent variable, hence we don't have to do anything when
negating it. The fallacy is that other dependent variables pointing
to the current expression must change the sign of their
coefficients if we make no change to the current expression.

Instead, we work around the problem by copying the current expression
and recycling it afterwards (cf.~the |stash_in| routine).

@<Negate the current expression@>=
switch (cur_type) {
case pair_type: case independent: {@+q=cur_exp;make_exp_copy(q);
  if (cur_type==dependent) negate_dep_list(dep_list(cur_exp));
  else if (cur_type==pair_type) 
    {@+p=value(cur_exp);
    if (type(x_part_loc(p))==known) negate(value(x_part_loc(p)));
    else negate_dep_list(dep_list(x_part_loc(p)));
    if (type(y_part_loc(p))==known) negate(value(y_part_loc(p)));
    else negate_dep_list(dep_list(y_part_loc(p)));
    }  /*if |cur_type==known| then |cur_exp==0|*/ 
  recycle_value(q);free_node(q, value_node_size);
  } @+break;
case dependent: case proto_dependent: negate_dep_list(dep_list(cur_exp));@+break;
case known: negate(cur_exp);@+break;
case picture_type: negate_edges(cur_exp);@+break;
default:bad_unary(minus);
} 

@ @<Declare unary action...@>=
void negate_dep_list(pointer @!p)
{@+
loop@+{@+negate(value(p));
  if (info(p)==null) return;
  p=link(p);
  } 
} 

@ @<Additional cases of unary operators@>=
case not_op: if (cur_type!=boolean_type) bad_unary(not_op);
  else cur_exp=true_code+false_code-cur_exp;@+break;

@ @d three_sixty_units	23592960 /*that's |360*unity|*/ 
@d boolean_reset(X)	if (X) cur_exp=true_code;@+else cur_exp=false_code

@<Additional cases of unary operators@>=
case sqrt_op: case m_exp_op: case m_log_op: case sin_d_op: case cos_d_op: case floor_op: 
 case uniform_deviate: case odd_op: case char_exists_op: @t@>@;@/
  if (cur_type!=known) bad_unary(c);
  else switch (c) {
  case sqrt_op: cur_exp=square_rt(cur_exp);@+break;
  case m_exp_op: cur_exp=m_exp(cur_exp);@+break;
  case m_log_op: cur_exp=m_log(cur_exp);@+break;
  case sin_d_op: case cos_d_op: {@+n_sin_cos((cur_exp%three_sixty_units)*16);
    if (c==sin_d_op) cur_exp=round_fraction(n_sin);
    else cur_exp=round_fraction(n_cos);
    } @+break;
  case floor_op: cur_exp=floor_scaled(cur_exp);@+break;
  case uniform_deviate: cur_exp=unif_rand(cur_exp);@+break;
  case odd_op: {@+boolean_reset(odd(round_unscaled(cur_exp)));
    cur_type=boolean_type;
    } @+break;
  case char_exists_op: @<Determine if a character has been shipped out@>;
  } @+break; /*there are no other cases*/ 

@ @<Additional cases of unary operators@>=
case angle_op: if (nice_pair(cur_exp, cur_type)) 
    {@+p=value(cur_exp);
    x=n_arg(value(x_part_loc(p)), value(y_part_loc(p)));
    if (x >= 0) flush_cur_exp((x+8)/16);
    else flush_cur_exp(-((-x+8)/16));
    } 
  else bad_unary(angle_op);@+break;

@ If the current expression is a pair, but the context wants it to
be a path, we call |pair_to_path|.

@<Declare unary action...@>=
void pair_to_path(void)
{@+cur_exp=new_knot();cur_type=path_type;
} 

@ @<Additional cases of unary operators@>=
case x_part: case y_part: if ((cur_type <= pair_type)&&(cur_type >= transform_type)) 
    take_part(c);
  else bad_unary(c);@+break;
case xx_part: case xy_part: case yx_part: case yy_part: if (cur_type==transform_type) take_part(c);
  else bad_unary(c);@+break;

@ In the following procedure, |cur_exp| points to a capsule, which points to
a big node. We want to delete all but one part of the big node.

@<Declare unary action...@>=
void take_part(quarterword @!c)
{@+pointer @!p; /*the big node*/ 
p=value(cur_exp);value(temp_val)=p;type(temp_val)=cur_type;
link(p)=temp_val;free_node(cur_exp, value_node_size);
make_exp_copy(p+2*(c-x_part));
recycle_value(temp_val);
} 

@ @<Initialize table entries...@>=
name_type(temp_val)=capsule;

@ @<Additional cases of unary...@>=
case char_op: if (cur_type!=known) bad_unary(char_op);
  else{@+cur_exp=round_unscaled(cur_exp)%256;cur_type=string_type;
    if (cur_exp < 0) cur_exp=cur_exp+256;
    if (length(cur_exp)!=1) 
      {@+str_room(1);append_char(cur_exp);cur_exp=make_string();
      } 
    } @+break;
case decimal: if (cur_type!=known) bad_unary(decimal);
  else{@+old_setting=selector;selector=new_string;
    print_scaled(cur_exp);cur_exp=make_string();
    selector=old_setting;cur_type=string_type;
    } @+break;
case oct_op: case hex_op: case ASCII_op: if (cur_type!=string_type) bad_unary(c);
  else str_to_num(c);@+break;

@ @<Declare unary action...@>=
void str_to_num(quarterword @!c) /*converts a string to a number*/ 
{@+int @!n; /*accumulator*/ 
ASCII_code @!m; /*current character*/ 
int @!k; /*index into |str_pool|*/ 
uint8_t @!b; /*radix of conversion*/ 
bool @!bad_char; /*did the string contain an invalid digit?*/ 
if (c==ASCII_op) 
  if (length(cur_exp)==0) n=-1;
  else n=so(str_pool[str_start[cur_exp]]);
else{@+if (c==oct_op) b=8;@+else b=16;
  n=0;bad_char=false;
  for (k=str_start[cur_exp]; k<=str_start[cur_exp+1]-1; k++) 
    {@+m=so(str_pool[k]);
    if ((m >= '0')&&(m <= '9')) m=m-'0';
    else if ((m >= 'A')&&(m <= 'F')) m=m-'A'+10;
    else if ((m >= 'a')&&(m <= 'f')) m=m-'a'+10;
    else{@+bad_char=true;m=0;
      } 
    if (m >= b) 
      {@+bad_char=true;m=0;
      } 
    if (n < 32768/b) n=n*b+m;@+else n=32767;
    } 
  @<Give error messages if |bad_char| or |n>=4096|@>;
  } 
flush_cur_exp(n*unity);
} 

@ @<Give error messages if |bad_char|...@>=
if (bad_char) 
  {@+exp_err(@[@<|"String contains illegal digits"|@>@]);
@.String contains illegal digits@>
  if (c==oct_op) 
    help1("I zeroed out characters that weren't in the range 0..7.")@;
  else help1("I zeroed out characters that weren't hex digits.");
  put_get_error();
  } 
if (n > 4095) 
  {@+print_err("Number too large (");print_int(n);print_char(')');
@.Number too large@>
  help1("I have trouble with numbers greater than 4095; watch out.");
  put_get_error();
  } 

@ The length operation is somewhat unusual in that it applies to a variety
of different types of operands.

@<Additional cases of unary...@>=
case length_op: if (cur_type==string_type) flush_cur_exp(length(cur_exp)*unity);
  else if (cur_type==path_type) flush_cur_exp(path_length());
  else if (cur_type==known) cur_exp=abs(cur_exp);
  else if (nice_pair(cur_exp, cur_type)) 
    flush_cur_exp(pyth_add(value(x_part_loc(value(cur_exp))),@|
      value(y_part_loc(value(cur_exp)))));
  else bad_unary(c);@+break;

@ @<Declare unary action...@>=
scaled path_length(void) /*computes the length of the current path*/ 
{@+scaled @!n; /*the path length so far*/ 
pointer @!p; /*traverser*/ 
p=cur_exp;
if (left_type(p)==endpoint) n=-unity;@+else n=0;
@/do@+{p=link(p);n=n+unity;
}@+ while (!(p==cur_exp));
return n;
} 

@ The turning number is computed only with respect to null pens. A different
pen might affect the turning number, in degenerate cases, because autorounding
will produce a slightly different path, or because excessively large coordinates
might be truncated.

@<Additional cases of unary...@>=
case turning_op: if (cur_type==pair_type) flush_cur_exp(0);
  else if (cur_type!=path_type) bad_unary(turning_op);
  else if (left_type(cur_exp)==endpoint) 
     flush_cur_exp(0); /*not a cyclic path*/ 
  else{@+cur_pen=null_pen;cur_path_type=contour_code;
    cur_exp=make_spec(cur_exp,
      fraction_one-half_unit-1-el_gordo, 0);
    flush_cur_exp(turning_number*unity); /*convert to |scaled|*/ 
    } @+break;

@ @d type_test_end	flush_cur_exp(true_code);
  else flush_cur_exp(false_code);
  cur_type=boolean_type;
  } 
@d type_range_end(X)	(cur_type <= X)) type_test_end
@d type_range(X)	{@+if ((cur_type >= X)&&type_range_end
@d type_test(X)	{@+if (cur_type==X) type_test_end

@<Additional cases of unary operators@>=
case boolean_type: type_range(boolean_type)(unknown_boolean)@;@+break;
case string_type: type_range(string_type)(unknown_string)@;@+break;
case pen_type: type_range(pen_type)(future_pen)@;@+break;
case path_type: type_range(path_type)(unknown_path)@;@+break;
case picture_type: type_range(picture_type)(unknown_picture)@;@+break;
case transform_type: case pair_type: type_test(c)@;@+break;
case numeric_type: type_range(known)(independent)@;@+break;
case known_op: case unknown_op: test_known(c);@+break;

@ @<Declare unary action procedures@>=
void test_known(quarterword @!c)
{@+
uint8_t @!b; /*is the current expression known?*/ 
pointer @!p, @!q; /*locations in a big node*/ 
b=false_code;
switch (cur_type) {
case vacuous: case boolean_type: case string_type: case pen_type: case future_pen: case path_type: case picture_type: 
 case known: b=true_code;@+break;
case transform_type: case pair_type: {@+p=value(cur_exp);q=p+big_node_size[cur_type];
  @/do@+{q=q-2;
  if (type(q)!=known) goto done;
  }@+ while (!(q==p));
  b=true_code;
done: ;} @+break;
default:do_nothing;
} 
if (c==known_op) flush_cur_exp(b);
else flush_cur_exp(true_code+false_code-b);
cur_type=boolean_type;
} 

@ @<Additional cases of unary operators@>=
case cycle_op: {@+if (cur_type!=path_type) flush_cur_exp(false_code);
  else if (left_type(cur_exp)!=endpoint) flush_cur_exp(true_code);
  else flush_cur_exp(false_code);
  cur_type=boolean_type;
  } @+break;

@ @<Additional cases of unary operators@>=
case make_pen_op: {@+if (cur_type==pair_type) pair_to_path();
  if (cur_type==path_type) cur_type=future_pen;
  else bad_unary(make_pen_op);
  } @+break;
case make_path_op: {@+if (cur_type==future_pen) materialize_pen();
  if (cur_type!=pen_type) bad_unary(make_path_op);
  else{@+flush_cur_exp(make_path(cur_exp));cur_type=path_type;
    } 
  } @+break;
case total_weight_op: if (cur_type!=picture_type) bad_unary(total_weight_op);
  else flush_cur_exp(total_weight(cur_exp));@+break;
case reverse: if (cur_type==path_type) 
    {@+p=htap_ypoc(cur_exp);
    if (right_type(p)==endpoint) p=link(p);
    toss_knot_list(cur_exp);cur_exp=p;
    } 
  else if (cur_type==pair_type) pair_to_path();
  else bad_unary(reverse);

@ Finally, we have the operations that combine a capsule~|p|
with the current expression.

@p@t\4@>@<Declare binary action procedures@>@;
void do_binary(pointer @!p, quarterword @!c)
{@+
pointer @!q, @!r, @!rr; /*for list manipulation*/ 
pointer @!old_p, @!old_exp; /*capsules to recycle*/ 
int @!v; /*for numeric manipulation*/ 
check_arith;
if (internal[tracing_commands] > two) 
  @<Trace the current binary operation@>;
@<Sidestep |independent| cases in capsule |p|@>;
@<Sidestep |independent| cases in the current expression@>;
switch (c) {
case plus: case minus: @<Add or subtract the current expression from |p|@>;@+break;
@t\4@>@<Additional cases of binary operators@>@;
}  /*there are no other cases*/ 
recycle_value(p);free_node(p, value_node_size); /*|goto end| to avoid this*/ 
end: check_arith;@<Recycle any sidestepped |independent| capsules@>;
} 

@ @<Declare binary action...@>=
void bad_binary(pointer @!p, quarterword @!c)
{@+disp_err(p, empty_string);
exp_err(@[@<|"Not implemented: "|@>@]);
@.Not implemented...@>
if (c >= min_of) print_op(c);
print_known_or_unknown_type(type(p), p);
if (c >= min_of) print_str("of");@+else print_op(c);
print_known_or_unknown_type(cur_type, cur_exp);@/
help3("I'm afraid I don't know how to apply that operation to that")@/
  ("combination of types. Continue, and I'll return the second")@/
  ("argument (see above) as the result of the operation.");
put_get_error();
} 

@ @<Trace the current binary operation@>=
{@+begin_diagnostic();print_nl("{(");
print_exp(p, 0); /*show the operand, but not verbosely*/ 
print_char(')');print_op(c);print_char('(');@/
print_exp(null, 0);print_str(")}");end_diagnostic(false);
} 

@ Several of the binary operations are potentially complicated by the
fact that |independent| values can sneak into capsules. For example,
we've seen an instance of this difficulty in the unary operation
of negation. In order to reduce the number of cases that need to be
handled, we first change the two operands (if necessary)
to rid them of |independent| components. The original operands are
put into capsules called |old_p| and |old_exp|, which will be
recycled after the binary operation has been safely carried out.

@<Recycle any sidestepped |independent| capsules@>=
if (old_p!=null) 
  {@+recycle_value(old_p);free_node(old_p, value_node_size);
  } 
if (old_exp!=null) 
  {@+recycle_value(old_exp);free_node(old_exp, value_node_size);
  } 

@ A big node is considered to be ``tarnished'' if it contains at least one
independent component. We will define a simple function called `|tarnished|'
that returns |null| if and only if its argument is not tarnished.

@<Sidestep |independent| cases in capsule |p|@>=
switch (type(p)) {
case transform_type: case pair_type: old_p=tarnished(p);@+break;
case independent: old_p=empty;@+break;
default:old_p=null;
} 
if (old_p!=null) 
  {@+q=stash_cur_exp();old_p=p;make_exp_copy(old_p);
  p=stash_cur_exp();unstash_cur_exp(q);
  } 

@ @<Sidestep |independent| cases in the current expression@>=
switch (cur_type) {
case transform_type: case pair_type: old_exp=tarnished(cur_exp);@+break;
case independent: old_exp=empty;@+break;
default:old_exp=null;
} 
if (old_exp!=null) 
  {@+old_exp=cur_exp;make_exp_copy(old_exp);
  } 

@ @<Declare binary action...@>=
pointer tarnished(pointer @!p)
{@+
pointer @!q; /*beginning of the big node*/ 
pointer @!r; /*current position in the big node*/ 
q=value(p);r=q+big_node_size[type(p)];
@/do@+{r=r-2;
if (type(r)==independent) 
  {@+return empty;
  } 
}@+ while (!(r==q));
return null;
} 

@ @<Add or subtract the current expression from |p|@>=
if ((cur_type < pair_type)||(type(p) < pair_type)) 
  if ((cur_type==picture_type)&&(type(p)==picture_type)) 
    {@+if (c==minus) negate_edges(cur_exp);
    cur_edges=cur_exp;merge_edges(value(p));
    } 
  else bad_binary(p, c);
else if (cur_type==pair_type) 
    if (type(p)!=pair_type) bad_binary(p, c);
    else{@+q=value(p);r=value(cur_exp);
      add_or_subtract(x_part_loc(q), x_part_loc(r), c);
      add_or_subtract(y_part_loc(q), y_part_loc(r), c);
      } 
  else if (type(p)==pair_type) bad_binary(p, c);
    else add_or_subtract(p, null, c)

@ The first argument to |add_or_subtract| is the location of a value node
in a capsule or pair node that will soon be recycled. The second argument
is either a location within a pair or transform node of |cur_exp|,
or it is null (which means that |cur_exp| itself should be the second
argument).  The third argument is either |plus| or |minus|.

The sum or difference of the numeric quantities will replace the second
operand.  Arithmetic overflow may go undetected; users aren't supposed to
be monkeying around with really big values.
@^overflow in arithmetic@>

@<Declare binary action...@>=
@t\4@>@<Declare the procedure called |dep_finish|@>@;
void add_or_subtract(pointer @!p, pointer @!q, quarterword @!c)
{@+
small_number @!s, @!t; /*operand types*/ 
pointer @!r; /*list traverser*/ 
int @!v; /*second operand value*/ 
if (q==null) 
  {@+t=cur_type;
  if (t < dependent) v=cur_exp;@+else v=dep_list(cur_exp);
  } 
else{@+t=type(q);
  if (t < dependent) v=value(q);@+else v=dep_list(q);
  } 
if (t==known) 
  {@+if (c==minus) negate(v);
  if (type(p)==known) 
    {@+v=slow_add(value(p), v);
    if (q==null) cur_exp=v;@+else value(q)=v;
    return;
    } 
  @<Add a known value to the constant term of |dep_list(p)|@>;
  } 
else{@+if (c==minus) negate_dep_list(v);
  @<Add operand |p| to the dependency list |v|@>;
  } 
} 

@ @<Add a known value to the constant term of |dep_list(p)|@>=
r=dep_list(p);
while (info(r)!=null) r=link(r);
value(r)=slow_add(value(r), v);
if (q==null) 
  {@+q=get_node(value_node_size);cur_exp=q;cur_type=type(p);
  name_type(q)=capsule;
  } 
dep_list(q)=dep_list(p);type(q)=type(p);
prev_dep(q)=prev_dep(p);link(prev_dep(p))=q;
type(p)=known; /*this will keep the recycler from collecting non-garbage*/ 

@ We prefer |dependent| lists to |proto_dependent| ones, because it is
nice to retain the extra accuracy of |fraction| coefficients.
But we have to handle both kinds, and mixtures too.

@<Add operand |p| to the dependency list |v|@>=
if (type(p)==known) 
  @<Add the known |value(p)| to the constant term of |v|@>@;
else{@+s=type(p);r=dep_list(p);
  if (t==dependent) 
    {@+if (s==dependent) 
     if (max_coef(r)+max_coef(v) < coef_bound) 
      {@+v=p_plus_q(v, r, dependent);goto done;
      }  /*|fix_needed| will necessarily be false*/ 
    t=proto_dependent;v=p_over_v(v, unity, dependent, proto_dependent);
    } 
  if (s==proto_dependent) v=p_plus_q(v, r, proto_dependent);
  else v=p_plus_fq(v, unity, r, proto_dependent, dependent);
 done: @<Output the answer, |v| (which might have become |known|)@>;
  } 

@ @<Add the known |value(p)| to the constant term of |v|@>=
{@+while (info(v)!=null) v=link(v);
value(v)=slow_add(value(p), value(v));
} 

@ @<Output the answer, |v| (which might have become |known|)@>=
if (q!=null) dep_finish(v, q, t);
else{@+cur_type=t;dep_finish(v, null, t);
  } 

@ Here's the current situation: The dependency list |v| of type |t|
should either be put into the current expression (if |q==null|) or
into location |q| within a pair node (otherwise). The destination (|cur_exp|
or |q|) formerly held a dependency list with the same
final pointer as the list |v|.

@<Declare the procedure called |dep_finish|@>=
void dep_finish(pointer @!v, pointer @!q, small_number @!t)
{@+pointer @!p; /*the destination*/ 
scaled @!vv; /*the value, if it is |known|*/ 
if (q==null) p=cur_exp;@+else p=q;
dep_list(p)=v;type(p)=t;
if (info(v)==null) 
  {@+vv=value(v);
  if (q==null) flush_cur_exp(vv);
  else{@+recycle_value(p);type(q)=known;value(q)=vv;
    } 
  } 
else if (q==null) cur_type=t;
if (fix_needed) fix_dependencies();
} 

@ Let's turn now to the six basic relations of comparison.

@<Additional cases of binary operators@>=
case less_than: case less_or_equal: case greater_than: case greater_or_equal: case equal_to: case unequal_to: 
  {@+@t@>@;
  if ((cur_type > pair_type)&&(type(p) > pair_type)) 
    add_or_subtract(p, null, minus); /*|cur_exp=(p)-cur_exp|*/ 
  else if (cur_type!=type(p)) 
    {@+bad_binary(p, c);goto done;
    } 
  else if (cur_type==string_type) 
    flush_cur_exp(str_vs_str(value(p), cur_exp));
  else if ((cur_type==unknown_string)||(cur_type==unknown_boolean)) 
    @<Check if unknowns have been equated@>@;
  else if ((cur_type==pair_type)||(cur_type==transform_type)) 
    @<Reduce comparison of big nodes to comparison of scalars@>@;
  else if (cur_type==boolean_type) flush_cur_exp(cur_exp-value(p));
  else{@+bad_binary(p, c);goto done;
    } 
  @<Compare the current expression with zero@>;
done: ;} @+break;

@ @<Compare the current expression with zero@>=
if (cur_type!=known) 
  {@+if (cur_type < known) 
    {@+disp_err(p, empty_string);
    help1("The quantities shown above have not been equated.")@;@/
    } 
  else help2("Oh dear. I can't decide if the expression above is positive,")@/
    ("negative, or zero. So this comparison test won't be `true'.");
  exp_err(@[@<|"Unknown relation will be considered false"|@>@]);
@.Unknown relation...@>
  put_get_flush_error(false_code);
  } 
else switch (c) {
  case less_than: boolean_reset(cur_exp < 0);@+break;
  case less_or_equal: boolean_reset(cur_exp <= 0);@+break;
  case greater_than: boolean_reset(cur_exp > 0);@+break;
  case greater_or_equal: boolean_reset(cur_exp >= 0);@+break;
  case equal_to: boolean_reset(cur_exp==0);@+break;
  case unequal_to: boolean_reset(cur_exp!=0);
  }  /*there are no other cases*/ 
 cur_type=boolean_type

@ When two unknown strings are in the same ring, we know that they are
equal. Otherwise, we don't know whether they are equal or not, so we
make no change.

@<Check if unknowns have been equated@>=
{@+q=value(cur_exp);
while ((q!=cur_exp)&&(q!=p)) q=value(q);
if (q==p) flush_cur_exp(0);
} 

@ @<Reduce comparison of big nodes to comparison of scalars@>=
{@+q=value(p);r=value(cur_exp);
rr=r+big_node_size[cur_type]-2;
loop@+{@+add_or_subtract(q, r, minus);
  if (type(r)!=known) goto done1;
  if (value(r)!=0) goto done1;
  if (r==rr) goto done1;
  q=q+2;r=r+2;
  } 
done1: take_part(x_part+half(r-value(cur_exp)));
} 

@ Here we use the sneaky fact that |and_op-false_code==or_op-true_code|.

@<Additional cases of binary operators@>=
case and_op: case or_op: if ((type(p)!=boolean_type)||(cur_type!=boolean_type)) 
    bad_binary(p, c);
  else if (value(p)==c+false_code-and_op) cur_exp=value(p);@+break;

@ @<Additional cases of binary operators@>=
case times: if ((cur_type < pair_type)||(type(p) < pair_type)) bad_binary(p, times);
  else if ((cur_type==known)||(type(p)==known)) 
    @<Multiply when at least one operand is known@>@;
  else if ((nice_pair(p, type(p))&&(cur_type > pair_type))
      ||(nice_pair(cur_exp, cur_type)&&(type(p) > pair_type))) 
    {@+hard_times(p);goto end;
    } 
  else bad_binary(p, times);@+break;

@ @<Multiply when at least one operand is known@>=
{@+if (type(p)==known) 
  {@+v=value(p);free_node(p, value_node_size);
  } 
else{@+v=cur_exp;unstash_cur_exp(p);
  } 
if (cur_type==known) cur_exp=take_scaled(cur_exp, v);
else if (cur_type==pair_type) 
  {@+p=value(cur_exp);
  dep_mult(x_part_loc(p), v, true);
  dep_mult(y_part_loc(p), v, true);
  } 
else dep_mult(null, v, true);
goto end;
} 

@ @<Declare binary action...@>=
void dep_mult(pointer @!p, int @!v, bool @!v_is_scaled)
{@+
pointer @!q; /*the dependency list being multiplied by |v|*/ 
small_number @!s, @!t; /*its type, before and after*/ 
if (p==null) q=cur_exp;
else if (type(p)!=known) q=p;
else{@+if (v_is_scaled) value(p)=take_scaled(value(p), v);
  else value(p)=take_fraction(value(p), v);
  return;
  } 
t=type(q);q=dep_list(q);s=t;
if (t==dependent) if (v_is_scaled) 
  if (ab_vs_cd(max_coef(q), abs(v), coef_bound-1, unity) >= 0) t=proto_dependent;
q=p_times_v(q, v, s, t, v_is_scaled);dep_finish(q, p, t);
} 

@ Here is a routine that is similar to |times|; but it is invoked only
internally, when |v| is a |fraction| whose magnitude is at most~1,
and when |cur_type >= pair_type|.

@p void frac_mult(scaled @!n, scaled @!d) /*multiplies |cur_exp| by |n/(double)d|*/ 
{@+pointer @!p; /*a pair node*/ 
pointer @!old_exp; /*a capsule to recycle*/ 
fraction @!v; /*|n/(double)d|*/ 
if (internal[tracing_commands] > two) 
  @<Trace the fraction multiplication@>;
switch (cur_type) {
case transform_type: case pair_type: old_exp=tarnished(cur_exp);@+break;
case independent: old_exp=empty;@+break;
default:old_exp=null;
} 
if (old_exp!=null) 
  {@+old_exp=cur_exp;make_exp_copy(old_exp);
  } 
v=make_fraction(n, d);
if (cur_type==known) cur_exp=take_fraction(cur_exp, v);
else if (cur_type==pair_type) 
  {@+p=value(cur_exp);
  dep_mult(x_part_loc(p), v, false);
  dep_mult(y_part_loc(p), v, false);
  } 
else dep_mult(null, v, false);
if (old_exp!=null) 
  {@+recycle_value(old_exp);free_node(old_exp, value_node_size);
  } 
} 

@ @<Trace the fraction multiplication@>=
{@+begin_diagnostic();print_nl("{(");print_scaled(n);print_char('/');
print_scaled(d);print_str(")*(");print_exp(null, 0);print_str(")}");
end_diagnostic(false);
} 

@ The |hard_times| routine multiplies a nice pair by a dependency list.

@<Declare binary action procedures@>=
void hard_times(pointer @!p)
{@+pointer @!q; /*a copy of the dependent variable |p|*/ 
pointer @!r; /*the big node for the nice pair*/ 
scaled @!u, @!v; /*the known values of the nice pair*/ 
if (type(p)==pair_type) 
  {@+q=stash_cur_exp();unstash_cur_exp(p);p=q;
  }  /*now |cur_type==pair_type|*/ 
r=value(cur_exp);u=value(x_part_loc(r));v=value(y_part_loc(r));
@<Move the dependent variable |p| into both parts of the pair node |r|@>;
dep_mult(x_part_loc(r), u, true);dep_mult(y_part_loc(r), v, true);
} 

@ @<Move the dependent variable |p|...@>=
type(y_part_loc(r))=type(p);
new_dep(y_part_loc(r), copy_dep_list(dep_list(p)));@/
type(x_part_loc(r))=type(p);
mem[value_loc(x_part_loc(r))]=mem[value_loc(p)];
link(prev_dep(p))=x_part_loc(r);
free_node(p, value_node_size)

@ @<Additional cases of binary operators@>=
case over: if ((cur_type!=known)||(type(p) < pair_type)) bad_binary(p, over);
  else{@+v=cur_exp;unstash_cur_exp(p);
    if (v==0) @<Squeal about division by zero@>@;
    else{@+if (cur_type==known) cur_exp=make_scaled(cur_exp, v);
      else if (cur_type==pair_type) 
        {@+p=value(cur_exp);
        dep_div(x_part_loc(p), v);
        dep_div(y_part_loc(p), v);
        } 
      else dep_div(null, v);
      } 
    goto end;
    } @+break;

@ @<Declare binary action...@>=
void dep_div(pointer @!p, scaled @!v)
{@+
pointer @!q; /*the dependency list being divided by |v|*/ 
small_number @!s, @!t; /*its type, before and after*/ 
if (p==null) q=cur_exp;
else if (type(p)!=known) q=p;
else{@+value(p)=make_scaled(value(p), v);return;
  } 
t=type(q);q=dep_list(q);s=t;
if (t==dependent) 
  if (ab_vs_cd(max_coef(q), unity, coef_bound-1, abs(v)) >= 0) t=proto_dependent;
q=p_over_v(q, v, s, t);dep_finish(q, p, t);
} 

@ @<Squeal about division by zero@>=
{@+exp_err(@[@<|"Division by zero"|@>@]);
@.Division by zero@>
help2("You're trying to divide the quantity shown above the error")@/
  ("message by zero. I'm going to divide it by one instead.");
put_get_error();
} 

@ @<Additional cases of binary operators@>=
case pythag_add: case pythag_sub: if ((cur_type==known)&&(type(p)==known)) 
    if (c==pythag_add) cur_exp=pyth_add(value(p), cur_exp);
    else cur_exp=pyth_sub(value(p), cur_exp);
  else bad_binary(p, c);@+break;

@ The next few sections of the program deal with affine transformations
of coordinate data.

@<Additional cases of binary operators@>=
case rotated_by: case slanted_by: case scaled_by: case shifted_by: case transformed_by: 
 case x_scaled: case y_scaled: case z_scaled: @t@>@;@/
  if ((type(p)==path_type)||(type(p)==future_pen)||(type(p)==pen_type)) 
    {@+path_trans(p, c);goto end;
    } 
  else if ((type(p)==pair_type)||(type(p)==transform_type)) big_trans(p, c);
  else if (type(p)==picture_type) 
    {@+edges_trans(p, c);goto end;
    } 
  else bad_binary(p, c);@+break;

@ Let |c| be one of the eight transform operators. The procedure call
|set_up_trans(c)| first changes |cur_exp| to a transform that corresponds to
|c| and the original value of |cur_exp|. (In particular, |cur_exp| doesn't
change at all if |c==transformed_by|.)

Then, if all components of the resulting transform are |known|, they are
moved to the global variables |txx|, |txy|, |tyx|, |tyy|, |tx|, |ty|;
and |cur_exp| is changed to the known value zero.

@<Declare binary action...@>=
void set_up_trans(quarterword @!c)
{@+
pointer @!p, @!q, @!r; /*list manipulation registers*/ 
if ((c!=transformed_by)||(cur_type!=transform_type)) 
  @<Put the current transform into |cur_exp|@>;
@<If the current transform is entirely known, stash it in global variables; otherwise
|return|@>;
} 

@ @<Glob...@>=
scaled @!txx, @!txy, @!tyx, @!tyy, @!tx, @!ty; /*current transform coefficients*/ 

@ @<Put the current transform...@>=
{@+p=stash_cur_exp();cur_exp=id_transform();cur_type=transform_type;
q=value(cur_exp);
switch (c) {
@<For each of the eight cases, change the relevant fields of |cur_exp| and |goto done|;
but do nothing if capsule |p| doesn't have the appropriate type@>@;
}  /*there are no other cases*/ 
disp_err(p,@[@<|"Improper transformation argument"|@>@]);
@.Improper transformation argument@>
help3("The expression shown above has the wrong type,")@/
  ("so I can't transform anything using it.")@/
  ("Proceed, and I'll omit the transformation.");
put_get_error();
done: recycle_value(p);free_node(p, value_node_size);
} 

@ @<If the current transform is entirely known,...@>=
q=value(cur_exp);r=q+transform_node_size;
@/do@+{r=r-2;
if (type(r)!=known) return;
}@+ while (!(r==q));
txx=value(xx_part_loc(q));
txy=value(xy_part_loc(q));
tyx=value(yx_part_loc(q));
tyy=value(yy_part_loc(q));
tx=value(x_part_loc(q));
ty=value(y_part_loc(q));
flush_cur_exp(0)

@ @<For each of the eight cases...@>=
case rotated_by: if (type(p)==known) 
  @<Install sines and cosines, then |goto done|@>@;@+break;
case slanted_by: if (type(p) > pair_type) 
  {@+install(xy_part_loc(q), p);goto done;
  } @+break;
case scaled_by: if (type(p) > pair_type) 
  {@+install(xx_part_loc(q), p);install(yy_part_loc(q), p);goto done;
  } @+break;
case shifted_by: if (type(p)==pair_type) 
  {@+r=value(p);install(x_part_loc(q), x_part_loc(r));
  install(y_part_loc(q), y_part_loc(r));goto done;
  } @+break;
case x_scaled: if (type(p) > pair_type) 
  {@+install(xx_part_loc(q), p);goto done;
  } @+break;
case y_scaled: if (type(p) > pair_type) 
  {@+install(yy_part_loc(q), p);goto done;
  } @+break;
case z_scaled: if (type(p)==pair_type) 
  @<Install a complex multiplier, then |goto done|@>@;@+break;
case transformed_by: do_nothing;

@ @<Install sines and cosines, then |goto done|@>=
{@+n_sin_cos((value(p)%three_sixty_units)*16);
value(xx_part_loc(q))=round_fraction(n_cos);
value(yx_part_loc(q))=round_fraction(n_sin);
value(xy_part_loc(q))=-value(yx_part_loc(q));
value(yy_part_loc(q))=value(xx_part_loc(q));
goto done;
} 

@ @<Install a complex multiplier, then |goto done|@>=
{@+r=value(p);
install(xx_part_loc(q), x_part_loc(r));
install(yy_part_loc(q), x_part_loc(r));
install(yx_part_loc(q), y_part_loc(r));
if (type(y_part_loc(r))==known) negate(value(y_part_loc(r)));
else negate_dep_list(dep_list(y_part_loc(r)));
install(xy_part_loc(q), y_part_loc(r));
goto done;
} 

@ Procedure |set_up_known_trans| is like |set_up_trans|, but it
insists that the transformation be entirely known.

@<Declare binary action...@>=
void set_up_known_trans(quarterword @!c)
{@+set_up_trans(c);
if (cur_type!=known) 
  {@+exp_err(@[@<|"Transform components aren't all known"|@>@]);
@.Transform components...@>
  help3("I'm unable to apply a partially specified transformation")@/
    ("except to a fully known pair or transform.")@/
    ("Proceed, and I'll omit the transformation.");
  put_get_flush_error(0);
  txx=unity;txy=0;tyx=0;tyy=unity;tx=0;ty=0;
  } 
} 

@ Here's a procedure that applies the transform |txx dotdot ty| to a pair of
coordinates in locations |p| and~|q|.

@<Declare binary action...@>=
void trans(pointer @!p, pointer @!q)
{@+scaled @!v; /*the new |x| value*/ 
v=take_scaled(mem[p].sc, txx)+take_scaled(mem[q].sc, txy)+tx;
mem[q].sc=take_scaled(mem[p].sc, tyx)+take_scaled(mem[q].sc, tyy)+ty;
mem[p].sc=v;
} 

@ The simplest transformation procedure applies a transform to all
coordinates of a path. The |null_pen| remains unchanged if it isn't
being shifted.

@<Declare binary action...@>=
void path_trans(pointer @!p, quarterword @!c)
{@+
pointer @!q; /*list traverser*/ 
set_up_known_trans(c);unstash_cur_exp(p);
if (cur_type==pen_type) 
  {@+if (max_offset(cur_exp)==0) if (tx==0) if (ty==0) return;
  flush_cur_exp(make_path(cur_exp));cur_type=future_pen;
  } 
q=cur_exp;
@/do@+{if (left_type(q)!=endpoint) 
  trans(q+3, q+4); /*that's |left_x| and |left_y|*/ 
trans(q+1, q+2); /*that's |x_coord| and |y_coord|*/ 
if (right_type(q)!=endpoint) 
  trans(q+5, q+6); /*that's |right_x| and |right_y|*/ 
q=link(q);
}@+ while (!(q==cur_exp));
} 

@ The next simplest transformation procedure applies to edges.
It is simple primarily because \MF\ doesn't allow very general
transformations to be made, and because the tricky subroutines
for edge transformation have already been written.

@<Declare binary action...@>=
void edges_trans(pointer @!p, quarterword @!c)
{@+
set_up_known_trans(c);unstash_cur_exp(p);cur_edges=cur_exp;
if (empty_edges(cur_edges)) return; /*the empty set is easy to transform*/ 
if (txx==0) if (tyy==0) 
 if (txy%unity==0) if (tyx%unity==0) 
  {@+xy_swap_edges();txx=txy;tyy=tyx;txy=0;tyx=0;
  if (empty_edges(cur_edges)) return;
  } 
if (txy==0) if (tyx==0) 
 if (txx%unity==0) if (tyy%unity==0) 
  @<Scale the edges, shift them, and |return|@>;
print_err("That transformation is too hard");
@.That transformation...@>
help3("I can apply complicated transformations to paths,")@/
  ("but I can only do integer operations on pictures.")@/
  ("Proceed, and I'll omit the transformation.");
put_get_error();
} 

@ @<Scale the edges, shift them, and |return|@>=
{@+if ((txx==0)||(tyy==0)) 
  {@+toss_edges(cur_edges);
  cur_exp=get_node(edge_header_size);init_edges(cur_exp);
  } 
else{@+if (txx < 0) 
    {@+x_reflect_edges();txx=-txx;
    } 
  if (tyy < 0) 
    {@+y_reflect_edges();tyy=-tyy;
    } 
  if (txx!=unity) x_scale_edges(txx/unity);
  if (tyy!=unity) y_scale_edges(tyy/unity);
  @<Shift the edges by |(tx,ty)|, rounded@>;
  } 
return;
} 

@ @<Shift the edges...@>=
tx=round_unscaled(tx);ty=round_unscaled(ty);
if ((m_min(cur_edges)+tx <= 0)||(m_max(cur_edges)+tx >= 8192)||@|
 (n_min(cur_edges)+ty <= 0)||(n_max(cur_edges)+ty >= 8191)||@|
 (abs(tx) >= 4096)||(abs(ty) >= 4096)) 
  {@+print_err("Too far to shift");
@.Too far to shift@>
  help3("I can't shift the picture as requested---it would")@/
    ("make some coordinates too large or too small.")@/
    ("Proceed, and I'll omit the transformation.");
  put_get_error();
  } 
else{@+if (tx!=0) 
    {@+if (!valid_range(m_offset(cur_edges)-tx)) fix_offset();
    m_min(cur_edges)=m_min(cur_edges)+tx;
    m_max(cur_edges)=m_max(cur_edges)+tx;
    m_offset(cur_edges)=m_offset(cur_edges)-tx;
    last_window_time(cur_edges)=0;
    } 
  if (ty!=0) 
    {@+n_min(cur_edges)=n_min(cur_edges)+ty;
    n_max(cur_edges)=n_max(cur_edges)+ty;
    n_pos(cur_edges)=n_pos(cur_edges)+ty;
    last_window_time(cur_edges)=0;
    } 
  } 

@ The hard cases of transformation occur when big nodes are involved,
and when some of their components are unknown.

@<Declare binary action...@>=
@t\4@>@<Declare subroutines needed by |big_trans|@>@;
void big_trans(pointer @!p, quarterword @!c)
{@+
pointer @!q, @!r, @!pp, @!qq; /*list manipulation registers*/ 
small_number @!s; /*size of a big node*/ 
s=big_node_size[type(p)];q=value(p);r=q+s;
@/do@+{r=r-2;
if (type(r)!=known) @<Transform an unknown big node and |return|@>;
}@+ while (!(r==q));
@<Transform a known big node@>;
}  /*node |p| will now be recycled by |do_binary|*/ 

@ @<Transform an unknown big node and |return|@>=
{@+set_up_known_trans(c);make_exp_copy(p);r=value(cur_exp);
if (cur_type==transform_type) 
  {@+bilin1(yy_part_loc(r), tyy, xy_part_loc(q), tyx, 0);
  bilin1(yx_part_loc(r), tyy, xx_part_loc(q), tyx, 0);
  bilin1(xy_part_loc(r), txx, yy_part_loc(q), txy, 0);
  bilin1(xx_part_loc(r), txx, yx_part_loc(q), txy, 0);
  } 
bilin1(y_part_loc(r), tyy, x_part_loc(q), tyx, ty);
bilin1(x_part_loc(r), txx, y_part_loc(q), txy, tx);
return;
} 

@ Let |p| point to a two-word value field inside a big node of |cur_exp|,
and let |q| point to a another value field. The |bilin1| procedure
replaces |p| by $p\cdot t+q\cdot u+\delta$.

@<Declare subroutines needed by |big_trans|@>=
void bilin1(pointer @!p, scaled @!t, pointer @!q, scaled @!u, scaled @!delta)
{@+pointer @!r; /*list traverser*/ 
if (t!=unity) dep_mult(p, t, true);
if (u!=0) 
  if (type(q)==known) delta=delta+take_scaled(value(q), u);
  else{@+@<Ensure that |type(p)=proto_dependent|@>;
    dep_list(p)=p_plus_fq(dep_list(p), u, dep_list(q), proto_dependent, type(q));
    } 
if (type(p)==known) value(p)=value(p)+delta;
else{@+r=dep_list(p);
  while (info(r)!=null) r=link(r);
  delta=value(r)+delta;
  if (r!=dep_list(p)) value(r)=delta;
  else{@+recycle_value(p);type(p)=known;value(p)=delta;
    } 
  } 
if (fix_needed) fix_dependencies();
} 

@ @<Ensure that |type(p)=proto_dependent|@>=
if (type(p)!=proto_dependent) 
  {@+if (type(p)==known) new_dep(p, const_dependency(value(p)));
  else dep_list(p)=p_times_v(dep_list(p), unity, dependent, proto_dependent, true);
  type(p)=proto_dependent;
  } 

@ @<Transform a known big node@>=
set_up_trans(c);
if (cur_type==known) @<Transform known by known@>@;
else{@+pp=stash_cur_exp();qq=value(pp);
  make_exp_copy(p);r=value(cur_exp);
  if (cur_type==transform_type) 
    {@+bilin2(yy_part_loc(r), yy_part_loc(qq),
      value(xy_part_loc(q)), yx_part_loc(qq), null);
    bilin2(yx_part_loc(r), yy_part_loc(qq),
      value(xx_part_loc(q)), yx_part_loc(qq), null);
    bilin2(xy_part_loc(r), xx_part_loc(qq),
      value(yy_part_loc(q)), xy_part_loc(qq), null);
    bilin2(xx_part_loc(r), xx_part_loc(qq),
      value(yx_part_loc(q)), xy_part_loc(qq), null);
    } 
  bilin2(y_part_loc(r), yy_part_loc(qq),
    value(x_part_loc(q)), yx_part_loc(qq), y_part_loc(qq));
  bilin2(x_part_loc(r), xx_part_loc(qq),
    value(y_part_loc(q)), xy_part_loc(qq), x_part_loc(qq));
  recycle_value(pp);free_node(pp, value_node_size);
  } 

@ Let |p| be a |proto_dependent| value whose dependency list ends
at |dep_final|. The following procedure adds |v| times another
numeric quantity to~|p|.

@<Declare subroutines needed by |big_trans|@>=
void add_mult_dep(pointer @!p, scaled @!v, pointer @!r)
{@+if (type(r)==known) 
  value(dep_final)=value(dep_final)+take_scaled(value(r), v);
else{@+dep_list(p)=
   p_plus_fq(dep_list(p), v, dep_list(r), proto_dependent, type(r));
  if (fix_needed) fix_dependencies();
  } 
} 

@ The |bilin2| procedure is something like |bilin1|, but with known
and unknown quantities reversed. Parameter |p| points to a value field
within the big node for |cur_exp|; and |type(p)==known|. Parameters
|t| and~|u| point to value fields elsewhere; so does parameter~|q|,
unless it is |null| (which stands for zero). Location~|p| will be
replaced by $p\cdot t+v\cdot u+q$.

@<Declare subroutines needed by |big_trans|@>=
void bilin2(pointer @!p, pointer @!t, scaled @!v, pointer @!u, pointer @!q)
{@+scaled @!vv; /*temporary storage for |value(p)|*/ 
vv=value(p);type(p)=proto_dependent;
new_dep(p, const_dependency(0)); /*this sets |dep_final|*/ 
if (vv!=0) add_mult_dep(p, vv, t); /*|dep_final| doesn't change*/ 
if (v!=0) add_mult_dep(p, v, u);
if (q!=null) add_mult_dep(p, unity, q);
if (dep_list(p)==dep_final) 
  {@+vv=value(dep_final);recycle_value(p);
  type(p)=known;value(p)=vv;
  } 
} 

@ @<Transform known by known@>=
{@+make_exp_copy(p);r=value(cur_exp);
if (cur_type==transform_type) 
  {@+bilin3(yy_part_loc(r), tyy, value(xy_part_loc(q)), tyx, 0);
  bilin3(yx_part_loc(r), tyy, value(xx_part_loc(q)), tyx, 0);
  bilin3(xy_part_loc(r), txx, value(yy_part_loc(q)), txy, 0);
  bilin3(xx_part_loc(r), txx, value(yx_part_loc(q)), txy, 0);
  } 
bilin3(y_part_loc(r), tyy, value(x_part_loc(q)), tyx, ty);
bilin3(x_part_loc(r), txx, value(y_part_loc(q)), txy, tx);
} 

@ Finally, in |bilin3| everything is |known|.

@<Declare subroutines needed by |big_trans|@>=
void bilin3(pointer @!p, scaled @!t, scaled @!v, scaled @!u, scaled @!delta)
{@+if (t!=unity) delta=delta+take_scaled(value(p), t);
else delta=delta+value(p);
if (u!=0) value(p)=delta+take_scaled(v, u);
else value(p)=delta;
} 

@ @<Additional cases of binary operators@>=
case concatenate: if ((cur_type==string_type)&&(type(p)==string_type)) cat(p);
  else bad_binary(p, concatenate);@+break;
case substring_of: if (nice_pair(p, type(p))&&(cur_type==string_type)) 
    chop_string(value(p));
  else bad_binary(p, substring_of);@+break;
case subpath_of: {@+if (cur_type==pair_type) pair_to_path();
  if (nice_pair(p, type(p))&&(cur_type==path_type)) 
    chop_path(value(p));
  else bad_binary(p, subpath_of);
  } @+break;

@ @<Declare binary action...@>=
void cat(pointer @!p)
{@+str_number @!a, @!b; /*the strings being concatenated*/ 
int @!k; /*index into |str_pool|*/ 
a=value(p);b=cur_exp;str_room(length(a)+length(b));
for (k=str_start[a]; k<=str_start[a+1]-1; k++) append_char(so(str_pool[k]));
for (k=str_start[b]; k<=str_start[b+1]-1; k++) append_char(so(str_pool[k]));
cur_exp=make_string();delete_str_ref(b);
} 

@ @<Declare binary action...@>=
void chop_string(pointer @!p)
{@+int @!a, @!b; /*start and stop points*/ 
int @!l; /*length of the original string*/ 
int @!k; /*runs from |a| to |b|*/ 
str_number @!s; /*the original string*/ 
bool @!reversed; /*was |a > b|?*/ 
a=round_unscaled(value(x_part_loc(p)));
b=round_unscaled(value(y_part_loc(p)));
if (a <= b) reversed=false;
else{@+reversed=true;k=a;a=b;b=k;
  } 
s=cur_exp;l=length(s);
if (a < 0) 
  {@+a=0;
  if (b < 0) b=0;
  } 
if (b > l) 
  {@+b=l;
  if (a > l) a=l;
  } 
str_room(b-a);
if (reversed)
  {for (k=str_start[s]+b-1; k>=str_start[s]+a; k--) append_char(so(str_pool[k]));}
else
  {for (k=str_start[s]+a; k<=str_start[s]+b-1; k++) append_char(so(str_pool[k]));}
cur_exp=make_string();delete_str_ref(s);
} 

@ @<Declare binary action...@>=
void chop_path(pointer @!p)
{@+pointer @!q; /*a knot in the original path*/ 
pointer @!pp, @!qq, @!rr, @!ss; /*link variables for copies of path nodes*/ 
scaled @!a, @!b, @!k, @!l; /*indices for chopping*/ 
bool @!reversed; /*was |a > b|?*/ 
l=path_length();a=value(x_part_loc(p));b=value(y_part_loc(p));
if (a <= b) reversed=false;
else{@+reversed=true;k=a;a=b;b=k;
  } 
@<Dispense with the cases |a<0| and/or |b>l|@>;
q=cur_exp;
while (a >= unity) 
  {@+q=link(q);a=a-unity;b=b-unity;
  } 
if (b==a) @<Construct a path from |pp| to |qq| of length zero@>@;
else@<Construct a path from |pp| to |qq| of length $\lceil b\rceil$@>;
left_type(pp)=endpoint;right_type(qq)=endpoint;link(qq)=pp;
toss_knot_list(cur_exp);
if (reversed) 
  {@+cur_exp=link(htap_ypoc(pp));toss_knot_list(pp);
  } 
else cur_exp=pp;
} 

@ @<Dispense with the cases |a<0| and/or |b>l|@>=
if (a < 0) 
  if (left_type(cur_exp)==endpoint) 
    {@+a=0;if (b < 0) b=0;
    } 
  else@/do@+{a=a+l;b=b+l;
    }@+ while (!(a >= 0)); /*a cycle always has length |l > 0|*/ 
if (b > l) if (left_type(cur_exp)==endpoint) 
    {@+b=l;if (a > l) a=l;
    } 
  else while (a >= l) 
    {@+a=a-l;b=b-l;
    } 

@ @<Construct a path from |pp| to |qq| of length $\lceil b\rceil$@>=
{@+pp=copy_knot(q);qq=pp;
@/do@+{q=link(q);rr=qq;qq=copy_knot(q);link(rr)=qq;b=b-unity;
}@+ while (!(b <= 0));
if (a > 0) 
  {@+ss=pp;pp=link(pp);
  split_cubic(ss, a*010000, x_coord(pp), y_coord(pp));pp=link(ss);
  free_node(ss, knot_node_size);
  if (rr==ss) 
    {@+b=make_scaled(b, unity-a);rr=pp;
    } 
  } 
if (b < 0) 
  {@+split_cubic(rr,(b+unity)*010000, x_coord(qq), y_coord(qq));
  free_node(qq, knot_node_size);
  qq=link(rr);
  } 
} 

@ @<Construct a path from |pp| to |qq| of length zero@>=
{@+if (a > 0) 
  {@+qq=link(q);
  split_cubic(q, a*010000, x_coord(qq), y_coord(qq));q=link(q);
  } 
pp=copy_knot(q);qq=pp;
} 

@ The |pair_value| routine changes the current expression to a
given ordered pair of values.

@<Declare binary action...@>=
void pair_value(scaled @!x, scaled @!y)
{@+pointer @!p; /*a pair node*/ 
p=get_node(value_node_size);flush_cur_exp(p);cur_type=pair_type;
type(p)=pair_type;name_type(p)=capsule;init_big_node(p);
p=value(p);@/
type(x_part_loc(p))=known;value(x_part_loc(p))=x;@/
type(y_part_loc(p))=known;value(y_part_loc(p))=y;@/
} 

@ @<Additional cases of binary operators@>=
case point_of: case precontrol_of: case postcontrol_of: {@+if (cur_type==pair_type) 
     pair_to_path();
  if ((cur_type==path_type)&&(type(p)==known)) 
    find_point(value(p), c);
  else bad_binary(p, c);
  } @+break;
case pen_offset_of: {@+if (cur_type==future_pen) materialize_pen();
  if ((cur_type==pen_type)&&nice_pair(p, type(p))) 
    set_up_offset(value(p));
  else bad_binary(p, pen_offset_of);
  } @+break;
case direction_time_of: {@+if (cur_type==pair_type) pair_to_path();
  if ((cur_type==path_type)&&nice_pair(p, type(p))) 
    set_up_direction_time(value(p));
  else bad_binary(p, direction_time_of);
  } @+break;

@ @<Declare binary action...@>=
void set_up_offset(pointer @!p)
{@+find_offset(value(x_part_loc(p)), value(y_part_loc(p)), cur_exp);
pair_value(cur_x, cur_y);
} 
@#
void set_up_direction_time(pointer @!p)
{@+flush_cur_exp(find_direction_time(value(x_part_loc(p)),
  value(y_part_loc(p)), cur_exp));
} 

@ @<Declare binary action...@>=
void find_point(scaled @!v, quarterword @!c)
{@+pointer @!p; /*the path*/ 
scaled @!n; /*its length*/ 
pointer @!q; /*successor of |p|*/ 
p=cur_exp;@/
if (left_type(p)==endpoint) n=-unity;@+else n=0;
@/do@+{p=link(p);n=n+unity;
}@+ while (!(p==cur_exp));
if (n==0) v=0;
else if (v < 0) 
  if (left_type(p)==endpoint) v=0;
  else v=n-1-((-v-1)%n);
else if (v > n) 
  if (left_type(p)==endpoint) v=n;
  else v=v%n;
p=cur_exp;
while (v >= unity) 
  {@+p=link(p);v=v-unity;
  } 
if (v!=0) @<Insert a fractional node by splitting the cubic@>;
@<Set the current expression to the desired path coordinates@>;
} 

@ @<Insert a fractional node...@>=
{@+q=link(p);split_cubic(p, v*010000, x_coord(q), y_coord(q));p=link(p);
} 

@ @<Set the current expression to the desired path coordinates...@>=
switch (c) {
case point_of: pair_value(x_coord(p), y_coord(p));@+break;
case precontrol_of: if (left_type(p)==endpoint) pair_value(x_coord(p), y_coord(p));
  else pair_value(left_x(p), left_y(p));@+break;
case postcontrol_of: if (right_type(p)==endpoint) pair_value(x_coord(p), y_coord(p));
  else pair_value(right_x(p), right_y(p));
}  /*there are no other cases*/ 

@ @<Additional cases of bin...@>=
case intersect: {@+if (type(p)==pair_type) 
    {@+q=stash_cur_exp();unstash_cur_exp(p);
    pair_to_path();p=stash_cur_exp();unstash_cur_exp(q);
    } 
  if (cur_type==pair_type) pair_to_path();
  if ((cur_type==path_type)&&(type(p)==path_type)) 
    {@+path_intersection(value(p), cur_exp);
    pair_value(cur_t, cur_tt);
    } 
  else bad_binary(p, intersect);
  } 

@* Statements and commands.
The chief executive of \MF\ is the |do_statement| routine, which
contains the master switch that causes all the various pieces of \MF\
to do their things, in the right order.

In a sense, this is the grand climax of the program: It applies all the
tools that we have worked so hard to construct. In another sense, this is
the messiest part of the program: It necessarily refers to other pieces
of code all over the place, so that a person can't fully understand what is
going on without paging back and forth to be reminded of conventions that
are defined elsewhere. We are now at the hub of the web.

The structure of |do_statement| itself is quite simple.  The first token
of the statement is fetched using |get_x_next|.  If it can be the first
token of an expression, we look for an equation, an assignment, or a
title. Otherwise we use a \&{case} construction to branch at high speed to
the appropriate routine for various and sundry other types of commands,
each of which has an ``action procedure'' that does the necessary work.

The program uses the fact that
$$\hbox{|min_primary_command==max_statement_command==type_name|}$$
to interpret a statement that starts with, e.g., `\&{string}',
as a type declaration rather than a boolean expression.

@p@t\4@>@<Declare generic font output procedures@>@;
@t\4@>@<Declare action procedures for use by |do_statement|@>@;
void do_statement(void) /*governs \MF's activities*/ 
{@+cur_type=vacuous;get_x_next();
if (cur_cmd > max_primary_command) @<Worry about bad statement@>@;
else if (cur_cmd > max_statement_command) 
  @<Do an equation, assignment, title, or `$\langle\,$expression$\,\rangle\,$\&{endgroup}'@>@;
else@<Do a statement that doesn't begin with an expression@>;
if (cur_cmd < semicolon) 
  @<Flush unparsable junk that was found after the statement@>;
error_count=0;
} 

@ The only command codes | > max_primary_command| that can be present
at the beginning of a statement are |semicolon| and higher; these
occur when the statement is null.

@<Worry about bad statement@>=
{@+if (cur_cmd < semicolon) 
  {@+print_err("A statement can't begin with `");
@.A statement can't begin with x@>
  print_cmd_mod(cur_cmd, cur_mod);print_char('\'');
  help5("I was looking for the beginning of a new statement.")@/
    ("If you just proceed without changing anything, I'll ignore")@/
    ("everything up to the next `;'. Please insert a semicolon")@/
    ("now in front of anything that you don't want me to delete.")@/
    ("(See Chapter 27 of The METAFONTbook for an example.)");@/
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
  back_error();get_x_next();
  } 
} 

@ The help message printed here says that everything is flushed up to
a semicolon, but actually the commands |end_group| and |stop| will
also terminate a statement.

@<Flush unparsable junk that was found after the statement@>=
{@+print_err("Extra tokens will be flushed");
@.Extra tokens will be flushed@>
help6("I've just read as much of that statement as I could fathom,")@/
("so a semicolon should have been next. It's very puzzling...")@/
("but I'll try to get myself back together, by ignoring")@/
("everything up to the next `;'. Please insert a semicolon")@/
("now in front of anything that you don't want me to delete.")@/
("(See Chapter 27 of The METAFONTbook for an example.)");@/
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
back_error();scanner_status=flushing;
@/do@+{get_next();
@<Decrease the string reference count...@>;
}@+ while (!(end_of_statement)); /*|cur_cmd==semicolon|, |end_group|, or |stop|*/ 
scanner_status=normal;
} 

@ If |do_statement| ends with |cur_cmd==end_group|, we should have
|cur_type==vacuous| unless the statement was simply an expression;
in the latter case, |cur_type| and |cur_exp| should represent that
expression.

@<Do a statement that doesn't...@>=
{@+if (internal[tracing_commands] > 0) show_cur_cmd_mod;
switch (cur_cmd) {
case type_name: do_type_declaration();@+break;
case macro_def: if (cur_mod > var_def) make_op_def();
  else if (cur_mod > end_def) scan_def();@+break;
@t\4@>@<Cases of |do_statement| that invoke particular commands@>@;
}  /*there are no other cases*/ 
cur_type=vacuous;
} 

@ The most important statements begin with expressions.

@<Do an equation, assignment, title, or...@>=
{@+var_flag=assignment;scan_expression();
if (cur_cmd < end_group) 
  {@+if (cur_cmd==equals) do_equation();
  else if (cur_cmd==assignment) do_assignment();
  else if (cur_type==string_type) @<Do a title@>@;
  else if (cur_type!=vacuous) 
    {@+exp_err(@[@<|"Isolated expression"|@>@]);
@.Isolated expression@>
    help3("I couldn't find an `=' or `:=' after the")@/
      ("expression that is shown above this error message,")@/
      ("so I guess I'll just ignore it and carry on.");
    put_get_error();
    } 
  flush_cur_exp(0);cur_type=vacuous;
  } 
} 

@ @<Do a title@>=
{@+if (internal[tracing_titles] > 0) 
  {@+print_nl("");slow_print(cur_exp);update_terminal;
  } 
if (internal[proofing] > 0) 
  @<Send the current expression as a title to the output file@>;
} 

@ Equations and assignments are performed by the pair of mutually recursive
@^recursion@>
routines |do_equation| and |do_assignment|. These routines are called when
|cur_cmd==equals| and when |cur_cmd==assignment|, respectively; the left-hand
side is in |cur_type| and |cur_exp|, while the right-hand side is yet
to be scanned. After the routines are finished, |cur_type| and |cur_exp|
will be equal to the right-hand side (which will normally be equal
to the left-hand side).

@<Declare action procedures for use by |do_statement|@>=
@t\4@>@<Declare the procedure called |try_eq|@>@;
@t\4@>@<Declare the procedure called |make_eq|@>@;
void do_assignment(void);@/
void do_equation(void)
{@+pointer @!lhs; /*capsule for the left-hand side*/ 
pointer @!p; /*temporary register*/ 
lhs=stash_cur_exp();get_x_next();var_flag=assignment;scan_expression();
if (cur_cmd==equals) do_equation();
else if (cur_cmd==assignment) do_assignment();
if (internal[tracing_commands] > two) @<Trace the current equation@>;
if (cur_type==unknown_path) if (type(lhs)==pair_type) 
  {@+p=stash_cur_exp();unstash_cur_exp(lhs);lhs=p;
  }  /*in this case |make_eq| will change the pair to a path*/ 
make_eq(lhs); /*equate |lhs| to |(cur_type, cur_exp)|*/ 
} 

@ And |do_assignment| is similar to |do_equation|:

@<Declare action procedures for use by |do_statement|@>=
void do_assignment(void)
{@+pointer @!lhs; /*token list for the left-hand side*/ 
pointer @!p; /*where the left-hand value is stored*/ 
pointer @!q; /*temporary capsule for the right-hand value*/ 
if (cur_type!=token_list) 
  {@+exp_err(@[@<|"Improper `:=' will be changed to `='"|@>@]);
@.Improper `:='@>
  help2("I didn't find a variable name at the left of the `:=',")@/
    ("so I'm going to pretend that you said `=' instead.");@/
  error();do_equation();
  } 
else{@+lhs=cur_exp;cur_type=vacuous;@/
  get_x_next();var_flag=assignment;scan_expression();
  if (cur_cmd==equals) do_equation();
  else if (cur_cmd==assignment) do_assignment();
  if (internal[tracing_commands] > two) @<Trace the current assignment@>;
  if (info(lhs) > hash_end) 
    @<Assign the current expression to an internal variable@>@;
  else@<Assign the current expression to the variable |lhs|@>;
  flush_node_list(lhs);
  } 
} 

@ @<Trace the current equation@>=
{@+begin_diagnostic();print_nl("{(");print_exp(lhs, 0);
print_str(")=(");print_exp(null, 0);print_str(")}");end_diagnostic(false);
} 

@ @<Trace the current assignment@>=
{@+begin_diagnostic();print_nl("{");
if (info(lhs) > hash_end) slow_print(int_name[info(lhs)-(hash_end)]);
else show_token_list(lhs, null, 1000, 0);
print_str(":=");print_exp(null, 0);print_char('}');end_diagnostic(false);
} 

@ @<Assign the current expression to an internal variable@>=
if (cur_type==known) internal[info(lhs)-(hash_end)]=cur_exp;
else{@+exp_err(@[@<|"Internal quantity `"|@>@]);
@.Internal quantity...@>
  slow_print(int_name[info(lhs)-(hash_end)]);
  print_str("' must receive a known value");
  help2("I can't set an internal quantity to anything but a known")@/
    ("numeric value, so I'll have to ignore this assignment.");
  put_get_error();
  } 

@ @<Assign the current expression to the variable |lhs|@>=
{@+p=find_variable(lhs);
if (p!=null) 
  {@+q=stash_cur_exp();cur_type=und_type(p);recycle_value(p);
  type(p)=cur_type;value(p)=null;make_exp_copy(p);
  p=stash_cur_exp();unstash_cur_exp(q);make_eq(p);
  } 
else{@+obliterated(lhs);put_get_error();
  } 
} 


@ And now we get to the nitty-gritty. The |make_eq| procedure is given
a pointer to a capsule that is to be equated to the current expression.

@<Declare the procedure called |make_eq|@>=
void make_eq(pointer @!lhs)
{@+
small_number @!t; /*type of the left-hand side*/ 
int @!v; /*value of the left-hand side*/ 
pointer @!p, @!q; /*pointers inside of big nodes*/ 
restart: t=type(lhs);
if (t <= pair_type) v=value(lhs);
switch (t) {
@t\4@>@<For each type |t|, make an equation and |goto done| unless |cur_type| is incompatible
with~|t|@>@;
}  /*all cases have been listed*/ 
@<Announce that the equation cannot be performed@>;
done: check_arith;recycle_value(lhs);free_node(lhs, value_node_size);
} 

@ @<Announce that the equation cannot be performed@>=
disp_err(lhs, empty_string);exp_err(@[@<|"Equation cannot be performed ("|@>@]);
@.Equation cannot be performed@>
if (type(lhs) <= pair_type) print_type(type(lhs));@+else print_str("numeric");
print_char('=');
if (cur_type <= pair_type) print_type(cur_type);@+else print_str("numeric");
print_char(')');@/
help2("I'm sorry, but I don't know how to make such things equal.")@/
  ("(See the two expressions just above the error message.)");
put_get_error()

@ @<For each type |t|, make an equation and |goto done| unless...@>=
case boolean_type: case string_type: case pen_type: case path_type: case picture_type: 
  if (cur_type==t+unknown_tag) 
    {@+nonlinear_eq(v, cur_exp, false);unstash_cur_exp(cur_exp);goto done;
    } 
  else if (cur_type==t) 
    @<Report redundant or inconsistent equation and |goto done|@>@;@+break;
unknown_types: if (cur_type==t-unknown_tag) 
    {@+nonlinear_eq(cur_exp, lhs, true);goto done;
    } 
  else if (cur_type==t) 
    {@+ring_merge(lhs, cur_exp);goto done;
    } 
  else if (cur_type==pair_type) if (t==unknown_path) 
    {@+pair_to_path();goto restart;
    } @+break;
case transform_type: case pair_type: if (cur_type==t) 
    @<Do multiple equations and |goto done|@>@;@+break;
case known: case dependent: case proto_dependent: case independent: if (cur_type >= known) 
    {@+try_eq(lhs, null);goto done;
    } @+break;
case vacuous: do_nothing;

@ @<Report redundant or inconsistent equation and |goto done|@>=
{@+if (cur_type <= string_type) 
  {@+if (cur_type==string_type) 
    {@+if (str_vs_str(v, cur_exp)!=0) goto not_found;
    } 
  else if (v!=cur_exp) goto not_found;
  @<Exclaim about a redundant equation@>;goto done;
  } 
print_err("Redundant or inconsistent equation");
@.Redundant or inconsistent equation@>
help2("An equation between already-known quantities can't help.")@/
  ("But don't worry; continue and I'll just ignore it.");
put_get_error();goto done;
not_found: print_err("Inconsistent equation");
@.Inconsistent equation@>
help2("The equation I just read contradicts what was said before.")@/
  ("But don't worry; continue and I'll just ignore it.");
put_get_error();goto done;
} 

@ @<Do multiple equations and |goto done|@>=
{@+p=v+big_node_size[t];q=value(cur_exp)+big_node_size[t];
@/do@+{p=p-2;q=q-2;try_eq(p, q);
}@+ while (!(p==v));
goto done;
} 

@ The first argument to |try_eq| is the location of a value node
in a capsule that will soon be recycled. The second argument is
either a location within a pair or transform node pointed to by
|cur_exp|, or it is |null| (which means that |cur_exp| itself
serves as the second argument). The idea is to leave |cur_exp| unchanged,
but to equate the two operands.

@<Declare the procedure called |try_eq|@>=
void try_eq(pointer @!l, pointer @!r)
{@+
pointer @!p; /*dependency list for right operand minus left operand*/ 
uint8_t @!t; /*the type of list |p|*/ 
pointer @!q; /*the constant term of |p| is here*/ 
pointer @!pp; /*dependency list for right operand*/ 
uint8_t @!tt; /*the type of list |pp|*/ 
bool @!copied; /*have we copied a list that ought to be recycled?*/ 
@<Remove the left operand from its container, negate it, and put it into dependency
list~|p| with constant term~|q|@>;
@<Add the right operand to list |p|@>;
if (info(p)==null) @<Deal with redundant or inconsistent equation@>@;
else{@+linear_eq(p, t);
  if (r==null) if (cur_type!=known) if (type(cur_exp)==known) 
    {@+pp=cur_exp;cur_exp=value(cur_exp);cur_type=known;
    free_node(pp, value_node_size);
    } 
  } 
} 

@ @<Remove the left operand from its container, negate it, and...@>=
t=type(l);
if (t==known) 
  {@+t=dependent;p=const_dependency(-value(l));q=p;
  } 
else if (t==independent) 
  {@+t=dependent;p=single_dependency(l);negate(value(p));
  q=dep_final;
  } 
else{@+p=dep_list(l);q=p;
  loop@+{@+negate(value(q));
    if (info(q)==null) goto done;
    q=link(q);
    } 
 done: link(prev_dep(l))=link(q);prev_dep(link(q))=prev_dep(l);
  type(l)=known;
  } 

@ @<Deal with redundant or inconsistent equation@>=
{@+if (abs(value(p)) > 64)  /*off by .001 or more*/ 
  {@+print_err("Inconsistent equation");@/
@.Inconsistent equation@>
  print_str(" (off by ");print_scaled(value(p));print_char(')');
  help2("The equation I just read contradicts what was said before.")@/
    ("But don't worry; continue and I'll just ignore it.");
  put_get_error();
  } 
else if (r==null) @<Exclaim about a redundant equation@>;
free_node(p, dep_node_size);
} 

@ @<Add the right operand to list |p|@>=
if (r==null) 
  if (cur_type==known) 
    {@+value(q)=value(q)+cur_exp;goto done1;
    } 
  else{@+tt=cur_type;
    if (tt==independent) pp=single_dependency(cur_exp);
    else pp=dep_list(cur_exp);
    } 
else if (type(r)==known) 
    {@+value(q)=value(q)+value(r);goto done1;
    } 
  else{@+tt=type(r);
    if (tt==independent) pp=single_dependency(r);
    else pp=dep_list(r);
    } 
if (tt!=independent) copied=false;
else{@+copied=true;tt=dependent;
  } 
@<Add dependency list |pp| of type |tt| to dependency list~|p| of type~|t|@>;
if (copied) flush_node_list(pp);
done1: 

@ @<Add dependency list |pp| of type |tt| to dependency list~|p| of type~|t|@>=
watch_coefs=false;
if (t==tt) p=p_plus_q(p, pp, t);
else if (t==proto_dependent) 
  p=p_plus_fq(p, unity, pp, proto_dependent, dependent);
else{@+q=p;
  while (info(q)!=null) 
    {@+value(q)=round_fraction(value(q));q=link(q);
    } 
  t=proto_dependent;p=p_plus_q(p, pp, t);
  } 
watch_coefs=true;

@ Our next goal is to process type declarations. For this purpose it's
convenient to have a procedure that scans a $\langle\,$declared
variable$\,\rangle$ and returns the corresponding token list. After the
following procedure has acted, the token after the declared variable
will have been scanned, so it will appear in |cur_cmd|, |cur_mod|,
and~|cur_sym|.

@<Declare the function called |scan_declared_variable|@>=
pointer scan_declared_variable(void)
{@+
pointer @!x; /*hash address of the variable's root*/ 
pointer @!h, @!t; /*head and tail of the token list to be returned*/ 
pointer @!l; /*hash address of left bracket*/ 
get_symbol();x=cur_sym;
if (cur_cmd!=tag_token) clear_symbol(x, false);
h=get_avail();info(h)=x;t=h;@/
loop@+{@+get_x_next();
  if (cur_sym==0) goto done;
  if (cur_cmd!=tag_token) if (cur_cmd!=internal_quantity) 
    if (cur_cmd==left_bracket) @<Descend past a collective subscript@>@;
    else goto done;
  link(t)=get_avail();t=link(t);info(t)=cur_sym;
  } 
done: if (eq_type(x)%outer_tag!=tag_token) clear_symbol(x, false);
if (equiv(x)==null) new_root(x);
return h;
} 

@ If the subscript isn't collective, we don't accept it as part of the
declared variable.

@<Descend past a collective subscript@>=
{@+l=cur_sym;get_x_next();
if (cur_cmd!=right_bracket) 
  {@+back_input();cur_sym=l;cur_cmd=left_bracket;goto done;
  } 
else cur_sym=collective_subscript;
} 

@ Type declarations are introduced by the following primitive operations.

@<Put each...@>=
primitive(@[@<|"numeric"|@>@], type_name, numeric_type);@/
@!@:numeric_}{\&{numeric} primitive@>
primitive(@[@<|"string"|@>@], type_name, string_type);@/
@!@:string_}{\&{string} primitive@>
primitive(@[@<|"boolean"|@>@], type_name, boolean_type);@/
@!@:boolean_}{\&{boolean} primitive@>
primitive(@[@<|"path"|@>@], type_name, path_type);@/
@!@:path_}{\&{path} primitive@>
primitive(@[@<|"pen"|@>@], type_name, pen_type);@/
@!@:pen_}{\&{pen} primitive@>
primitive(@[@<|"picture"|@>@], type_name, picture_type);@/
@!@:picture_}{\&{picture} primitive@>
primitive(@[@<|"transform"|@>@], type_name, transform_type);@/
@!@:transform_}{\&{transform} primitive@>
primitive(@[@<|"pair"|@>@], type_name, pair_type);@/
@!@:pair_}{\&{pair} primitive@>

@ @<Cases of |print_cmd...@>=
case type_name: print_type(m);@+break;

@ Now we are ready to handle type declarations, assuming that a
|type_name| has just been scanned.

@<Declare action procedures for use by |do_statement|@>=
void do_type_declaration(void)
{@+small_number @!t; /*the type being declared*/ 
pointer @!p; /*token list for a declared variable*/ 
pointer @!q; /*value node for the variable*/ 
if (cur_mod >= transform_type) t=cur_mod;@+else t=cur_mod+unknown_tag;
@/do@+{p=scan_declared_variable();
flush_variable(equiv(info(p)), link(p), false);@/
q=find_variable(p);
if (q!=null) 
  {@+type(q)=t;value(q)=null;
  } 
else{@+print_err("Declared variable conflicts with previous vardef");
@.Declared variable conflicts...@>
  help2("You can't use, e.g., `numeric foo[]' after `vardef foo'.")@/
    ("Proceed, and I'll ignore the illegal redeclaration.");
  put_get_error();
  } 
flush_list(p);
if (cur_cmd < comma) @<Flush spurious symbols after the declared variable@>;
}@+ while (!(end_of_statement));
} 

@ @<Flush spurious symbols after the declared variable@>=
{@+print_err("Illegal suffix of declared variable will be flushed");
@.Illegal suffix...flushed@>
help5("Variables in declarations must consist entirely of")@/
  ("names and collective subscripts, e.g., `x[]a'.")@/
  ("Are you trying to use a reserved word in a variable name?")@/
  ("I'm going to discard the junk I found here,")@/
  ("up to the next comma or the end of the declaration.");
if (cur_cmd==numeric_token) 
  help_line[2]="Explicit subscripts like `x15a' aren't permitted.";
put_get_error();scanner_status=flushing;
@/do@+{get_next();
@<Decrease the string reference count...@>;
}@+ while (!(cur_cmd >= comma)); /*either |end_of_statement| or |cur_cmd==comma|*/ 
scanner_status=normal;
} 

@ \MF's |main_control| procedure just calls |do_statement| repeatedly
until coming to the end of the user's program.
Each execution of |do_statement| concludes with
|cur_cmd==semicolon|, |end_group|, or |stop|.

@p void main_control(void)
{@+@/do@+{do_statement();
if (cur_cmd==end_group) 
  {@+print_err("Extra `endgroup'");
@.Extra `endgroup'@>
  help2("I'm not currently working on a `begingroup',")@/
    ("so I had better not try to end anything.");
  flush_error(0);
  } 
}@+ while (!(cur_cmd==stop));
} 

@ @<Put each...@>=
primitive(@[@<|"end"|@>@], stop, 0);@/
@!@:end_}{\&{end} primitive@>
primitive(@[@<|"dump"|@>@], stop, 1);@/
@!@:dump_}{\&{dump} primitive@>

@ @<Cases of |print_cmd...@>=
case stop: if (m==0) print_str("end");@+else print_str("dump");@+break;

@* Commands.
Let's turn now to statements that are classified as ``commands'' because
of their imperative nature. We'll begin with simple ones, so that it
will be clear how to hook command processing into the |do_statement| routine;
then we'll tackle the tougher commands.

Here's one of the simplest:

@<Cases of |do_statement|...@>=
case random_seed: do_random_seed();@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void do_random_seed(void)
{@+get_x_next();
if (cur_cmd!=assignment) 
  {@+missing_err(@[@<|":="|@>@]);
@.Missing `:='@>
  help1("Always say `randomseed:=<numeric expression>'.");
  back_error();
  } 
get_x_next();scan_expression();
if (cur_type!=known) 
  {@+exp_err(@[@<|"Unknown value will be ignored"|@>@]);
@.Unknown value...ignored@>
  help2("Your expression was too random for me to handle,")@/
    ("so I won't change the random seed just now.");@/
  put_get_flush_error(0);
  } 
else@<Initialize the random seed to |cur_exp|@>;
} 

@ @<Initialize the random seed to |cur_exp|@>=
{@+init_randoms(cur_exp);
if (selector >= log_only) 
  {@+old_setting=selector;selector=log_only;
  print_nl("{randomseed:=");print_scaled(cur_exp);print_char('}');
  print_nl("");selector=old_setting;
  } 
} 

@ And here's another simple one (somewhat different in flavor):

@<Cases of |do_statement|...@>=
case mode_command: {@+print_ln();interaction=cur_mod;
  @<Initialize the print |selector| based on |interaction|@>;
  if (log_opened) selector=selector+2;
  get_x_next();
  } @+break;

@ @<Put each...@>=
primitive(@[@<|"batchmode"|@>@], mode_command, batch_mode);
@!@:batch_mode_}{\&{batchmode} primitive@>
primitive(@[@<|"nonstopmode"|@>@], mode_command, nonstop_mode);
@!@:nonstop_mode_}{\&{nonstopmode} primitive@>
primitive(@[@<|"scrollmode"|@>@], mode_command, scroll_mode);
@!@:scroll_mode_}{\&{scrollmode} primitive@>
primitive(@[@<|"errorstopmode"|@>@], mode_command, error_stop_mode);
@!@:error_stop_mode_}{\&{errorstopmode} primitive@>

@ @<Cases of |print_cmd_mod|...@>=
case mode_command: switch (m) {
  case batch_mode: print_str("batchmode");@+break;
  case nonstop_mode: print_str("nonstopmode");@+break;
  case scroll_mode: print_str("scrollmode");@+break;
  default:print_str("errorstopmode");
  } @+break;

@ The `\&{inner}' and `\&{outer}' commands are only slightly harder.

@<Cases of |do_statement|...@>=
case protection_command: do_protection();@+break;

@ @<Put each...@>=
primitive(@[@<|"inner"|@>@], protection_command, 0);@/
@!@:inner_}{\&{inner} primitive@>
primitive(@[@<|"outer"|@>@], protection_command, 1);@/
@!@:outer_}{\&{outer} primitive@>

@ @<Cases of |print_cmd...@>=
case protection_command: if (m==0) print_str("inner");@+else print_str("outer");@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void do_protection(void)
{@+uint8_t @!m; /*0 to unprotect, 1 to protect*/ 
halfword @!t; /*the |eq_type| before we change it*/ 
m=cur_mod;
@/do@+{get_symbol();t=eq_type(cur_sym);
  if (m==0) 
    {@+if (t >= outer_tag) eq_type(cur_sym)=t-outer_tag;
    } 
  else if (t < outer_tag) eq_type(cur_sym)=t+outer_tag;
  get_x_next();
}@+ while (!(cur_cmd!=comma));
} 

@ \MF\ never defines the tokens `\.(' and `\.)' to be primitives, but
plain \MF\ begins with the declaration `\&{delimiters} \.{()}'. Such a
declaration assigns the command code |left_delimiter| to `\.{(}' and
|right_delimiter| to `\.{)}'; the |equiv| of each delimiter is the
hash address of its mate.

@<Cases of |do_statement|...@>=
case delimiters: def_delims();@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void def_delims(void)
{@+pointer l_delim, r_delim; /*the new delimiter pair*/ 
get_clear_symbol();l_delim=cur_sym;@/
get_clear_symbol();r_delim=cur_sym;@/
eq_type(l_delim)=left_delimiter;equiv(l_delim)=r_delim;@/
eq_type(r_delim)=right_delimiter;equiv(r_delim)=l_delim;@/
get_x_next();
} 

@ Here is a procedure that is called when \MF\ has reached a point
where some right delimiter is mandatory.

@<Declare the procedure called |check_delimiter|@>=
void check_delimiter(pointer @!l_delim, pointer @!r_delim)
{@+
if (cur_cmd==right_delimiter) if (cur_mod==l_delim) return;
if (cur_sym!=r_delim) 
  {@+missing_err(text(r_delim));@/
@.Missing `)'@>
  help2("I found no right delimiter to match a left one. So I've")@/
    ("put one in, behind the scenes; this may fix the problem.");
  back_error();
  } 
else{@+print_err("The token `");slow_print(text(r_delim));
@.The token...delimiter@>
  print_str("' is no longer a right delimiter");
  help3("Strange: This token has lost its former meaning!")@/
    ("I'll read it as a right delimiter this time;")@/
    ("but watch out, I'll probably miss it later.");
  error();
  } 
} 

@ The next four commands save or change the values associated with tokens.

@<Cases of |do_statement|...@>=
case save_command: @/do@+{get_symbol();save_variable(cur_sym);get_x_next();
  }@+ while (!(cur_cmd!=comma));@+break;
case interim_command: do_interim();@+break;
case let_command: do_let();@+break;
case new_internal: do_new_internal();@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void do_statement(void);@/
void do_interim(void)
{@+get_x_next();
if (cur_cmd!=internal_quantity) 
  {@+print_err("The token `");
@.The token...quantity@>
  if (cur_sym==0) print_str("(%CAPSULE)");
  else slow_print(text(cur_sym));
  print_str("' isn't an internal quantity");
  help1("Something like `tracingonline' should follow `interim'.");
  back_error();
  } 
else{@+save_internal(cur_mod);back_input();
  } 
do_statement();
} 

@ The following procedure is careful not to undefine the left-hand symbol
too soon, lest commands like `{\tt let x=x}' have a surprising effect.

@<Declare action procedures for use by |do_statement|@>=
void do_let(void)
{@+pointer @!l; /*hash location of the left-hand symbol*/ 
get_symbol();l=cur_sym;get_x_next();
if (cur_cmd!=equals) if (cur_cmd!=assignment) 
  {@+missing_err('=');
@.Missing `='@>
  help3("You should have said `let symbol = something'.")@/
    ("But don't worry; I'll pretend that an equals sign")@/
    ("was present. The next token I read will be `something'.");
  back_error();
  } 
get_symbol();
switch (cur_cmd) {
case defined_macro: case secondary_primary_macro: case tertiary_secondary_macro: 
 case expression_tertiary_macro: add_mac_ref(cur_mod);@+break;
default:do_nothing;
} @/
clear_symbol(l, false);eq_type(l)=cur_cmd;
if (cur_cmd==tag_token) equiv(l)=null;
else equiv(l)=cur_mod;
get_x_next();
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_new_internal(void)
{@+@/do@+{if (int_ptr==max_internal) 
  overflow("number of internals", max_internal);
@:METAFONT capacity exceeded number of int}{\quad number of internals@>
get_clear_symbol();incr(int_ptr);
eq_type(cur_sym)=internal_quantity;equiv(cur_sym)=int_ptr;
int_name[int_ptr]=text(cur_sym);internal[int_ptr]=0;
get_x_next();
}@+ while (!(cur_cmd!=comma));
} 

@ The various `\&{show}' commands are distinguished by modifier fields
in the usual way.

@d show_token_code	0 /*show the meaning of a single token*/ 
@d show_stats_code	1 /*show current memory and string usage*/ 
@d show_code	2 /*show a list of expressions*/ 
@d show_var_code	3 /*show a variable and its descendents*/ 
@d show_dependencies_code	4 /*show dependent variables in terms of independents*/ 

@<Put each...@>=
primitive(@[@<|"showtoken"|@>@], show_command, show_token_code);@/
@!@:show_token_}{\&{showtoken} primitive@>
primitive(@[@<|"showstats"|@>@], show_command, show_stats_code);@/
@!@:show_stats_}{\&{showstats} primitive@>
primitive(@[@<|"show"|@>@], show_command, show_code);@/
@!@:show_}{\&{show} primitive@>
primitive(@[@<|"showvariable"|@>@], show_command, show_var_code);@/
@!@:show_var_}{\&{showvariable} primitive@>
primitive(@[@<|"showdependencies"|@>@], show_command, show_dependencies_code);@/
@!@:show_dependencies_}{\&{showdependencies} primitive@>

@ @<Cases of |print_cmd...@>=
case show_command: switch (m) {
  case show_token_code: print_str("showtoken");@+break;
  case show_stats_code: print_str("showstats");@+break;
  case show_code: print_str("show");@+break;
  case show_var_code: print_str("showvariable");@+break;
  default:print_str("showdependencies");
  } @+break;

@ @<Cases of |do_statement|...@>=
case show_command: do_show_whatever();@+break;

@ The value of |cur_mod| controls the |verbosity| in the |print_exp| routine:
If it's |show_code|, complicated structures are abbreviated, otherwise
they aren't.

@<Declare action procedures for use by |do_statement|@>=
void do_show(void)
{@+@/do@+{get_x_next();scan_expression();
print_nl(">> ");
@.>>@>
print_exp(null, 2);flush_cur_exp(0);
}@+ while (!(cur_cmd!=comma));
} 

@ @<Declare action procedures for use by |do_statement|@>=
void disp_token(void)
{@+print_nl("> ");
@.>\relax@>
if (cur_sym==0) @<Show a numeric or string or capsule token@>@;
else{@+slow_print(text(cur_sym));print_char('=');
  if (eq_type(cur_sym) >= outer_tag) print_str("(outer) ");
  print_cmd_mod(cur_cmd, cur_mod);
  if (cur_cmd==defined_macro) 
    {@+print_ln();show_macro(cur_mod, null, 100000);
    }  /*this avoids recursion between |show_macro| and |print_cmd_mod|*/ 
@^recursion@>
  } 
} 

@ @<Show a numeric or string or capsule token@>=
{@+if (cur_cmd==numeric_token) print_scaled(cur_mod);
else if (cur_cmd==capsule_token) 
  {@+g_pointer=cur_mod;print_capsule();
  } 
else{@+print_char('"');slow_print(cur_mod);print_char('"');
  delete_str_ref(cur_mod);
  } 
} 

@ The following cases of |print_cmd_mod| might arise in connection
with |disp_token|, although they don't necessarily correspond to
primitive tokens.

@<Cases of |print_cmd_...@>=
case left_delimiter: case right_delimiter: {@+if (c==left_delimiter) print_str("lef");
  else print_str("righ");
  print_str("t delimiter that matches ");slow_print(text(m));
  } @+break;
case tag_token: if (m==null) print_str("tag");@+else print_str("variable");@+break;
case defined_macro: print_str("macro:");@+break;
case secondary_primary_macro: case tertiary_secondary_macro: case expression_tertiary_macro: 
  {@+print_cmd_mod(macro_def, c);print_str("'d macro:");
  print_ln();show_token_list(link(link(m)), null, 1000, 0);
  } @+break;
case repeat_loop: print_str("[repeat the loop]");@+break;
case internal_quantity: slow_print(int_name[m]);@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void do_show_token(void)
{@+@/do@+{get_next();disp_token();
get_x_next();
}@+ while (!(cur_cmd!=comma));
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_show_stats(void)
{@+print_nl("Memory usage ");
@.Memory usage...@>
#ifdef @!STAT
print_int(var_used);print_char('&');print_int(dyn_used);
if (false) 
#endif
@t@>@;@/
print_str("unknown");
print_str(" (");print_int(hi_mem_min-lo_mem_max-1);
print_str(" still untouched)");print_ln();
print_nl("String usage ");
print_int(str_ptr-init_str_ptr);print_char('&');
print_int(pool_ptr-init_pool_ptr);
print_str(" (");
print_int(max_strings-max_str_ptr);print_char('&');
print_int(pool_size-max_pool_ptr);print_str(" still untouched)");print_ln();
get_x_next();
} 

@ Here's a recursive procedure that gives an abbreviated account
of a variable, for use by |do_show_var|.

@<Declare action procedures for use by |do_statement|@>=
void disp_var(pointer @!p)
{@+pointer @!q; /*traverses attributes and subscripts*/ 
uint8_t @!n; /*amount of macro text to show*/ 
if (type(p)==structured) @<Descend the structure@>@;
else if (type(p) >= unsuffixed_macro) @<Display a variable macro@>@;
else if (type(p)!=undefined) 
  {@+print_nl("");print_variable_name(p);print_char('=');
  print_exp(p, 0);
  } 
} 

@ @<Descend the structure@>=
{@+q=attr_head(p);
@/do@+{disp_var(q);q=link(q);
}@+ while (!(q==end_attr));
q=subscr_head(p);
while (name_type(q)==subscr) 
  {@+disp_var(q);q=link(q);
  } 
} 

@ @<Display a variable macro@>=
{@+print_nl("");print_variable_name(p);
if (type(p) > unsuffixed_macro) print_str("@@#"); /*|suffixed_macro|*/ 
print_str("=macro:");
if (file_offset >= max_print_line-20) n=5;
else n=max_print_line-file_offset-15;
show_macro(value(p), null, n);
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_show_var(void)
{@+
@/do@+{get_next();
if (cur_sym > 0) if (cur_sym <= hash_end) 
 if (cur_cmd==tag_token) if (cur_mod!=null) 
  {@+disp_var(cur_mod);goto done;
  } 
disp_token();
done: get_x_next();
}@+ while (!(cur_cmd!=comma));
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_show_dependencies(void)
{@+pointer @!p; /*link that runs through all dependencies*/ 
p=link(dep_head);
while (p!=dep_head) 
  {@+if (interesting(p)) 
    {@+print_nl("");print_variable_name(p);
    if (type(p)==dependent) print_char('=');
    else print_str(" = "); /*extra spaces imply proto-dependency*/ 
    print_dependency(dep_list(p), type(p));
    } 
  p=dep_list(p);
  while (info(p)!=null) p=link(p);
  p=link(p);
  } 
get_x_next();
} 

@ Finally we are ready for the procedure that governs all of the
show commands.

@<Declare action procedures for use by |do_statement|@>=
void do_show_whatever(void)
{@+if (interaction==error_stop_mode) wake_up_terminal;
switch (cur_mod) {
case show_token_code: do_show_token();@+break;
case show_stats_code: do_show_stats();@+break;
case show_code: do_show();@+break;
case show_var_code: do_show_var();@+break;
case show_dependencies_code: do_show_dependencies();
}  /*there are no other cases*/ 
if (internal[showstopping] > 0) 
  {@+print_err("OK");
@.OK@>
  if (interaction < error_stop_mode) 
    {@+help0;decr(error_count);
    } 
  else help1("This isn't an error message; I'm just showing something.");
  if (cur_cmd==semicolon) error();@+else put_get_error();
  } 
} 

@ The `\&{addto}' command needs the following additional primitives:

@d drop_code	0 /*command modifier for `\&{dropping}'*/ 
@d keep_code	1 /*command modifier for `\&{keeping}'*/ 

@<Put each...@>=
primitive(@[@<|"contour"|@>@], thing_to_add, contour_code);@/
@!@:contour_}{\&{contour} primitive@>
primitive(@[@<|"doublepath"|@>@], thing_to_add, double_path_code);@/
@!@:double_path_}{\&{doublepath} primitive@>
primitive(@[@<|"also"|@>@], thing_to_add, also_code);@/
@!@:also_}{\&{also} primitive@>
primitive(@[@<|"withpen"|@>@], with_option, pen_type);@/
@!@:with_pen_}{\&{withpen} primitive@>
primitive(@[@<|"withweight"|@>@], with_option, known);@/
@!@:with_weight_}{\&{withweight} primitive@>
primitive(@[@<|"dropping"|@>@], cull_op, drop_code);@/
@!@:dropping_}{\&{dropping} primitive@>
primitive(@[@<|"keeping"|@>@], cull_op, keep_code);@/
@!@:keeping_}{\&{keeping} primitive@>

@ @<Cases of |print_cmd...@>=
case thing_to_add: if (m==contour_code) print_str("contour");
  else if (m==double_path_code) print_str("doublepath");
  else print_str("also");@+break;
case with_option: if (m==pen_type) print_str("withpen");
  else print_str("withweight");@+break;
case cull_op: if (m==drop_code) print_str("dropping");
  else print_str("keeping");@+break;

@ @<Declare action procedures for use by |do_statement|@>=
bool scan_with(void)
{@+small_number @!t; /*|known| or |pen_type|*/ 
bool @!result; /*the value to return*/ 
t=cur_mod;cur_type=vacuous;get_x_next();scan_expression();
result=false;
if (cur_type!=t) @<Complain about improper type@>@;
else if (cur_type==pen_type) result=true;
else@<Check the tentative weight@>;
return result;
} 

@ @<Complain about improper type@>=
{@+exp_err(@[@<|"Improper type"|@>@]);
@.Improper type@>
help2("Next time say `withweight <known numeric expression>';")@/
  ("I'll ignore the bad `with' clause and look for another.");
if (t==pen_type) 
  help_line[1]="Next time say `withpen <known pen expression>';";
put_get_flush_error(0);
} 

@ @<Check the tentative weight@>=
{@+cur_exp=round_unscaled(cur_exp);
if ((abs(cur_exp) < 4)&&(cur_exp!=0)) result=true;
else{@+print_err("Weight must be -3, -2, -1, +1, +2, or +3");
@.Weight must be...@>
  help1("I'll ignore the bad `with' clause and look for another.");
  put_get_flush_error(0);
  } 
} 

@ One of the things we need to do when we've parsed an \&{addto} or
similar command is set |cur_edges| to the header of a supposed \&{picture}
variable, given a token list for that variable.

@<Declare action procedures for use by |do_statement|@>=
void find_edges_var(pointer @!t)
{@+pointer @!p;
p=find_variable(t);cur_edges=null;
if (p==null) 
  {@+obliterated(t);put_get_error();
  } 
else if (type(p)!=picture_type) 
  {@+print_err("Variable ");show_token_list(t, null, 1000, 0);
@.Variable x is the wrong type@>
  print_str(" is the wrong type (");print_type(type(p));print_char(')');
  help2("I was looking for a \"known\" picture variable.")@/
    ("So I'll not change anything just now.");put_get_error();
  } 
else cur_edges=value(p);
flush_node_list(t);
} 

@ @<Cases of |do_statement|...@>=
case add_to_command: do_add_to();@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void do_add_to(void)
{@+
pointer @!lhs, @!rhs; /*variable on left, path on right*/ 
int @!w; /*tentative weight*/ 
pointer @!p; /*list manipulation register*/ 
pointer @!q; /*beginning of second half of doubled path*/ 
uint8_t @!add_to_type; /*modifier of \&{addto}*/ 
get_x_next();var_flag=thing_to_add;scan_primary();
if (cur_type!=token_list) 
  @<Abandon edges command because there's no variable@>@;
else{@+lhs=cur_exp;add_to_type=cur_mod;@/
  cur_type=vacuous;get_x_next();scan_expression();
  if (add_to_type==also_code) @<Augment some edges by others@>@;
  else@<Get ready to fill a contour, and fill it@>;
  } 
} 

@ @<Abandon edges command because there's no variable@>=
{@+exp_err(@[@<|"Not a suitable variable"|@>@]);
@.Not a suitable variable@>
help4("At this point I needed to see the name of a picture variable.")@/
  ("(Or perhaps you have indeed presented me with one; I might")@/
  ("have missed it, if it wasn't followed by the proper token.)")@/
  ("So I'll not change anything just now.");
put_get_flush_error(0);
} 

@ @<Augment some edges by others@>=
{@+find_edges_var(lhs);
if (cur_edges==null) flush_cur_exp(0);
else if (cur_type!=picture_type) 
  {@+exp_err(@[@<|"Improper `addto'"|@>@]);
@.Improper `addto'@>
  help2("This expression should have specified a known picture.")@/
    ("So I'll not change anything just now.");put_get_flush_error(0);
  } 
else{@+merge_edges(cur_exp);flush_cur_exp(0);
  } 
} 

@ @<Get ready to fill a contour...@>=
{@+if (cur_type==pair_type) pair_to_path();
if (cur_type!=path_type) 
  {@+exp_err(@[@<|"Improper `addto'"|@>@]);
@.Improper `addto'@>
  help2("This expression should have been a known path.")@/
    ("So I'll not change anything just now.");
  put_get_flush_error(0);flush_token_list(lhs);
  } 
else{@+rhs=cur_exp;w=1;cur_pen=null_pen;
  while (cur_cmd==with_option) 
    if (scan_with()) 
      if (cur_type==known) w=cur_exp;
      else@<Change the tentative pen@>;
  @<Complete the contour filling operation@>;
  delete_pen_ref(cur_pen);
  } 
} 

@ We could say `|add_pen_ref(cur_pen)|; |flush_cur_exp(0)|' after changing
|cur_pen| here.  But that would have no effect, because the current expression
will not be flushed. Thus we save a bit of code (at the risk of being too
tricky).

@<Change the tentative pen@>=
{@+delete_pen_ref(cur_pen);cur_pen=cur_exp;
} 

@ @<Complete the contour filling...@>=
find_edges_var(lhs);
if (cur_edges==null) toss_knot_list(rhs);
else{@+lhs=null;cur_path_type=add_to_type;
  if (left_type(rhs)==endpoint) 
    if (cur_path_type==double_path_code) @<Double the path@>@;
    else@<Complain about non-cycle and |goto not_found|@>@;
  else if (cur_path_type==double_path_code) lhs=htap_ypoc(rhs);
  cur_wt=w;rhs=make_spec(rhs, max_offset(cur_pen), internal[tracing_specs]);
  @<Check the turning number@>;
  if (max_offset(cur_pen)==0) fill_spec(rhs);
  else fill_envelope(rhs);
  if (lhs!=null) 
    {@+rev_turns=true;
    lhs=make_spec(lhs, max_offset(cur_pen), internal[tracing_specs]);
    rev_turns=false;
    if (max_offset(cur_pen)==0) fill_spec(lhs);
    else fill_envelope(lhs);
    } 
not_found: ;} 

@ @<Double the path@>=
if (link(rhs)==rhs) @<Make a trivial one-point path cycle@>@;
else{@+p=htap_ypoc(rhs);q=link(p);@/
  right_x(path_tail)=right_x(q);right_y(path_tail)=right_y(q);
  right_type(path_tail)=right_type(q);
  link(path_tail)=link(q);free_node(q, knot_node_size);@/
  right_x(p)=right_x(rhs);right_y(p)=right_y(rhs);
  right_type(p)=right_type(rhs);
  link(p)=link(rhs);free_node(rhs, knot_node_size);@/
  rhs=p;
  } 

@ @<Make a trivial one-point path cycle@>=
{@+right_x(rhs)=x_coord(rhs);right_y(rhs)=y_coord(rhs);
left_x(rhs)=x_coord(rhs);left_y(rhs)=y_coord(rhs);
left_type(rhs)=explicit;right_type(rhs)=explicit;
} 

@ @<Complain about non-cycle...@>=
{@+print_err("Not a cycle");
@.Not a cycle@>
help2("That contour should have ended with `..cycle' or `&cycle'.")@/
  ("So I'll not change anything just now.");put_get_error();
toss_knot_list(rhs);goto not_found;
} 

@ @<Check the turning number@>=
if (turning_number <= 0) 
 if (cur_path_type!=double_path_code) if (internal[turning_check] > 0) 
  if ((turning_number < 0)&&(link(cur_pen)==null)) negate(cur_wt);
  else{@+if (turning_number==0) 
      if ((internal[turning_check] <= unity)&&(link(cur_pen)==null)) goto done;
      else print_strange(@[@<|"Strange path (turning number is zero)"|@>@]);
@.Strange path...@>
    else print_strange(@[@<|"Backwards path (turning number is negative)"|@>@]);
@.Backwards path...@>
    help3("The path doesn't have a counterclockwise orientation,")@/
      ("so I'll probably have trouble drawing it.")@/
      ("(See Chapter 27 of The METAFONTbook for more help.)");
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
    put_get_error();
    } 
done: 

@ @<Cases of |do_statement|...@>=
case ship_out_command: do_ship_out();@+break;
case display_command: do_display();@+break;
case open_window: do_open_window();@+break;
case cull_command: do_cull();@+break;

@ @<Declare action procedures for use by |do_statement|@>=
@t\4@>@<Declare the function called |tfm_check|@>@;
void do_ship_out(void)
{@+
int @!c; /*the character code*/ 
get_x_next();var_flag=semicolon;scan_expression();
if (cur_type!=token_list) 
  if (cur_type==picture_type) cur_edges=cur_exp;
  else{@+@<Abandon edges command because there's no variable@>;
    return;
    } 
else{@+find_edges_var(cur_exp);cur_type=vacuous;
  } 
if (cur_edges!=null) 
  {@+c=round_unscaled(internal[char_code])%256;
  if (c < 0) c=c+256;
  @<Store the width information for character code~|c|@>;
  if (internal[proofing] >= 0) ship_out(c);
  } 
flush_cur_exp(0);
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_display(void)
{@+
pointer @!e; /*token list for a picture variable*/ 
get_x_next();var_flag=in_window;scan_primary();
if (cur_type!=token_list) 
  @<Abandon edges command because there's no variable@>@;
else{@+e=cur_exp;cur_type=vacuous;
  get_x_next();scan_expression();
  if (cur_type!=known) goto common_ending;
  cur_exp=round_unscaled(cur_exp);
  if (cur_exp < 0) goto not_found;
  if (cur_exp > 15) goto not_found;
  if (!window_open[cur_exp]) goto not_found;
  find_edges_var(e);
  if (cur_edges!=null) disp_edges(cur_exp);
  return;
 not_found: cur_exp=cur_exp*unity;
 common_ending: exp_err(@[@<|"Bad window number"|@>@]);
@.Bad window number@>
  help1("It should be the number of an open window.");
  put_get_flush_error(0);flush_token_list(e);
  } 
} 

@ The only thing difficult about `\&{openwindow}' is that the syntax
allows the user to go astray in many ways. The following subroutine
helps keep the necessary program reasonably short and sweet.

@<Declare action procedures for use by |do_statement|@>=
bool get_pair(command_code @!c)
{@+pointer @!p; /*a pair of values that are known (we hope)*/ 
bool @!b; /*did we find such a pair?*/ 
if (cur_cmd!=c) return false;
else{@+get_x_next();scan_expression();
  if (nice_pair(cur_exp, cur_type)) 
    {@+p=value(cur_exp);
    cur_x=value(x_part_loc(p));cur_y=value(y_part_loc(p));
    b=true;
    } 
  else b=false;
  flush_cur_exp(0);return b;
  } 
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_open_window(void)
{@+
int @!k; /*the window number in question*/ 
scaled @!r0, @!c0, @!r1, @!c1; /*window coordinates*/ 
get_x_next();scan_expression();
if (cur_type!=known) goto not_found;
k=round_unscaled(cur_exp);
if (k < 0) goto not_found;
if (k > 15) goto not_found;
if (!get_pair(from_token)) goto not_found;
r0=cur_x;c0=cur_y;
if (!get_pair(to_token)) goto not_found;
r1=cur_x;c1=cur_y;
if (!get_pair(at_token)) goto not_found;
open_a_window(k, r0, c0, r1, c1, cur_x, cur_y);return;
not_found: print_err("Improper `openwindow'");
@.Improper `openwindow'@>
help2("Say `openwindow k from (r0,c0) to (r1,c1) at (x,y)',")@/
  ("where all quantities are known and k is between 0 and 15.");
put_get_error();
} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_cull(void)
{@+
pointer @!e; /*token list for a picture variable*/ 
uint8_t @!keeping; /*modifier of |cull_op|*/ 
int @!w, @!w_in, @!w_out; /*culling weights*/ 
w=1;
get_x_next();var_flag=cull_op;scan_primary();
if (cur_type!=token_list) 
  @<Abandon edges command because there's no variable@>@;
else{@+e=cur_exp;cur_type=vacuous;keeping=cur_mod;
  if (!get_pair(cull_op)) goto not_found;
  while ((cur_cmd==with_option)&&(cur_mod==known)) 
    if (scan_with()) w=cur_exp;
  @<Set up the culling weights, or |goto not_found| if the thresholds are bad@>;
  find_edges_var(e);
  if (cur_edges!=null) 
    cull_edges(floor_unscaled(cur_x+unity-1), floor_unscaled(cur_y), w_out, w_in);
  return;
 not_found: print_err("Bad culling amounts");
@.Bad culling amounts@>
  help1("Always cull by known amounts that exclude 0.");
  put_get_error();flush_token_list(e);
  } 
} 

@ @<Set up the culling weights, or |goto not_found| if the thresholds are bad@>=
if (cur_x > cur_y) goto not_found;
if (keeping==drop_code) 
  {@+if ((cur_x > 0)||(cur_y < 0)) goto not_found;
  w_out=w;w_in=0;
  } 
else{@+if ((cur_x <= 0)&&(cur_y >= 0)) goto not_found;
  w_out=0;w_in=w;
  } 

@ The \&{everyjob} command simply assigns a nonzero value to the global variable
|start_sym|.

@<Cases of |do_statement|...@>=
case every_job_command: {@+get_symbol();start_sym=cur_sym;get_x_next();
  } @+break;

@ @<Glob...@>=
halfword @!start_sym; /*a symbolic token to insert at beginning of job*/ 

@ @<Set init...@>=
start_sym=0;

@ Finally, we have only the ``message'' commands remaining.

@d message_code	0
@d err_message_code	1
@d err_help_code	2

@<Put each...@>=
primitive(@[@<|"message"|@>@], message_command, message_code);@/
@!@:message_}{\&{message} primitive@>
primitive(@[@<|"errmessage"|@>@], message_command, err_message_code);@/
@!@:err_message_}{\&{errmessage} primitive@>
primitive(@[@<|"errhelp"|@>@], message_command, err_help_code);@/
@!@:err_help_}{\&{errhelp} primitive@>

@ @<Cases of |print_cmd...@>=
case message_command: if (m < err_message_code) print_str("message");
  else if (m==err_message_code) print_str("errmessage");
  else print_str("errhelp");@+break;

@ @<Cases of |do_statement|...@>=
case message_command: do_message();@+break;

@ @<Declare action procedures for use by |do_statement|@>=
void do_message(void)
{@+uint8_t @!m; /*the type of message*/ 
m=cur_mod;get_x_next();scan_expression();
if (cur_type!=string_type) 
  {@+exp_err(@[@<|"Not a string"|@>@]);
@.Not a string@>
  help1("A message should be a known string expression.");
  put_get_error();
  } 
else switch (m) {
  case message_code: {@+print_nl("");slow_print(cur_exp);
    } @+break;
  case err_message_code: @<Print string |cur_exp| as an error message@>@;@+break;
  case err_help_code: @<Save string |cur_exp| as the |err_help|@>;
  }  /*there are no other cases*/ 
flush_cur_exp(0);
} 

@ The global variable |err_help| is zero when the user has most recently
given an empty help string, or if none has ever been given.

@<Save string |cur_exp| as the |err_help|@>=
{@+if (err_help!=0) delete_str_ref(err_help);
if (length(cur_exp)==0) err_help=0;
else{@+err_help=cur_exp;add_str_ref(err_help);
  } 
} 

@ If \&{errmessage} occurs often in |scroll_mode|, without user-defined
\&{errhelp}, we don't want to give a long help message each time. So we
give a verbose explanation only once.

@<Glob...@>=
bool @!long_help_seen; /*has the long \&{errmessage} help been used?*/ 

@ @<Set init...@>=long_help_seen=false;

@ @<Print string |cur_exp| as an error message@>=
{@+print_err("");slow_print(cur_exp);
if (err_help!=0) use_err_help=true;
else if (long_help_seen) help1("(That was another `errmessage'.)")@;
else{@+if (interaction < error_stop_mode) long_help_seen=true;
  help4("This error message was generated by an `errmessage'")@/
  ("command, so I can't give any explicit help.")@/
  ("Pretend that you're Miss Marple: Examine all clues,")@/
@^Marple, Jane@>
  ("and deduce the truth by inspired guesses.");
  } 
put_get_error();use_err_help=false;
} 

@* Font metric data.
\TeX\ gets its knowledge about fonts from font metric files, also called
\.{TFM} files; the `\.T' in `\.{TFM}' stands for \TeX,
but other programs know about them too. One of \MF's duties is to
write \.{TFM} files so that the user's fonts can readily be
applied to typesetting.
@:TFM files}{\.{TFM} files@>
@^font metric files@>

The information in a \.{TFM} file appears in a sequence of 8-bit bytes.
Since the number of bytes is always a multiple of~4, we could
also regard the file as a sequence of 32-bit words, but \MF\ uses the
byte interpretation. The format of \.{TFM} files was designed by
Lyle Ramshaw in 1980. The intent is to convey a lot of different kinds
@^Ramshaw, Lyle Harold@>
of information in a compact but useful form.

@<Glob...@>=
byte_file @!tfm_file; /*the font metric output goes here*/ 
str_number @!metric_file_name; /*full name of the font metric file*/ 

@ The first 24 bytes (6 words) of a \.{TFM} file contain twelve 16-bit
integers that give the lengths of the various subsequent portions
of the file. These twelve integers are, in order:
$$\vbox{\halign{\hfil#&$\null=\null$#\hfil\cr
|lf|&length of the entire file, in words;\cr
|lh|&length of the header data, in words;\cr
|bc|&smallest character code in the font;\cr
|ec|&largest character code in the font;\cr
|nw|&number of words in the width table;\cr
|nh|&number of words in the height table;\cr
|nd|&number of words in the depth table;\cr
|ni|&number of words in the italic correction table;\cr
|nl|&number of words in the lig/kern table;\cr
|nk|&number of words in the kern table;\cr
|ne|&number of words in the extensible character table;\cr
|np|&number of font parameter words.\cr}}$$
They are all nonnegative and less than $2^{15}$. We must have |bc-1 <= ec <= 255|,
|ne <= 256|, and
$$\hbox{|lf==6+lh+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np|.}$$
Note that a font may contain as many as 256 characters (if |bc==0| and |ec==255|),
and as few as 0 characters (if |bc==ec+1|).

Incidentally, when two or more 8-bit bytes are combined to form an integer of
16 or more bits, the most significant bytes appear first in the file.
This is called BigEndian order.
@!@^BigEndian order@>

@ The rest of the \.{TFM} file may be regarded as a sequence of ten data
arrays having the informal specification
$$\def\arr$[#1]#2${\&{array} $[#1]$ \&{of} #2}
\tabskip\centering
\halign to\displaywidth{\hfil\\{#}\tabskip=0pt&$\,:\,$\arr#\hfil
 \tabskip\centering\cr
header&|[0 dotdot lh-1]@t\\{stuff}@>|\cr
char\_info&|[bc dotdot ec]char_info_word|\cr
width&|[0 dotdot nw-1]fix_word|\cr
height&|[0 dotdot nh-1]fix_word|\cr
depth&|[0 dotdot nd-1]fix_word|\cr
italic&|[0 dotdot ni-1]fix_word|\cr
lig\_kern&|[0 dotdot nl-1]lig_kern_command|\cr
kern&|[0 dotdot nk-1]fix_word|\cr
exten&|[0 dotdot ne-1]extensible_recipe|\cr
param&|[1 dotdot np]fix_word|\cr}$$
The most important data type used here is a |@!fix_word|, which is
a 32-bit representation of a binary fraction. A |fix_word| is a signed
quantity, with the two's complement of the entire word used to represent
negation. Of the 32 bits in a |fix_word|, exactly 12 are to the left of the
binary point; thus, the largest |fix_word| value is $2048-2^{-20}$, and
the smallest is $-2048$. We will see below, however, that all but two of
the |fix_word| values must lie between $-16$ and $+16$.

@ The first data array is a block of header information, which contains
general facts about the font. The header must contain at least two words,
|header[0]| and |header[1]|, whose meaning is explained below.  Additional
header information of use to other software routines might also be
included, and \MF\ will generate it if the \.{headerbyte} command occurs.
For example, 16 more words of header information are in use at the Xerox
Palo Alto Research Center; the first ten specify the character coding
scheme used (e.g., `\.{XEROX TEXT}' or `\.{TEX MATHSY}'), the next five
give the font family name (e.g., `\.{HELVETICA}' or `\.{CMSY}'), and the
last gives the ``face byte.''

\yskip\hang|header[0]| is a 32-bit check sum that \MF\ will copy into
the \.{GF} output file. This helps ensure consistency between files,
since \TeX\ records the check sums from the \.{TFM}'s it reads, and these
should match the check sums on actual fonts that are used.  The actual
relation between this check sum and the rest of the \.{TFM} file is not
important; the check sum is simply an identification number with the
property that incompatible fonts almost always have distinct check sums.
@^check sum@>

\yskip\hang|header[1]| is a |fix_word| containing the design size of the
font, in units of \TeX\ points. This number must be at least 1.0; it is
fairly arbitrary, but usually the design size is 10.0 for a ``10 point''
font, i.e., a font that was designed to look best at a 10-point size,
whatever that really means. When a \TeX\ user asks for a font `\.{at}
$\delta$ \.{pt}', the effect is to override the design size and replace it
by $\delta$, and to multiply the $x$ and~$y$ coordinates of the points in
the font image by a factor of $\delta$ divided by the design size.  {\sl
All other dimensions in the\/ \.{TFM} file are |fix_word|\kern-1pt\
numbers in design-size units.} Thus, for example, the value of |param[6]|,
which defines the \.{em} unit, is often the |fix_word| value $2^{20}=1.0$,
since many fonts have a design size equal to one em.  The other dimensions
must be less than 16 design-size units in absolute value; thus,
|header[1]| and |param[1]| are the only |fix_word| entries in the whole
\.{TFM} file whose first byte might be something besides 0 or 255.
@^design size@>

@ Next comes the |char_info| array, which contains one |@!char_info_word|
per character. Each word in this part of the file contains six fields
packed into four bytes as follows.

\yskip\hang first byte: |@!width_index| (8 bits)\par
\hang second byte: |@!height_index| (4 bits) times 16, plus |@!depth_index|
  (4~bits)\par
\hang third byte: |@!italic_index| (6 bits) times 4, plus |@!tag|
  (2~bits)\par
\hang fourth byte: |@!rem| (8 bits)\par
\yskip\noindent
The actual width of a character is \\{width}|[width_index]|, in design-size
units; this is a device for compressing information, since many characters
have the same width. Since it is quite common for many characters
to have the same height, depth, or italic correction, the \.{TFM} format
imposes a limit of 16 different heights, 16 different depths, and
64 different italic corrections.

Incidentally, the relation $\\{width}[0]=\\{height}[0]=\\{depth}[0]=
\\{italic}[0]=0$ should always hold, so that an index of zero implies a
value of zero.  The |width_index| should never be zero unless the
character does not exist in the font, since a character is valid if and
only if it lies between |bc| and |ec| and has a nonzero |width_index|.

@ The |tag| field in a |char_info_word| has four values that explain how to
interpret the |rem| field.

\def\hangg#1 {\hang\hbox{#1 }}
\yskip\hangg|tag==0| (|no_tag|) means that |rem| is unused.\par
\hangg|tag==1| (|lig_tag|) means that this character has a ligature/kerning
program starting at location |rem| in the |lig_kern| array.\par
\hangg|tag==2| (|list_tag|) means that this character is part of a chain of
characters of ascending sizes, and not the largest in the chain.  The
|rem| field gives the character code of the next larger character.\par
\hangg|tag==3| (|ext_tag|) means that this character code represents an
extensible character, i.e., a character that is built up of smaller pieces
so that it can be made arbitrarily large. The pieces are specified in
|@!exten[rem]|.\par
\yskip\noindent
Characters with |tag==2| and |tag==3| are treated as characters with |tag==0|
unless they are used in special circumstances in math formulas. For example,
\TeX's \.{\\sum} operation looks for a |list_tag|, and the \.{\\left}
operation looks for both |list_tag| and |ext_tag|.

@d no_tag	0 /*vanilla character*/ 
@d lig_tag	1 /*character has a ligature/kerning program*/ 
@d list_tag	2 /*character has a successor in a charlist*/ 
@d ext_tag	3 /*character is extensible*/ 

@ The |lig_kern| array contains instructions in a simple programming language
that explains what to do for special letter pairs. Each word in this array is a
|@!lig_kern_command| of four bytes.

\yskip\hang first byte: |skip_byte|, indicates that this is the final program
  step if the byte is 128 or more, otherwise the next step is obtained by
  skipping this number of intervening steps.\par
\hang second byte: |next_char|, ``if |next_char| follows the current character,
  then perform the operation and stop, otherwise continue.''\par
\hang third byte: |op_byte|, indicates a ligature step if less than~128,
  a kern step otherwise.\par
\hang fourth byte: |rem|.\par
\yskip\noindent
In a kern step, an
additional space equal to |kern[256*(op_byte-128)+rem]| is inserted
between the current character and |next_char|. This amount is
often negative, so that the characters are brought closer together
by kerning; but it might be positive.

There are eight kinds of ligature steps, having |op_byte| codes $4a+2b+c$ where
$0\le a\le b+c$ and $0\le b,c\le1$. The character whose code is
|rem| is inserted between the current character and |next_char|;
then the current character is deleted if $b=0$, and |next_char| is
deleted if $c=0$; then we pass over $a$~characters to reach the next
current character (which may have a ligature/kerning program of its own).

If the very first instruction of the |lig_kern| array has |skip_byte==255|,
the |next_char| byte is the so-called right boundary character of this font;
the value of |next_char| need not lie between |bc| and~|ec|.
If the very last instruction of the |lig_kern| array has |skip_byte==255|,
there is a special ligature/kerning program for a left boundary character,
beginning at location |256*op_byte+rem|.
The interpretation is that \TeX\ puts implicit boundary characters
before and after each consecutive string of characters from the same font.
These implicit characters do not appear in the output, but they can affect
ligatures and kerning.

If the very first instruction of a character's |lig_kern| program has
|skip_byte > 128|, the program actually begins in location
|256*op_byte+rem|. This feature allows access to large |lig_kern|
arrays, because the first instruction must otherwise
appear in a location | <= 255|.

Any instruction with |skip_byte > 128| in the |lig_kern| array must satisfy
the condition
$$\hbox{|256*op_byte+rem < nl|.}$$
If such an instruction is encountered during
normal program execution, it denotes an unconditional halt; no ligature
command is performed.

@d stop_flag	(128+min_quarterword)
   /*value indicating `\.{STOP}' in a lig/kern program*/ 
@d kern_flag	(128+min_quarterword) /*op code for a kern step*/ 
@d skip_byte(X)	lig_kern[X].b0
@d next_char(X)	lig_kern[X].b1
@d op_byte(X)	lig_kern[X].b2
@d rem_byte(X)	lig_kern[X].b3

@ Extensible characters are specified by an |@!extensible_recipe|, which
consists of four bytes called |@!top|, |@!mid|, |@!bot|, and |@!rep| (in this
order). These bytes are the character codes of individual pieces used to
build up a large symbol.  If |top|, |mid|, or |bot| are zero, they are not
present in the built-up result. For example, an extensible vertical line is
like an extensible bracket, except that the top and bottom pieces are missing.

Let $T$, $M$, $B$, and $R$ denote the respective pieces, or an empty box
if the piece isn't present. Then the extensible characters have the form
$TR^kMR^kB$ from top to bottom, for some |k >= 0|, unless $M$ is absent;
in the latter case we can have $TR^kB$ for both even and odd values of~|k|.
The width of the extensible character is the width of $R$; and the
height-plus-depth is the sum of the individual height-plus-depths of the
components used, since the pieces are butted together in a vertical list.

@d ext_top(X)	exten[X].b0 /*|top| piece in a recipe*/ 
@d ext_mid(X)	exten[X].b1 /*|mid| piece in a recipe*/ 
@d ext_bot(X)	exten[X].b2 /*|bot| piece in a recipe*/ 
@d ext_rep(X)	exten[X].b3 /*|rep| piece in a recipe*/ 

@ The final portion of a \.{TFM} file is the |param| array, which is another
sequence of |fix_word| values.

\yskip\hang|param[1]==slant| is the amount of italic slant, which is used
to help position accents. For example, |slant==.25| means that when you go
up one unit, you also go .25 units to the right. The |slant| is a pure
number; it is the only |fix_word| other than the design size itself that is
not scaled by the design size.
@^design size@>

\hang|param[2]==space| is the normal spacing between words in text.
Note that character 040 in the font need not have anything to do with
blank spaces.

\hang|param[3]==space_stretch| is the amount of glue stretching between words.

\hang|param[4]==space_shrink| is the amount of glue shrinking between words.

\hang|param[5]==x_height| is the size of one ex in the font; it is also
the height of letters for which accents don't have to be raised or lowered.

\hang|param[6]==quad| is the size of one em in the font.

\hang|param[7]==extra_space| is the amount added to |param[2]| at the
ends of sentences.

\yskip\noindent
If fewer than seven parameters are present, \TeX\ sets the missing parameters
to zero.

@d slant_code	1
@d space_code	2
@d space_stretch_code	3
@d space_shrink_code	4
@d x_height_code	5
@d quad_code	6
@d extra_space_code	7

@ So that is what \.{TFM} files hold. One of \MF's duties is to output such
information, and it does this all at once at the end of a job.
In order to prepare for such frenetic activity, it squirrels away the
necessary facts in various arrays as information becomes available.

Character dimensions (\&{charwd}, \&{charht}, \&{chardp}, and \&{charic})
are stored respectively in |tfm_width|, |tfm_height|, |tfm_depth|, and
|tfm_ital_corr|. Other information about a character (e.g., about
its ligatures or successors) is accessible via the |char_tag| and
|char_remainder| arrays. Other information about the font as a whole
is kept in additional arrays called |header_byte|, |lig_kern|,
|kern|, |exten|, and |param|.

@d undefined_label	lig_table_size /*an undefined local label*/ 

@<Glob...@>=
eight_bits @!bc, @!ec; /*smallest and largest character codes shipped out*/ 
scaled @!tfm_width[256]; /*\&{charwd} values*/ 
scaled @!tfm_height[256]; /*\&{charht} values*/ 
scaled @!tfm_depth[256]; /*\&{chardp} values*/ 
scaled @!tfm_ital_corr[256]; /*\&{charic} values*/ 
bool @!char_exists[256]; /*has this code been shipped out?*/ 
uint8_t @!char_tag[256]; /*|rem| category*/ 
uint16_t @!char_remainder[256]; /*the |rem| byte*/ 
int16_t @!header_byte0[header_size], *const @!header_byte = @!header_byte0-1;
   /*bytes of the \.{TFM} header, or $-1$ if unset*/ 
four_quarters @!lig_kern[lig_table_size+1]; /*the ligature/kern table*/ 
uint16_t @!nl; /*the number of ligature/kern steps so far*/ 
scaled @!kern[max_kerns+1]; /*distinct kerning amounts*/ 
uint16_t @!nk; /*the number of distinct kerns so far*/ 
four_quarters @!exten[256]; /*extensible character recipes*/ 
uint16_t @!ne; /*the number of extensible characters so far*/ 
scaled @!param0[max_font_dimen], *const @!param = @!param0-1; /*\&{fontinfo} parameters*/ 
uint8_t @!np; /*the largest \&{fontinfo} parameter specified so far*/ 
uint16_t @!nw, @!nh, @!nd, @!ni; /*sizes of \.{TFM} subtables*/ 
uint16_t @!skip_table[256]; /*local label status*/ 
bool @!lk_started; /*has there been a lig/kern step in this command yet?*/ 
int @!bchar; /*right boundary character*/ 
uint16_t @!bch_label; /*left boundary starting location*/ 
uint16_t @!ll, @!lll; /*registers used for lig/kern processing*/ 
int16_t @!label_loc[257]; /*lig/kern starting addresses*/ 
eight_bits @!label_char0[256], *const @!label_char = @!label_char0-1; /*characters for |label_loc|*/ 
uint16_t @!label_ptr; /*highest position occupied in |label_loc|*/ 

@ @<Set init...@>=
for (k=0; k<=255; k++) 
  {@+tfm_width[k]=0;tfm_height[k]=0;tfm_depth[k]=0;tfm_ital_corr[k]=0;
  char_exists[k]=false;char_tag[k]=no_tag;char_remainder[k]=0;
  skip_table[k]=undefined_label;
  } 
for (k=1; k<=header_size; k++) header_byte[k]=-1;
bc=255;ec=0;nl=0;nk=0;ne=0;np=0;@/
internal[boundary_char]=-unity;
bch_label=undefined_label;@/
label_loc[0]=-1;label_ptr=0;

@ @<Declare the function called |tfm_check|@>=
scaled tfm_check(small_number @!m)
{@+if (abs(internal[m]) >= fraction_half) 
  {@+print_err("Enormous ");print(int_name[m]);
@.Enormous charwd...@>
@.Enormous chardp...@>
@.Enormous charht...@>
@.Enormous charic...@>
@.Enormous designsize...@>
  print_str(" has been reduced");
  help1("Font metric dimensions must be less than 2048pt.");
  put_get_error();
  if (internal[m] > 0) return fraction_half-1;
  else return 1-fraction_half;
  } 
else return internal[m];
} 

@ @<Store the width information for character code~|c|@>=
if (c < bc) bc=c;
if (c > ec) ec=c;
char_exists[c]=true;
gf_dx[c]=internal[char_dx];gf_dy[c]=internal[char_dy];
tfm_width[c]=tfm_check(char_wd);
tfm_height[c]=tfm_check(char_ht);
tfm_depth[c]=tfm_check(char_dp);
tfm_ital_corr[c]=tfm_check(char_ic)

@ Now let's consider \MF's special \.{TFM}-oriented commands.

@<Cases of |do_statement|...@>=
case tfm_command: do_tfm_command();@+break;

@ @d char_list_code	0
@d lig_table_code	1
@d extensible_code	2
@d header_byte_code	3
@d font_dimen_code	4

@<Put each...@>=
primitive(@[@<|"charlist"|@>@], tfm_command, char_list_code);@/
@!@:char_list_}{\&{charlist} primitive@>
primitive(@[@<|"ligtable"|@>@], tfm_command, lig_table_code);@/
@!@:lig_table_}{\&{ligtable} primitive@>
primitive(@[@<|"extensible"|@>@], tfm_command, extensible_code);@/
@!@:extensible_}{\&{extensible} primitive@>
primitive(@[@<|"headerbyte"|@>@], tfm_command, header_byte_code);@/
@!@:header_byte_}{\&{headerbyte} primitive@>
primitive(@[@<|"fontdimen"|@>@], tfm_command, font_dimen_code);@/
@!@:font_dimen_}{\&{fontdimen} primitive@>

@ @<Cases of |print_cmd...@>=
case tfm_command: switch (m) {
  case char_list_code: print_str("charlist");@+break;
  case lig_table_code: print_str("ligtable");@+break;
  case extensible_code: print_str("extensible");@+break;
  case header_byte_code: print_str("headerbyte");@+break;
  default:print_str("fontdimen");
  } @+break;

@ @<Declare action procedures for use by |do_statement|@>=
eight_bits get_code(void) /*scans a character code value*/ 
{@+
int @!c; /*the code value found*/ 
get_x_next();scan_expression();
if (cur_type==known) 
  {@+c=round_unscaled(cur_exp);
  if (c >= 0) if (c < 256) goto found;
  } 
else if (cur_type==string_type) if (length(cur_exp)==1) 
  {@+c=so(str_pool[str_start[cur_exp]]);goto found;
  } 
exp_err(@[@<|"Invalid code has been replaced by 0"|@>@]);
@.Invalid code...@>
help2("I was looking for a number between 0 and 255, or for a")@/
  ("string of length 1. Didn't find it; will use 0 instead.");
put_get_flush_error(0);c=0;
found: return c;
} 

@ @<Declare action procedures for use by |do_statement|@>=
void set_tag(halfword @!c, small_number @!t, halfword @!r)
{@+if (char_tag[c]==no_tag) 
  {@+char_tag[c]=t;char_remainder[c]=r;
  if (t==lig_tag) 
    {@+incr(label_ptr);label_loc[label_ptr]=r;label_char[label_ptr]=c;
    } 
  } 
else@<Complain about a character tag conflict@>;
} 

@ @<Complain about a character tag conflict@>=
{@+print_err("Character ");
if ((c > ' ')&&(c < 127)) print(c);
else if (c==256) print_str("||");
else{@+print_str("code ");print_int(c);
  } 
print_str(" is already ");
@.Character c is already...@>
switch (char_tag[c]) {
case lig_tag: print_str("in a ligtable");@+break;
case list_tag: print_str("in a charlist");@+break;
case ext_tag: print_str("extensible");
}  /*there are no other cases*/ 
help2("It's not legal to label a character more than once.")@/
  ("So I'll not change anything just now.");
put_get_error();} 

@ @<Declare action procedures for use by |do_statement|@>=
void do_tfm_command(void)
{@+
uint16_t @!c, @!cc; /*character codes*/ 
uint16_t @!k; /*index into the |kern| array*/ 
int @!j; /*index into |header_byte| or |param|*/ 
switch (cur_mod) {
case char_list_code: {@+c=get_code();
      /*we will store a list of character successors*/ 
  while (cur_cmd==colon) 
    {@+cc=get_code();set_tag(c, list_tag, cc);c=cc;
    } 
  } @+break;
case lig_table_code: @<Store a list of ligature/kern steps@>@;@+break;
case extensible_code: @<Define an extensible recipe@>@;@+break;
case header_byte_code: case font_dimen_code: {@+c=cur_mod;get_x_next();
  scan_expression();
  if ((cur_type!=known)||(cur_exp < half_unit)) 
    {@+exp_err(@[@<|"Improper location"|@>@]);
@.Improper location@>
    help2("I was looking for a known, positive number.")@/
      ("For safety's sake I'll ignore the present command.");
    put_get_error();
    } 
  else{@+j=round_unscaled(cur_exp);
    if (cur_cmd!=colon) 
      {@+missing_err(':');
@.Missing `:'@>
      help1("A colon should follow a headerbyte or fontinfo location.");
      back_error();
      } 
    if (c==header_byte_code) @<Store a list of header bytes@>;
    else@<Store a list of font dimensions@>;
    } 
  } 
}  /*there are no other cases*/ 
} 

@ @<Store a list of ligature/kern steps@>=
{@+lk_started=false;
resume: get_x_next();
if ((cur_cmd==skip_to)&&lk_started) 
 @<Process a |skip_to| command and |goto done|@>;
if (cur_cmd==bchar_label) 
  {@+c=256;cur_cmd=colon;@+} 
else{@+back_input();c=get_code();@+} 
if ((cur_cmd==colon)||(cur_cmd==double_colon)) 
  @<Record a label in a lig/kern subprogram and |goto continue|@>;
if (cur_cmd==lig_kern_token) @<Compile a ligature/kern command@>@;
else{@+print_err("Illegal ligtable step");
@.Illegal ligtable step@>
  help1("I was looking for `=:' or `kern' here.");
  back_error();next_char(nl)=qi(0);op_byte(nl)=qi(0);rem_byte(nl)=qi(0);@/
  skip_byte(nl)=stop_flag+1; /*this specifies an unconditional stop*/ 
  } 
if (nl==lig_table_size) overflow("ligtable size", lig_table_size);
@:METAFONT capacity exceeded ligtable size}{\quad ligtable size@>
incr(nl);
if (cur_cmd==comma) goto resume;
if (skip_byte(nl-1) < stop_flag) skip_byte(nl-1)=stop_flag;
done: ;} 

@ @<Put each...@>=
primitive(@[@<|"=:"|@>@], lig_kern_token, 0);
@!@:=:_}{\.{=:} primitive@>
primitive(@[@<|"=:|"|@>@], lig_kern_token, 1);
@!@:=:/_}{\.{=:\char'174} primitive@>
primitive(@[@<|"=:|>"|@>@], lig_kern_token, 5);
@!@:=:/>_}{\.{=:\char'174>} primitive@>
primitive(@[@<|"|=:"|@>@], lig_kern_token, 2);
@!@:=:/_}{\.{\char'174=:} primitive@>
primitive(@[@<|"|=:>"|@>@], lig_kern_token, 6);
@!@:=:/>_}{\.{\char'174=:>} primitive@>
primitive(@[@<|"|=:|"|@>@], lig_kern_token, 3);
@!@:=:/_}{\.{\char'174=:\char'174} primitive@>
primitive(@[@<|"|=:|>"|@>@], lig_kern_token, 7);
@!@:=:/>_}{\.{\char'174=:\char'174>} primitive@>
primitive(@[@<|"|=:|>>"|@>@], lig_kern_token, 11);
@!@:=:/>_}{\.{\char'174=:\char'174>>} primitive@>
primitive(@[@<|"kern"|@>@], lig_kern_token, 128);
@!@:kern_}{\&{kern} primitive@>

@ @<Cases of |print_cmd...@>=
case lig_kern_token: switch (m) {
case 0: print_str("=:");@+break;
case 1: print_str("=:|");@+break;
case 2: print_str("|=:");@+break;
case 3: print_str("|=:|");@+break;
case 5: print_str("=:|>");@+break;
case 6: print_str("|=:>");@+break;
case 7: print_str("|=:|>");@+break;
case 11: print_str("|=:|>>");@+break;
default:print_str("kern");
} @+break;

@ Local labels are implemented by maintaining the |skip_table| array,
where |skip_table[c]| is either |undefined_label| or the address of the
most recent lig/kern instruction that skips to local label~|c|. In the
latter case, the |skip_byte| in that instruction will (temporarily)
be zero if there were no prior skips to this label, or it will be the
distance to the prior skip.

We may need to cancel skips that span more than 127 lig/kern steps.

@d cancel_skips(X)	ll=X;
  @/do@+{lll=qo(skip_byte(ll));skip_byte(ll)=stop_flag;ll=ll-lll;
  }@+ while (!(lll==0))
@d skip_error(X)	{@+print_err("Too far to skip");
@.Too far to skip@>
  help1("At most 127 lig/kern steps can separate skipto1 from 1::.");
  error();cancel_skips(X);
  } 

@<Process a |skip_to| command and |goto done|@>=
{@+c=get_code();
if (nl-skip_table[c] > 128) 
  {@+skip_error(skip_table[c]);skip_table[c]=undefined_label;
  } 
if (skip_table[c]==undefined_label) skip_byte(nl-1)=qi(0);
else skip_byte(nl-1)=qi(nl-skip_table[c]-1);
skip_table[c]=nl-1;goto done;
} 

@ @<Record a label in a lig/kern subprogram and |goto continue|@>=
{@+if (cur_cmd==colon) 
  if (c==256) bch_label=nl;
  else set_tag(c, lig_tag, nl);
else if (skip_table[c] < undefined_label) 
  {@+ll=skip_table[c];skip_table[c]=undefined_label;
  @/do@+{lll=qo(skip_byte(ll));
  if (nl-ll > 128) 
    {@+skip_error(ll);goto resume;
    } 
  skip_byte(ll)=qi(nl-ll-1);ll=ll-lll;
  }@+ while (!(lll==0));
  } 
goto resume;
} 

@ @<Compile a ligature/kern...@>=
{@+next_char(nl)=qi(c);skip_byte(nl)=qi(0);
if (cur_mod < 128)  /*ligature op*/ 
  {@+op_byte(nl)=qi(cur_mod);rem_byte(nl)=qi(get_code());
  } 
else{@+get_x_next();scan_expression();
  if (cur_type!=known) 
    {@+exp_err(@[@<|"Improper kern"|@>@]);
@.Improper kern@>
    help2("The amount of kern should be a known numeric value.")@/
      ("I'm zeroing this one. Proceed, with fingers crossed.");
    put_get_flush_error(0);
    } 
  kern[nk]=cur_exp;
  k=0;@+while (kern[k]!=cur_exp) incr(k);
  if (k==nk) 
    {@+if (nk==max_kerns) overflow("kern", max_kerns);
@:METAFONT capacity exceeded kern}{\quad kern@>
    incr(nk);
    } 
  op_byte(nl)=kern_flag+(k/256);
  rem_byte(nl)=qi((k%256));
  } 
lk_started=true;
} 

@ @d missing_extensible_punctuation(X)	
  {@+missing_err(X);
@.Missing `\char`\#'@>
  help1("I'm processing `extensible c: t,m,b,r'.");back_error();
  } 

@<Define an extensible recipe@>=
{@+if (ne==256) overflow("extensible", 256);
@:METAFONT capacity exceeded extensible}{\quad extensible@>
c=get_code();set_tag(c, ext_tag, ne);
if (cur_cmd!=colon) missing_extensible_punctuation(':');
ext_top(ne)=qi(get_code());
if (cur_cmd!=comma) missing_extensible_punctuation(',');
ext_mid(ne)=qi(get_code());
if (cur_cmd!=comma) missing_extensible_punctuation(',');
ext_bot(ne)=qi(get_code());
if (cur_cmd!=comma) missing_extensible_punctuation(',');
ext_rep(ne)=qi(get_code());
incr(ne);
} 

@ @<Store a list of header bytes@>=
@/do@+{if (j > header_size) overflow("headerbyte", header_size);
@:METAFONT capacity exceeded headerbyte}{\quad headerbyte@>
header_byte[j]=get_code();incr(j);
}@+ while (!(cur_cmd!=comma))

@ @<Store a list of font dimensions@>=
@/do@+{if (j > max_font_dimen) overflow("fontdimen", max_font_dimen);
@:METAFONT capacity exceeded fontdimen}{\quad fontdimen@>
while (j > np) 
  {@+incr(np);param[np]=0;
  } 
get_x_next();scan_expression();
if (cur_type!=known) 
  {@+exp_err(@[@<|"Improper font parameter"|@>@]);
@.Improper font parameter@>
  help1("I'm zeroing this one. Proceed, with fingers crossed.");
  put_get_flush_error(0);
  } 
param[j]=cur_exp;incr(j);
}@+ while (!(cur_cmd!=comma))

@ OK: We've stored all the data that is needed for the \.{TFM} file.
All that remains is to output it in the correct format.

An interesting problem needs to be solved in this connection, because
the \.{TFM} format allows at most 256~widths, 16~heights, 16~depths,
and 64~italic corrections. If the data has more distinct values than
this, we want to meet the necessary restrictions by perturbing the
given values as little as possible.

\MF\ solves this problem in two steps. First the values of a given
kind (widths, heights, depths, or italic corrections) are sorted;
then the list of sorted values is perturbed, if necessary.

The sorting operation is facilitated by having a special node of
essentially infinite |value| at the end of the current list.

@<Initialize table entries...@>=
value(inf_val)=fraction_four;

@ Straight linear insertion is good enough for sorting, since the lists
are usually not terribly long. As we work on the data, the current list
will start at |link(temp_head)| and end at |inf_val|; the nodes in this
list will be in increasing order of their |value| fields.

Given such a list, the |sort_in| function takes a value and returns a pointer
to where that value can be found in the list. The value is inserted in
the proper place, if necessary.

At the time we need to do these operations, most of \MF's work has been
completed, so we will have plenty of memory to play with. The value nodes
that are allocated for sorting will never be returned to free storage.

@d clear_the_list	link(temp_head)=inf_val

@p pointer sort_in(scaled @!v)
{@+
pointer @!p, @!q, @!r; /*list manipulation registers*/ 
p=temp_head;
loop@+{@+q=link(p);
  if (v <= value(q)) goto found;
  p=q;
  } 
found: if (v < value(q)) 
  {@+r=get_node(value_node_size);value(r)=v;link(r)=q;link(p)=r;
  } 
return link(p);
} 

@ Now we come to the interesting part, where we reduce the list if necessary
until it has the required size. The |min_cover| routine is basic to this
process; it computes the minimum number~|m| such that the values of the
current sorted list can be covered by |m|~intervals of width~|d|. It
also sets the global value |perturbation| to the smallest value $d'>d$
such that the covering found by this algorithm would be different.

In particular, |min_cover(0)| returns the number of distinct values in the
current list and sets |perturbation| to the minimum distance between
adjacent values.

@p int min_cover(scaled @!d)
{@+pointer @!p; /*runs through the current list*/ 
scaled @!l; /*the least element covered by the current interval*/ 
int @!m; /*lower bound on the size of the minimum cover*/ 
m=0;p=link(temp_head);perturbation=el_gordo;
while (p!=inf_val) 
  {@+incr(m);l=value(p);
  @/do@+{p=link(p);
  }@+ while (!(value(p) > l+d));
  if (value(p)-l < perturbation) perturbation=value(p)-l;
  } 
return m;
} 

@ @<Glob...@>=
scaled @!perturbation; /*quantity related to \.{TFM} rounding*/ 
int @!excess; /*the list is this much too long*/ 

@ The smallest |d| such that a given list can be covered with |m| intervals
is determined by the |threshold| routine, which is sort of an inverse
to |min_cover|. The idea is to increase the interval size rapidly until
finding the range, then to go sequentially until the exact borderline has
been discovered.

@p scaled threshold(int @!m)
{@+scaled @!d; /*lower bound on the smallest interval size*/ 
excess=min_cover(0)-m;
if (excess <= 0) return 0;
else{@+@/do@+{d=perturbation;
  }@+ while (!(min_cover(d+d) <= m));
  while (min_cover(d) > m) d=perturbation;
  return d;
  } 
} 

@ The |skimp| procedure reduces the current list to at most |m| entries,
by changing values if necessary. It also sets |info(p)=k| if |value(p)|
is the |k|th distinct value on the resulting list, and it sets
|perturbation| to the maximum amount by which a |value| field has
been changed. The size of the resulting list is returned as the
value of |skimp|.

@p int skimp(int @!m)
{@+scaled @!d; /*the size of intervals being coalesced*/ 
pointer @!p, @!q, @!r; /*list manipulation registers*/ 
scaled @!l; /*the least value in the current interval*/ 
scaled @!v; /*a compromise value*/ 
d=threshold(m);perturbation=0;
q=temp_head;m=0;p=link(temp_head);
while (p!=inf_val) 
  {@+incr(m);l=value(p);info(p)=m;
  if (value(link(p)) <= l+d) 
    @<Replace an interval of values by its midpoint@>;
  q=p;p=link(p);
  } 
return m;
} 

@ @<Replace an interval...@>=
{@+@/do@+{p=link(p);info(p)=m;
decr(excess);@+if (excess==0) d=0;
}@+ while (!(value(link(p)) > l+d));
v=l+half(value(p)-l);
if (value(p)-v > perturbation) perturbation=value(p)-v;
r=q;
@/do@+{r=link(r);value(r)=v;
}@+ while (!(r==p));
link(q)=p; /*remove duplicate values from the current list*/ 
} 

@ A warning message is issued whenever something is perturbed by
more than 1/16\thinspace pt.

@p void tfm_warning(small_number @!m)
{@+print_nl("(some ");print(int_name[m]);
@.some charwds...@>
@.some chardps...@>
@.some charhts...@>
@.some charics...@>
print_str(" values had to be adjusted by as much as ");
print_scaled(perturbation);print_str("pt)");
} 

@ Here's an example of how we use these routines.
The width data needs to be perturbed only if there are 256 distinct
widths, but \MF\ must check for this case even though it is
highly unusual.

An integer variable |k| will be defined when we use this code.
The |dimen_head| array will contain pointers to the sorted
lists of dimensions.

@<Massage the \.{TFM} widths@>=
clear_the_list;
for (k=bc; k<=ec; k++) if (char_exists[k]) 
  tfm_width[k]=sort_in(tfm_width[k]);
nw=skimp(255)+1;dimen_head[1]=link(temp_head);
if (perturbation >= 010000) tfm_warning(char_wd)

@ @<Glob...@>=
pointer @!dimen_head0[4], *const @!dimen_head = @!dimen_head0-1; /*lists of \.{TFM} dimensions*/ 

@ Heights, depths, and italic corrections are different from widths
not only because their list length is more severely restricted, but
also because zero values do not need to be put into the lists.

@<Massage the \.{TFM} heights, depths, and italic corrections@>=
clear_the_list;
for (k=bc; k<=ec; k++) if (char_exists[k]) 
  if (tfm_height[k]==0) tfm_height[k]=zero_val;
  else tfm_height[k]=sort_in(tfm_height[k]);
nh=skimp(15)+1;dimen_head[2]=link(temp_head);
if (perturbation >= 010000) tfm_warning(char_ht);
clear_the_list;
for (k=bc; k<=ec; k++) if (char_exists[k]) 
  if (tfm_depth[k]==0) tfm_depth[k]=zero_val;
  else tfm_depth[k]=sort_in(tfm_depth[k]);
nd=skimp(15)+1;dimen_head[3]=link(temp_head);
if (perturbation >= 010000) tfm_warning(char_dp);
clear_the_list;
for (k=bc; k<=ec; k++) if (char_exists[k]) 
  if (tfm_ital_corr[k]==0) tfm_ital_corr[k]=zero_val;
  else tfm_ital_corr[k]=sort_in(tfm_ital_corr[k]);
ni=skimp(63)+1;dimen_head[4]=link(temp_head);
if (perturbation >= 010000) tfm_warning(char_ic)

@ @<Initialize table entries...@>=
value(zero_val)=0;info(zero_val)=0;

@ Bytes 5--8 of the header are set to the design size, unless the user has
some crazy reason for specifying them differently.
@^design size@>

Error messages are not allowed at the time this procedure is called,
so a warning is printed instead.

The value of |max_tfm_dimen| is calculated so that
$$\hbox{|make_scaled(16*max_tfm_dimen, internal[design_size])|}
 < \\{three\_bytes}.$$

@d three_bytes	0100000000 /*$2^{24}$*/ 

@p void fix_design_size(void)
{@+scaled @!d; /*the design size*/ 
d=internal[design_size];
if ((d < unity)||(d >= fraction_half)) 
  {@+if (d!=0) 
    print_nl("(illegal design size has been changed to 128pt)");
@.illegal design size...@>
  d=040000000;internal[design_size]=d;
  } 
if (header_byte[5] < 0) if (header_byte[6] < 0) 
  if (header_byte[7] < 0) if (header_byte[8] < 0) 
  {@+header_byte[5]=d/04000000;
  header_byte[6]=(d/4096)%256;
  header_byte[7]=(d/16)%256;
  header_byte[8]=(d%16)*16;
  } 
max_tfm_dimen=16*internal[design_size]-1-internal[design_size]/010000000;
if (max_tfm_dimen >= fraction_half) max_tfm_dimen=fraction_half-1;
} 

@ The |dimen_out| procedure computes a |fix_word| relative to the
design size. If the data was out of range, it is corrected and the
global variable |tfm_changed| is increased by~one.

@p int dimen_out(scaled @!x)
{@+if (abs(x) > max_tfm_dimen) 
  {@+incr(tfm_changed);
  if (x > 0) x=max_tfm_dimen;@+else x=-max_tfm_dimen;
  } 
x=make_scaled(x*16, internal[design_size]);
return x;
} 

@ @<Glob...@>=
scaled @!max_tfm_dimen; /*bound on widths, heights, kerns, etc.*/ 
int @!tfm_changed; /*the number of data entries that were out of bounds*/ 

@ If the user has not specified any of the first four header bytes,
the |fix_check_sum| procedure replaces them by a ``check sum'' computed
from the |tfm_width| data relative to the design size.
@^check sum@>

@p void fix_check_sum(void)
{@+
int @!k; /*runs through character codes*/ 
eight_bits @!b1, @!b2, @!b3, @!b4; /*bytes of the check sum*/ 
int @!x; /*hash value used in check sum computation*/ 
if (header_byte[1] < 0) if (header_byte[2] < 0) 
  if (header_byte[3] < 0) if (header_byte[4] < 0) 
  {@+@<Compute a check sum in |(b1,b2,b3,b4)|@>;
  header_byte[1]=b1;header_byte[2]=b2;
  header_byte[3]=b3;header_byte[4]=b4;return;
  } 
for (k=1; k<=4; k++) if (header_byte[k] < 0) header_byte[k]=0;
} 

@ @<Compute a check sum in |(b1,b2,b3,b4)|@>=
b1=bc;b2=ec;b3=bc;b4=ec;tfm_changed=0;
for (k=bc; k<=ec; k++) if (char_exists[k]) 
  {@+x=dimen_out(value(tfm_width[k]))+(k+4)*020000000; /*this is positive*/ 
  b1=(b1+b1+x)%255;
  b2=(b2+b2+x)%253;
  b3=(b3+b3+x)%251;
  b4=(b4+b4+x)%247;
  } 

@ Finally we're ready to actually write the \.{TFM} information.
Here are some utility routines for this purpose.

@d tfm_out(X)	pascal_write(tfm_file, "%c", X) /*output one byte to |tfm_file|*/ 

@p void tfm_two(int @!x) /*output two bytes to |tfm_file|*/ 
{@+tfm_out(x/256);tfm_out(x%256);
} 
@#
void tfm_four(int @!x) /*output four bytes to |tfm_file|*/ 
{@+if (x >= 0) tfm_out(x/three_bytes);
else{@+x=x+010000000000; /*use two's complement for negative values*/ 
  x=x+010000000000;
  tfm_out((x/three_bytes)+128);
  } 
x=x%three_bytes;tfm_out(x/unity);
x=x%unity;tfm_out(x/0400);
tfm_out(x%0400);
} 
@#
void tfm_qqqq(four_quarters @!x) /*output four quarterwords to |tfm_file|*/ 
{@+tfm_out(qo(x.b0));tfm_out(qo(x.b1));tfm_out(qo(x.b2));
tfm_out(qo(x.b3));
} 

@ @<Finish the \.{TFM} file@>=
if (job_name==0) open_log_file();
pack_job_name(@[@<|".tfm"|@>@]);
while (!b_open_out(&tfm_file)) 
  prompt_file_name("file name for font metrics",@[@<|".tfm"|@>@]);
metric_file_name=b_make_name_string(&tfm_file);
@<Output the subfile sizes and header bytes@>;
@<Output the character information bytes, then output the dimensions themselves@>;
@<Output the ligature/kern program@>;
@<Output the extensible character recipes and the font metric parameters@>;
#ifdef @!STAT
if (internal[tracing_stats] > 0) 
  @<Log the subfile sizes of the \.{TFM} file@>;@;
#endif
print_nl("Font metrics written on ");slow_print(metric_file_name);
print_char('.');
@.Font metrics written...@>
b_close(&tfm_file)

@ Integer variables |lh|, |k|, and |lk_offset| will be defined when we use
this code.

@<Output the subfile sizes and header bytes@>=
k=header_size;
while (header_byte[k] < 0) decr(k);
lh=(k+3)/4; /*this is the number of header words*/ 
if (bc > ec) bc=1; /*if there are no characters, |ec==0| and |bc==1|*/ 
@<Compute the ligature/kern program offset and implant the left boundary label@>;
tfm_two(6+lh+(ec-bc+1)+nw+nh+nd+ni+nl+lk_offset+nk+ne+np);
   /*this is the total number of file words that will be output*/ 
tfm_two(lh);tfm_two(bc);tfm_two(ec);tfm_two(nw);tfm_two(nh);
tfm_two(nd);tfm_two(ni);tfm_two(nl+lk_offset);tfm_two(nk);tfm_two(ne);
tfm_two(np);
for (k=1; k<=4*lh; k++) 
  {@+if (header_byte[k] < 0) header_byte[k]=0;
  tfm_out(header_byte[k]);
  } 

@ @<Output the character information bytes...@>=
for (k=bc; k<=ec; k++) 
  if (!char_exists[k]) tfm_four(0);
  else{@+tfm_out(info(tfm_width[k])); /*the width index*/ 
    tfm_out((info(tfm_height[k]))*16+info(tfm_depth[k]));
    tfm_out((info(tfm_ital_corr[k]))*4+char_tag[k]);
    tfm_out(char_remainder[k]);
    } 
tfm_changed=0;
for (k=1; k<=4; k++) 
  {@+tfm_four(0);p=dimen_head[k];
  while (p!=inf_val) 
    {@+tfm_four(dimen_out(value(p)));p=link(p);
    } 
  } 

@ We need to output special instructions at the beginning of the
|lig_kern| array in order to specify the right boundary character
and/or to handle starting addresses that exceed 255. The |label_loc|
and |label_char| arrays have been set up to record all the
starting addresses; we have $-1=|label_loc|[0]<|label_loc|[1]\le\cdots
\le|label_loc|[|label_ptr]|$.

@<Compute the ligature/kern program offset...@>=
bchar=round_unscaled(internal[boundary_char]);
if ((bchar < 0)||(bchar > 255)) 
  {@+bchar=-1;lk_started=false;lk_offset=0;@+} 
else{@+lk_started=true;lk_offset=1;@+} 
@<Find the minimum |lk_offset| and adjust all remainders@>;
if (bch_label < undefined_label) 
  {@+skip_byte(nl)=qi(255);next_char(nl)=qi(0);
  op_byte(nl)=qi(((bch_label+lk_offset)/256));
  rem_byte(nl)=qi(((bch_label+lk_offset)%256));
  incr(nl); /*possibly |nl==lig_table_size+1|*/ 
  } 

@ @<Find the minimum |lk_offset|...@>=
k=label_ptr; /*pointer to the largest unallocated label*/ 
if (label_loc[k]+lk_offset > 255) 
  {@+lk_offset=0;lk_started=false; /*location 0 can do double duty*/ 
  @/do@+{char_remainder[label_char[k]]=lk_offset;
  while (label_loc[k-1]==label_loc[k]) 
    {@+decr(k);char_remainder[label_char[k]]=lk_offset;
    } 
  incr(lk_offset);decr(k);
  }@+ while (!(lk_offset+label_loc[k] < 256));
     /*N.B.: |lk_offset==256| satisfies this when |k==0|*/ 
  } 
if (lk_offset > 0) 
  while (k > 0) 
    {@+char_remainder[label_char[k]]
     =char_remainder[label_char[k]]+lk_offset;
    decr(k);
    } 

@ @<Output the ligature/kern program@>=
for (k=0; k<=255; k++) if (skip_table[k] < undefined_label) 
  {@+print_nl("(local label ");print_int(k);print_str(":: was missing)");
@.local label l:: was missing@>
  cancel_skips(skip_table[k]);
  } 
if (lk_started)  /*|lk_offset==1| for the special |bchar|*/ 
  {@+tfm_out(255);tfm_out(bchar);tfm_two(0);
  } 
else for (k=1; k<=lk_offset; k++)  /*output the redirection specs*/ 
  {@+ll=label_loc[label_ptr];
  if (bchar < 0) 
    {@+tfm_out(254);tfm_out(0);
    } 
  else{@+tfm_out(255);tfm_out(bchar);
    } 
  tfm_two(ll+lk_offset);
  @/do@+{decr(label_ptr);
  }@+ while (!(label_loc[label_ptr] < ll));
  } 
for (k=0; k<=nl-1; k++) tfm_qqqq(lig_kern[k]);
for (k=0; k<=nk-1; k++) tfm_four(dimen_out(kern[k]))

@ @<Output the extensible character recipes...@>=
for (k=0; k<=ne-1; k++) tfm_qqqq(exten[k]);
for (k=1; k<=np; k++) 
  if (k==1) 
    if (abs(param[1]) < fraction_half) tfm_four(param[1]*16);
    else{@+incr(tfm_changed);
      if (param[1] > 0) tfm_four(el_gordo);
      else tfm_four(-el_gordo);
      } 
  else tfm_four(dimen_out(param[k]));
if (tfm_changed > 0) 
  {@+if (tfm_changed==1) print_nl("(a font metric dimension");
@.a font metric dimension...@>
  else{@+print_nl("(");print_int(tfm_changed);
@.font metric dimensions...@>
    print_str(" font metric dimensions");
    } 
  print_str(" had to be decreased)");
  } 

@ @<Log the subfile sizes of the \.{TFM} file@>=
{@+wlog_ln(" ");
if (bch_label < undefined_label) decr(nl);
wlog_ln("(You used %dw,%dh,%dd,%di,%dl,%dk,%de,%dp metric file positions", nw,@|nh,@|nd,@|ni,@|
 nl,@|nk,@|ne,@|
 np);
wlog_ln("  out of 256w,16h,16d,64i,%dl,%dk,256e,%dp)",@|
 lig_table_size, max_kerns,@|
 max_font_dimen);
} 

@* Generic font file format.
The most important output produced by a typical run of \MF\ is the
``generic font'' (\.{GF}) file that specifies the bit patterns of the
characters that have been drawn. The term {\sl generic\/} indicates that
this file format doesn't match the conventions of any name-brand manufacturer;
but it is easy to convert \.{GF} files to the special format required by
almost all digital phototypesetting equipment. There's a strong analogy
between the \.{DVI} files written by \TeX\ and the \.{GF} files written
by \MF; and, in fact, the file formats have a lot in common.

A \.{GF} file is a stream of 8-bit bytes that may be
regarded as a series of commands in a machine-like language. The first
byte of each command is the operation code, and this code is followed by
zero or more bytes that provide parameters to the command. The parameters
themselves may consist of several consecutive bytes; for example, the
`|boc|' (beginning of character) command has six parameters, each of
which is four bytes long. Parameters are usually regarded as nonnegative
integers; but four-byte-long parameters can be either positive or
negative, hence they range in value from $-2^{31}$ to $2^{31}-1$.
As in \.{TFM} files, numbers that occupy
more than one byte position appear in BigEndian order,
and negative numbers appear in two's complement notation.

A \.{GF} file consists of a ``preamble,'' followed by a sequence of one or
more ``characters,'' followed by a ``postamble.'' The preamble is simply a
|pre| command, with its parameters that introduce the file; this must come
first.  Each ``character'' consists of a |boc| command, followed by any
number of other commands that specify ``black'' pixels,
followed by an |eoc| command. The characters appear in the order that \MF\
generated them. If we ignore no-op commands (which are allowed between any
two commands in the file), each |eoc| command is immediately followed by a
|boc| command, or by a |post| command; in the latter case, there are no
more characters in the file, and the remaining bytes form the postamble.
Further details about the postamble will be explained later.

Some parameters in \.{GF} commands are ``pointers.'' These are four-byte
quantities that give the location number of some other byte in the file;
the first file byte is number~0, then comes number~1, and so on.

@ The \.{GF} format is intended to be both compact and easily interpreted
by a machine. Compactness is achieved by making most of the information
relative instead of absolute. When a \.{GF}-reading program reads the
commands for a character, it keeps track of two quantities: (a)~the current
column number,~|m|; and (b)~the current row number,~|n|.  These are 32-bit
signed integers, although most actual font formats produced from \.{GF}
files will need to curtail this vast range because of practical
limitations. (\MF\ output will never allow $\vert m\vert$ or $\vert
n\vert$ to get extremely large, but the \.{GF} format tries to be more general.)

How do \.{GF}'s row and column numbers correspond to the conventions
of \TeX\ and \MF? Well, the ``reference point'' of a character, in \TeX's
view, is considered to be at the lower left corner of the pixel in row~0
and column~0. This point is the intersection of the baseline with the left
edge of the type; it corresponds to location $(0,0)$ in \MF\ programs.
Thus the pixel in \.{GF} row~0 and column~0 is \MF's unit square, comprising the
region of the plane whose coordinates both lie between 0 and~1. The
pixel in \.{GF} row~|n| and column~|m| consists of the points whose \MF\
coordinates |(x, y)| satisfy |m <= x <= m+1| and |n <= y <= n+1|.  Negative values of
|m| and~|x| correspond to columns of pixels {\sl left\/} of the reference
point; negative values of |n| and~|y| correspond to rows of pixels {\sl
below\/} the baseline.

Besides |m| and |n|, there's also a third aspect of the current
state, namely the @!|paint_switch|, which is always either |black| or
|white|. Each \\{paint} command advances |m| by a specified amount~|d|,
and blackens the intervening pixels if |paint_switch==black|; then
the |paint_switch| changes to the opposite state. \.{GF}'s commands are
designed so that |m| will never decrease within a row, and |n| will never
increase within a character; hence there is no way to whiten a pixel that
has been blackened.

@ Here is a list of all the commands that may appear in a \.{GF} file. Each
command is specified by its symbolic name (e.g., |boc|), its opcode byte
(e.g., 67), and its parameters (if any). The parameters are followed
by a bracketed number telling how many bytes they occupy; for example,
`|d[2]|' means that parameter |d| is two bytes long.

\yskip\hang|paint_0| 0. This is a \\{paint} command with |d==0|; it does
nothing but change the |paint_switch| from \\{black} to \\{white} or vice~versa.

\yskip\hang\\{paint\_1} through \\{paint\_63} (opcodes 1 to 63).
These are \\{paint} commands with |d==1| to~63, defined as follows: If
|paint_switch==black|, blacken |d|~pixels of the current row~|n|,
in columns |m| through |m+d-1| inclusive. Then, in any case,
complement the |paint_switch| and advance |m| by~|d|.

\yskip\hang|paint1| 64 |d[1]|. This is a \\{paint} command with a specified
value of~|d|; \MF\ uses it to paint when |64 <= d < 256|.

\yskip\hang|@!paint2| 65 |d[2]|. Same as |paint1|, but |d|~can be as high
as~65535.

\yskip\hang|@!paint3| 66 |d[3]|. Same as |paint1|, but |d|~can be as high
as $2^{24}-1$. \MF\ never needs this command, and it is hard to imagine
anybody making practical use of it; surely a more compact encoding will be
desirable when characters can be this large. But the command is there,
anyway, just in case.

\yskip\hang|boc| 67 |c[4]| |p[4]| |min_m[4]| |max_m[4]| |min_n[4]|
|max_n[4]|. Beginning of a character:  Here |c| is the character code, and
|p| points to the previous character beginning (if any) for characters having
this code number modulo 256.  (The pointer |p| is |-1| if there was no
prior character with an equivalent code.) The values of registers |m| and |n|
defined by the instructions that follow for this character must
satisfy |min_m <= m <= max_m| and |min_n <= n <= max_n|.  (The values of |max_m| and
|min_n| need not be the tightest bounds possible.)  When a \.{GF}-reading
program sees a |boc|, it can use |min_m|, |max_m|, |min_n|, and |max_n| to
initialize the bounds of an array. Then it sets |m=min_m|, |n=max_n|, and
|paint_switch=white|.

\yskip\hang|boc1| 68 |c[1]| |@!del_m[1]| |max_m[1]| |@!del_n[1]| |max_n[1]|.
Same as |boc|, but |p| is assumed to be~$-1$; also |del_m==max_m-min_m|
and |del_n==max_n-min_n| are given instead of |min_m| and |min_n|.
The one-byte parameters must be between 0 and 255, inclusive.
\ (This abbreviated |boc| saves 19~bytes per character, in common cases.)

\yskip\hang|eoc| 69. End of character: All pixels blackened so far
constitute the pattern for this character. In particular, a completely
blank character might have |eoc| immediately following |boc|.

\yskip\hang|skip0| 70. Decrease |n| by 1 and set |m=min_m|,
|paint_switch=white|. \ (This finishes one row and begins another,
ready to whiten the leftmost pixel in the new row.)

\yskip\hang|skip1| 71 |d[1]|. Decrease |n| by |d+1|, set |m=min_m|, and set
|paint_switch=white|. This is a way to produce |d| all-white rows.

\yskip\hang|@!skip2| 72 |d[2]|. Same as |skip1|, but |d| can be as large
as 65535.

\yskip\hang|@!skip3| 73 |d[3]|. Same as |skip1|, but |d| can be as large
as $2^{24}-1$. \MF\ obviously never needs this command.

\yskip\hang|new_row_0| 74. Decrease |n| by 1 and set |m=min_m|,
|paint_switch=black|. \ (This finishes one row and begins another,
ready to {\sl blacken\/} the leftmost pixel in the new row.)

\yskip\hang|@!new_row_1| through |@!new_row_164| (opcodes 75 to 238). Same as
|new_row_0|, but with |m=min_m+1| through |min_m+164|, respectively.

\yskip\hang|xxx1| 239 |k[1]| |x[k]|. This command is undefined in
general; it functions as a $(k+2)$-byte |no_op| unless special \.{GF}-reading
programs are being used. \MF\ generates \\{xxx} commands when encountering
a \&{special} string; this occurs in the \.{GF} file only between
characters, after the preamble, and before the postamble. However,
\\{xxx} commands might appear within characters,
in \.{GF} files generated by other
processors. It is recommended that |x| be a string having the form of a
keyword followed by possible parameters relevant to that keyword.

\yskip\hang|@!xxx2| 240 |k[2]| |x[k]|. Like |xxx1|, but |0 <= k < 65536|.

\yskip\hang|xxx3| 241 |k[3]| |x[k]|. Like |xxx1|, but |0 <= k < @t$2^{24}$@>|.
\MF\ uses this when sending a \&{special} string whose length exceeds~255.

\yskip\hang|@!xxx4| 242 |k[4]| |x[k]|. Like |xxx1|, but |k| can be
ridiculously large; |k| mustn't be negative.

\yskip\hang|yyy| 243 |y[4]|. This command is undefined in general;
it functions as a 5-byte |no_op| unless special \.{GF}-reading programs
are being used. \MF\ puts |scaled| numbers into |yyy|'s, as a
result of \&{numspecial} commands; the intent is to provide numeric
parameters to \\{xxx} commands that immediately precede.

\yskip\hang|@!no_op| 244. No operation, do nothing. Any number of |no_op|'s
may occur between \.{GF} commands, but a |no_op| cannot be inserted between
a command and its parameters or between two parameters.

\yskip\hang|char_loc| 245 |c[1]| |dx[4]| |dy[4]| |w[4]| |p[4]|.
This command will appear only in the postamble, which will be explained shortly.

\yskip\hang|@!char_loc0| 246 |c[1]| |@!dm[1]| |w[4]| |p[4]|.
Same as |char_loc|, except that |dy| is assumed to be zero, and the value
of~|dx| is taken to be |65536*dm|, where |0 <= dm < 256|.

\yskip\hang|pre| 247 |i[1]| |k[1]| |x[k]|.
Beginning of the preamble; this must come at the very beginning of the
file. Parameter |i| is an identifying number for \.{GF} format, currently
131. The other information is merely commentary; it is not given
special interpretation like \\{xxx} commands are. (Note that \\{xxx}
commands may immediately follow the preamble, before the first |boc|.)

\yskip\hang|post| 248. Beginning of the postamble, see below.

\yskip\hang|post_post| 249. Ending of the postamble, see below.

\yskip\noindent Commands 250--255 are undefined at the present time.

@d gf_id_byte	131 /*identifies the kind of \.{GF} files described here*/ 

@ \MF\ refers to the following opcodes explicitly.

@d paint_0	0 /*beginning of the \\{paint} commands*/ 
@d paint1	64 /*move right a given number of columns, then
  black${}\swap{}$white*/ 
@d boc	67 /*beginning of a character*/ 
@d boc1	68 /*short form of |boc|*/ 
@d eoc	69 /*end of a character*/ 
@d skip0	70 /*skip no blank rows*/ 
@d skip1	71 /*skip over blank rows*/ 
@d new_row_0	74 /*move down one row and then right*/ 
@d max_new_row	164 /*the largest \\{new\_row} command is |new_row_164|*/ 
@d xxx1	239 /*for \&{special} strings*/ 
@d xxx3	241 /*for long \&{special} strings*/ 
@d yyy	243 /*for \&{numspecial} numbers*/ 
@d char_loc	245 /*character locators in the postamble*/ 
@d pre	247 /*preamble*/ 
@d post	248 /*postamble beginning*/ 
@d post_post	249 /*postamble ending*/ 

@ The last character in a \.{GF} file is followed by `|post|'; this command
introduces the postamble, which summarizes important facts that \MF\ has
accumulated. The postamble has the form
$$\vbox{\halign{\hbox{#\hfil}\cr
  |post| |p[4]| |@!ds[4]| |@!cs[4]| |@!hppp[4]| |@!vppp[4]|
   |@!min_m[4]| |@!max_m[4]| |@!min_n[4]| |@!max_n[4]|\cr
  $\langle\,$character locators$\,\rangle$\cr
  |post_post| |q[4]| |i[1]| 223's$[{\G}4]$\cr}}$$
Here |p| is a pointer to the byte following the final |eoc| in the file
(or to the byte following the preamble, if there are no characters);
it can be used to locate the beginning of \\{xxx} commands
that might have preceded the postamble. The |ds| and |cs| parameters
@^design size@> @^check sum@>
give the design size and check sum, respectively, which are exactly the
values put into the header of the \.{TFM} file that \MF\ produces (or
would produce) on this run. Parameters |hppp| and |vppp| are the ratios of
pixels per point, horizontally and vertically, expressed as |scaled| integers
(i.e., multiplied by $2^{16}$); they can be used to correlate the font
with specific device resolutions, magnifications, and ``at sizes.''  Then
come |min_m|, |max_m|, |min_n|, and |max_n|, which bound the values that
registers |m| and~|n| assume in all characters in this \.{GF} file.
(These bounds need not be the best possible; |max_m| and |min_n| may, on the
other hand, be tighter than the similar bounds in |boc| commands. For
example, some character may have |min_n==-100| in its |boc|, but it might
turn out that |n| never gets lower than |-50| in any character; then
|min_n| can have any value | <= -50|. If there are no characters in the file,
it's possible to have |min_m > max_m| and/or |min_n > max_n|.)

@ Character locators are introduced by |char_loc| commands,
which specify a character residue~|c|, character escapements (|dx, dy|),
a character width~|w|, and a pointer~|p|
to the beginning of that character. (If two or more characters have the
same code~|c| modulo 256, only the last will be indicated; the others can be
located by following backpointers. Characters whose codes differ by a
multiple of 256 are assumed to share the same font metric information,
hence the \.{TFM} file contains only residues of character codes modulo~256.
This convention is intended for oriental languages, when there are many
character shapes but few distinct widths.)
@^oriental characters@>@^Chinese characters@>@^Japanese characters@>

The character escapements (|dx, dy|) are the values of \MF's \&{chardx}
and \&{chardy} parameters; they are in units of |scaled| pixels;
i.e., |dx| is in horizontal pixel units times $2^{16}$, and |dy| is in
vertical pixel units times $2^{16}$.  This is the intended amount of
displacement after typesetting the character; for \.{DVI} files, |dy|
should be zero, but other document file formats allow nonzero vertical
escapement.

The character width~|w| duplicates the information in the \.{TFM} file; it
is a |fix_word| value relative to the design size, and it should be
independent of magnification.

The backpointer |p| points to the character's |boc|, or to the first of
a sequence of consecutive \\{xxx} or |yyy| or |no_op| commands that
immediately precede the |boc|, if such commands exist; such ``special''
commands essentially belong to the characters, while the special commands
after the final character belong to the postamble (i.e., to the font
as a whole). This convention about |p| applies also to the backpointers
in |boc| commands, even though it wasn't explained in the description
of~|boc|. @^backpointers@>

Pointer |p| might be |-1| if the character exists in the \.{TFM} file
but not in the \.{GF} file. This unusual situation can arise in \MF\ output
if the user had |proofing < 0| when the character was being shipped out,
but then made |proofing >= 0| in order to get a \.{GF} file.

@ The last part of the postamble, following the |post_post| byte that
signifies the end of the character locators, contains |q|, a pointer to the
|post| command that started the postamble.  An identification byte, |i|,
comes next; this currently equals~131, as in the preamble.

The |i| byte is followed by four or more bytes that are all equal to
the decimal number 223 (i.e., 0337 in octal). \MF\ puts out four to seven of
these trailing bytes, until the total length of the file is a multiple of
four bytes, since this works out best on machines that pack four bytes per
word; but any number of 223's is allowed, as long as there are at least four
of them. In effect, 223 is a sort of signature that is added at the very end.
@^Fuchs, David Raymond@>

This curious way to finish off a \.{GF} file makes it feasible for
\.{GF}-reading programs to find the postamble first, on most computers,
even though \MF\ wants to write the postamble last. Most operating
systems permit random access to individual words or bytes of a file, so
the \.{GF} reader can start at the end and skip backwards over the 223's
until finding the identification byte. Then it can back up four bytes, read
|q|, and move to byte |q| of the file. This byte should, of course,
contain the value 248 (|post|); now the postamble can be read, so the
\.{GF} reader can discover all the information needed for individual characters.

Unfortunately, however, standard \PASCAL\ does not include the ability to
@^system dependencies@>
access a random position in a file, or even to determine the length of a file.
Almost all systems nowadays provide the necessary capabilities, so \.{GF}
format has been designed to work most efficiently with modern operating systems.
But if \.{GF} files have to be processed under the restrictions of standard
\PASCAL, one can simply read them from front to back. This will
be adequate for most applications. However, the postamble-first approach
would facilitate a program that merges two \.{GF} files, replacing data
from one that is overridden by corresponding data in the other.

@* Shipping characters out.
The |ship_out| procedure, to be described below, is given a pointer to
an edge structure. Its mission is to describe the positive pixels
in \.{GF} form, outputting a ``character'' to |gf_file|.

Several global variables hold information about the font file as a whole:\
|gf_min_m|, |gf_max_m|, |gf_min_n|, and |gf_max_n| are the minimum and
maximum \.{GF} coordinates output so far; |gf_prev_ptr| is the byte number
following the preamble or the last |eoc| command in the output;
|total_chars| is the total number of characters (i.e., |boc dotdot eoc| segments)
shipped out.  There's also an array, |char_ptr|, containing the starting
positions of each character in the file, as required for the postamble. If
character code~|c| has not yet been output, |char_ptr[c]==-1|.

@<Glob...@>=
int @!gf_min_m, @!gf_max_m, @!gf_min_n, @!gf_max_n; /*bounding rectangle*/ 
int @!gf_prev_ptr; /*where the present/next character started/starts*/ 
int @!total_chars; /*the number of characters output so far*/ 
int @!char_ptr[256]; /*where individual characters started*/ 
int @!gf_dx[256], @!gf_dy[256]; /*device escapements*/ 

@ @<Set init...@>=
gf_prev_ptr=0;total_chars=0;

@ The \.{GF} bytes are output to a buffer instead of being sent
byte-by-byte to |gf_file|, because this tends to save a lot of
subroutine-call overhead. \MF\ uses the same conventions for |gf_file|
as \TeX\ uses for its \\{dvi\_file}; hence if system-dependent
changes are needed, they should probably be the same for both programs.

The output buffer is divided into two parts of equal size; the bytes found
in |gf_buf[0 dotdot half_buf-1]| constitute the first half, and those in
|gf_buf[half_buf dotdot gf_buf_size-1]| constitute the second. The global
variable |gf_ptr| points to the position that will receive the next
output byte. When |gf_ptr| reaches |gf_limit|, which is always equal
to one of the two values |half_buf| or |gf_buf_size|, the half buffer that
is about to be invaded next is sent to the output and |gf_limit| is
changed to its other value. Thus, there is always at least a half buffer's
worth of information present, except at the very beginning of the job.

Bytes of the \.{GF} file are numbered sequentially starting with 0;
the next byte to be generated will be number |gf_offset+gf_ptr|.

@<Types...@>=
typedef uint16_t gf_index; /*an index into the output buffer*/ 

@ Some systems may find it more efficient to make |gf_buf| a ||
array, since output of four bytes at once may be facilitated.
@^system dependencies@>

@<Glob...@>=
eight_bits @!gf_buf[gf_buf_size+1]; /*buffer for \.{GF} output*/ 
gf_index @!half_buf; /*half of |gf_buf_size|*/ 
gf_index @!gf_limit; /*end of the current half buffer*/ 
gf_index @!gf_ptr; /*the next available buffer address*/ 
int @!gf_offset; /*|gf_buf_size| times the number of times the
  output buffer has been fully emptied*/ 

@ Initially the buffer is all in one piece; we will output half of it only
after it first fills up.

@<Set init...@>=
half_buf=gf_buf_size/2;gf_limit=gf_buf_size;gf_ptr=0;
gf_offset=0;

@ The actual output of |gf_buf[a dotdot b]| to |gf_file| is performed by calling
|write_gf(a, b)|. It is safe to assume that |a| and |b+1| will both be
multiples of 4 when |write_gf(a, b)| is called; therefore it is possible on
many machines to use efficient methods to pack four bytes per word and to
output an array of words with one system call.
@^system dependencies@>

@<Declare generic font output procedures@>=
void write_gf(gf_index @!a, gf_index @!b)
{@+int k;
for (k=a; k<=b; k++) pascal_write(gf_file, "%c", gf_buf[k]);
} 

@ To put a byte in the buffer without paying the cost of invoking a procedure
each time, we use the macro |gf_out|.

@d gf_out(X)	@+{@+gf_buf[gf_ptr]=X;incr(gf_ptr);
  if (gf_ptr==gf_limit) gf_swap();
  } 

@<Declare generic font output procedures@>=
void gf_swap(void) /*outputs half of the buffer*/ 
{@+if (gf_limit==gf_buf_size) 
  {@+write_gf(0, half_buf-1);gf_limit=half_buf;
  gf_offset=gf_offset+gf_buf_size;gf_ptr=0;
  } 
else{@+write_gf(half_buf, gf_buf_size-1);gf_limit=gf_buf_size;
  } 
} 

@ Here is how we clean out the buffer when \MF\ is all through; |gf_ptr|
will be a multiple of~4.

@<Empty the last bytes out of |gf_buf|@>=
if (gf_limit==half_buf) write_gf(half_buf, gf_buf_size-1);
if (gf_ptr > 0) write_gf(0, gf_ptr-1)

@ The |gf_four| procedure outputs four bytes in two's complement notation,
without risking arithmetic overflow.

@<Declare generic font output procedures@>=
void gf_four(int @!x)
{@+if (x >= 0) gf_out(x/three_bytes)@;
else{@+x=x+010000000000;
  x=x+010000000000;
  gf_out((x/three_bytes)+128);
  } 
x=x%three_bytes;gf_out(x/unity);
x=x%unity;gf_out(x/0400);
gf_out(x%0400);
} 

@ Of course, it's even easier to output just two or three bytes.

@<Declare generic font output procedures@>=
void gf_two(int @!x)
{@+gf_out(x/0400);gf_out(x%0400);
} 
@#
void gf_three(int @!x)
{@+gf_out(x/unity);gf_out((x%unity)/0400);
gf_out(x%0400);
} 

@ We need a simple routine to generate a \\{paint}
command of the appropriate type.

@<Declare generic font output procedures@>=
void gf_paint(int @!d) /*here |0 <= d < 65536|*/ 
{@+if (d < 64) gf_out(paint_0+d)@;
else if (d < 256) 
  {@+gf_out(paint1);gf_out(d);
  } 
else{@+gf_out(paint1+1);gf_two(d);
  } 
} 

@ And |gf_string| outputs one or two strings. If the first string number
is nonzero, an \\{xxx} command is generated.

@<Declare generic font output procedures@>=
void gf_string(str_number @!s, str_number @!t)
{@+int @!k;
int @!l; /*length of the strings to output*/ 
if (s!=0) 
  {@+l=length(s);
  if (t!=0) l=l+length(t);
  if (l <= 255) 
    {@+gf_out(xxx1);gf_out(l);
    } 
  else{@+gf_out(xxx3);gf_three(l);
    } 
  for (k=str_start[s]; k<=str_start[s+1]-1; k++) gf_out(so(str_pool[k]));
  } 
if (t!=0) for (k=str_start[t]; k<=str_start[t+1]-1; k++) gf_out(so(str_pool[k]));
} 

@ The choice between |boc| commands is handled by |gf_boc|.

@d one_byte(X)	X >= 0) if (X < 256

@<Declare generic font output procedures@>=
void gf_boc(int @!min_m, int @!max_m, int @!min_n, int @!max_n)
{@+
if (min_m < gf_min_m) gf_min_m=min_m;
if (max_n > gf_max_n) gf_max_n=max_n;
if (boc_p==-1) if (one_byte(boc_c)) 
 if (one_byte(max_m-min_m)) if (one_byte(max_m)) 
  if (one_byte(max_n-min_n)) if (one_byte(max_n)) 
  {@+gf_out(boc1);gf_out(boc_c);@/
  gf_out(max_m-min_m);gf_out(max_m);
  gf_out(max_n-min_n);gf_out(max_n);return;
  } 
gf_out(boc);gf_four(boc_c);gf_four(boc_p);@/
gf_four(min_m);gf_four(max_m);gf_four(min_n);gf_four(max_n);
} 

@ Two of the parameters to |gf_boc| are global.

@<Glob...@>=
int @!boc_c, @!boc_p; /*parameters of the next |boc| command*/ 

@ Here is a routine that gets a \.{GF} file off to a good start.

@d check_gf	@t@>@+if (output_file_name==0) init_gf()

@<Declare generic font output procedures@>=
void init_gf(void)
{@+int @!k; /*runs through all possible character codes*/ 
int @!t; /*the time of this run*/ 
gf_min_m=4096;gf_max_m=-4096;gf_min_n=4096;gf_max_n=-4096;
for (k=0; k<=255; k++) char_ptr[k]=-1;
@<Determine the file extension, |gf_ext|@>;
set_output_file_name;
gf_out(pre);gf_out(gf_id_byte); /*begin to output the preamble*/ 
old_setting=selector;selector=new_string;print_str(" METAFONT output ");
print_int(round_unscaled(internal[year]));print_char('.');
print_dd(round_unscaled(internal[month]));print_char('.');
print_dd(round_unscaled(internal[day]));print_char(':');@/
t=round_unscaled(internal[time]);
print_dd(t/60);print_dd(t%60);@/
selector=old_setting;gf_out(cur_length);
gf_string(0, make_string());decr(str_ptr);
pool_ptr=str_start[str_ptr]; /*flush that string from memory*/ 
gf_prev_ptr=gf_offset+gf_ptr;
} 

@ @<Determine the file extension...@>=
if (internal[hppp] <= 0) gf_ext=@[@<|".gf"|@>@];
else{@+old_setting=selector;selector=new_string;print_char('.');
  print_int(make_scaled(internal[hppp], 59429463));
     /*$2^{32}/72.27\approx59429463.07$*/ 
  print_str("gf");gf_ext=make_string();selector=old_setting;
  } 

@ With those preliminaries out of the way, |ship_out| is not especially
difficult.

@<Declare generic font output procedures@>=
void ship_out(eight_bits @!c)
{@+
int @!f; /*current character extension*/ 
int @!prev_m, @!m, @!mm; /*previous and current pixel column numbers*/ 
int @!prev_n, @!n; /*previous and current pixel row numbers*/ 
pointer @!p, @!q; /*for list traversal*/ 
int @!prev_w, @!w, @!ww; /*old and new weights*/ 
int @!d; /*data from edge-weight node*/ 
int @!delta; /*number of rows to skip*/ 
int @!cur_min_m; /*starting column, relative to the current offset*/ 
int @!x_off, @!y_off; /*offsets, rounded to integers*/ 
check_gf;f=round_unscaled(internal[char_ext]);@/
x_off=round_unscaled(internal[x_offset]);
y_off=round_unscaled(internal[y_offset]);
if (term_offset > max_print_line-9) print_ln();
else if ((term_offset > 0)||(file_offset > 0)) print_char(' ');
print_char('[');print_int(c);
if (f!=0) 
  {@+print_char('.');print_int(f);
  } 
update_terminal;
boc_c=256*f+c;boc_p=char_ptr[c];char_ptr[c]=gf_prev_ptr;@/
if (internal[proofing] > 0) @<Send nonzero offsets to the output file@>;
@<Output the character represented in |cur_edges|@>;
gf_out(eoc);gf_prev_ptr=gf_offset+gf_ptr;incr(total_chars);
print_char(']');update_terminal; /*progress report*/ 
if (internal[tracing_output] > 0) 
  print_edges(@[@<|" (just shipped out)"|@>@], true, x_off, y_off);
} 

@ @<Send nonzero offsets to the output file@>=
{@+if (x_off!=0) 
  {@+gf_string(@[@<|"xoffset"|@>@], 0);gf_out(yyy);gf_four(x_off*unity);
  } 
if (y_off!=0) 
  {@+gf_string(@[@<|"yoffset"|@>@], 0);gf_out(yyy);gf_four(y_off*unity);
  } 
} 

@ @<Output the character represented in |cur_edges|@>=
prev_n=4096;p=knil(cur_edges);n=n_max(cur_edges)-zero_field;
while (p!=cur_edges) 
  {@+@<Output the pixels of edge row |p| to font row |n|@>;
  p=knil(p);decr(n);
  } 
if (prev_n==4096) @<Finish off an entirely blank character@>@;
else if (prev_n+y_off < gf_min_n) 
  gf_min_n=prev_n+y_off

@ @<Finish off an entirely blank...@>=
{@+gf_boc(0, 0, 0, 0);
if (gf_max_m < 0) gf_max_m=0;
if (gf_min_n > 0) gf_min_n=0;
} 

@ In this loop, |prev_w| represents the weight at column |prev_m|, which is
the most recent column reflected in the output so far; |w| represents the
weight at column~|m|, which is the most recent column in the edge data.
Several edges might cancel at the same column position, so we need to
look ahead to column~|mm| before actually outputting anything.

@<Output the pixels of edge row |p| to font row |n|@>=
if (unsorted(p) > empty) sort_edges(p);
q=sorted(p);w=0;prev_m=-fraction_one; /*$|fraction_one|\approx\infty$*/ 
ww=0;prev_w=0;m=prev_m;
@/do@+{if (q==sentinel) mm=fraction_one;
else{@+d=ho(info(q));mm=d/8;ww=ww+(d%8)-zero_w;
  } 
if (mm!=m) 
  {@+if (prev_w <= 0) 
    {@+if (w > 0) @<Start black at $(m,n)$@>;
    } 
  else if (w <= 0) @<Stop black at $(m,n)$@>;
  m=mm;
  } 
w=ww;q=link(q);
}@+ while (!(mm==fraction_one));
if (w!=0)  /*this should be impossible*/ 
  print_nl("(There's unbounded black in character shipped out!)");
@.There's unbounded black...@>
if (prev_m-m_offset(cur_edges)+x_off > gf_max_m) 
  gf_max_m=prev_m-m_offset(cur_edges)+x_off


@ @<Start black at $(m,n)$@>=
{@+if (prev_m==-fraction_one) @<Start a new row at $(m,n)$@>@;
else gf_paint(m-prev_m);
prev_m=m;prev_w=w;
} 

@ @<Stop black at $(m,n)$@>=
{@+gf_paint(m-prev_m);prev_m=m;prev_w=w;
} 

@ @<Start a new row at $(m,n)$@>=
{@+if (prev_n==4096) 
  {@+gf_boc(m_min(cur_edges)+x_off-zero_field,
    m_max(cur_edges)+x_off-zero_field,@|
    n_min(cur_edges)+y_off-zero_field, n+y_off);
  cur_min_m=m_min(cur_edges)-zero_field+m_offset(cur_edges);
  } 
else if (prev_n > n+1) @<Skip down |prev_n-n| rows@>@;
else@<Skip to column $m$ in the next row and |goto done|, or skip zero rows@>;
gf_paint(m-cur_min_m); /*skip to column $m$, painting white*/ 
done: prev_n=n;
} 

@ @<Skip to column $m$ in the next row...@>=
{@+delta=m-cur_min_m;
if (delta > max_new_row) gf_out(skip0)@;
else{@+gf_out(new_row_0+delta);goto done;
  } 
} 

@ @<Skip down...@>=
{@+delta=prev_n-n-1;
if (delta < 0400) 
  {@+gf_out(skip1);gf_out(delta);
  } 
else{@+gf_out(skip1+1);gf_two(delta);
  } 
} 

@ Now that we've finished |ship_out|, let's look at the other commands
by which a user can send things to the \.{GF} file.

@<Cases of |do_statement|...@>=
case special_command: do_special();

@ @<Put each...@>=
primitive(@[@<|"special"|@>@], special_command, string_type);@/
@!@:special_}{\&{special} primitive@>
primitive(@[@<|"numspecial"|@>@], special_command, known);@/
@!@:num_special_}{\&{numspecial} primitive@>

@ @<Declare action procedures for use by |do_statement|@>=
void do_special(void)
{@+small_number @!m; /*either |string_type| or |known|*/ 
m=cur_mod;get_x_next();scan_expression();
if (internal[proofing] >= 0) 
  if (cur_type!=m) @<Complain about improper special operation@>@;
  else{@+check_gf;
    if (m==string_type) gf_string(cur_exp, 0);
    else{@+gf_out(yyy);gf_four(cur_exp);
      } 
    } 
flush_cur_exp(0);
} 

@ @<Complain about improper special operation@>=
{@+exp_err(@[@<|"Unsuitable expression"|@>@]);
@.Unsuitable expression@>
help1("The expression shown above has the wrong type to be output.");
put_get_error();
} 

@ @<Send the current expression as a title to the output file@>=
{@+check_gf;gf_string(@[@<|"title "|@>@], cur_exp);
@.title@>
} 

@ @<Cases of |print_cmd...@>=
case special_command: if (m==known) print_str("numspecial");
  else print_str("special");@+break;

@ @<Determine if a character has been shipped out@>=
{@+cur_exp=round_unscaled(cur_exp)%256;
if (cur_exp < 0) cur_exp=cur_exp+256;
boolean_reset(char_exists[cur_exp]);cur_type=boolean_type;
} 

@ At the end of the program we must finish things off by writing the postamble.
The \.{TFM} information should have been computed first.

An integer variable |k| and a |scaled| variable |x| will be declared for
use by this routine.

@<Finish the \.{GF} file@>=
{@+gf_out(post); /*beginning of the postamble*/ 
gf_four(gf_prev_ptr);gf_prev_ptr=gf_offset+gf_ptr-5; /*|post| location*/ 
gf_four(internal[design_size]*16);
for (k=1; k<=4; k++) gf_out(header_byte[k]); /*the check sum*/ 
gf_four(internal[hppp]);
gf_four(internal[vppp]);@/
gf_four(gf_min_m);gf_four(gf_max_m);
gf_four(gf_min_n);gf_four(gf_max_n);
for (k=0; k<=255; k++) if (char_exists[k]) 
  {@+x=gf_dx[k]/unity;
  if ((gf_dy[k]==0)&&(x >= 0)&&(x < 256)&&(gf_dx[k]==x*unity)) 
    {@+gf_out(char_loc+1);gf_out(k);gf_out(x);
    } 
  else{@+gf_out(char_loc);gf_out(k);
    gf_four(gf_dx[k]);gf_four(gf_dy[k]);
    } 
  x=value(tfm_width[k]);
  if (abs(x) > max_tfm_dimen) 
    if (x > 0) x=three_bytes-1;@+else x=1-three_bytes;
  else x=make_scaled(x*16, internal[design_size]);
  gf_four(x);gf_four(char_ptr[k]);
  } 
gf_out(post_post);gf_four(gf_prev_ptr);gf_out(gf_id_byte);@/
k=4+((gf_buf_size-gf_ptr)%4); /*the number of 223's*/ 
while (k > 0) 
  {@+gf_out(223);decr(k);
  } 
@<Empty the last bytes out of |gf_buf|@>;
print_nl("Output written on ");slow_print(output_file_name);
@.Output written...@>
print_str(" (");print_int(total_chars);print_str(" character");
if (total_chars!=1) print_char('s');
print_str(", ");print_int(gf_offset+gf_ptr);print_str(" bytes).");
b_close(&gf_file);
} 

@* Dumping and undumping the tables.
After \.{INIMF} has seen a collection of macros, it
can write all the necessary information on an auxiliary file so
that production versions of \MF\ are able to initialize their
memory at high speed. The present section of the program takes
care of such output and input. We shall consider simultaneously
the processes of storing and restoring,
so that the inverse relation between them is clear.
@.INIMF@>

The global variable |base_ident| is a string that is printed right
after the |banner| line when \MF\ is ready to start. For \.{INIMF} this
string says simply `\.{(INIMF)}'; for other versions of \MF\ it says,
for example, `\.{(preloaded base=plain 1984.2.29)}', showing the year,
month, and day that the base file was created. We have |base_ident==0|
before \MF's tables are loaded.

@<Glob...@>=
str_number @!base_ident;

@ @<Set init...@>=
base_ident=0;

@ @<Initialize table entries...@>=
base_ident=@[@<|" (INIMF)"|@>@];

@ @<Declare act...@>=
#ifdef @!INIT
void store_base_file(void)
{@+int @!k; /*all-purpose index*/ 
pointer @!p, @!q; /*all-purpose pointers*/ 
int @!x; /*something to dump*/ 
four_quarters @!w; /*four ASCII codes*/ 
@<Create the |base_ident|, open the base file, and inform the user that dumping has
begun@>;
@<Dump constants for consistency check@>;
@<Dump the string pool@>;
@<Dump the dynamic memory@>;
@<Dump the table of equivalents and the hash table@>;
@<Dump a few more things and the closing check word@>;
@<Close the base file@>;
} 
#endif

@ Corresponding to the procedure that dumps a base file, we also have a function
that reads~one~in. The function returns |false| if the dumped base is
incompatible with the present \MF\ table sizes, etc.

@d too_small(X)	{@+wake_up_terminal;
  wterm_ln("---! Must increase the %s", X);
@.Must increase the x@>
  goto off_base;
  } 

@p@t\4@>@<Declare the function called |open_base_file|@>@;
bool load_base_file(void)
{@+
int @!k; /*all-purpose index*/ 
pointer @!p, @!q; /*all-purpose pointers*/ 
int @!x; /*something undumped*/ 
four_quarters @!w; /*four ASCII codes*/ 
@<Undump constants for consistency check@>;
@<Undump the string pool@>;
@<Undump the dynamic memory@>;
@<Undump the table of equivalents and the hash table@>;
@<Undump a few more things and the closing check word@>;
return true; /*it worked!*/ 
off_base: wake_up_terminal;
  wterm_ln("(Fatal base file error; I'm stymied)");
@.Fatal base file error@>
return false;
} 

@ Base files consist of |memory_word| items, and we use the following
macros to dump words of different types:

@d dump_wd(X)	{@+base_file.d=X;put(base_file);@+} 
@d dump_int(X)	{@+base_file.d.i=X;put(base_file);@+} 
@d dump_hh(X)	{@+base_file.d.hh=X;put(base_file);@+} 
@d dump_qqqq(X)	{@+base_file.d.qqqq=X;put(base_file);@+} 

@<Glob...@>=
word_file @!base_file; /*for input or output of base information*/ 

@ The inverse macros are slightly more complicated, since we need to check
the range of the values we are reading in. We say `|undump(a)(b)(x)|' to
read an integer value |x| that is supposed to be in the range |a <= x <= b|.

@d undump_wd(X)	{@+get(base_file);X=base_file.d;@+} 
@d undump_int(X)	{@+get(base_file);X=base_file.d.i;@+} 
@d undump_hh(X)	{@+get(base_file);X=base_file.d.hh;@+} 
@d undump_qqqq(X)	{@+get(base_file);X=base_file.d.qqqq;@+} 
@d undump_end_end(X)	X=x;@+} 
@d undump_end(X)	(x > X)) goto off_base;@+else undump_end_end
@d undump(X)	{@+undump_int(x);if ((x < X)||undump_end
@d undump_size_end_end(X)	too_small(X)@;@+else undump_end_end
@d undump_size_end(X)	if (x > X) undump_size_end_end
@d undump_size(X)	{@+undump_int(x);
  if (x < X) goto off_base;undump_size_end

@ The next few sections of the program should make it clear how we use the
dump/undump macros.

@<Dump constants for consistency check@>=
dump_int(0);@/
dump_int(mem_min);@/
dump_int(mem_top);@/
dump_int(hash_size);@/
dump_int(hash_prime);@/
dump_int(max_in_open)

@ Sections of a \.{WEB} program that are ``commented out'' still contribute
strings to the string pool; therefore \.{INIMF} and \MF\ will have
the same strings. (And it is, of course, a good thing that they do.)
@.WEB@>
@^string pool@>

@<Undump constants for consistency check@>=
x=base_file.d.i;
if (x!=0) goto off_base; /*check that strings are the same*/ 
undump_int(x);
if (x!=mem_min) goto off_base;
undump_int(x);
if (x!=mem_top) goto off_base;
undump_int(x);
if (x!=hash_size) goto off_base;
undump_int(x);
if (x!=hash_prime) goto off_base;
undump_int(x);
if (x!=max_in_open) goto off_base

@ @d dump_four_ASCII	
  w.b0=qi(so(str_pool[k]));w.b1=qi(so(str_pool[k+1]));
  w.b2=qi(so(str_pool[k+2]));w.b3=qi(so(str_pool[k+3]));
  dump_qqqq(w)

@<Dump the string pool@>=
dump_int(pool_ptr);
dump_int(str_ptr);
for (k=0; k<=str_ptr; k++) dump_int(str_start[k]);
k=0;
while (k+4 < pool_ptr) 
  {@+dump_four_ASCII;k=k+4;
  } 
k=pool_ptr-4;dump_four_ASCII;
print_ln();print_int(str_ptr);print_str(" strings of total length ");
print_int(pool_ptr)

@ @d undump_four_ASCII	
  undump_qqqq(w);
  str_pool[k]=si(qo(w.b0));str_pool[k+1]=si(qo(w.b1));
  str_pool[k+2]=si(qo(w.b2));str_pool[k+3]=si(qo(w.b3))

@<Undump the string pool@>=
undump_size(0)(pool_size)("string pool size")(pool_ptr);
undump_size(0)(max_strings)("max strings")(str_ptr);
for (k=0; k<=str_ptr; k++) 
  {@+undump(0)(pool_ptr)(str_start[k]);str_ref[k]=max_str_ref;
  } 
k=0;
while (k+4 < pool_ptr) 
  {@+undump_four_ASCII;k=k+4;
  } 
k=pool_ptr-4;undump_four_ASCII;
init_str_ptr=str_ptr;init_pool_ptr=pool_ptr;
max_str_ptr=str_ptr;max_pool_ptr=pool_ptr

@ By sorting the list of available spaces in the variable-size portion of
|mem|, we are usually able to get by without having to dump very much
of the dynamic memory.

We recompute |var_used| and |dyn_used|, so that \.{INIMF} dumps valid
information even when it has not been gathering statistics.

@<Dump the dynamic memory@>=
sort_avail();var_used=0;
dump_int(lo_mem_max);dump_int(rover);
p=mem_min;q=rover;x=0;
@/do@+{for (k=p; k<=q+1; k++) dump_wd(mem[k]);
x=x+q+2-p;var_used=var_used+q-p;
p=q+node_size(q);q=rlink(q);
}@+ while (!(q==rover));
var_used=var_used+lo_mem_max-p;dyn_used=mem_end+1-hi_mem_min;@/
for (k=p; k<=lo_mem_max; k++) dump_wd(mem[k]);
x=x+lo_mem_max+1-p;
dump_int(hi_mem_min);dump_int(avail);
for (k=hi_mem_min; k<=mem_end; k++) dump_wd(mem[k]);
x=x+mem_end+1-hi_mem_min;
p=avail;
while (p!=null) 
  {@+decr(dyn_used);p=link(p);
  } 
dump_int(var_used);dump_int(dyn_used);
print_ln();print_int(x);
print_str(" memory locations dumped; current usage is ");
print_int(var_used);print_char('&');print_int(dyn_used)

@ @<Undump the dynamic memory@>=
undump(lo_mem_stat_max+1000)(hi_mem_stat_min-1)(lo_mem_max);
undump(lo_mem_stat_max+1)(lo_mem_max)(rover);
p=mem_min;q=rover;
@/do@+{for (k=p; k<=q+1; k++) undump_wd(mem[k]);
p=q+node_size(q);
if ((p > lo_mem_max)||((q >= rlink(q))&&(rlink(q)!=rover))) goto off_base;
q=rlink(q);
}@+ while (!(q==rover));
for (k=p; k<=lo_mem_max; k++) undump_wd(mem[k]);
undump(lo_mem_max+1)(hi_mem_stat_min)(hi_mem_min);
undump(null)(mem_top)(avail);mem_end=mem_top;
for (k=hi_mem_min; k<=mem_end; k++) undump_wd(mem[k]);
undump_int(var_used);undump_int(dyn_used)

@ A different scheme is used to compress the hash table, since its lower region
is usually sparse. When |text(p)!=0| for |p <= hash_used|, we output three
words: |p|, |hash[p]|, and |eqtb[p]|. The hash table is, of course, densely
packed for |p >= hash_used|, so the remaining entries are output in~a~block.

@<Dump the table of equivalents and the hash table@>=
dump_int(hash_used);st_count=frozen_inaccessible-1-hash_used;
for (p=1; p<=hash_used; p++) if (text(p)!=0) 
  {@+dump_int(p);dump_hh(hash[p]);dump_hh(eqtb[p]);incr(st_count);
  } 
for (p=hash_used+1; p<=hash_end; p++) 
  {@+dump_hh(hash[p]);dump_hh(eqtb[p]);
  } 
dump_int(st_count);@/
print_ln();print_int(st_count);print_str(" symbolic tokens")

@ @<Undump the table of equivalents and the hash table@>=
undump(1)(frozen_inaccessible)(hash_used);p=0;
@/do@+{undump(p+1)(hash_used)(p);undump_hh(hash[p]);undump_hh(eqtb[p]);
}@+ while (!(p==hash_used));
for (p=hash_used+1; p<=hash_end; p++) 
  {@+undump_hh(hash[p]);undump_hh(eqtb[p]);
  } 
undump_int(st_count)

@ We have already printed a lot of statistics, so we set |tracing_stats=0|
to prevent them from appearing again.

@<Dump a few more things and the closing check word@>=
dump_int(int_ptr);
for (k=1; k<=int_ptr; k++) 
  {@+dump_int(internal[k]);dump_int(int_name[k]);
  } 
dump_int(start_sym);dump_int(interaction);dump_int(base_ident);
dump_int(bg_loc);dump_int(eg_loc);dump_int(serial_no);dump_int(69069);
internal[tracing_stats]=0

@ @<Undump a few more things and the closing check word@>=
undump(max_given_internal)(max_internal)(int_ptr);
for (k=1; k<=int_ptr; k++) 
  {@+undump_int(internal[k]);
  undump(0)(str_ptr)(int_name[k]);
  } 
undump(0)(frozen_inaccessible)(start_sym);
undump(batch_mode)(error_stop_mode)(interaction);
undump(0)(str_ptr)(base_ident);
undump(1)(hash_end)(bg_loc);
undump(1)(hash_end)(eg_loc);
undump_int(serial_no);@/
undump_int(x);@+if ((x!=69069)||eof(base_file)) goto off_base

@ @<Create the |base_ident|...@>=
selector=new_string;
print_str(" (preloaded base=");print(job_name);print_char(' ');
print_int(round_unscaled(internal[year]));print_char('.');
print_int(round_unscaled(internal[month]));print_char('.');
print_int(round_unscaled(internal[day]));print_char(')');
if (interaction==batch_mode) selector=log_only;
else selector=term_and_log;
str_room(1);base_ident=make_string();str_ref[base_ident]=max_str_ref;@/
pack_job_name(base_extension);
while (!w_open_out(&base_file)) 
 prompt_file_name("base file name", base_extension);
print_nl("Beginning to dump on file ");
@.Beginning to dump...@>
slow_print(w_make_name_string(&base_file));flush_string(str_ptr-1);
print_nl("");slow_print(base_ident)

@ @<Close the base file@>=
w_close(&base_file)

@* The main program.
This is it: the part of \MF\ that executes all those procedures we have
written.

Well---almost. We haven't put the parsing subroutines into the
program yet; and we'd better leave space for a few more routines that may
have been forgotten.

@p@<Declare the basic parsing subroutines@>@;
@<Declare miscellaneous procedures that were declared |forward|@>@;
@<Last-minute procedures@>@;

@ We've noted that there are two versions of \MF84. One, called \.{INIMF},
@.INIMF@>
has to be run first; it initializes everything from scratch, without
reading a base file, and it has the capability of dumping a base file.
The other one is called `\.{VIRMF}'; it is a ``virgin'' program that needs
@.VIRMF@>
to input a base file in order to get started. \.{VIRMF} typically has
a bit more memory capacity than \.{INIMF}, because it does not need the
space consumed by the dumping/undumping routines and the numerous calls on
|primitive|, etc.

The \.{VIRMF} program cannot read a base file instantaneously, of course;
the best implementations therefore allow for production versions of \MF\ that
not only avoid the loading routine for \PASCAL\ object code, they also have
a base file pre-loaded. This is impossible to do if we stick to standard
\PASCAL; but there is a simple way to fool many systems into avoiding the
initialization, as follows:\quad(1)~We declare a global integer variable
called |ready_already|. The probability is negligible that this
variable holds any particular value like 314159 when \.{VIRMF} is first
loaded.\quad(2)~After we have read in a base file and initialized
everything, we set |ready_already=314159|.\quad(3)~Soon \.{VIRMF}
will print `\.*', waiting for more input; and at this point we
interrupt the program and save its core image in some form that the
operating system can reload speedily.\quad(4)~When that core image is
activated, the program starts again at the beginning; but now
|ready_already==314159| and all the other global variables have
their initial values too. The former chastity has vanished!

In other words, if we allow ourselves to test the condition
|ready_already==314159|, before |ready_already| has been
assigned a value, we can avoid the lengthy initialization. Dirty tricks
rarely pay off so handsomely.
@^dirty \PASCAL@>
@^system dependencies@>

On systems that allow such preloading, the standard program called \.{MF}
should be the one that has \.{plain} base preloaded, since that agrees
with {\sl The {\logos METAFONT\/}book}.  Other versions, e.g., \.{CMMF},
should also be provided for commonly used bases such as \.{cmbase}.
@:METAFONTbook}{\sl The {\logos METAFONT\/}book@>
@.cmbase@>
@.plain@>

@<Glob...@>=
int @!ready_already; /*a sacrifice of purity for economy*/ 

@ Now this is really it: \MF\ starts and ends here.

The initial test involving |ready_already| should be deleted if the
\PASCAL\ runtime system is smart enough to detect such a ``mistake.''
@^system dependencies@>

@p int main(void) {@! /*|start_here|*/ 
history=fatal_error_stop; /*in case we quit during initialization*/ 
t_open_out; /*open the terminal for output*/ 
if (ready_already==314159) goto start_of_MF;
@<Check the ``constant'' values...@>@;
if (bad > 0) 
  {@+wterm_ln("Ouch---my internal constants have been clobbered!"
    "---case %d", bad);
@.Ouch...clobbered@>
  exit(0);
  } 
initialize(); /*set global variables to their starting values*/ 
#ifdef @!INIT
for (int i = 0; i < str_ptr; i++) str_ref[i] = max_str_ref; /* TO FIND OUT: there is no
  analogous thing in TeX - why? */
init_tab(); /*initialize the tables*/ 
init_prim(); /*call |primitive| for each primitive*/ 
init_str_ptr=str_ptr;init_pool_ptr=pool_ptr;@/
max_str_ptr=str_ptr;max_pool_ptr=pool_ptr;fix_date_and_time();
#endif
ready_already=314159;
start_of_MF: @<Initialize the output routines@>;
@<Get the first line of input and prepare to start@>;
history=spotless; /*ready to go!*/ 
if (start_sym > 0)  /*insert the `\&{everyjob}' symbol*/ 
  {@+cur_sym=start_sym;back_input();
  } 
main_control(); /*come to life*/ 
final_cleanup(); /*prepare for death*/ 
close_files_and_terminate();
ready_already=0;
return 0; }

@ Here we do whatever is needed to complete \MF's job gracefully on the
local operating system. The code here might come into play after a fatal
error; it must therefore consist entirely of ``safe'' operations that
cannot produce error messages. For example, it would be a mistake to call
|str_room| or |make_string| at this time, because a call on |overflow|
might lead to an infinite loop.
@^system dependencies@>

This program doesn't bother to close the input files that may still be open.

@<Last-minute...@>=
void close_files_and_terminate(void)
{@+int @!k; /*all-purpose index*/ 
int @!lh; /*the length of the \.{TFM} header, in words*/ 
uint16_t @!lk_offset; /*extra words inserted at beginning of |lig_kern| array*/ 
pointer @!p; /*runs through a list of \.{TFM} dimensions*/ 
scaled @!x; /*a |tfm_width| value being output to the \.{GF} file*/ 

#ifdef @!STAT
if (internal[tracing_stats] > 0) 
  @<Output statistics about this job@>;@;
#endif
wake_up_terminal;@<Finish the \.{TFM} and \.{GF} files@>;
if (log_opened) 
  {@+wlog_cr;
  a_close(&log_file);selector=selector-2;
  if (selector==term_only) 
    {@+print_nl("Transcript written on ");
@.Transcript written...@>
    slow_print(log_name);print_char('.');
    } 
  } 
} 

@ We want to finish the \.{GF} file if and only if it has already been started;
this will be true if and only if |gf_prev_ptr| is positive.
We want to produce a \.{TFM} file if and only if |fontmaking| is positive.
The \.{TFM} widths must be computed if there's a \.{GF} file, even if
there's going to be no \.{TFM}~file.

We reclaim all of the variable-size memory at this point, so that
there is no chance of another memory overflow after the memory capacity
has already been exceeded.

@<Finish the \.{TFM} and \.{GF} files@>=
if ((gf_prev_ptr > 0)||(internal[fontmaking] > 0)) 
  {@+@<Make the dynamic memory into one big available node@>;
  @<Massage the \.{TFM} widths@>;
  fix_design_size();fix_check_sum();
  if (internal[fontmaking] > 0) 
    {@+@<Massage the \.{TFM} heights, depths, and italic corrections@>;
    internal[fontmaking]=0; /*avoid loop in case of fatal error*/ 
    @<Finish the \.{TFM} file@>;
    } 
  if (gf_prev_ptr > 0) @<Finish the \.{GF} file@>;
  } 

@ @<Make the dynamic memory into one big available node@>=
rover=lo_mem_stat_max+1;link(rover)=empty_flag;lo_mem_max=hi_mem_min-1;
if (lo_mem_max-rover > max_halfword) lo_mem_max=max_halfword+rover;
node_size(rover)=lo_mem_max-rover;llink(rover)=rover;rlink(rover)=rover;
link(lo_mem_max)=null;info(lo_mem_max)=null

@ The present section goes directly to the log file instead of using
|print| commands, because there's no need for these strings to take
up |str_pool| memory when a non-{\bf stat} version of \MF\ is being used.

@<Output statistics...@>=
if (log_opened) 
  {@+wlog_ln(" ");
  wlog_ln("Here is how much of METAFONT's memory you used:");
@.Here is how much...@>
  wlog(" %d string", max_str_ptr-init_str_ptr);
  if (max_str_ptr!=init_str_ptr+1) wlog( "s" );
  wlog_ln( " out of %d", max_strings-init_str_ptr);@/
  wlog_ln( " %d string characters out of %d", max_pool_ptr-init_pool_ptr,
    pool_size-init_pool_ptr);@/
  wlog_ln(" %d words of memory out of %d", lo_mem_max-mem_min+mem_end-hi_mem_min+2,@|
    mem_end+1-mem_min);@/
  wlog_ln(" %d symbolic tokens out of %d", st_count, hash_size);@/
  wlog_ln(" %di,%dn,%dr,%dp,%db stack positions out of %di,%dn,%dr,%dp,%db",
    max_in_stack,@|
    int_ptr,@|
    max_rounding_ptr,@|
    max_param_stack,@|
    max_buf_stack+1,@|
    stack_size,
    max_internal,
    max_wiggle,
    param_size,
    buf_size );
  } 

@ We get to the |final_cleanup| routine when \&{end} or \&{dump} has
been scanned.

@<Last-minute...@>=
void final_cleanup(void)
{@+
small_number c; /*0 for \&{end}, 1 for \&{dump}*/ 
c=cur_mod;
if (job_name==0) open_log_file();
while (input_ptr > 0) 
  if (token_state) end_token_list();@+else end_file_reading();
while (loop_ptr!=null) stop_iteration();
while (open_parens > 0) 
  {@+print_str(" )");decr(open_parens);
  } 
while (cond_ptr!=null) 
  {@+print_nl("(end occurred when ");@/
@.end occurred...@>
  print_cmd_mod(fi_or_else, cur_if);
     /*`\.{if}' or `\.{elseif}' or `\.{else}'*/ 
  if (if_line!=0) 
    {@+print_str(" on line ");print_int(if_line);
    } 
  print_str(" was incomplete)");
  if_line=if_line_field(cond_ptr);
  cur_if=name_type(cond_ptr);loop_ptr=cond_ptr;
  cond_ptr=link(cond_ptr);free_node(loop_ptr, if_node_size);
  } 
if (history!=spotless) 
 if (((history==warning_issued)||(interaction < error_stop_mode))) 
  if (selector==term_and_log) 
  {@+selector=term_only;
  print_nl("(see the transcript file for additional information)");
@.see the transcript file...@>
  selector=term_and_log;
  } 
if (c==1) 
  {
#ifdef @!INIT
store_base_file();return;
#endif
  print_nl("(dump is performed only by INIMF)");return;
@.dump...only by INIMF@>
  } 
} 

@ @<Last-minute...@>=
#ifdef @!INIT
void init_prim(void) /*initialize all the primitives*/ 
{@+
@<Put each...@>;
} 
@#
void init_tab(void) /*initialize other tables*/ 
{@+int @!k; /*all-purpose index*/ 
@<Initialize table entries (done by \.{INIMF} only)@>;
} 
#endif

@ When we begin the following code, \MF's tables may still contain garbage;
the strings might not even be present. Thus we must proceed cautiously to get
bootstrapped in.

But when we finish this part of the program, \MF\ is ready to call on the
|main_control| routine to do its work.

@<Get the first line...@>=
{@+@<Initialize the input routines@>;
if ((base_ident==0)||(buffer[loc]=='&')) 
  {@+if (base_ident!=0) initialize(); /*erase preloaded base*/ 
  if (!open_base_file()) exit(0);
  if (!load_base_file()) 
    {@+w_close(&base_file);exit(0);
    } 
  w_close(&base_file);
  while ((loc < limit)&&(buffer[loc]==' ')) incr(loc);
  } 
buffer[limit]='%';@/
fix_date_and_time();init_randoms((internal[time]/unity)+internal[day]);@/
@<Initialize the print |selector|...@>;
if (loc < limit) if (buffer[loc]!='\\') start_input(); /*\&{input} assumed*/ 
} 

@* Debugging.
Once \MF\ is working, you should be able to diagnose most errors with
the \.{show} commands and other diagnostic features. But for the initial
stages of debugging, and for the revelation of really deep mysteries, you
can compile \MF\ with a few more aids, including the \PASCAL\ runtime
checks and its debugger. An additional routine called |debug_help|
will also come into play when you type `\.D' after an error message;
|debug_help| also occurs just before a fatal error causes \MF\ to succumb.
@^debugging@>
@^system dependencies@>

The interface to |debug_help| is primitive, but it is good enough when used
with a \PASCAL\ debugger that allows you to set breakpoints and to read
variables and change their values. After getting the prompt `\.{debug \#}', you
type either a negative number (this exits |debug_help|), or zero (this
goes to a location where you can set a breakpoint, thereby entering into
dialog with the \PASCAL\ debugger), or a positive number |m| followed by
an argument |n|. The meaning of |m| and |n| will be clear from the
program below. (If |m==13|, there is an additional argument, |l|.)
@.debug \#@>

@<Last-minute...@>=
#ifdef @!DEBUG
void debug_help(void) /*routine to display various things*/ 
{@+
int @!k, @!l, @!m, @!n;
loop{@+wake_up_terminal;
  print_nl("debug # (-1 to exit):");update_terminal;
@.debug \#@>
  if (fscanf(term_in.f," %d",&m)<1 ||
      m < 0) return;
  else if (m==0) 
    {@+goto breakpoint; /*go to every label at least once*/ 
    breakpoint: m=0;/*'BREAKPOINT'*/
    } 
  else{@+fscanf(term_in.f," %d",&n);
    switch (m) {
    @t\4@>@<Numbered cases for |debug_help|@>@;
    default:print_str("?");
    } 
    } 
  } 
} 
#endif

@ @<Numbered cases...@>=
case 1: print_word(mem[n]);@+break; /*display |mem[n]| in all forms*/ 
case 2: print_int(info(n));@+break;
case 3: print_int(link(n));@+break;
case 4: {@+print_int(eq_type(n));print_char(':');print_int(equiv(n));
  } @+break;
case 5: print_variable_name(n);@+break;
case 6: print_int(internal[n]);@+break;
case 7: do_show_dependencies();@+break;
case 9: show_token_list(n, null, 100000, 0);@+break;
case 10: slow_print(n);@+break;
case 11: check_mem(n > 0);@+break; /*check wellformedness; print new busy locations if |n > 0|*/ 
case 12: search_mem(n);@+break; /*look for pointers to |n|*/ 
case 13: {@+fscanf(term_in.f," %d",&l);print_cmd_mod(n, l);
  } @+break;
case 14: for (k=0; k<=n; k++) print(buffer[k]);@+break;
case 15: panicking=!panicking;@+break;

@* System-dependent changes.
This section should be replaced, if necessary, by any special
modifications of the program
that are necessary to make \MF\ work at a particular installation.
It is usually best to design your change file so that all changes to
previous sections preserve the section numbering; then everybody's version
will be consistent with the published program. More extensive changes,
which introduce new sections, can be inserted here; then only the index
itself will get a new section number.
@^system dependencies@>

@* Index.
Here is where you can find all uses of each identifier in the program,
with underlined entries pointing to where the identifier was defined.
If the identifier is only one letter long, however, you get to see only
the underlined entries. {\sl All references are to section numbers instead of
page numbers.}

This index also lists error messages and other aspects of the program
that you might want to look up some day. For example, the entry
for ``system dependencies'' lists all sections that should receive
special attention from people who are installing \MF\ in a new
operating environment. A list of various things that can't happen appears
under ``this can't happen''.
Approximately 25 sections are listed under ``inner loop''; these account
for more than 60\pct! of \MF's running time, exclusive of input and output.

@ Appendix: Replacement of the string pool file.
@d str_0_255 	"^^@@^^A^^B^^C^^D^^E^^F^^G^^H^^I^^J^^K^^L^^M^^N^^O"@/
	"^^P^^Q^^R^^S^^T^^U^^V^^W^^X^^Y^^Z^^[^^\\^^]^^^^^_"@/
	" !\"#$%&'()*+,-./"@/
	"0123456789:;<=>?"@/
	"@@ABCDEFGHIJKLMNO"@/
	"PQRSTUVWXYZ[\\]^_"@/
	"`abcdefghijklmno"@/
	"pqrstuvwxyz{|}~^^?"@/
	"^^80^^81^^82^^83^^84^^85^^86^^87^^88^^89^^8a^^8b^^8c^^8d^^8e^^8f"@/
	"^^90^^91^^92^^93^^94^^95^^96^^97^^98^^99^^9a^^9b^^9c^^9d^^9e^^9f"@/
	"^^a0^^a1^^a2^^a3^^a4^^a5^^a6^^a7^^a8^^a9^^aa^^ab^^ac^^ad^^ae^^af"@/
	"^^b0^^b1^^b2^^b3^^b4^^b5^^b6^^b7^^b8^^b9^^ba^^bb^^bc^^bd^^be^^bf"@/
	"^^c0^^c1^^c2^^c3^^c4^^c5^^c6^^c7^^c8^^c9^^ca^^cb^^cc^^cd^^ce^^cf"@/
	"^^d0^^d1^^d2^^d3^^d4^^d5^^d6^^d7^^d8^^d9^^da^^db^^dc^^dd^^de^^df"@/
	"^^e0^^e1^^e2^^e3^^e4^^e5^^e6^^e7^^e8^^e9^^ea^^eb^^ec^^ed^^ee^^ef"@/
	"^^f0^^f1^^f2^^f3^^f4^^f5^^f6^^f7^^f8^^f9^^fa^^fb^^fc^^fd^^fe^^ff"@/
@d str_start_0_255	0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45,@/
	48, 51, 54, 57, 60, 63, 66, 69, 72, 75, 78, 81, 84, 87, 90, 93,@/
	96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,@/
	112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,@/
	128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,@/
	144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,@/
	160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,@/
	176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,@/
	194, 198, 202, 206, 210, 214, 218, 222, 226, 230, 234, 238, 242, 246, 250, 254,@/
	258, 262, 266, 270, 274, 278, 282, 286, 290, 294, 298, 302, 306, 310, 314, 318,@/
	322, 326, 330, 334, 338, 342, 346, 350, 354, 358, 362, 366, 370, 374, 378, 382,@/
	386, 390, 394, 398, 402, 406, 410, 414, 418, 422, 426, 430, 434, 438, 442, 446,@/
	450, 454, 458, 462, 466, 470, 474, 478, 482, 486, 490, 494, 498, 502, 506, 510,@/
	514, 518, 522, 526, 530, 534, 538, 542, 546, 550, 554, 558, 562, 566, 570, 574,@/
	578, 582, 586, 590, 594, 598, 602, 606, 610, 614, 618, 622, 626, 630, 634, 638,@/
	642, 646, 650, 654, 658, 662, 666, 670, 674, 678, 682, 686, 690, 694, 698, 702,@/
@ 
@d str_256 "???"
@<|"???"|@>=@+256
@ 
@d str_257 "batchmode"
@<|"batchmode"|@>=@+257
@ 
@d str_258 "nonstopmode"
@<|"nonstopmode"|@>=@+258
@ 
@d str_259 "scrollmode"
@<|"scrollmode"|@>=@+259
@ 
@d str_260 ""
@d empty_string 260
@ 
@d str_261 "+-+"
@<|"+-+"|@>=@+261
@ 
@d str_262 "boolean"
@<|"boolean"|@>=@+262
@ 
@d str_263 "string"
@<|"string"|@>=@+263
@ 
@d str_264 "pen"
@<|"pen"|@>=@+264
@ 
@d str_265 "path"
@<|"path"|@>=@+265
@ 
@d str_266 "picture"
@<|"picture"|@>=@+266
@ 
@d str_267 "transform"
@<|"transform"|@>=@+267
@ 
@d str_268 "pair"
@<|"pair"|@>=@+268
@ 
@d str_269 "numeric"
@<|"numeric"|@>=@+269
@ 
@d str_270 "true"
@<|"true"|@>=@+270
@ 
@d str_271 "false"
@<|"false"|@>=@+271
@ 
@d str_272 "nullpicture"
@<|"nullpicture"|@>=@+272
@ 
@d str_273 "nullpen"
@<|"nullpen"|@>=@+273
@ 
@d str_274 "jobname"
@<|"jobname"|@>=@+274
@ 
@d str_275 "readstring"
@<|"readstring"|@>=@+275
@ 
@d str_276 "pencircle"
@<|"pencircle"|@>=@+276
@ 
@d str_277 "normaldeviate"
@<|"normaldeviate"|@>=@+277
@ 
@d str_278 "odd"
@<|"odd"|@>=@+278
@ 
@d str_279 "known"
@<|"known"|@>=@+279
@ 
@d str_280 "unknown"
@<|"unknown"|@>=@+280
@ 
@d str_281 "not"
@<|"not"|@>=@+281
@ 
@d str_282 "decimal"
@<|"decimal"|@>=@+282
@ 
@d str_283 "reverse"
@<|"reverse"|@>=@+283
@ 
@d str_284 "makepath"
@<|"makepath"|@>=@+284
@ 
@d str_285 "makepen"
@<|"makepen"|@>=@+285
@ 
@d str_286 "totalweight"
@<|"totalweight"|@>=@+286
@ 
@d str_287 "oct"
@<|"oct"|@>=@+287
@ 
@d str_288 "hex"
@<|"hex"|@>=@+288
@ 
@d str_289 "ASCII"
@<|"ASCII"|@>=@+289
@ 
@d str_290 "char"
@<|"char"|@>=@+290
@ 
@d str_291 "length"
@<|"length"|@>=@+291
@ 
@d str_292 "turningnumber"
@<|"turningnumber"|@>=@+292
@ 
@d str_293 "xpart"
@<|"xpart"|@>=@+293
@ 
@d str_294 "ypart"
@<|"ypart"|@>=@+294
@ 
@d str_295 "xxpart"
@<|"xxpart"|@>=@+295
@ 
@d str_296 "xypart"
@<|"xypart"|@>=@+296
@ 
@d str_297 "yxpart"
@<|"yxpart"|@>=@+297
@ 
@d str_298 "yypart"
@<|"yypart"|@>=@+298
@ 
@d str_299 "sqrt"
@<|"sqrt"|@>=@+299
@ 
@d str_300 "mexp"
@<|"mexp"|@>=@+300
@ 
@d str_301 "mlog"
@<|"mlog"|@>=@+301
@ 
@d str_302 "sind"
@<|"sind"|@>=@+302
@ 
@d str_303 "cosd"
@<|"cosd"|@>=@+303
@ 
@d str_304 "floor"
@<|"floor"|@>=@+304
@ 
@d str_305 "uniformdeviate"
@<|"uniformdeviate"|@>=@+305
@ 
@d str_306 "charexists"
@<|"charexists"|@>=@+306
@ 
@d str_307 "angle"
@<|"angle"|@>=@+307
@ 
@d str_308 "cycle"
@<|"cycle"|@>=@+308
@ 
@d str_309 "++"
@<|"++"|@>=@+309
@ 
@d str_310 "or"
@<|"or"|@>=@+310
@ 
@d str_311 "and"
@<|"and"|@>=@+311
@ 
@d str_312 "<="
@<|"<="|@>=@+312
@ 
@d str_313 ">="
@<|">="|@>=@+313
@ 
@d str_314 "<>"
@<|"<>"|@>=@+314
@ 
@d str_315 "rotated"
@<|"rotated"|@>=@+315
@ 
@d str_316 "slanted"
@<|"slanted"|@>=@+316
@ 
@d str_317 "scaled"
@<|"scaled"|@>=@+317
@ 
@d str_318 "shifted"
@<|"shifted"|@>=@+318
@ 
@d str_319 "transformed"
@<|"transformed"|@>=@+319
@ 
@d str_320 "xscaled"
@<|"xscaled"|@>=@+320
@ 
@d str_321 "yscaled"
@<|"yscaled"|@>=@+321
@ 
@d str_322 "zscaled"
@<|"zscaled"|@>=@+322
@ 
@d str_323 "intersectiontimes"
@<|"intersectiontimes"|@>=@+323
@ 
@d str_324 "substring"
@<|"substring"|@>=@+324
@ 
@d str_325 "subpath"
@<|"subpath"|@>=@+325
@ 
@d str_326 "directiontime"
@<|"directiontime"|@>=@+326
@ 
@d str_327 "point"
@<|"point"|@>=@+327
@ 
@d str_328 "precontrol"
@<|"precontrol"|@>=@+328
@ 
@d str_329 "postcontrol"
@<|"postcontrol"|@>=@+329
@ 
@d str_330 "penoffset"
@<|"penoffset"|@>=@+330
@ 
@d str_331 ".."
@<|".."|@>=@+331
@ 
@d str_332 "tracingtitles"
@<|"tracingtitles"|@>=@+332
@ 
@d str_333 "tracingequations"
@<|"tracingequations"|@>=@+333
@ 
@d str_334 "tracingcapsules"
@<|"tracingcapsules"|@>=@+334
@ 
@d str_335 "tracingchoices"
@<|"tracingchoices"|@>=@+335
@ 
@d str_336 "tracingspecs"
@<|"tracingspecs"|@>=@+336
@ 
@d str_337 "tracingpens"
@<|"tracingpens"|@>=@+337
@ 
@d str_338 "tracingcommands"
@<|"tracingcommands"|@>=@+338
@ 
@d str_339 "tracingrestores"
@<|"tracingrestores"|@>=@+339
@ 
@d str_340 "tracingmacros"
@<|"tracingmacros"|@>=@+340
@ 
@d str_341 "tracingedges"
@<|"tracingedges"|@>=@+341
@ 
@d str_342 "tracingoutput"
@<|"tracingoutput"|@>=@+342
@ 
@d str_343 "tracingstats"
@<|"tracingstats"|@>=@+343
@ 
@d str_344 "tracingonline"
@<|"tracingonline"|@>=@+344
@ 
@d str_345 "year"
@<|"year"|@>=@+345
@ 
@d str_346 "month"
@<|"month"|@>=@+346
@ 
@d str_347 "day"
@<|"day"|@>=@+347
@ 
@d str_348 "time"
@<|"time"|@>=@+348
@ 
@d str_349 "charcode"
@<|"charcode"|@>=@+349
@ 
@d str_350 "charext"
@<|"charext"|@>=@+350
@ 
@d str_351 "charwd"
@<|"charwd"|@>=@+351
@ 
@d str_352 "charht"
@<|"charht"|@>=@+352
@ 
@d str_353 "chardp"
@<|"chardp"|@>=@+353
@ 
@d str_354 "charic"
@<|"charic"|@>=@+354
@ 
@d str_355 "chardx"
@<|"chardx"|@>=@+355
@ 
@d str_356 "chardy"
@<|"chardy"|@>=@+356
@ 
@d str_357 "designsize"
@<|"designsize"|@>=@+357
@ 
@d str_358 "hppp"
@<|"hppp"|@>=@+358
@ 
@d str_359 "vppp"
@<|"vppp"|@>=@+359
@ 
@d str_360 "xoffset"
@<|"xoffset"|@>=@+360
@ 
@d str_361 "yoffset"
@<|"yoffset"|@>=@+361
@ 
@d str_362 "pausing"
@<|"pausing"|@>=@+362
@ 
@d str_363 "showstopping"
@<|"showstopping"|@>=@+363
@ 
@d str_364 "fontmaking"
@<|"fontmaking"|@>=@+364
@ 
@d str_365 "proofing"
@<|"proofing"|@>=@+365
@ 
@d str_366 "smoothing"
@<|"smoothing"|@>=@+366
@ 
@d str_367 "autorounding"
@<|"autorounding"|@>=@+367
@ 
@d str_368 "granularity"
@<|"granularity"|@>=@+368
@ 
@d str_369 "fillin"
@<|"fillin"|@>=@+369
@ 
@d str_370 "turningcheck"
@<|"turningcheck"|@>=@+370
@ 
@d str_371 "warningcheck"
@<|"warningcheck"|@>=@+371
@ 
@d str_372 "boundarychar"
@<|"boundarychar"|@>=@+372
@ 
@d str_373 "Path"
@<|"Path"|@>=@+373
@ 
@d str_374 "Cycle spec"
@<|"Cycle spec"|@>=@+374
@ 
@d str_375 "@@"
@<|"@@"|@>=@+375
@ 
@d str_376 "a bad variable"
@<|"a bad variable"|@>=@+376
@ 
@d str_377 "fi"
@<|"fi"|@>=@+377
@ 
@d str_378 "endgroup"
@<|"endgroup"|@>=@+378
@ 
@d str_379 "enddef"
@<|"enddef"|@>=@+379
@ 
@d str_380 "endfor"
@<|"endfor"|@>=@+380
@ 
@d str_381 " INACCESSIBLE"
@<|" INACCESSIBLE"|@>=@+381
@ 
@d str_382 "::"
@<|"::"|@>=@+382
@ 
@d str_383 "||:"
@<|"||:"|@>=@+383
@ 
@d str_384 ":="
@<|":="|@>=@+384
@ 
@d str_385 "addto"
@<|"addto"|@>=@+385
@ 
@d str_386 "at"
@<|"at"|@>=@+386
@ 
@d str_387 "atleast"
@<|"atleast"|@>=@+387
@ 
@d str_388 "begingroup"
@<|"begingroup"|@>=@+388
@ 
@d str_389 "controls"
@<|"controls"|@>=@+389
@ 
@d str_390 "cull"
@<|"cull"|@>=@+390
@ 
@d str_391 "curl"
@<|"curl"|@>=@+391
@ 
@d str_392 "delimiters"
@<|"delimiters"|@>=@+392
@ 
@d str_393 "display"
@<|"display"|@>=@+393
@ 
@d str_394 "everyjob"
@<|"everyjob"|@>=@+394
@ 
@d str_395 "exitif"
@<|"exitif"|@>=@+395
@ 
@d str_396 "expandafter"
@<|"expandafter"|@>=@+396
@ 
@d str_397 "from"
@<|"from"|@>=@+397
@ 
@d str_398 "inwindow"
@<|"inwindow"|@>=@+398
@ 
@d str_399 "interim"
@<|"interim"|@>=@+399
@ 
@d str_400 "let"
@<|"let"|@>=@+400
@ 
@d str_401 "newinternal"
@<|"newinternal"|@>=@+401
@ 
@d str_402 "of"
@<|"of"|@>=@+402
@ 
@d str_403 "openwindow"
@<|"openwindow"|@>=@+403
@ 
@d str_404 "randomseed"
@<|"randomseed"|@>=@+404
@ 
@d str_405 "save"
@<|"save"|@>=@+405
@ 
@d str_406 "scantokens"
@<|"scantokens"|@>=@+406
@ 
@d str_407 "shipout"
@<|"shipout"|@>=@+407
@ 
@d str_408 "skipto"
@<|"skipto"|@>=@+408
@ 
@d str_409 "step"
@<|"step"|@>=@+409
@ 
@d str_410 "str"
@<|"str"|@>=@+410
@ 
@d str_411 "tension"
@<|"tension"|@>=@+411
@ 
@d str_412 "to"
@<|"to"|@>=@+412
@ 
@d str_413 "until"
@<|"until"|@>=@+413
@ 
@d str_414 "def"
@<|"def"|@>=@+414
@ 
@d str_415 "token"
@<|"token"|@>=@+415
@ 
@d str_416 "var"
@<|"var"|@>=@+416
@ 
@d str_417 "xy"
@<|"xy"|@>=@+417
@ 
@d str_418 "struct"
@<|"struct"|@>=@+418
@ 
@d str_419 ", before choices"
@<|", before choices"|@>=@+419
@ 
@d str_420 ", after choices"
@<|", after choices"|@>=@+420
@ 
@d str_421 "Edge structure"
@<|"Edge structure"|@>=@+421
@ 
@d str_422 "Tracing edges"
@<|"Tracing edges"|@>=@+422
@ 
@d str_423 "ENE"
@<|"ENE"|@>=@+423
@ 
@d str_424 "NNE"
@<|"NNE"|@>=@+424
@ 
@d str_425 "NNW"
@<|"NNW"|@>=@+425
@ 
@d str_426 "WNW"
@<|"WNW"|@>=@+426
@ 
@d str_427 "WSW"
@<|"WSW"|@>=@+427
@ 
@d str_428 "SSW"
@<|"SSW"|@>=@+428
@ 
@d str_429 "SSE"
@<|"SSE"|@>=@+429
@ 
@d str_430 "ESE"
@<|"ESE"|@>=@+430
@ 
@d str_431 ", before subdivision into octants"
@<|", before subdivision into octants"|@>=@+431
@ 
@d str_432 ", after subdivision"
@<|", after subdivision"|@>=@+432
@ 
@d str_433 ", after subdivision and double autorounding"
@<|", after subdivision and double autorounding"|@>=@+433
@ 
@d str_434 ", after subdivision and autorounding"
@<|", after subdivision and autorounding"|@>=@+434
@ 
@d str_435 "Pen polygon"
@<|"Pen polygon"|@>=@+435
@ 
@d str_436 " (newly created)"
@<|" (newly created)"|@>=@+436
@ 
@d str_437 "dep"
@<|"dep"|@>=@+437
@ 
@d str_438 "endinput"
@<|"endinput"|@>=@+438
@ 
@d str_439 "vardef"
@<|"vardef"|@>=@+439
@ 
@d str_440 "primarydef"
@<|"primarydef"|@>=@+440
@ 
@d str_441 "secondarydef"
@<|"secondarydef"|@>=@+441
@ 
@d str_442 "tertiarydef"
@<|"tertiarydef"|@>=@+442
@ 
@d str_443 "for"
@<|"for"|@>=@+443
@ 
@d str_444 "forsuffixes"
@<|"forsuffixes"|@>=@+444
@ 
@d str_445 "forever"
@<|"forever"|@>=@+445
@ 
@d str_446 "quote"
@<|"quote"|@>=@+446
@ 
@d str_447 "#@@"
@<|"#@@"|@>=@+447
@ 
@d str_448 "@@#"
@<|"@@#"|@>=@+448
@ 
@d str_449 "expr"
@<|"expr"|@>=@+449
@ 
@d str_450 "suffix"
@<|"suffix"|@>=@+450
@ 
@d str_451 "text"
@<|"text"|@>=@+451
@ 
@d str_452 "primary"
@<|"primary"|@>=@+452
@ 
@d str_453 "secondary"
@<|"secondary"|@>=@+453
@ 
@d str_454 "tertiary"
@<|"tertiary"|@>=@+454
@ 
@d str_455 "input"
@<|"input"|@>=@+455
@ 
@d str_456 "Not a string"
@<|"Not a string"|@>=@+456
@ 
@d str_457 "if"
@<|"if"|@>=@+457
@ 
@d str_458 "else"
@<|"else"|@>=@+458
@ 
@d str_459 "elseif"
@<|"elseif"|@>=@+459
@ 
@d str_460 "Improper "
@<|"Improper "|@>=@+460
@ 
@d str_461 " ENDFOR"
@<|" ENDFOR"|@>=@+461
@ 
@d str_462 "initial value"
@<|"initial value"|@>=@+462
@ 
@d str_463 "step size"
@<|"step size"|@>=@+463
@ 
@d str_464 "final value"
@<|"final value"|@>=@+464
@ 
@d str_465 "MFinputs/"
@d MF_area 465
@ 
@d str_466 ".base"
@d base_extension 466
@ 
@d str_467 ".log"
@<|".log"|@>=@+467
@ 
@d str_468 ".gf"
@<|".gf"|@>=@+468
@ 
@d str_469 ".tfm"
@<|".tfm"|@>=@+469
@ 
@d str_470 "input file name"
@<|"input file name"|@>=@+470
@ 
@d str_471 ".mf"
@<|".mf"|@>=@+471
@ 
@d str_472 "mfput"
@<|"mfput"|@>=@+472
@ 
@d str_473 "exp"
@<|"exp"|@>=@+473
@ 
@d str_474 " (future pen)"
@<|" (future pen)"|@>=@+474
@ 
@d str_475 "recycle"
@<|"recycle"|@>=@+475
@ 
@d str_476 "A primary"
@<|"A primary"|@>=@+476
@ 
@d str_477 "Nonnumeric ypart has been replaced by 0"
@<|"Nonnumeric ypart has been replaced by 0"|@>=@+477
@ 
@d str_478 "Division by zero"
@<|"Division by zero"|@>=@+478
@ 
@d str_479 "Improper subscript has been replaced by zero"
@<|"Improper subscript has been replaced by zero"|@>=@+479
@ 
@d str_480 "copy"
@<|"copy"|@>=@+480
@ 
@d str_481 "A secondary"
@<|"A secondary"|@>=@+481
@ 
@d str_482 "A tertiary"
@<|"A tertiary"|@>=@+482
@ 
@d str_483 "An"
@<|"An"|@>=@+483
@ 
@d str_484 "Undefined coordinates have been replaced by (0,0)"
@<|"Undefined coordinates have been replaced by (0,0)"|@>=@+484
@ 
@d str_485 "Undefined x coordinate has been replaced by 0"
@<|"Undefined x coordinate has been replaced by 0"|@>=@+485
@ 
@d str_486 "Undefined y coordinate has been replaced by 0"
@<|"Undefined y coordinate has been replaced by 0"|@>=@+486
@ 
@d str_487 "Improper curl has been replaced by 1"
@<|"Improper curl has been replaced by 1"|@>=@+487
@ 
@d str_488 "Improper tension has been set to 1"
@<|"Improper tension has been set to 1"|@>=@+488
@ 
@d str_489 "Undefined condition will be treated as `false'"
@<|"Undefined condition will be treated as `false'"|@>=@+489
@ 
@d str_490 "Not implemented: "
@<|"Not implemented: "|@>=@+490
@ 
@d str_491 "String contains illegal digits"
@<|"String contains illegal digits"|@>=@+491
@ 
@d str_492 "Unknown relation will be considered false"
@<|"Unknown relation will be considered false"|@>=@+492
@ 
@d str_493 "Improper transformation argument"
@<|"Improper transformation argument"|@>=@+493
@ 
@d str_494 "Transform components aren't all known"
@<|"Transform components aren't all known"|@>=@+494
@ 
@d str_495 "Isolated expression"
@<|"Isolated expression"|@>=@+495
@ 
@d str_496 "Improper `:=' will be changed to `='"
@<|"Improper `:=' will be changed to `='"|@>=@+496
@ 
@d str_497 "Internal quantity `"
@<|"Internal quantity `"|@>=@+497
@ 
@d str_498 "Equation cannot be performed ("
@<|"Equation cannot be performed ("|@>=@+498
@ 
@d str_499 "end"
@<|"end"|@>=@+499
@ 
@d str_500 "dump"
@<|"dump"|@>=@+500
@ 
@d str_501 "Unknown value will be ignored"
@<|"Unknown value will be ignored"|@>=@+501
@ 
@d str_502 "errorstopmode"
@<|"errorstopmode"|@>=@+502
@ 
@d str_503 "inner"
@<|"inner"|@>=@+503
@ 
@d str_504 "outer"
@<|"outer"|@>=@+504
@ 
@d str_505 "showtoken"
@<|"showtoken"|@>=@+505
@ 
@d str_506 "showstats"
@<|"showstats"|@>=@+506
@ 
@d str_507 "show"
@<|"show"|@>=@+507
@ 
@d str_508 "showvariable"
@<|"showvariable"|@>=@+508
@ 
@d str_509 "showdependencies"
@<|"showdependencies"|@>=@+509
@ 
@d str_510 "contour"
@<|"contour"|@>=@+510
@ 
@d str_511 "doublepath"
@<|"doublepath"|@>=@+511
@ 
@d str_512 "also"
@<|"also"|@>=@+512
@ 
@d str_513 "withpen"
@<|"withpen"|@>=@+513
@ 
@d str_514 "withweight"
@<|"withweight"|@>=@+514
@ 
@d str_515 "dropping"
@<|"dropping"|@>=@+515
@ 
@d str_516 "keeping"
@<|"keeping"|@>=@+516
@ 
@d str_517 "Improper type"
@<|"Improper type"|@>=@+517
@ 
@d str_518 "Not a suitable variable"
@<|"Not a suitable variable"|@>=@+518
@ 
@d str_519 "Improper `addto'"
@<|"Improper `addto'"|@>=@+519
@ 
@d str_520 "Strange path (turning number is zero)"
@<|"Strange path (turning number is zero)"|@>=@+520
@ 
@d str_521 "Backwards path (turning number is negative)"
@<|"Backwards path (turning number is negative)"|@>=@+521
@ 
@d str_522 "Bad window number"
@<|"Bad window number"|@>=@+522
@ 
@d str_523 "message"
@<|"message"|@>=@+523
@ 
@d str_524 "errmessage"
@<|"errmessage"|@>=@+524
@ 
@d str_525 "errhelp"
@<|"errhelp"|@>=@+525
@ 
@d str_526 "charlist"
@<|"charlist"|@>=@+526
@ 
@d str_527 "ligtable"
@<|"ligtable"|@>=@+527
@ 
@d str_528 "extensible"
@<|"extensible"|@>=@+528
@ 
@d str_529 "headerbyte"
@<|"headerbyte"|@>=@+529
@ 
@d str_530 "fontdimen"
@<|"fontdimen"|@>=@+530
@ 
@d str_531 "Invalid code has been replaced by 0"
@<|"Invalid code has been replaced by 0"|@>=@+531
@ 
@d str_532 "Improper location"
@<|"Improper location"|@>=@+532
@ 
@d str_533 "=:"
@<|"=:"|@>=@+533
@ 
@d str_534 "=:|"
@<|"=:|"|@>=@+534
@ 
@d str_535 "=:|>"
@<|"=:|>"|@>=@+535
@ 
@d str_536 "|=:"
@<|"|=:"|@>=@+536
@ 
@d str_537 "|=:>"
@<|"|=:>"|@>=@+537
@ 
@d str_538 "|=:|"
@<|"|=:|"|@>=@+538
@ 
@d str_539 "|=:|>"
@<|"|=:|>"|@>=@+539
@ 
@d str_540 "|=:|>>"
@<|"|=:|>>"|@>=@+540
@ 
@d str_541 "kern"
@<|"kern"|@>=@+541
@ 
@d str_542 "Improper kern"
@<|"Improper kern"|@>=@+542
@ 
@d str_543 "Improper font parameter"
@<|"Improper font parameter"|@>=@+543
@ 
@d str_544 " (just shipped out)"
@<|" (just shipped out)"|@>=@+544
@ 
@d str_545 "special"
@<|"special"|@>=@+545
@ 
@d str_546 "numspecial"
@<|"numspecial"|@>=@+546
@ 
@d str_547 "Unsuitable expression"
@<|"Unsuitable expression"|@>=@+547
@ 
@d str_548 "title "
@<|"title "|@>=@+548
@ 
@d str_549 " (INIMF)"
@<|" (INIMF)"|@>=@+549

@ All the above strings together make up the string pool.
@<|str_pool| initialization@>=
str_0_255
str_256 str_257 str_258 str_259 str_260 str_261 str_262 str_263@/
str_264 str_265 str_266 str_267 str_268 str_269 str_270 str_271@/
str_272 str_273 str_274 str_275 str_276 str_277 str_278 str_279@/
str_280 str_281 str_282 str_283 str_284 str_285 str_286 str_287@/
str_288 str_289 str_290 str_291 str_292 str_293 str_294 str_295@/
str_296 str_297 str_298 str_299 str_300 str_301 str_302 str_303@/
str_304 str_305 str_306 str_307 str_308 str_309 str_310 str_311@/
str_312 str_313 str_314 str_315 str_316 str_317 str_318 str_319@/
str_320 str_321 str_322 str_323 str_324 str_325 str_326 str_327@/
str_328 str_329 str_330 str_331 str_332 str_333 str_334 str_335@/
str_336 str_337 str_338 str_339 str_340 str_341 str_342 str_343@/
str_344 str_345 str_346 str_347 str_348 str_349 str_350 str_351@/
str_352 str_353 str_354 str_355 str_356 str_357 str_358 str_359@/
str_360 str_361 str_362 str_363 str_364 str_365 str_366 str_367@/
str_368 str_369 str_370 str_371 str_372 str_373 str_374 str_375@/
str_376 str_377 str_378 str_379 str_380 str_381 str_382 str_383@/
str_384 str_385 str_386 str_387 str_388 str_389 str_390 str_391@/
str_392 str_393 str_394 str_395 str_396 str_397 str_398 str_399@/
str_400 str_401 str_402 str_403 str_404 str_405 str_406 str_407@/
str_408 str_409 str_410 str_411 str_412 str_413 str_414 str_415@/
str_416 str_417 str_418 str_419 str_420 str_421 str_422 str_423@/
str_424 str_425 str_426 str_427 str_428 str_429 str_430 str_431@/
str_432 str_433 str_434 str_435 str_436 str_437 str_438 str_439@/
str_440 str_441 str_442 str_443 str_444 str_445 str_446 str_447@/
str_448 str_449 str_450 str_451 str_452 str_453 str_454 str_455@/
str_456 str_457 str_458 str_459 str_460 str_461 str_462 str_463@/
str_464 str_465 str_466 str_467 str_468 str_469 str_470 str_471@/
str_472 str_473 str_474 str_475 str_476 str_477 str_478 str_479@/
str_480 str_481 str_482 str_483 str_484 str_485 str_486 str_487@/
str_488 str_489 str_490 str_491 str_492 str_493 str_494 str_495@/
str_496 str_497 str_498 str_499 str_500 str_501 str_502 str_503@/
str_504 str_505 str_506 str_507 str_508 str_509 str_510 str_511@/
str_512 str_513 str_514 str_515 str_516 str_517 str_518 str_519@/
str_520 str_521 str_522 str_523 str_524 str_525 str_526 str_527@/
str_528 str_529 str_530 str_531 str_532 str_533 str_534 str_535@/
str_536 str_537 str_538 str_539 str_540 str_541 str_542 str_543@/
str_544 str_545 str_546 str_547 str_548 str_549 

@ @<|str_start| initialization@>=
str_start_0_255
str_start_256, str_start_257, str_start_258, str_start_259,
str_start_260, str_start_261, str_start_262, str_start_263,
str_start_264, str_start_265, str_start_266, str_start_267,
str_start_268, str_start_269, str_start_270, str_start_271,
str_start_272, str_start_273, str_start_274, str_start_275,
str_start_276, str_start_277, str_start_278, str_start_279,
str_start_280, str_start_281, str_start_282, str_start_283,
str_start_284, str_start_285, str_start_286, str_start_287,
str_start_288, str_start_289, str_start_290, str_start_291,
str_start_292, str_start_293, str_start_294, str_start_295,
str_start_296, str_start_297, str_start_298, str_start_299,
str_start_300, str_start_301, str_start_302, str_start_303,
str_start_304, str_start_305, str_start_306, str_start_307,
str_start_308, str_start_309, str_start_310, str_start_311,
str_start_312, str_start_313, str_start_314, str_start_315,
str_start_316, str_start_317, str_start_318, str_start_319,
str_start_320, str_start_321, str_start_322, str_start_323,
str_start_324, str_start_325, str_start_326, str_start_327,
str_start_328, str_start_329, str_start_330, str_start_331,
str_start_332, str_start_333, str_start_334, str_start_335,
str_start_336, str_start_337, str_start_338, str_start_339,
str_start_340, str_start_341, str_start_342, str_start_343,
str_start_344, str_start_345, str_start_346, str_start_347,
str_start_348, str_start_349, str_start_350, str_start_351,
str_start_352, str_start_353, str_start_354, str_start_355,
str_start_356, str_start_357, str_start_358, str_start_359,
str_start_360, str_start_361, str_start_362, str_start_363,
str_start_364, str_start_365, str_start_366, str_start_367,
str_start_368, str_start_369, str_start_370, str_start_371,
str_start_372, str_start_373, str_start_374, str_start_375,
str_start_376, str_start_377, str_start_378, str_start_379,
str_start_380, str_start_381, str_start_382, str_start_383,
str_start_384, str_start_385, str_start_386, str_start_387,
str_start_388, str_start_389, str_start_390, str_start_391,
str_start_392, str_start_393, str_start_394, str_start_395,
str_start_396, str_start_397, str_start_398, str_start_399,
str_start_400, str_start_401, str_start_402, str_start_403,
str_start_404, str_start_405, str_start_406, str_start_407,
str_start_408, str_start_409, str_start_410, str_start_411,
str_start_412, str_start_413, str_start_414, str_start_415,
str_start_416, str_start_417, str_start_418, str_start_419,
str_start_420, str_start_421, str_start_422, str_start_423,
str_start_424, str_start_425, str_start_426, str_start_427,
str_start_428, str_start_429, str_start_430, str_start_431,
str_start_432, str_start_433, str_start_434, str_start_435,
str_start_436, str_start_437, str_start_438, str_start_439,
str_start_440, str_start_441, str_start_442, str_start_443,
str_start_444, str_start_445, str_start_446, str_start_447,
str_start_448, str_start_449, str_start_450, str_start_451,
str_start_452, str_start_453, str_start_454, str_start_455,
str_start_456, str_start_457, str_start_458, str_start_459,
str_start_460, str_start_461, str_start_462, str_start_463,
str_start_464, str_start_465, str_start_466, str_start_467,
str_start_468, str_start_469, str_start_470, str_start_471,
str_start_472, str_start_473, str_start_474, str_start_475,
str_start_476, str_start_477, str_start_478, str_start_479,
str_start_480, str_start_481, str_start_482, str_start_483,
str_start_484, str_start_485, str_start_486, str_start_487,
str_start_488, str_start_489, str_start_490, str_start_491,
str_start_492, str_start_493, str_start_494, str_start_495,
str_start_496, str_start_497, str_start_498, str_start_499,
str_start_500, str_start_501, str_start_502, str_start_503,
str_start_504, str_start_505, str_start_506, str_start_507,
str_start_508, str_start_509, str_start_510, str_start_511,
str_start_512, str_start_513, str_start_514, str_start_515,
str_start_516, str_start_517, str_start_518, str_start_519,
str_start_520, str_start_521, str_start_522, str_start_523,
str_start_524, str_start_525, str_start_526, str_start_527,
str_start_528, str_start_529, str_start_530, str_start_531,
str_start_532, str_start_533, str_start_534, str_start_535,
str_start_536, str_start_537, str_start_538, str_start_539,
str_start_540, str_start_541, str_start_542, str_start_543,
str_start_544, str_start_545, str_start_546, str_start_547,
str_start_548, str_start_549, str_start_550

@ We still need to define the start locations of the strings.
@<prepare for string pool initialization@>=
typedef enum {
str_start_256=sizeof(str_0_255)-1,
str_start_257=str_start_256+sizeof(str_256)-1,@/
str_start_258=str_start_257+sizeof(str_257)-1,@/
str_start_259=str_start_258+sizeof(str_258)-1,@/
str_start_260=str_start_259+sizeof(str_259)-1,@/
str_start_261=str_start_260+sizeof(str_260)-1,@/
str_start_262=str_start_261+sizeof(str_261)-1,@/
str_start_263=str_start_262+sizeof(str_262)-1,@/
str_start_264=str_start_263+sizeof(str_263)-1,@/
str_start_265=str_start_264+sizeof(str_264)-1,@/
str_start_266=str_start_265+sizeof(str_265)-1,@/
str_start_267=str_start_266+sizeof(str_266)-1,@/
str_start_268=str_start_267+sizeof(str_267)-1,@/
str_start_269=str_start_268+sizeof(str_268)-1,@/
str_start_270=str_start_269+sizeof(str_269)-1,@/
str_start_271=str_start_270+sizeof(str_270)-1,@/
str_start_272=str_start_271+sizeof(str_271)-1,@/
str_start_273=str_start_272+sizeof(str_272)-1,@/
str_start_274=str_start_273+sizeof(str_273)-1,@/
str_start_275=str_start_274+sizeof(str_274)-1,@/
str_start_276=str_start_275+sizeof(str_275)-1,@/
str_start_277=str_start_276+sizeof(str_276)-1,@/
str_start_278=str_start_277+sizeof(str_277)-1,@/
str_start_279=str_start_278+sizeof(str_278)-1,@/
str_start_280=str_start_279+sizeof(str_279)-1,@/
str_start_281=str_start_280+sizeof(str_280)-1,@/
str_start_282=str_start_281+sizeof(str_281)-1,@/
str_start_283=str_start_282+sizeof(str_282)-1,@/
str_start_284=str_start_283+sizeof(str_283)-1,@/
str_start_285=str_start_284+sizeof(str_284)-1,@/
str_start_286=str_start_285+sizeof(str_285)-1,@/
str_start_287=str_start_286+sizeof(str_286)-1,@/
str_start_288=str_start_287+sizeof(str_287)-1,@/
str_start_289=str_start_288+sizeof(str_288)-1,@/
str_start_290=str_start_289+sizeof(str_289)-1,@/
str_start_291=str_start_290+sizeof(str_290)-1,@/
str_start_292=str_start_291+sizeof(str_291)-1,@/
str_start_293=str_start_292+sizeof(str_292)-1,@/
str_start_294=str_start_293+sizeof(str_293)-1,@/
str_start_295=str_start_294+sizeof(str_294)-1,@/
str_start_296=str_start_295+sizeof(str_295)-1,@/
str_start_297=str_start_296+sizeof(str_296)-1,@/
str_start_298=str_start_297+sizeof(str_297)-1,@/
str_start_299=str_start_298+sizeof(str_298)-1,@/
str_start_300=str_start_299+sizeof(str_299)-1,@/
str_start_301=str_start_300+sizeof(str_300)-1,@/
str_start_302=str_start_301+sizeof(str_301)-1,@/
str_start_303=str_start_302+sizeof(str_302)-1,@/
str_start_304=str_start_303+sizeof(str_303)-1,@/
str_start_305=str_start_304+sizeof(str_304)-1,@/
str_start_306=str_start_305+sizeof(str_305)-1,@/
str_start_307=str_start_306+sizeof(str_306)-1,@/
str_start_308=str_start_307+sizeof(str_307)-1,@/
str_start_309=str_start_308+sizeof(str_308)-1,@/
str_start_310=str_start_309+sizeof(str_309)-1,@/
str_start_311=str_start_310+sizeof(str_310)-1,@/
str_start_312=str_start_311+sizeof(str_311)-1,@/
str_start_313=str_start_312+sizeof(str_312)-1,@/
str_start_314=str_start_313+sizeof(str_313)-1,@/
str_start_315=str_start_314+sizeof(str_314)-1,@/
str_start_316=str_start_315+sizeof(str_315)-1,@/
str_start_317=str_start_316+sizeof(str_316)-1,@/
str_start_318=str_start_317+sizeof(str_317)-1,@/
str_start_319=str_start_318+sizeof(str_318)-1,@/
str_start_320=str_start_319+sizeof(str_319)-1,@/
str_start_321=str_start_320+sizeof(str_320)-1,@/
str_start_322=str_start_321+sizeof(str_321)-1,@/
str_start_323=str_start_322+sizeof(str_322)-1,@/
str_start_324=str_start_323+sizeof(str_323)-1,@/
str_start_325=str_start_324+sizeof(str_324)-1,@/
str_start_326=str_start_325+sizeof(str_325)-1,@/
str_start_327=str_start_326+sizeof(str_326)-1,@/
str_start_328=str_start_327+sizeof(str_327)-1,@/
str_start_329=str_start_328+sizeof(str_328)-1,@/
str_start_330=str_start_329+sizeof(str_329)-1,@/
str_start_331=str_start_330+sizeof(str_330)-1,@/
str_start_332=str_start_331+sizeof(str_331)-1,@/
str_start_333=str_start_332+sizeof(str_332)-1,@/
str_start_334=str_start_333+sizeof(str_333)-1,@/
str_start_335=str_start_334+sizeof(str_334)-1,@/
str_start_336=str_start_335+sizeof(str_335)-1,@/
str_start_337=str_start_336+sizeof(str_336)-1,@/
str_start_338=str_start_337+sizeof(str_337)-1,@/
str_start_339=str_start_338+sizeof(str_338)-1,@/
str_start_340=str_start_339+sizeof(str_339)-1,@/
str_start_341=str_start_340+sizeof(str_340)-1,@/
str_start_342=str_start_341+sizeof(str_341)-1,@/
str_start_343=str_start_342+sizeof(str_342)-1,@/
str_start_344=str_start_343+sizeof(str_343)-1,@/
str_start_345=str_start_344+sizeof(str_344)-1,@/
str_start_346=str_start_345+sizeof(str_345)-1,@/
str_start_347=str_start_346+sizeof(str_346)-1,@/
str_start_348=str_start_347+sizeof(str_347)-1,@/
str_start_349=str_start_348+sizeof(str_348)-1,@/
str_start_350=str_start_349+sizeof(str_349)-1,@/
str_start_351=str_start_350+sizeof(str_350)-1,@/
str_start_352=str_start_351+sizeof(str_351)-1,@/
str_start_353=str_start_352+sizeof(str_352)-1,@/
str_start_354=str_start_353+sizeof(str_353)-1,@/
str_start_355=str_start_354+sizeof(str_354)-1,@/
str_start_356=str_start_355+sizeof(str_355)-1,@/
str_start_357=str_start_356+sizeof(str_356)-1,@/
str_start_358=str_start_357+sizeof(str_357)-1,@/
str_start_359=str_start_358+sizeof(str_358)-1,@/
str_start_360=str_start_359+sizeof(str_359)-1,@/
str_start_361=str_start_360+sizeof(str_360)-1,@/
str_start_362=str_start_361+sizeof(str_361)-1,@/
str_start_363=str_start_362+sizeof(str_362)-1,@/
str_start_364=str_start_363+sizeof(str_363)-1,@/
str_start_365=str_start_364+sizeof(str_364)-1,@/
str_start_366=str_start_365+sizeof(str_365)-1,@/
str_start_367=str_start_366+sizeof(str_366)-1,@/
str_start_368=str_start_367+sizeof(str_367)-1,@/
str_start_369=str_start_368+sizeof(str_368)-1,@/
str_start_370=str_start_369+sizeof(str_369)-1,@/
str_start_371=str_start_370+sizeof(str_370)-1,@/
str_start_372=str_start_371+sizeof(str_371)-1,@/
str_start_373=str_start_372+sizeof(str_372)-1,@/
str_start_374=str_start_373+sizeof(str_373)-1,@/
str_start_375=str_start_374+sizeof(str_374)-1,@/
str_start_376=str_start_375+sizeof(str_375)-1,@/
str_start_377=str_start_376+sizeof(str_376)-1,@/
str_start_378=str_start_377+sizeof(str_377)-1,@/
str_start_379=str_start_378+sizeof(str_378)-1,@/
str_start_380=str_start_379+sizeof(str_379)-1,@/
str_start_381=str_start_380+sizeof(str_380)-1,@/
str_start_382=str_start_381+sizeof(str_381)-1,@/
str_start_383=str_start_382+sizeof(str_382)-1,@/
str_start_384=str_start_383+sizeof(str_383)-1,@/
str_start_385=str_start_384+sizeof(str_384)-1,@/
str_start_386=str_start_385+sizeof(str_385)-1,@/
str_start_387=str_start_386+sizeof(str_386)-1,@/
str_start_388=str_start_387+sizeof(str_387)-1,@/
str_start_389=str_start_388+sizeof(str_388)-1,@/
str_start_390=str_start_389+sizeof(str_389)-1,@/
str_start_391=str_start_390+sizeof(str_390)-1,@/
str_start_392=str_start_391+sizeof(str_391)-1,@/
str_start_393=str_start_392+sizeof(str_392)-1,@/
str_start_394=str_start_393+sizeof(str_393)-1,@/
str_start_395=str_start_394+sizeof(str_394)-1,@/
str_start_396=str_start_395+sizeof(str_395)-1,@/
str_start_397=str_start_396+sizeof(str_396)-1,@/
str_start_398=str_start_397+sizeof(str_397)-1,@/
str_start_399=str_start_398+sizeof(str_398)-1,@/
str_start_400=str_start_399+sizeof(str_399)-1,@/
str_start_401=str_start_400+sizeof(str_400)-1,@/
str_start_402=str_start_401+sizeof(str_401)-1,@/
str_start_403=str_start_402+sizeof(str_402)-1,@/
str_start_404=str_start_403+sizeof(str_403)-1,@/
str_start_405=str_start_404+sizeof(str_404)-1,@/
str_start_406=str_start_405+sizeof(str_405)-1,@/
str_start_407=str_start_406+sizeof(str_406)-1,@/
str_start_408=str_start_407+sizeof(str_407)-1,@/
str_start_409=str_start_408+sizeof(str_408)-1,@/
str_start_410=str_start_409+sizeof(str_409)-1,@/
str_start_411=str_start_410+sizeof(str_410)-1,@/
str_start_412=str_start_411+sizeof(str_411)-1,@/
str_start_413=str_start_412+sizeof(str_412)-1,@/
str_start_414=str_start_413+sizeof(str_413)-1,@/
str_start_415=str_start_414+sizeof(str_414)-1,@/
str_start_416=str_start_415+sizeof(str_415)-1,@/
str_start_417=str_start_416+sizeof(str_416)-1,@/
str_start_418=str_start_417+sizeof(str_417)-1,@/
str_start_419=str_start_418+sizeof(str_418)-1,@/
str_start_420=str_start_419+sizeof(str_419)-1,@/
str_start_421=str_start_420+sizeof(str_420)-1,@/
str_start_422=str_start_421+sizeof(str_421)-1,@/
str_start_423=str_start_422+sizeof(str_422)-1,@/
str_start_424=str_start_423+sizeof(str_423)-1,@/
str_start_425=str_start_424+sizeof(str_424)-1,@/
str_start_426=str_start_425+sizeof(str_425)-1,@/
str_start_427=str_start_426+sizeof(str_426)-1,@/
str_start_428=str_start_427+sizeof(str_427)-1,@/
str_start_429=str_start_428+sizeof(str_428)-1,@/
str_start_430=str_start_429+sizeof(str_429)-1,@/
str_start_431=str_start_430+sizeof(str_430)-1,@/
str_start_432=str_start_431+sizeof(str_431)-1,@/
str_start_433=str_start_432+sizeof(str_432)-1,@/
str_start_434=str_start_433+sizeof(str_433)-1,@/
str_start_435=str_start_434+sizeof(str_434)-1,@/
str_start_436=str_start_435+sizeof(str_435)-1,@/
str_start_437=str_start_436+sizeof(str_436)-1,@/
str_start_438=str_start_437+sizeof(str_437)-1,@/
str_start_439=str_start_438+sizeof(str_438)-1,@/
str_start_440=str_start_439+sizeof(str_439)-1,@/
str_start_441=str_start_440+sizeof(str_440)-1,@/
str_start_442=str_start_441+sizeof(str_441)-1,@/
str_start_443=str_start_442+sizeof(str_442)-1,@/
str_start_444=str_start_443+sizeof(str_443)-1,@/
str_start_445=str_start_444+sizeof(str_444)-1,@/
str_start_446=str_start_445+sizeof(str_445)-1,@/
str_start_447=str_start_446+sizeof(str_446)-1,@/
str_start_448=str_start_447+sizeof(str_447)-1,@/
str_start_449=str_start_448+sizeof(str_448)-1,@/
str_start_450=str_start_449+sizeof(str_449)-1,@/
str_start_451=str_start_450+sizeof(str_450)-1,@/
str_start_452=str_start_451+sizeof(str_451)-1,@/
str_start_453=str_start_452+sizeof(str_452)-1,@/
str_start_454=str_start_453+sizeof(str_453)-1,@/
str_start_455=str_start_454+sizeof(str_454)-1,@/
str_start_456=str_start_455+sizeof(str_455)-1,@/
str_start_457=str_start_456+sizeof(str_456)-1,@/
str_start_458=str_start_457+sizeof(str_457)-1,@/
str_start_459=str_start_458+sizeof(str_458)-1,@/
str_start_460=str_start_459+sizeof(str_459)-1,@/
str_start_461=str_start_460+sizeof(str_460)-1,@/
str_start_462=str_start_461+sizeof(str_461)-1,@/
str_start_463=str_start_462+sizeof(str_462)-1,@/
str_start_464=str_start_463+sizeof(str_463)-1,@/
str_start_465=str_start_464+sizeof(str_464)-1,@/
str_start_466=str_start_465+sizeof(str_465)-1,@/
str_start_467=str_start_466+sizeof(str_466)-1,@/
str_start_468=str_start_467+sizeof(str_467)-1,@/
str_start_469=str_start_468+sizeof(str_468)-1,@/
str_start_470=str_start_469+sizeof(str_469)-1,@/
str_start_471=str_start_470+sizeof(str_470)-1,@/
str_start_472=str_start_471+sizeof(str_471)-1,@/
str_start_473=str_start_472+sizeof(str_472)-1,@/
str_start_474=str_start_473+sizeof(str_473)-1,@/
str_start_475=str_start_474+sizeof(str_474)-1,@/
str_start_476=str_start_475+sizeof(str_475)-1,@/
str_start_477=str_start_476+sizeof(str_476)-1,@/
str_start_478=str_start_477+sizeof(str_477)-1,@/
str_start_479=str_start_478+sizeof(str_478)-1,@/
str_start_480=str_start_479+sizeof(str_479)-1,@/
str_start_481=str_start_480+sizeof(str_480)-1,@/
str_start_482=str_start_481+sizeof(str_481)-1,@/
str_start_483=str_start_482+sizeof(str_482)-1,@/
str_start_484=str_start_483+sizeof(str_483)-1,@/
str_start_485=str_start_484+sizeof(str_484)-1,@/
str_start_486=str_start_485+sizeof(str_485)-1,@/
str_start_487=str_start_486+sizeof(str_486)-1,@/
str_start_488=str_start_487+sizeof(str_487)-1,@/
str_start_489=str_start_488+sizeof(str_488)-1,@/
str_start_490=str_start_489+sizeof(str_489)-1,@/
str_start_491=str_start_490+sizeof(str_490)-1,@/
str_start_492=str_start_491+sizeof(str_491)-1,@/
str_start_493=str_start_492+sizeof(str_492)-1,@/
str_start_494=str_start_493+sizeof(str_493)-1,@/
str_start_495=str_start_494+sizeof(str_494)-1,@/
str_start_496=str_start_495+sizeof(str_495)-1,@/
str_start_497=str_start_496+sizeof(str_496)-1,@/
str_start_498=str_start_497+sizeof(str_497)-1,@/
str_start_499=str_start_498+sizeof(str_498)-1,@/
str_start_500=str_start_499+sizeof(str_499)-1,@/
str_start_501=str_start_500+sizeof(str_500)-1,@/
str_start_502=str_start_501+sizeof(str_501)-1,@/
str_start_503=str_start_502+sizeof(str_502)-1,@/
str_start_504=str_start_503+sizeof(str_503)-1,@/
str_start_505=str_start_504+sizeof(str_504)-1,@/
str_start_506=str_start_505+sizeof(str_505)-1,@/
str_start_507=str_start_506+sizeof(str_506)-1,@/
str_start_508=str_start_507+sizeof(str_507)-1,@/
str_start_509=str_start_508+sizeof(str_508)-1,@/
str_start_510=str_start_509+sizeof(str_509)-1,@/
str_start_511=str_start_510+sizeof(str_510)-1,@/
str_start_512=str_start_511+sizeof(str_511)-1,@/
str_start_513=str_start_512+sizeof(str_512)-1,@/
str_start_514=str_start_513+sizeof(str_513)-1,@/
str_start_515=str_start_514+sizeof(str_514)-1,@/
str_start_516=str_start_515+sizeof(str_515)-1,@/
str_start_517=str_start_516+sizeof(str_516)-1,@/
str_start_518=str_start_517+sizeof(str_517)-1,@/
str_start_519=str_start_518+sizeof(str_518)-1,@/
str_start_520=str_start_519+sizeof(str_519)-1,@/
str_start_521=str_start_520+sizeof(str_520)-1,@/
str_start_522=str_start_521+sizeof(str_521)-1,@/
str_start_523=str_start_522+sizeof(str_522)-1,@/
str_start_524=str_start_523+sizeof(str_523)-1,@/
str_start_525=str_start_524+sizeof(str_524)-1,@/
str_start_526=str_start_525+sizeof(str_525)-1,@/
str_start_527=str_start_526+sizeof(str_526)-1,@/
str_start_528=str_start_527+sizeof(str_527)-1,@/
str_start_529=str_start_528+sizeof(str_528)-1,@/
str_start_530=str_start_529+sizeof(str_529)-1,@/
str_start_531=str_start_530+sizeof(str_530)-1,@/
str_start_532=str_start_531+sizeof(str_531)-1,@/
str_start_533=str_start_532+sizeof(str_532)-1,@/
str_start_534=str_start_533+sizeof(str_533)-1,@/
str_start_535=str_start_534+sizeof(str_534)-1,@/
str_start_536=str_start_535+sizeof(str_535)-1,@/
str_start_537=str_start_536+sizeof(str_536)-1,@/
str_start_538=str_start_537+sizeof(str_537)-1,@/
str_start_539=str_start_538+sizeof(str_538)-1,@/
str_start_540=str_start_539+sizeof(str_539)-1,@/
str_start_541=str_start_540+sizeof(str_540)-1,@/
str_start_542=str_start_541+sizeof(str_541)-1,@/
str_start_543=str_start_542+sizeof(str_542)-1,@/
str_start_544=str_start_543+sizeof(str_543)-1,@/
str_start_545=str_start_544+sizeof(str_544)-1,@/
str_start_546=str_start_545+sizeof(str_545)-1,@/
str_start_547=str_start_546+sizeof(str_546)-1,@/
str_start_548=str_start_547+sizeof(str_547)-1,@/
str_start_549=str_start_548+sizeof(str_548)-1,@/
str_start_550=str_start_549+sizeof(str_549)-1,@/
str_start_end } str_starts;

@ @<|pool_ptr| initialization@>= str_start_550

@ @<|str_ptr| initialization@>= 550
