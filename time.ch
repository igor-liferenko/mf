@x
@h
@y
#include <time.h>
@h
@z

@x
{@+internal[time_of_day]=12*60*unity; /*minutes since midnight*/
internal[day]=4*unity; /*fourth day of the month*/
internal[month]=7*unity; /*seventh month of the year*/
internal[year]=1776*unity; /*Anno Domini*/
@y
{ time_t $ = time(NULL);
  struct tm *t = localtime(&$);

  internal[time_of_day] = (t->tm_hour * 60 + t->tm_min) * unity;
  internal[day] = t->tm_mday * unity;
  internal[month] = (t->tm_mon + 1) * unity;
  internal[year] = (t->tm_year + 1900) * unity;
@z
