#include <stdint.h>

#define TO_PTR(ADDR) (volatile uint32_t*)(ADDR) 

#define HEX3_HEX0_PTR (TO_PTR(0xFF200020))
#define HEX5_HEX4_PTR (TO_PTR(0xFF200030))

#define KEY_EDGE_PTR  (TO_PTR(0xFF20005C))

typedef struct __attribute__((packed)) {
  volatile uint32_t status;
  volatile uint32_t control;
  volatile uint32_t countstart_lo;
  volatile uint32_t countstart_hi;
  volatile uint32_t countsnap_lo;
  volatile uint32_t countsnap_hi; 
} intervaltime_t;
#define INTERVAL_TIMER ((volatile intervaltime_t*)0xFF202000)

#define DECIMAL_SIZE 10
const uint8_t DECIMAL_7_SEG_ENCODER[DECIMAL_SIZE] = {
  0x3F, 0x06, 0x5B, 0x4F, 0x66,
  0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

// Number of centiseconds in an hour
#define HOUR_CENTISECONDS 360000

void main(void) {
  int minutes, seconds, centiseconds;
  int time = 0;
  
  // Initialize machine timer to time 1 centisecond
  INTERVAL_TIMER->countstart_lo = 0x4240;
  INTERVAL_TIMER->countstart_hi = 0x000F;
  INTERVAL_TIMER->control = 0x06; // START | CONT
  
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
    
    minutes = time / 100 / 60;
    seconds = time / 100 % 60;
    centiseconds = time % 100;
    time++;
    // Overflow 59:59:99 to 00:00:00
    if(time == HOUR_CENTISECONDS) time = 0;
    
    // minutes
    *HEX5_HEX4_PTR = (DECIMAL_7_SEG_ENCODER[minutes / 10] << 8) | DECIMAL_7_SEG_ENCODER[minutes % 10];
    // seconds
    *HEX3_HEX0_PTR = (DECIMAL_7_SEG_ENCODER[seconds / 10] << 24) | (DECIMAL_7_SEG_ENCODER[seconds % 10] << 16);
    // centiseconds
    *HEX3_HEX0_PTR |= (DECIMAL_7_SEG_ENCODER[centiseconds / 10] << 8) | (DECIMAL_7_SEG_ENCODER[centiseconds % 10]);
    
    // Wait until machine timer times 1 centisecond
    // Exercise specifically expects busy-wait loop instead of interrupt routine
    while((INTERVAL_TIMER->status & 1) == 0) {
      ;
    }
    
    // Restart the timeout flag
    INTERVAL_TIMER->status ^= 0x01;
  }
}