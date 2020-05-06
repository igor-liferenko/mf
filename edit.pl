#!/usr/bin/perl -i -0777 -p
# add headers and purge bodies of functions
use Regexp::Common;
BEGIN { $bp = $RE{balanced}{-parens=>'{}'} }
s/^/#include <stdbool.h>\n#include <stdint.h>\n/;
s/(init_screen\(.*?\)).*?$bp/$1;/s;
s/(update_screen\(.*?\)).*?$bp/$1;/s;
s/(blank_rectangle\(.*?\)).*?$bp/$1;/s;
s/(paint_row\(.*?\)).*?$bp/$1;/s;
