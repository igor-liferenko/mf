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
{ time_t timestamp = time(NULL);
  struct tm *tm = localtime(&timestamp);

  internal[17] = (tm->tm_hour * 60 + tm->tm_min) * unity;
  internal[day] = tm->tm_mday * unity;
  internal[month] = (tm->tm_mon + 1) * unity;
  internal[year] = (tm->tm_year + 1900) * unity;
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
