/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Flash an LED on the XDK board 
 ============================================================================
 */

#include <platform.h>
#define FLASH_PERIOD 20000000

out port led = PORT_LED_0_1;

int main (void) {
    timer tmr;
    unsigned isOff = 1;
    unsigned t;
    tmr :> t;
    while (1) {
        led <: isOff;
        t += FLASH_PERIOD;
        tmr when timerafter (t) :> void;
        isOff = !isOff;
    }
    return 0;
}
