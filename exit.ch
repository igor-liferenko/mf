@x
@h
@y
@h
#define exit do { wterm_cr; wait_window; \
  if (history <= warning_issued) exit(0); else exit(1); } while
@z

@x
return 0; }
@y
exit(0); }
@z
