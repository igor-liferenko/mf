@x
  {@+write_ln(term_out,"Buffer size exceeded!");exit(0);
@y
  {@+write_ln(term_out,"Buffer size exceeded!");exit(1);
@z

@x
{@+ close_files_and_terminate(); exit(0);
@y
{@+ close_files_and_terminate(); exit(1);
@z

@x
if (!init_terminal(argc,argv)) exit(0);
@y
if (!init_terminal(argc,argv)) exit(1);
@z

@x
  exit(0);
@y
  exit(1);
@z

@x
return 0; }
@y
if (history <= warning_issued) return 0; else return 1; }
@z

@x
  if (!open_base_file()) exit(0);
@y
  if (!open_base_file()) exit(1);
@z

@x
    {@+w_close(&base_file);exit(0);
@y
    {@+w_close(&base_file);exit(1);
@z
