#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <asm/io.h>

#include "address_map_arm.h"
#include "interrupt_ID.h"

static const unsigned char seg7[10] = {
  0x3F, 0x06, 0x5B, 0x4F, 0x66,
  0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

void* LW_virtual;
volatile int *LEDR_ptr, *KEY_ptr, *HEX3_HEX0_ptr;

irq_handler_t irq_handler(int irq, void* dev_id, struct pt_regs* regs) {
  if((*LEDR_ptr & 9) == 9) *LEDR_ptr ^= 9;
  else *LEDR_ptr += 1;

  *HEX3_HEX0_ptr = seg7[*LEDR_ptr & 0xF];

  printk(KERN_ERR "\e[?25l0\e[2J\e[HCurrent digit is \e[32m%d\e[0m\n",
         *LEDR_ptr & 0xF);

  *(KEY_ptr+3) = 0xF; // Clear EdgeCapture register   
  return (irq_handler_t)(IRQ_HANDLED);
}

static int __init init(void) {
  int value;

  LW_virtual = ioremap_nocache(LW_BRIDGE_BASE, LW_BRIDGE_SPAN);
  
  LEDR_ptr = (int*)(LW_virtual + LEDR_BASE);
  *LEDR_ptr = 0x200;


  HEX3_HEX0_ptr = (int*)(LW_virtual + HEX3_HEX0_BASE);
  *(HEX3_HEX0_ptr) = 0x7F;

  printk(KERN_ERR "\e[?25l0\e[2J\e[HCurrent digit is \e[32m0\e[0m\n");

  KEY_ptr = (int*)(LW_virtual + KEY_BASE);
  *(KEY_ptr+3) = 0xF; // Clear EdgeCapture register
  *(KEY_ptr+2) = 0xF; // Enable IRQ

  value = request_irq(KEY_IRQ, (irq_handler_t)(irq_handler), IRQF_SHARED,
                      "part3", (void*)(irq_handler));
  return value;
}

static void __exit cleanup(void) {
  free_irq(KEY_IRQ, (void*)(irq_handler));

  *LEDR_ptr = 0; // Turn off LEDs
  *HEX3_HEX0_ptr = 0; // Turn off HEX displays

  iounmap(LW_virtual);
}

module_init(init);
module_exit(cleanup);
