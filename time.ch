@x
@h
@y
#include <time.h>
@h
@z

@x
{@+internal[internal_time]=12*60*unity; /*minutes since midnight*/
internal[day]=4*unity; /*fourth day of the month*/
internal[month]=7*unity; /*seventh month of the year*/
internal[year]=1776*unity; /*Anno Domini*/
@y
{ time_t timestamp = time(NULL);
  struct tm *tm = localtime(&timestamp);

  internal[internal_time] = (tm->tm_hour * 60 + tm->tm_min) * unity;
  internal[day] = tm->tm_mday * unity;
  internal[month] = (tm->tm_mon + 1) * unity;
  internal[year] = (tm->tm_year + 1900) * unity;
@z
