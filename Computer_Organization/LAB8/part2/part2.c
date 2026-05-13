#include <stdlib.h>

volatile int pixel_buffer_start; // global variable

#define COLUMN_SIZE 320
#define ROW_SIZE 240

#define BLACK 0x0000
#define GREEN 0x07E0

void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, short int color);
void plot_pixel(int x, int y, short int line_color);
void swap(int* a, int* b) {
  *a ^= *b;
  *b ^= *a;
  *a ^= *b;
}

int main(void) {
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // Read location of the pixel buffer from the pixel buffer controller
    pixel_buffer_start = *pixel_ctrl_ptr;
    // Set backbuffer to buffer
    *(pixel_ctrl_ptr+1) = pixel_buffer_start;
    
    int row = 0;
    int direction = 1;
    clear_screen();
    draw_line(0, row, COLUMN_SIZE-1, row, GREEN); // draw inital line
    *pixel_ctrl_ptr = 1; // render frame
    
    while(1) {
      while(*(pixel_ctrl_ptr+3) & 1); // wait for render to finish
      draw_line(0, row, COLUMN_SIZE-1, row, BLACK); // erase old line
      row += direction;
      draw_line(0, row, COLUMN_SIZE-1, row, GREEN); // draw new line
      
      if(row == 0 || row == ROW_SIZE-1) direction = -direction; // reverse direction
      *pixel_ctrl_ptr = 1; // render frame
    }
}

void clear_screen() {
  for (int i = 0; i < ROW_SIZE; i++) {
    for (int j = 0; j <  COLUMN_SIZE; j++) {
      plot_pixel(j, i, BLACK);
    }
  }
}

void draw_line(int x0, int y0, int x1, int y1, short int color) {
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

void plot_pixel(int x, int y, short int line_color) {
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}
