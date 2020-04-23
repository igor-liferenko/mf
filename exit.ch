@x
@h
@y
@h
#define exit do { wterm_cr; \
  if (display) { wprintf(L"Waiting..."); fflush(stdout); read; kill; wprintf(L"\r"); } \
  if (history <= warning_issued) exit(0); else exit(1); } while
@z
TODO: don't kill window process when mf starts as in web2c's mf because there will be no window process when mf starts

@x
return 0; }
@y
exit(0); }
@z
