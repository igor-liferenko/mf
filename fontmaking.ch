Determine if TFM file was created.

@x
if (getenv("tfm")) assert(fclose(fopen(getenv("tfm"), "w")) == 0);
b_close(&tfm_file)
@y
b_close(&tfm_file)
@z
