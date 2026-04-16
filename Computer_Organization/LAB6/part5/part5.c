#include <stdint.h>

#define TO_PTR(ADDR) (volatile uint32_t*)(ADDR) 

#define HEX3_HEX0_PTR (TO_PTR(0xFF200020))
#define HEX5_HEX4_PTR (TO_PTR(0xFF200030))

#define KEY_EDGE_PTR  (TO_PTR(0xFF20005C))

typedef struct __attribute__((packed)) {
  volatile uint32_t mtime_lo;
  volatile uint32_t mtime_hi;
  volatile uint32_t mtimecmp_lo;
  volatile uint32_t mtimecmp_hi;
} mtime_t;
#define MACHINE_TIMER ((volatile mtime_t*)0xFF202100)

#define MESSAGE_LEN 13
const uint8_t message[MESSAGE_LEN + 1] = "dE1-SoC      ";

static uint8_t char_7_seg_decoder(uint8_t c) {
  switch(c) {
  case 'd': return 0x5E;
  case 'E': return 0x79;
  case '1': return 0x06;
  case '-': return 0x40;
  case 'S': return 0x6D;
  case 'o': return 0x5C;
  case 'C': return 0x39;
  case ' ': return 0x00;
  }

  return 0x00;
} 

void main(void) {
  // Initialize machine timer
  MACHINE_TIMER->mtime_lo = 0;  
  MACHINE_TIMER->mtime_hi = 0;
  MACHINE_TIMER->mtimecmp_lo = 0x2FFFFFF;
  MACHINE_TIMER->mtimecmp_hi = 0;
  
  // Index to character displayed at HEX5 (left-most display)
  int idx = 0;
  
  while(1) {
    // If button was pressed stop the clock
    if(*KEY_EDGE_PTR != 0) {
      *KEY_EDGE_PTR = 0xFFFFFFFF;
      // Wait for button press to resume the clock
      while(*KEY_EDGE_PTR == 0) {
        ;
      }
      *KEY_EDGE_PTR = 0xFFFFFFFF;
    }
    
    *HEX5_HEX4_PTR =  char_7_seg_decoder(message[idx % MESSAGE_LEN]) << 8;
    *HEX5_HEX4_PTR |= char_7_seg_decoder(message[(idx+1) % MESSAGE_LEN]);
    *HEX3_HEX0_PTR =  char_7_seg_decoder(message[(idx+2) % MESSAGE_LEN]) << 24;
    *HEX3_HEX0_PTR |= char_7_seg_decoder(message[(idx+3) % MESSAGE_LEN]) << 16;
    *HEX3_HEX0_PTR |= char_7_seg_decoder(message[(idx+4) % MESSAGE_LEN]) << 8;
    *HEX3_HEX0_PTR |= char_7_seg_decoder(message[(idx+5) % MESSAGE_LEN]);
    idx = (idx + 1) % MESSAGE_LEN;
    
    // Exercise specifically expects busy-wait loop instead of interrupt routine
    while(MACHINE_TIMER->mtime_hi == 0 && MACHINE_TIMER->mtime_lo < MACHINE_TIMER->mtimecmp_lo) {
      ;
    }
    
    // Restart the timer
    MACHINE_TIMER->mtime_lo = 0;
    MACHINE_TIMER->mtime_hi = 0;
  }
}