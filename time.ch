@x
@h
@y
#include <time.h>
@h
@z

@x
@d time	17 /*the number of minutes past midnight when this job started*/ 
@y
@z

@x
primitive(@[@<|"time"|@>@], internal_quantity, time);@/
@y
primitive(@[@<|"time"|@>@], internal_quantity, 17);@/
@z

@x
int_name[time]=@[@<|"time"|@>@];
@y
int_name[17]=@[@<|"time"|@>@];
@z

@x
{@+internal[time]=12*60*unity; /*minutes since midnight*/
internal[day]=4*unity; /*fourth day of the month*/
internal[month]=7*unity; /*seventh month of the year*/
internal[year]=1776*unity; /*Anno Domini*/
@y
{ time_t clock = time(NULL);
  struct tm *time = localtime(&clock);

  internal[17] = (time->tm_hour * 60 + time->tm_min) * unity;
  internal[day] = time->tm_mday * unity;
  internal[month] = (time->tm_mon + 1) * unity;
  internal[year] = (time->tm_year + 1900) * unity;
@z

@x
m=round_unscaled(internal[time]);
@y
m=round_unscaled(internal[17]);
@z

@x
t=round_unscaled(internal[time]);
@y
t=round_unscaled(internal[17]);
@z

@x
fix_date_and_time();init_randoms((internal[time]/unity)+internal[day]);@/
@y
fix_date_and_time();init_randoms((internal[17]/unity)+internal[day]);@/
@z
