#ifndef __SDRAM_BUFFER_H__
#define __SDRAM_BUFFER_H__

#define BANKS 4
#define ROWS 8192
#define COLS 256
#define BANK_SIZE (ROWS*COLS) // 0x200000
#define BANK_MASK ((ROWS*COLS) -1) // 0x1ffff
#define ROW_MASK (ROWS - 1) // assuming BANK_SIZE will be power of 2, but will need offset 0x1fff
#define COL_MASK (COLS - 1) //

// 256 = 0x100.
#define FIFO_SIZE 1024



#ifdef __XC__
void sdram_send_data (streaming chanend c_lcd, chanend c_lcd_fifo_ready) ;
void sdram_buffer (chanend c_sdram, chanend c_flash, chanend c_lcd_fifo_ready);
void sdram_store(chanend c_sdram, const unsigned data[], int size, int address);
void sdram_fetch_burst (chanend c_sdram, unsigned data[], int fifo_addr, int sdram_addr );

#else
void sdram_send_data (unsigned c_lcd, unsigned c_lcd_fifo_ready) ;
void sdram_buffer (unsigned c_sdram, unsigned c_flash, unsigned c_lcd_fifo_ready);
void sdram_store(unsigned c_sdram, const unsigned data[], int size, int address);
void sdram_fetch_burst (unsigned c_sdram, unsigned data[], int fifo_addr, int sdram_addr );

#endif

#endif
