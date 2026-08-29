#include <stdint.h>
#include <time.h>

#include "address_map_arm.h"
#include "physical.h"

#define SLEEP_TIME_NS 500000000

#define TEXT_SIZE 20
static const uint8_t seg7[TEXT_SIZE] = {
  0x06, 0x54, 0x78, 0x79, 0x38, 0x00,
  0x6D, 0x5C, 0x39, 0x00, 0x71, 0x73,
  0x3D, 0x77, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00
};

int main(void) {
  volatile uint32_t* HEX3_HEX0_ptr;
  volatile uint32_t* HEX5_HEX4_ptr;
  volatile uint32_t* KEY_EDGE_ptr;
  void* LW_virtual;

  int fd = -1;
  if ((fd = open_physical(fd)) == -1) return -1;

  if (!(LW_virtual = map_physical(fd, LW_BRIDGE_BASE, LW_BRIDGE_SPAN))) {
    close_physical(fd);
    return -1;
  }

  HEX3_HEX0_ptr = (volatile uint32_t*)(LW_virtual + HEX3_HEX0_BASE);
  HEX5_HEX4_ptr = (volatile uint32_t*)(LW_virtual + HEX5_HEX4_BASE);
  KEY_EDGE_ptr  = (volatile uint32_t*)(LW_virtual + KEY_BASE + 0xC);
  // Clear edgecapture register
  *KEY_EDGE_ptr = *KEY_EDGE_ptr;

  struct timespec req;
  req.tv_sec = 0;
  req.tv_nsec = SLEEP_TIME_NS;

  uint8_t iterator = 0;
  uint8_t paused = 0;
  while (1) {
    // PAUSE/RUN if KEY0 is pressed
    if ((*KEY_EDGE_ptr & 1) != 0) {
      paused ^= 1;
      *KEY_EDGE_ptr = *KEY_EDGE_ptr;
    }

    if (paused) continue;

    nanosleep(&req, NULL);
    *HEX3_HEX0_ptr = ((uint32_t)seg7[(iterator+2) % TEXT_SIZE] << 24) |
                     ((uint32_t)seg7[(iterator+3) % TEXT_SIZE] << 16) |
                     ((uint32_t)seg7[(iterator+4) % TEXT_SIZE] <<  8) |
                      (uint32_t)seg7[(iterator+5) % TEXT_SIZE];

    *HEX5_HEX4_ptr = ((uint32_t)seg7[iterator] << 8) |
                     ((uint32_t)seg7[(iterator+1) % TEXT_SIZE]);

    iterator = (iterator+1) % TEXT_SIZE;
  }

  return 0;
}
