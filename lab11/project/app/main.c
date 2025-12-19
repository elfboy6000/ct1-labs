/* ------------------------------------------------------------------
 * --  _____       ______  _____                                    -
 * -- |_   _|     |  ____|/ ____|                                   -
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
 * --   | | | '_ \|  __|  \___ \   Zuercher Hochschule Winterthur   -
 * --  _| |_| | | | |____ ____) |  (University of Applied Sciences) -
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
 * ------------------------------------------------------------------
 * --
 * -- Project     : CT2 lab - Linking
 * --
 * -- $Id$
 * ------------------------------------------------------------------
 */


#include <stdint.h>

// add missing includes
/// STUDENTS: To be programmed

#include "toggle.h"
#include "read.h"


/// END: To be programmed

#define BUTTONS 0x60000210
#define T0      (1 << 0)

static uint8_t last = 0;

int main()
{
    while(1) {
        uint8_t buttons = read8(BUTTONS);
        uint8_t pressed_T0 = (~last & buttons) & T0;
        last = buttons;
        
        if (pressed_T0) {
            toggle();
        }
    }
}
