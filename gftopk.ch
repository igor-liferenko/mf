@x
b_close(&gf_file);
@y
char tmp[22];
sprintf(tmp, "/proc/self/fd/%d", fileno(gf_file.f));
char fname[1000] = { };
if (readlink(tmp, fname, sizeof fname) == -1 || fname[sizeof fname - 1])
  kill(getpid(), SIGABRT), pause();
b_close(&gf_file);
pid_t gftopk = fork();
if (gftopk == -1) kill(getpid(), SIGABRT), pause();
if (gftopk == 0) {
  signal(SIGINT, SIG_IGN);
  execl("/bin/gftopk", "gftopk", fname, (char *) NULL);
  exit(1);
}
int wstatus;
waitpid(gftopk, &wstatus, 0);
if (WEXITSTATUS(wstatus) != 0) kill(getpid(), SIGABRT), pause();
@z
