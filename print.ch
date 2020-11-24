Print "MFinputs/" instead of full path to it in log file and on terminal.

@x
@h
@y
@h
#define str_(x) str_ ## x
#define str(x) str_(x)
@z

@x
else{@+for (k=1; k<=name_length; k++) append_char(xord[name_of_file[k]]);
@y
else {
  k=1;
  if (strncmp(name_of_file+1, str(MF_area), strlen(str(MF_area))) == 0)
    k += strlen(str(MF_area)) - strlen("MFinputs/");
  for (; k<=name_length; k++) append_char(xord[name_of_file[k]]);
@z
