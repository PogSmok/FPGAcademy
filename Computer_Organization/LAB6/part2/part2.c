#include <stdint.h>

#define LIST_SIZE 8
const unsigned char LIST[LIST_SIZE] = {7, 4, 5, 3, 6, 1, 8, 2};

#define LEDR_BASE (0xFF200000)

void main() {
  unsigned char max_val = 0;
  for(unsigned char i = 0; i < LIST_SIZE; i++) {
    if(max_val < LIST[i]) max_val = LIST[i];
  }
  
  volatile uint32_t *pLEDR = (uint32_t *)LEDR_BASE;
  *pLEDR = (uint32_t)max_val;
  
  while(1) {
  ;
  }
}