@x
@h
@y
@h
#define str_(x) str_ ## x
#define str(x) str_(x)
@z

Display "MFinputs/" instead of full path to it in log files and on terminal.
@x
else{@+for (k=1; k<=name_length; k++) append_char(xord[name_of_file[k]]);
@y
else {
  k=1;
  if (strstr(name_of_file+1, str(MF_area)) == (char *) name_of_file+1) /* TODO: see operator precedence and add spaces around + if cast is before +; same for ctex */
    if (strstr(str(MF_area), "MFinputs/") != NULL)
      k = strstr(str(MF_area), "MFinputs/") - str(MF_area) + 1;
  for (; k<=name_length; k++) append_char(xord[name_of_file[k]]);
@z
