@x
@h
@y
@h
#ifndef wait_window
#define wait_window
#endif
#define exit do { wterm_cr; wait_window; \
  if (history <= warning_issued) exit(0); else exit(1); } while
@z

@x
return 0; }
@y
exit(0); }
@z
