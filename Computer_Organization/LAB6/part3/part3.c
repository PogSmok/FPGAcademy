#include <stdint.h>

#define HEX_3_0_BASE (0xFF200020)
#define HEX_5_4_BASE (0xFF200030) 

#define NUM_SIZE 11
const uint32_t TEST_NUM[NUM_SIZE] = {
  0x0000e000, 0x3fabedef, 0x00000001, 0x00000002, 0x75a5a5a5,
  0x01ffC000, 0x03ffC000, 0x55555555, 0x77777777, 0x08888888,
  0x00000000
};

#define DECIMAL_SIZE 10
const uint8_t DECIMAL_7_SEG_ENCODER[DECIMAL_SIZE] = {
  0x3F, 0x06, 0x5B, 0x4F, 0x66,
  0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

// Function returns the longest string of
// consecutive 1s in num
uint8_t longest_ones(uint32_t num) {
  uint8_t longest = 0;
  while(num != 0) {
    num &= num >> 1;
    longest++;
  }
  return longest;
}

// Function returns the longest string of
// consecutive 0s in num
uint8_t longest_zeroes(uint32_t num) {
  return longest_ones(~num);
}

// Function returns the longest string of
// alternating 1s and 0s in num
uint8_t longest_alternating(uint32_t num) {
  return longest_ones(num ^ (num >> 1));
}

void main(void) {
  uint8_t ones = 0, zeroes = 0, alternating = 0;
  for(unsigned char i = 0; i < NUM_SIZE; i++) {
    int temp;
    temp = longest_ones(TEST_NUM[i]);
    if(temp > ones) ones = temp;
    temp = longest_zeroes(TEST_NUM[i]);
    if(temp > zeroes) zeroes = temp;
    temp = longest_alternating(TEST_NUM[i]);
    if(temp > alternating) alternating = temp;
  }
  
  volatile uint32_t* const hex_3_0_base = (uint32_t*)HEX_3_0_BASE;
  volatile uint32_t* const hex_5_4_base = (uint32_t*)HEX_5_4_BASE;
  
  // Write ones to HEX1-0
  *hex_3_0_base = 0xFFFFFFFF; // Turn off all segments
  *hex_3_0_base = DECIMAL_7_SEG_ENCODER[ones % 10];
  *hex_3_0_base |= DECIMAL_7_SEG_ENCODER[ones / 10] << 8;
  
  // Write zeroes to HEX3-2
  *hex_3_0_base |= DECIMAL_7_SEG_ENCODER[zeroes % 10] << 16;
  *hex_3_0_base |= DECIMAL_7_SEG_ENCODER[zeroes / 10] << 24;
  
  // Write alternating to HEX5-4
  *hex_5_4_base = 0xFFFFFFFF; // Turn off all segments
  *hex_5_4_base = DECIMAL_7_SEG_ENCODER[alternating % 10];
  *hex_5_4_base |= DECIMAL_7_SEG_ENCODER[alternating / 10] << 8;
  
  while(1) {
    ;
  }
}