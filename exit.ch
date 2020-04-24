@x
@h
@y
@h
#define exit do { wterm_cr; \
  if (cpid != -1) { printf("Waiting...\r"); fflush(stdout); getchar(); kill(cpid, SIGTERM); } \
  if (history <= warning_issued) exit(0); else exit(1); } while
@z
TODO: rm mf.fn because there will be no window process when mf starts; and make corresponding changes in doc-part of wl.w

@x
return 0; }
@y
exit(0); }
@z
