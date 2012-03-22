/**
 *
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2012
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
 **/
#include <xs1.h>
#include <platform.h>
#include <stdlib.h>
#include <print.h>
#include "sdram_burst.h"
#include "lcd.h"
#include "flash_image_load.h"
#include "sdram_buffer.h"


int main()
{
  chan c_sdram, c_flash, c_flash_done, c_sdram_lcd, c_sdram_loaded, c_lcd_fifo_ready;
  streaming chan c_lcd;

#define SD_CORE 1
#define FLASH_CORE 0
#define LCD_CORE 3

  par
  {
    // SDRAM has 3 threads.
    // server is physical interface
    // Buffer acts as the server client and interface for flash.
    // sdram_send_data reads from the fifo populated by buffer and sends to LCD
    on stdcore[SD_CORE] : sdram_server(c_sdram);
    on stdcore[SD_CORE]: sdram_buffer(c_sdram, c_flash, c_lcd_fifo_ready);
    on stdcore [SD_CORE]: sdram_send_data(c_lcd, c_lcd_fifo_ready);

    // Basic LCD driver.
    on stdcore[LCD_CORE] : LCD_driver(c_lcd, c_flash_done);

    // Basic flash reader.
    on stdcore[FLASH_CORE] : flash_image_load(c_flash, c_flash_done);

  }
  return 0;
}
