#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <asm/io.h>

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

static void* LW_virtual;
static volatile timer0_t* TIMER0_ptr;
static volatile uint32_t* HEX3_HEX0_ptr;
static volatile uint32_t* HEX5_HEX4_ptr;

#define LOCAL_TIME_WRAPAROUND (0x00057E40) // 60:00:00
static volatile uint32_t local_time;

#define CENTISECONDS_IN_MINUTE (6000)
#define CENTISECONDS_IN_SECOND (100)

static irqreturn_t irq_handler(int irq, void* dev_id) {
  uint32_t local_time_cpy;
  uint8_t minutes, seconds, centiseconds;
  
  TIMER0_ptr->status_register = 0;
  
  local_time++;
  if (local_time >= LOCAL_TIME_WRAPAROUND) local_time = 0;
  
  local_time_cpy = local_time;
  minutes = local_time_cpy / CENTISECONDS_IN_MINUTE;
  local_time_cpy %= CENTISECONDS_IN_MINUTE;
  seconds = local_time_cpy / CENTISECONDS_IN_SECOND;
  local_time_cpy %= CENTISECONDS_IN_SECOND;
  centiseconds = local_time_cpy;
  
  *HEX3_HEX0_ptr = (seg7[seconds/10] << 24)     | (seg7[seconds%10] << 16) |
                   (seg7[centiseconds/10] << 8) | seg7[centiseconds%10];
  *HEX5_HEX4_ptr = (seg7[minutes/10] << 8) | seg7[minutes%10];
  
  return IRQ_HANDLED;
}

static int __init init(void) {
  int value;

  LW_virtual = ioremap(LW_BRIDGE_BASE, LW_BRIDGE_SPAN);

  TIMER0_ptr = (volatile timer0_t*)(LW_virtual + TIMER0_BASE);
  HEX3_HEX0_ptr = (volatile uint32_t*)(LW_virtual + HEX3_HEX0_BASE);
  HEX5_HEX4_ptr = (volatile uint32_t*)(LW_virtual + HEX5_HEX4_BASE);
  
  TIMER0_ptr->control_register = 0x8;
  TIMER0_ptr->counter_start_lo = TIMER0_COUNTER_100_HZ_LO;
  TIMER0_ptr->counter_start_hi = TIMER0_COUNTER_100_HZ_HI;
  TIMER0_ptr->control_register = 0x7;
  
  // Start at 00:00:00
  local_time = 0;
  *HEX3_HEX0_ptr = (seg7[0] << 24) | (seg7[0] << 16) | (seg7[0] << 8) | seg7[0];
  *HEX5_HEX4_ptr = (seg7[0] << 8) | seg7[0];

  value = request_irq(TIMER0_IRQ, (irq_handler_t)(irq_handler), IRQF_SHARED,
                      "part2", (void*)(irq_handler));
  return value;
}

static void __exit cleanup(void) {
  free_irq(TIMER0_IRQ, (void*)(irq_handler));

  // Turn off HEX displays
  *HEX3_HEX0_ptr = 0;
  *HEX5_HEX4_ptr = 0;

  iounmap(LW_virtual);
}

module_init(init);
module_exit(cleanup);