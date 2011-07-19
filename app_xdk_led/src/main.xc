/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate an LED on the XDK board 
 ============================================================================
 */

#include <platform.h>

out port led = PORT_LED_0_1;

int main (void){
  led <: 0;
  while (1)
    ;
  return 0;
}
