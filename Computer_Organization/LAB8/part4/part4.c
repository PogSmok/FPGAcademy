#include <stdlib.h>
#include <time.h>

#define COLUMN_SIZE 320
#define ROW_SIZE    240
#define BUFFER_SIZE 122688 // number of short ints

#define SWITCH_BASE   0xFF200040
#define KEY_BASE      0xFF200050
#define MTIME_BASE    0xFF202100

#define TO_PTR(addr) (volatile uint32_t*)((addr))
#define SWITCH_PORT_PTR (TO_PTR(SWITCH_BASE))
typedef struct __attribute__((packed)) {
  volatile uint32_t data;
           uint32_t _reserved;
  volatile uint32_t interruptmask;
  volatile uint32_t edgecapture;
} keyreg_t;
#define KEY_REGISTER ((keyreg_t*)KEY_BASE)

typedef struct __attribute__((packed)) {
  volatile uint32_t mtime_lo;
  volatile uint32_t mtime_hi;
  volatile uint32_t mtimecmp_lo;
  volatile uint32_t mtimecmp_hi;
} mtime_t;
#define MACHINE_TIMER ((volatile mtime_t*)MTIME_BASE)

volatile int* pixel_ctrl_ptr = (int *)0xFF203020;
volatile int  pixel_buffer_start;
short int SDRAM_back_buffer[BUFFER_SIZE]; // space for pixel buffer

typedef struct {
  short int x_cord;
  short int y_cord;
  signed char x_step;
  signed char y_step;
} Box;
#define BOX_MAX_COUNT 40
Box box_arr[BOX_MAX_COUNT];
#define BOX_STARTING_COUNT 20
char box_current_count = BOX_STARTING_COUNT; // Number of boxes in currently generated frame
volatile char box_next_count = BOX_STARTING_COUNT; // Number of boxes next frame

#define BLACK 0x0000
#define CYAN  0x07FF
#define PINK  0xF81F

static void handler(void) __attribute__ ((interrupt ("machine")));
static void set_KEY(void);
static void KEY_ISR(void);
static void wait_for_vsync(void);
static void clear_screen(void);
static void draw_line(int x0, int y0, int x1, int y1, short int color);
static void plot_pixel(int x, int y, short int line_color);
void swap(int* a, int* b) {
  *a ^= *b;
  *b ^= *a;
  *a ^= *b;
}

#define MACHINE_INTERRUPT_FLAG 0x8
#define KEY_IRQ 0x40000
int main(void) {
  srand(time(NULL)); // initialize seed
  for (int i = 0; i < BOX_MAX_COUNT; i++) {
    box_arr[i].x_cord = rand() % COLUMN_SIZE;
    box_arr[i].y_cord = rand() % ROW_SIZE;
    box_arr[i].x_step = (rand() % 3) - 1;
    box_arr[i].y_step = (rand() % 3) - 1;
  }

  // set location of the front pixel buffer
  *(pixel_ctrl_ptr + 1) = 0x08000000; // FPGA on-chip memory
  // now, swap the back/front buffers to set the front buffer
  wait_for_vsync();

  // set pointer to pixel buffer, used by drawing functions
  pixel_buffer_start = *pixel_ctrl_ptr;
  clear_screen(); // uses pixel_buffer_start

  // set location of back buffer 
  *(pixel_ctrl_ptr + 1) = SDRAM_back_buffer;  // location in SDRAM memory
  pixel_buffer_start = *(pixel_ctrl_ptr + 1); // draw on the back buffer
  
  // initialize machine timer to 60Hz
  MACHINE_TIMER->mtimecmp_lo = 0x0196E6B;
  MACHINE_TIMER->mtimecmp_hi = 0;
  
  // enable interrupts KEY port
  set_KEY(); 
  uint32_t mtvec_val = &handler;
  uint32_t mie_val   = KEY_IRQ;
  __asm__ volatile ("csrci mstatus, %0" :: "i"(MACHINE_INTERRUPT_FLAG) : "memory"); // disable machine interrupts
  __asm__ volatile ("csrw  mtvec, %0"   :: "r"(mtvec_val)); // set trap address
  __asm__ volatile ("csrw  mie, %0"     :: "r"(mie_val));   // enable key IRQs 
  __asm__ volatile ("csrsi mstatus, %0" :: "i"(MACHINE_INTERRUPT_FLAG) : "memory"); // enable machine interrupts

  while (1) {
    // start the timer
    MACHINE_TIMER->mtime_lo = 0;
    MACHINE_TIMER->mtime_hi = 0;
  
    // erase previous connections
    clear_screen(); 
    
    // update box count
    box_current_count = box_next_count;
    
    // move boxes
    for (int i = 0; i < box_current_count; i++) {
      // bounce logic
      if (box_arr[i].x_cord + box_arr[i].x_step < 1 ||
          box_arr[i].x_cord + box_arr[i].x_step >= COLUMN_SIZE-1) {
        box_arr[i].x_step = -box_arr[i].x_step;
      }
  
      if (box_arr[i].y_cord + box_arr[i].y_step < 1 ||
        box_arr[i].y_cord + box_arr[i].y_step >= ROW_SIZE-1) {
        box_arr[i].y_step = -box_arr[i].y_step;
      }
    
      box_arr[i].x_cord += box_arr[i].x_step;
      box_arr[i].y_cord += box_arr[i].y_step;
    }
    
    // draw new connections only if all sliders are off
    if ((*SWITCH_PORT_PTR & 0x3FF) == 0) {
      for (int i = 0; i < box_current_count; i++) {
        draw_line(box_arr[i].x_cord, box_arr[i].y_cord,
          box_arr[(i + 1) % box_current_count].x_cord, box_arr[(i + 1) % box_current_count].y_cord,
          PINK);
      }
    }
    
    // draw boxes 3x3 pixels
    for (int i = 0; i < box_current_count; i++) {
      for (int j = -1; j <= 1; j++) {
        plot_pixel(box_arr[i].x_cord + j, box_arr[i].y_cord - 1, CYAN);
        plot_pixel(box_arr[i].x_cord + j, box_arr[i].y_cord    , CYAN);
        plot_pixel(box_arr[i].x_cord + j, box_arr[i].y_cord + 1, CYAN);
      }
    }
    
    // wait for timer to finish
    while(MACHINE_TIMER->mtime_hi == 0 && MACHINE_TIMER->mtime_lo < MACHINE_TIMER->mtimecmp_lo) {
      ;
    }
    
    wait_for_vsync(); // swap back/front buffers on VGA sync
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // update pointer
  }
}

