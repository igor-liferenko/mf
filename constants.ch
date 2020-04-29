xxxmy
% [1.11] Compile-time constants.  Although we only change a few of
% these, listing them all makes the patch file for a big Metafont simpler.
% 16K for BSD I/O; file_name_size is set from the system constant.
@x
@<Constants...@>=
@!mem_max=30000; {greatest index in \MF's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INIMF}, otherwise |>=mem_top|}
@!max_internal=100; {maximum number of internal quantities}
@!buf_size=500; {maximum number of characters simultaneously present in
  current lines of open files; must not exceed |max_halfword|}
@!error_line=72; {width of context lines on terminal error messages}
@!half_error_line=42; {width of first lines of contexts in terminal
  error messages; should be between 30 and |error_line-15|}
@!max_print_line=79; {width of longest text lines output; should be at least 60}
@!screen_width=768; {number of pixels in each row of screen display}
@!screen_depth=1024; {number of pixels in each column of screen display}
@!stack_size=30; {maximum number of simultaneous input sources}
@!max_strings=2000; {maximum number of strings; must not exceed |max_halfword|}
@!string_vacancies=8000; {the minimum number of characters that should be
  available for the user's identifier names and strings,
  after \MF's own error messages are stored}
@!pool_size=32000; {maximum number of characters in strings, including all
  error messages and help texts, and the names of all identifiers;
  must exceed |string_vacancies| by the total
  length of \MF's own strings, which is currently about 22000}
@!move_size=5000; {space for storing moves in a single octant}
@!max_wiggle=300; {number of autorounded points per cycle}
@!gf_buf_size=800; {size of the output buffer, must be a multiple of 8}
@!file_name_size=40; {file names shouldn't be longer than this}
@!pool_name='MFbases:MF.POOL                         ';
  {string of length |file_name_size|; tells where the string pool appears}
@.MFbases@>
@!path_size=300; {maximum number of knots between breakpoints of a path}
@!bistack_size=785; {size of stack for bisection algorithms;
  should probably be left at this value}
@!header_size=100; {maximum number of \.{TFM} header words, times~4}
@!lig_table_size=5000; {maximum number of ligature/kern steps, must be
  at least 255 and at most 32510}
@!max_kerns=500; {maximum number of distinct kern amounts}
@!max_font_dimen=50; {maximum number of \&{fontdimen} parameters}
@y
@d file_name_size == maxint
@d ssup_error_line = 255
@d ssup_screen_width = 32767
@d ssup_screen_depth = 32767

@<Constants...@>=
@!max_internal=300; {maximum number of internal quantities}
@!stack_size=300; {maximum number of simultaneous input sources}
@!max_strings=7500; {maximum number of strings; must not exceed |max_halfword|}
@!string_vacancies=74000; {the minimum number of characters that should be
  available for the user's identifier names and strings,
  after \MF's own error messages are stored}
@!pool_size=100000; {maximum number of characters in strings, including all
  error messages and help texts, and the names of all identifiers;
  must exceed |string_vacancies| by the total
  length of \MF's own strings, which is currently about 22000}
@!move_size=20000; {space for storing moves in a single octant}
@!max_wiggle=1000; {number of autorounded points per cycle}
@!pool_name=TEXMF_POOL_NAME;
  {string that tells where the string pool appears}
@!engine_name=TEXMF_ENGINE_NAME; {the name of this engine}
@!path_size=1000; {maximum number of knots between breakpoints of a path}
@!bistack_size=1500; {size of stack for bisection algorithms;
  should probably be left at this value}
@!header_size=100; {maximum number of \.{TFM} header words, times~4}
@!lig_table_size=15000; {maximum number of ligature/kern steps, must be
  at least 255 and at most 32510}
@!max_kerns=2500; {maximum number of distinct kern amounts}
@!max_font_dimen=60; {maximum number of \&{fontdimen} parameters}
@#
@!inf_main_memory = 3000;
@!sup_main_memory = 8000000;

@!inf_buf_size = 500;
@!sup_buf_size = 30000000;
@z

@x [1.12] Constants defined as WEB macros.
@d mem_min=0 {smallest index in the |mem| array, must not be less
  than |min_halfword|}
@d mem_top==30000 {largest index in the |mem| array dumped by \.{INIMF};
  must be substantially larger than |mem_min|
  and not greater than |mem_max|}
@d hash_size=2100 {maximum number of symbolic tokens,
  must be less than |max_halfword-3*param_size|}
@d hash_prime=1777 {a prime number equal to about 85\pct! of |hash_size|}
@d max_in_open=6 {maximum number of input files and error insertions that
  can be going on simultaneously}
@d param_size=150 {maximum number of simultaneous macro parameters}
@y
@d mem_min=0 {smallest index in the |mem| array, must not be less
  than |min_halfword|}
@d hash_size=9500 {maximum number of symbolic tokens,
  must be less than |max_halfword-3*param_size|}
@d hash_prime=7919 {a prime number equal to about 85\pct! of |hash_size|}
@d max_in_open=15 {maximum number of input files and error insertions that
  can be going on simultaneously}
@d param_size=150 {maximum number of simultaneous macro parameters}
@z
yyymy
