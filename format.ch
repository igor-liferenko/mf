NOTE: remove this after some time (when ensured)
@x
if (ready_already==314159) goto start_of_MF;
@y
if (ready_already!=0) { fprintf(stderr, "error: this can not be"); exit(0); }
@z

TODO: compare tex with metafont

NOTE: this code was taken verbatim from @<Get the first line...@> (except that open_fmt_file is replaced with w_open_in)
NOTE: length of progname (in bytes) must be <= file_name_size-format_area_length-4
@x
initialize(); /*set global variables to their starting values*/ 
@y
initialize(); /*set global variables to their starting values*/ 
#ifndef INIT
strncpy(name_of_file+1, MF_base_default+1, base_area_length);
strcat(name_of_file+1, strrchr(argv[0], '/') == NULL ? argv[0] : strrchr(argv[0], '/') + 1);
strcat(name_of_file+1, ".base");
if (!w_open_in(&base_file)) exit(0);
if (!load_base_file()) {
  w_close(&base_file);
  exit(0);
} 
w_close(&base_file);
#endif
@z