// Trap handler
#define MCAUSE_KEY_IRQ 0x80000012
static void handler (void) {
  uint32_t mcause_val;
  __asm__ volatile ("csrr %0, mcause" : "=r"(mcause_val));
  
  if(mcause_val == MCAUSE_KEY_IRQ)      KEY_ISR();
}

#define KEY0 1
#define KEY1 2
#define KEY2 4
#define KEY3 8
volatile int speed = 0; // 0 = normal (60Hz), positive = faster, negative = slower
static void KEY_ISR(void) {
  int val = KEY_REGISTER->edgecapture;
  KEY_REGISTER->edgecapture = 0xFFFFFFFF; // clear interrupt
  
  if (val & KEY0) {
      if (speed > 3) return;
      if (speed >= 0) {
          for (int i = 0; i < BOX_MAX_COUNT; i++) {
              box_arr[i].x_step *= 2;
              box_arr[i].y_step *= 2;
          }
      } else {
          // halve the timer period
          uint64_t period = ((uint64_t)MACHINE_TIMER->mtimecmp_hi << 32) | MACHINE_TIMER->mtimecmp_lo;
          period >>= 1;
          MACHINE_TIMER->mtimecmp_lo = period & 0xFFFFFFFF;
          MACHINE_TIMER->mtimecmp_hi = (period >> 32) & 0xFFFFFFFF;
      }
      speed++;
  } else if (val & KEY1) {
      if (speed < -3) return;
      if (speed > 0) {
          for (int i = 0; i < BOX_MAX_COUNT; i++) {
              box_arr[i].x_step /= 2;
              box_arr[i].y_step /= 2;
          }
      } else {
          // double the timer period
          uint64_t period = ((uint64_t)MACHINE_TIMER->mtimecmp_hi << 32) | MACHINE_TIMER->mtimecmp_lo;
          period <<= 1;
          MACHINE_TIMER->mtimecmp_lo = period & 0xFFFFFFFF;
          MACHINE_TIMER->mtimecmp_hi = (period >> 32) & 0xFFFFFFFF;
      }
      speed--;
  } else if (val & KEY2) {
    if (box_next_count < BOX_MAX_COUNT) box_next_count++;
  } else if (val & KEY3){
    if (box_next_count > 0) box_next_count--;
  }
}

static void wait_for_vsync(void) {
  *pixel_ctrl_ptr = 1;
  while (*(pixel_ctrl_ptr + 3) & 1);
}

static void clear_screen(void) {
  for (int i = 0; i < ROW_SIZE; i++) {
    for (int j = 0; j <  COLUMN_SIZE; j++) {
      plot_pixel(j, i, BLACK);
    }
  }
}

static void draw_line(int x0, int y0, int x1, int y1, short int color) {
  char is_steep = abs(y1 - y0) > abs(x1 - x0);
  if (is_steep) {
    swap(&x0, &y0);
    swap(&x1, &y1);
  } 
  
  if (x0 > x1) {
    swap(&x0, &x1);
    swap(&y0, &y1);
  }

  int deltax = x1 - x0;
  int deltay = abs(y1 - y0);
  int error = -(deltax/2);
  int y = y0;
  int y_step = 1;
  if (y0 >= y1) y_step = -1;
  
  for (int x = x0; x <= x1; x++) {
    if (is_steep) plot_pixel(y, x, color);
    else plot_pixel(x, y, color);
    
    error += deltay;
    if (error >= 0) {
      y += y_step;
      error -= deltax;
    }
  }
}

static void plot_pixel(int x, int y, short int line_color) {
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

static void set_KEY(void) {
  KEY_REGISTER->edgecapture   = 0xFFFFFFFF; // clear edgecapture register
  KEY_REGISTER->interruptmask = 0xFFFFFFFF; // enable interrupts for all KEYs
}