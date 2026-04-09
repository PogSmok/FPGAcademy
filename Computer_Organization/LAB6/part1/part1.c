#include <stdio.h>

#define LIST_SIZE 8
const unsigned char LIST[LIST_SIZE] = {7, 4, 5, 3, 6, 1, 8, 2};

void main() {
  unsigned char max_val = 0;
  for(unsigned char i = 0; i < LIST_SIZE; i++) {
    if(max_val < LIST[i]) max_val = LIST[i];
  }
  
  printf("Maximum value is: %d\n", max_val);
  
  while(1) {
  ;
  }
}