@x
if (getenv("tfm")) assert(symlink("/", getenv("tfm")) == 0);
b_close(&tfm_file)
@y
b_close(&tfm_file)
@z
