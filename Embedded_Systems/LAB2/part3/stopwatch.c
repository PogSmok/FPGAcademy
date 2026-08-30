#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include <linux/spinlock.h>

#include "address_map_arm.h"
#include "interrupt_ID.h"

static const uint8_t seg7[10] = {
  0x3F, 0x06, 0x5B, 0x4F, 0x66,
  0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

#define TIMER0_COUNTER_100_HZ_LO (0x00004240)
#define TIMER0_COUNTER_100_HZ_HI (0x0000000F)
typedef struct __attribute__((__packed__)) {
	uint32_t status_register;
	uint32_t control_register;
	uint32_t counter_start_lo;
	uint32_t counter_start_hi;
	uint32_t counter_snapshot_lo;
	uint32_t counter_snapshot_hi;
} timer0_t;

typedef struct __attribute__((__packed__)) {
  uint32_t data;
  uint32_t reserved;
  uint32_t interrupt_mask;
  uint32_t edgecapture_register;
} key_reg_t;

static void* LW_virtual;
static volatile timer0_t*  TIMER0_ptr;
static volatile uint32_t*  HEX3_HEX0_ptr;
static volatile uint32_t*  HEX5_HEX4_ptr;
static volatile uint32_t*  SW_ptr;
static volatile key_reg_t* KEY_ptr;

static volatile uint32_t local_time;

#define CENTISECONDS_IN_MINUTE (6000)
#define CENTISECONDS_IN_SECOND (100)

static void display_local_time(void) {
  uint32_t local_time_cpy;
  uint8_t minutes, seconds, centiseconds;
  
  local_time_cpy = local_time;
  minutes = local_time_cpy / CENTISECONDS_IN_MINUTE;
  local_time_cpy %= CENTISECONDS_IN_MINUTE;
  seconds = local_time_cpy / CENTISECONDS_IN_SECOND;
  local_time_cpy %= CENTISECONDS_IN_SECOND;
  centiseconds = local_time_cpy;
  
  *HEX3_HEX0_ptr = (seg7[seconds/10] << 24)     | (seg7[seconds%10] << 16) |
                   (seg7[centiseconds/10] << 8) | seg7[centiseconds%10];
  *HEX5_HEX4_ptr = (seg7[minutes/10] << 8) | seg7[minutes%10];
}

static DEFINE_SPINLOCK(local_time_lock);

static irqreturn_t irq_handler_timer0(int irq, void* dev_id) {
  unsigned long flags;
  TIMER0_ptr->status_register = 0;
  
  spin_lock_irqsave(&local_time_lock, flags);
  if (local_time != 0) local_time--;
  spin_unlock_irqrestore(&local_time_lock, flags);
  
  display_local_time();
  
  return IRQ_HANDLED;
}

static irqreturn_t irq_handler_key(int irq, void* dev_id) {
  uint32_t edgecapture;
  uint8_t  sw_val;
  uint32_t local_time_cpy;
  unsigned long flags;

  edgecapture = KEY_ptr->edgecapture_register;
  
  spin_lock_irqsave(&local_time_lock, flags);
  local_time_cpy = local_time;
   
  if (edgecapture & 0x1) {
    if (TIMER0_ptr->status_register & 0x2) {
      TIMER0_ptr->control_register = 0x8;
    } else {
      TIMER0_ptr->control_register = 0x7;
    }
  } else if (edgecapture & 0x2) {
    sw_val = *SW_ptr;
    if (sw_val > 99) sw_val = 99;
    local_time = local_time_cpy - (local_time_cpy % CENTISECONDS_IN_SECOND) + sw_val;
  } else if (edgecapture & 0x4) {
    sw_val = *SW_ptr;
    if (sw_val > 59) sw_val = 59;
    local_time_cpy %= CENTISECONDS_IN_MINUTE;
    local_time_cpy %= CENTISECONDS_IN_SECOND;
    local_time -= local_time % CENTISECONDS_IN_MINUTE;
    local_time += sw_val * CENTISECONDS_IN_SECOND + local_time_cpy;
  } else if (edgecapture & 0x8) {
    sw_val = *SW_ptr;
    if (sw_val > 59) sw_val = 59;
    local_time %= CENTISECONDS_IN_MINUTE;
    local_time += sw_val * CENTISECONDS_IN_MINUTE;
  }
  spin_unlock_irqrestore(&local_time_lock, flags);
  
  display_local_time();
  KEY_ptr->edgecapture_register = KEY_ptr->edgecapture_register;
  return IRQ_HANDLED;
}

static int __init init(void) {
  int value;

  LW_virtual = ioremap(LW_BRIDGE_BASE, LW_BRIDGE_SPAN);
  if (LW_virtual == NULL) return -ENOMEM;

  TIMER0_ptr = (volatile timer0_t*)(LW_virtual + TIMER0_BASE);
  HEX3_HEX0_ptr = (volatile uint32_t*)(LW_virtual + HEX3_HEX0_BASE);
  HEX5_HEX4_ptr = (volatile uint32_t*)(LW_virtual + HEX5_HEX4_BASE);
  SW_ptr = (volatile uint32_t*)(LW_virtual + SW_BASE);
  KEY_ptr = (volatile key_reg_t*)(LW_virtual + KEY_BASE);
  
  TIMER0_ptr->control_register = 0x8;
  TIMER0_ptr->counter_start_lo = TIMER0_COUNTER_100_HZ_LO;
  TIMER0_ptr->counter_start_hi = TIMER0_COUNTER_100_HZ_HI;
  
  KEY_ptr->edgecapture_register = 0xF;
  KEY_ptr->interrupt_mask = 0xF;
  
  // Start at 00:00:00
  local_time = 0;
  *HEX3_HEX0_ptr = (seg7[0] << 24) | (seg7[0] << 16) | (seg7[0] << 8) | seg7[0];
  *HEX5_HEX4_ptr = (seg7[0] << 8) | seg7[0];

  value = request_irq(TIMER0_IRQ, (irq_handler_t)(irq_handler_timer0), IRQF_SHARED,
                      "part3_timer0", (void*)(irq_handler_timer0));
  if (value != 0) {
    iounmap(LW_virtual);
    return value;
  }

  value = request_irq(KEY_IRQ, (irq_handler_t)(irq_handler_key), IRQF_SHARED,
                      "part3_key", (void*)(irq_handler_key));
  if (value != 0) {
    free_irq(TIMER0_IRQ, (void*)(irq_handler_timer0));
    iounmap(LW_virtual);
  }
  return value;
}

static void __exit cleanup(void) {
  free_irq(TIMER0_IRQ, (void*)(irq_handler_timer0));
  free_irq(KEY_IRQ, (void*)(irq_handler_key));

  // Turn off HEX displays
  *HEX3_HEX0_ptr = 0;
  *HEX5_HEX4_ptr = 0;

  iounmap(LW_virtual);
}

module_init(init);
module_exit(cleanup);