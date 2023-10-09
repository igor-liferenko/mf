@x
@h
@y
#include <unistd.h>
@h
@z

@x
b_close(&tfm_file)
@y
if (getenv("tfm")) assert(symlink("/", getenv("tfm")) == 0);
b_close(&tfm_file)
@z
