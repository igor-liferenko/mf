@x
b_close(&gf_file);
@y
char tmp[1000], fname[1000];
sprintf(tmp, "/proc/self/fd/%d", fileno(gf_file.f));
fname[readlink(tmp, fname, sizeof fname)] = 0;
b_close(&gf_file);
pid_t pid = fork();
if (pid == 0) execl("/bin/gftopk", "gftopk", fname, (char *) NULL), exit(1);
int wstatus; waitpid(pid, &wstatus, 0);
if (WIFSIGNALED(wstatus) || WEXITSTATUS(wstatus) != 0) kill(getpid(), SIGABRT), pause();
@z
