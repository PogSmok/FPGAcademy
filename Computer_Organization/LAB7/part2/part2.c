#include <stdint.h>

#define LEDR_BASE  0xFF200000
#define MTIME_BASE 0xFF202100
#define KEY_BASE   0xFF200050

#define TO_PTR(addr) ((volatile uint32_t*)(addr))
#define LEDR_PTR TO_PTR(LEDR_BASE)

typedef struct __attribute__ ((packed)) {
  volatile uint32_t mtime_lo;
  volatile uint32_t mtime_hi;
  volatile uint32_t mtcmp_lo;
  volatile uint32_t mtcmp_hi;
} mtime_t;
#define MACHINE_TIMER ((mtime_t*)(MTIME_BASE))

typedef struct __attribute__ ((packed)) {
  volatile uint32_t data;
           uint32_t _reserved;
  volatile uint32_t interruptmask;
  volatile uint32_t edgecapture;
} key_t;
#define KEY_REGISTER ((key_t*)(KEY_BASE))

static void handler(void) __attribute__ ((interrupt ("machine")));
void set_mtimer(void);
void set_KEY(void);
void mtimer_ISR(void);
void KEY_ISR(void);

volatile uint32_t counter = 0; // binary counter to be displayed
volatile uint8_t  run     = 1; // the amount to be added

// Program that displays a binary counter on LEDR using interrupts
#define MACHINE_INTERRUPT_FLAG 0x8
#define MACHINE_TIMER_IRQ 0x80
#define KEY_IRQ           0x40000
int main(void) {
    set_mtimer();
    set_KEY();

    // enable interrupts for Machine Timer and KEY port
    uint32_t mtvec_val = &handler;
    uint32_t mie_val   = MACHINE_TIMER_IRQ | KEY_IRQ;
    __asm__ volatile ("csrci mstatus, %0" :: "i"(MACHINE_INTERRUPT_FLAG) : "memory"); // disable machine interrupts
    __asm__ volatile ("csrw  mtvec, %0"   :: "r"(mtvec_val)); // set trap address
    __asm__ volatile ("csrw  mie, %0"     :: "r"(mie_val));   // enable machine timer and key IRQs 
    __asm__ volatile ("csrsi mstatus, %0" :: "i"(MACHINE_INTERRUPT_FLAG) : "memory"); // enable machine interrupts

    while (1) {
        *LEDR_PTR = counter;
    }
}

// Trap handler
#define MCAUSE_MACHINE_TIMER_IRQ 0x80000007
#define MCAUSE_KEY_IRQ           0x80000012
void handler (void) {
  uint32_t mcause_val;
  __asm__ volatile ("csrr %0, mcause" : "=r"(mcause_val));
  
  if(mcause_val == MCAUSE_MACHINE_TIMER_IRQ) mtimer_ISR();
  else if(mcause_val == MCAUSE_KEY_IRQ)      KEY_ISR();
}

void mtimer_ISR(void) {
  counter += run;
  MACHINE_TIMER->mtime_lo = 0;
  MACHINE_TIMER->mtime_hi = 0;
}

void KEY_ISR(void) {
  run ^= 1;
  KEY_REGISTER->edgecapture = 0xFFFFFFFF; // clear interrupt
}

#define QUARTER_SECOND 0x017D7840 // number of 100MHz cycles in quarter of a second
void set_mtimer(void) {
  MACHINE_TIMER->mtime_lo = 0;
  MACHINE_TIMER->mtime_hi = 0;
  MACHINE_TIMER->mtcmp_lo = QUARTER_SECOND;
  MACHINE_TIMER->mtcmp_hi = 0;
}

void set_KEY(void) {
  KEY_REGISTER->edgecapture   = 0xFFFFFFFF; // clear edgecapture register
  KEY_REGISTER->interruptmask = 0xFFFFFFFF; // enable interrupts for all KEYs
}