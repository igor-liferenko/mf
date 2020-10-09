@x
b_close(&gf_file);
@y
char tmp[1000], fname[1000];
sprintf(tmp, "/proc/self/fd/%d", fileno(gf_file.f));
fname[readlink(tmp, fname, sizeof fname)] = 0;
b_close(&gf_file);
pid_t pid = fork();
if (pid == 0) {
  signal(SIGINT, SIG_IGN);
  execl("/bin/gftopk", "gftopk", fname, (char *) NULL);
}
waitpid(pid, NULL, 0);
@z
