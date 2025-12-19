#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

extern void out_word(uint32_t out_address, uint32_t out_value);
extern uint32_t in_word(uint32_t in_address);

#define ADDR_LED          0x60000100
#define ADDR_DIPSW        0x60000200

int main(void){

  while(true){
    // Read DIP Switch 
    uint32_t dip_Value = in_word(ADDR_DIPSW);
    
    // Output value
    out_word(ADDR_LED,dip_Value);  
  
  }
  return EXIT_SUCCESS;
}

