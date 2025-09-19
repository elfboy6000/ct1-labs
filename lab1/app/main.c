#include "utils_ctboard.h"

#define LED_ADDR		((uint32_t)0x60000100)
#define DIP_ADDR		((uint32_t)0x60000200)
#define ROT_ADDR 		((uint32_t)0x60000211)
#define SEG_ADDR		((uint32_t)0x60000110)

static const uint8_t SEG_VAL[16] = {
    /*0*/ 0xC0, /*1*/ 0xF9, /*2*/ 0xA4, /*3*/ 0xB0,
    /*4*/ 0x99, /*5*/ 0x92, /*6*/ 0x82, /*7*/ 0xF8,
    /*8*/ 0x80, /*9*/ 0x90, /*A*/ 0x88, /*b*/ 0x83,
    /*C*/ 0xC6, /*d*/ 0xA1, /*E*/ 0x86, /*F*/ 0x8E
};

int main(void) {
	/* initializations go here */
	while (1) {
		// Task 5.1
		uint32_t value = read_word(DIP_ADDR);
		write_word(LED_ADDR, value);
		
		// Task 5.2
		uint8_t rot_val = read_byte(ROT_ADDR) & 0x0F;
		uint8_t seg_val = SEG_VAL[rot_val];
		write_byte(SEG_ADDR, seg_val);
	}
}