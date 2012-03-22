/* SDRAM client thread. Manages refresh and interfacing between LCD and Flash threads */

#include <xs1.h>
#include "sdram_burst.h"
#include "lcd_defines.h"
#include "sdram_buffer.h"

#define FIFO_MASK 0x3ff

// Have a small (row size) buffer for reading from flash.
unsigned int flash_buf[LCD_WIDTH];

// Have a larger fifo for reading and sending to LCD.
unsigned int sdram_buf[FIFO_SIZE]; // 4k buffer. Flip between.
unsigned int wr_ptr = 0 ;
unsigned int rd_ptr = FIFO_SIZE - BURST; // Set to a higher value in the fifo to allow
// us to start populating it. This is set to 0 once the first burst has been stored into the fifo.

void init(chanend c)
{
  sdram_init(c);
  sdram_refresh(c);
}

void sdram_buffer (chanend c_sdram, chanend c_flash, chanend c_lcd_fifo_ready) {

  timer t_sdrefresh;
  unsigned refresh_time;
  unsigned flash_cmd, lcd_cmd;
  unsigned flash_buf_empty = 1, flash_buf_ctr = 0;
  unsigned sdram_address = 0;
  unsigned lcd_addr = 0;
  int i;
unsigned int fifo_valid = 0;

#ifdef LCD_565
 unsigned lcd_size = LCD_HEIGHT * LCD_WIDTH / 2; // If 565, fit 2 pixels per word
#else
  unsigned lcd_size = LCD_HEIGHT * LCD_WIDTH ; // Otherwise 1 pixel per word
#endif
  unsigned y0[256]; // temp array to wipe SDRAM at startup
  init(c_sdram);
  t_sdrefresh :> refresh_time;

  // Initialise SDRAM to a particular colour (could be zeroed)
  for (i=0; i< 256;i++) {
    y0[i]=LCD_BLUE;
  }
  for (int bank = 0; bank < 4; bank++)
  {
    for (int row = 0; row < 8192; row++)
    {
      sdram_write(c_sdram, bank, row, 0, y0, 256);
      sdram_refresh(c_sdram);
    }
  }

  // Main functional loop
  while (1){
    select {
    // Need a 7us timer to do sdram refresh
    // Needs to be every 7.8us. If we do every 7us then allows a bit of slack.
    case t_sdrefresh when timerafter (refresh_time+700)  :> refresh_time :
      sdram_refresh(c_sdram);
      break;
    case (flash_buf_empty) => c_flash :> flash_cmd:
      // Flash has read 1 row. Indicate we're ready then buffer data.
      c_flash <: 0;
      for (i = 0; i < (LCD_ROW_WORDS); i++) {
      c_flash :> flash_buf[i];
      }

      flash_buf_empty = 0;
      break;
    default:
      break;
    }

    // If buffered a row, write to flash. Need to track address?
    if(!flash_buf_empty) {
      sdram_refresh(c_sdram);
      sdram_store(c_sdram, flash_buf, LCD_ROW_WORDS, sdram_address);
      sdram_address += LCD_ROW_WORDS;
      flash_buf_ctr = 0;
      flash_buf_empty = 1; // everything written to SDRAM, ready for next row from flash
    }


    // Address needs to be managed separately from wr_ptr.
    // Needs to loop over LCD_SIZE, not fifo.

    // Set rd_ptr to last entry in fifo allow new ones in.
    // Once first valid data has been set, signal lcd_buffer thread and reset
    // rd_ptr to 0.

    if((wr_ptr & ~BURST_MASK) != (rd_ptr & ~BURST_MASK)) {
      // Burst should divide into fifo_size nicely so wrapping should be okay
      sdram_fetch_burst(c_sdram, sdram_buf, wr_ptr & FIFO_MASK, lcd_addr);
      wr_ptr += BURST;
      lcd_addr += BURST; // need to wrap on size of lcd?
      if (lcd_addr >= lcd_size) {
        lcd_addr = 0;
      }
      if (wr_ptr >= FIFO_SIZE - 1) {
        wr_ptr = 0;
      }
      // First time through indicate to lcd_buffer thread that fifo now has valid data
      if (!fifo_valid) {
        fifo_valid = 1;
        outuint(c_lcd_fifo_ready,1);
      }
    }


  }


}

