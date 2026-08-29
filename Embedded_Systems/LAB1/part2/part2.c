#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>

#include "address_map_arm.h"

int open_physical(int fd);
void close_physical(int fd);
void* map_physical(int fd, unsigned int base, unsigned int span);
int unmap_physical(void* virtual_base, unsigned int span);

#define SLEEP_TIME_NS 250000000

int main(void) {
  volatile int* LEDR_ptr;
  int fd = -1;
  void* LW_virtual;

  if ((fd = open_physical(fd)) == -1) return -1;
  
  if (!(LW_virtual = map_physical(fd, LW_BRIDGE_BASE, LW_BRIDGE_SPAN))) {
    return -1;
  }
  
  struct timespec req;
  req.tv_sec = 0;
  req.tv_nsec = SLEEP_TIME_NS;
  
  LEDR_ptr = (int*)(LW_virtual + LEDR_BASE);
  *LEDR_ptr = 1;  // Turn on first LED
  int iteration = 0;
  int sign = 0;

  while (1) {
    nanosleep(&req, NULL);
    if (!(++iteration % 10)) {
      iteration = 1;
      sign ^= 1;
    }

    if (!sign) *LEDR_ptr <<= 1;  
    else       *LEDR_ptr >>= 1;
  }

  return 0;
}


int open_physical(int fd) {
  if (fd != -1) return fd;

  if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
    printf("ERROR: Could not open \"/dev/mem\".\n");
    return -1;
  }
 
  return fd;
}

void close_physical(int fd) {
  close(fd);
}

void* map_physical(int fd, unsigned int base, unsigned int span) {
  void* virtual_base;
  
  virtual_base = mmap(NULL, span, (PROT_READ | PROT_WRITE), MAP_SHARED,
                      fd, base);
  if (virtual_base == MAP_FAILED) {
    printf("ERROR: mmap() failed.\n");
    close(fd);
    return (NULL);
  }

  return virtual_base;
}

int unmap_physical(void* virtual_base, unsigned int span) {
  if (munmap(virtual_base, span)) {
    printf("ERROR: munmap() failed.\n");
    return -1;
  }

  return 0;
}

