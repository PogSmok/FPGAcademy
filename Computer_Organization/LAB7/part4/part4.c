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

#define DECIMAL_SIZE 10
const uint8_t DECIMAL_7_SEG_ENCODER[DECIMAL_SIZE] = {
  0x3F, 0x06, 0x5B, 0x4F, 0x66,
  0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

static void handler(void) __attribute__ ((interrupt ("machine")));
static void mtimer_ISR(void);

volatile uint32_t time = 0;

#define MACHINE_INTERRUPT_FLAG 0x8
#define MACHINE_TIMER_IRQ 0x80
void main(void) {
  int minutes, seconds, centiseconds;
  
  // Initialize machine timer to time 1 centisecond
  MACHINE_TIMER->mtime_lo = 0;
  MACHINE_TIMER->mtime_hi = 0;
  MACHINE_TIMER->mtimecmp_lo = 0x000F4240;  
  MACHINE_TIMER->mtimecmp_hi = 0;
  
  // enable interrupts for Machine Timer
  uint32_t mtvec_val = &handler;
  uint32_t mie_val   = MACHINE_TIMER_IRQ;
  __asm__ volatile ("csrci mstatus, %0" :: "i"(MACHINE_INTERRUPT_FLAG) : "memory"); // disable machine interrupts
  __asm__ volatile ("csrw  mtvec, %0"   :: "r"(mtvec_val)); // set trap address
  __asm__ volatile ("csrw  mie, %0"     :: "r"(mie_val));   // enable machine timer IRQs
  __asm__ volatile ("csrsi mstatus, %0" :: "i"(MACHINE_INTERRUPT_FLAG) : "memory"); // enable machine interrupts
  
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
    
    // minutes
    *HEX5_HEX4_PTR = (DECIMAL_7_SEG_ENCODER[minutes / 10] << 8) | DECIMAL_7_SEG_ENCODER[minutes % 10];
    // seconds
    *HEX3_HEX0_PTR = (DECIMAL_7_SEG_ENCODER[seconds / 10] << 24) | (DECIMAL_7_SEG_ENCODER[seconds % 10] << 16);
    // centiseconds
    *HEX3_HEX0_PTR |= (DECIMAL_7_SEG_ENCODER[centiseconds / 10] << 8) | (DECIMAL_7_SEG_ENCODER[centiseconds % 10]);
  }
}

#define MCAUSE_MACHINE_TIMER_IRQ 0x80000007
static void handler(void) {
  uint32_t mcause_val;
  __asm__ volatile ("csrr %0, mcause" : "=r"(mcause_val));
  if(mcause_val == MCAUSE_MACHINE_TIMER_IRQ) mtimer_ISR();
}

// Number of centiseconds in an hour
#define HOUR_CENTISECONDS 360000
static void mtimer_ISR(void) {
  time++;
  // Overflow 59:59:99 to 00:00:00
  if(time == HOUR_CENTISECONDS) time = 0;
    
  // Restart machine timer
  MACHINE_TIMER->mtime_lo = 0;
  MACHINE_TIMER->mtime_hi = 0;
}