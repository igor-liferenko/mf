#include <stdio.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <unistd.h>
int main(void)
{
    int fd = syscall(SYS_memfd_create, "shm", 0);
    if (fd == -1) return 1;

    size_t size = 1024*1024*1024; /* minimal */

//    int check = ftruncate(fd, size);
//    if (check == -1) return 1;
printf("%zu\n", sizeof (long));
    long pixel=1;
    for (int n = 0; n < size/8; n++)
      write(fd, &pixel, sizeof (long));

printf("done\n");fflush(stdout);
sleep(10);

    void *ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) return 1;
long *x1 = ptr;
*(x1+100)=14;
printf("%p\n",ptr);fflush(stdout);
sleep(10);
    void *ptr2 = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr2 == MAP_FAILED) return 1;
long *x2 = ptr2;
    printf("%p\n", ptr2);fflush(stdout);
printf("val2: %ld\n",*(x2+100));
sleep(10);
    return 0;
}
