Print "MFinputs/" instead of full path to it in log file and on terminal.

@x
else{@+for (k=1; k<=name_length; k++) append_char(xord[name_of_file[k]]);
@y
else {
  char EXT_area[length(MF_area)+1];
  for (k=0; k<length(MF_area); k++)
    EXT_area[k] = xchr[so(str_pool[str_start[MF_area]+k])];
  EXT_area[k] = '\0';
  k=1;
  if (strncmp(name_of_file+1, EXT_area, strlen(EXT_area)) == 0)
    k += strlen(EXT_area) - strlen("MFinputs/");
  for (; k<=name_length; k++) append_char(xord[name_of_file[k]]);
@z
