#include <stdlib.h>
#include <time.h>

#define COLUMN_SIZE 320
#define ROW_SIZE    240
#define BUFFER_SIZE 122688 // number of short ints

volatile int* pixel_ctrl_ptr = (int *)0xFF203020;
volatile int  pixel_buffer_start;
short int SDRAM_back_buffer[BUFFER_SIZE]; // space for pixel buffer

typedef struct {
  short int x_cord;
  short int y_cord;
  signed char x_step;
  signed char y_step;
} Box;
#define BOX_COUNT 20
Box box_arr[BOX_COUNT];

#define BLACK 0x0000
#define CYAN  0x07FF
#define PINK  0xF81F

static void wait_for_vsync(void);
static void clear_screen(void);
static void draw_line(int x0, int y0, int x1, int y1, short int color);
static void plot_pixel(int x, int y, short int line_color);
void swap(int* a, int* b) {
  *a ^= *b;
  *b ^= *a;
  *a ^= *b;
}

int main(void) {
  srand(time(NULL)); // initialize seed
  for(int i = 0; i < BOX_COUNT; i++) {
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

  while (1) {
    // erase previous connections
    clear_screen(); 
    
    // move boxes
    for(int i = 0; i < BOX_COUNT; i++) {
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
    
    // draw new connections
    for(int i = 0; i < BOX_COUNT; i++) {
      draw_line(box_arr[i].x_cord, box_arr[i].y_cord,
        box_arr[(i + 1) % BOX_COUNT].x_cord, box_arr[(i + 1) % BOX_COUNT].y_cord,
        PINK);
    }
    
    // draw boxes 3x3 pixels
    for(int i = 0; i < BOX_COUNT; i++) {
      for(int j = -1; j <= 1; j++) {
        plot_pixel(box_arr[i].x_cord + j, box_arr[i].y_cord - 1, CYAN);
        plot_pixel(box_arr[i].x_cord + j, box_arr[i].y_cord    , CYAN);
        plot_pixel(box_arr[i].x_cord + j, box_arr[i].y_cord + 1, CYAN);
      }
    }
    
    wait_for_vsync(); // swap back/front buffers on VGA sync
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // update pointer
  }
}

static void wait_for_vsync(void) {
  *pixel_ctrl_ptr = 1;
  while(*(pixel_ctrl_ptr+3) & 1);
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
