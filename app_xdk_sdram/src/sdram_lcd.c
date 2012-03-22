/* Need C to allow shared memory */
#include <xs1.h>
#include "sdram_buffer.h"
#include "lcd_defines.h"
#include <xccompat.h>
#include "sdram_burst.h"
#include <print.h>


// Shared memory for FIFO
extern unsigned int sdram_buf[FIFO_SIZE];
extern unsigned int rd_ptr;

#ifndef __XC__
// ASM because we don't have a language that supports both global memory AND channel
// operations.
#define outuint(a,b) {__asm__ __volatile__ ("out res[%0], %1": : "r" (a) , "r" (b));}
#define inuint_byref(a,b) {__asm__ __volatile__ ("in %0, res[%1]": "=r" (b) : "r" (a));}

#endif

void sdram_send_data (unsigned c_lcd, unsigned c_lcd_fifo_ready) {
  // This thread doesn't need a select - it can just wait on LCD requesting data.
  // Wait until the sdram_buffer thread indicates there is valid data in the fifo.
  // We then assume it can run ahead fast enough to always have valid data.
  unsigned int tmp, i;
  inuint_byref (c_lcd_fifo_ready, tmp);
  rd_ptr = 0;
  while (1) {
    inuint_byref(c_lcd, tmp);
    outuint(c_lcd,0);

#ifdef LCD_565
      if (( rd_ptr + (LCD_ROW_WORDS)) >= FIFO_SIZE) {
        // will wrap
        for (i = rd_ptr; i < FIFO_SIZE; i++) {
          outuint(c_lcd, sdram_buf[i]);
          outuint(c_lcd, sdram_buf[i] >> 16);
        }
        for (i=0 ; i < (rd_ptr+(LCD_ROW_WORDS)) - FIFO_SIZE; i++) {
          outuint(c_lcd,sdram_buf[i]);
          outuint(c_lcd,sdram_buf[i] >> 16);
        }
        rd_ptr = i;
      } else {
        //won't wrap
        for (i = 0; i < (LCD_ROW_WORDS) ; i++ ){
          outuint(c_lcd, sdram_buf[rd_ptr]);
          outuint(c_lcd, sdram_buf[rd_ptr++] >> 16);
        }
      }
#else
      if (( rd_ptr + (LCD_ROW_WORDS)) >= FIFO_SIZE) {
        // will wrap
        for (i = rd_ptr; i < FIFO_SIZE; i++) {
          outuint(c_lcd, sdram_buf[i]);
        }
        for (i=0 ; i < (rd_ptr+(LCD_ROW_WORDS)) - FIFO_SIZE; i++) {
          outuint(c_lcd,sdram_buf[i]);
        }
        rd_ptr = i;
      } else {
        //won't wrap
        for (i = 0; i < (LCD_ROW_WORDS) ; i++ ){
          outuint(c_lcd, sdram_buf[rd_ptr++]);
        }
      }

#endif
      // There's an additional IN done on the LCD side as the first value is preloaded.
      outuint(c_lcd, sdram_buf[rd_ptr]);
  }

}

/* FUNCTIONS BELOW ARE CALLED FROM BUFFER THREAD, but need to be in C */

// Have write function in here as XC won't allow array offsets.
// More generic write function to abstract knowledge of columns/rows etc.
void sdram_store(unsigned c_sdram, const unsigned data[], int size, int address) {
  int bank, col, row ;
  int addr = address;
  int i;
  // Cheap nasty approach - write a word at a time.
  for (i = 0; i < size; i ++ ) {
  bank = addr  >> 21;
  row = (addr >> 8) & ROW_MASK ;
    col = addr & COL_MASK;
  addr ++;
#if 0
    printstrln("store to addr: bank: row: col");
    printint(address);
    printstr(" ");
    printint(bank);
    printstr(" ");
    printint(row);
    printstr(" ");
    printintln(col);
#endif
    sdram_write(c_sdram, bank, row, col, data+i, 1);
    sdram_refresh(c_sdram);
  }
}

// Read a burst from SDRam and store into LCD fifo.
void sdram_fetch_burst (chanend c_sdram, unsigned data[], int fifo_addr, int sdram_addr ){
  int bank, col, row ;
  bank = sdram_addr  >> 21;
  row = (sdram_addr >> 8) & ROW_MASK ;
    col = sdram_addr & COL_MASK;
  sdram_read(c_sdram, bank, row, col, data+fifo_addr, BURST);
  sdram_refresh(c_sdram);
}

