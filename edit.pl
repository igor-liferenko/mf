#!/usr/bin/perl -0777 -p
# purge bodies of functions
use Regexp::Common;
BEGIN { $bp = $RE{balanced}{-parens=>'{}'} }
s/(init_screen\(.*?\)).*?$bp/$1;/s;
s/(update_screen\(.*?\)).*?$bp/$1;/s;
s/(blank_rectangle\(.*?\)).*?$bp/$1;/s;
s/(paint_row\(.*?\)).*?$bp/$1;/s;
