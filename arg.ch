Only one argument is handled (filename).

@x
@p bool init_terminal(void) /*gets the terminal input started*/
@y
@p bool init_terminal(int argc, char **argv)
@z

@x
t_open_in;
@y
t_open_in;
if (argc == 2) {
  last = loc = first;
  for (int k = 0; k < strlen(argv[1]); k++)
    buffer[last++] = xord[argv[1][k]];
  return true;
}
@z

@x
if (!init_terminal()) goto final_end;
@y
if (!init_terminal(argc,argv)) goto final_end;
@z

@x
@p int main(void) {@! /*|start_here|*/
@y
@p int main(int argc, char **argv) {
@z
