@x
b_close(&gf_file);
@y
char tmp[30];
if (snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(gf_file.f)) >= sizeof tmp)
  kill(getpid(), SIGABRT), pause();
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
int ws; waitpid(gftopk, &ws, 0); if (ws) kill(getpid(), SIGABRT), pause();
@z
