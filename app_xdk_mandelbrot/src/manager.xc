// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "mandelbrot_traphandler.h"
#include "lrsd_client.h"
#include "libtrap.h"
#include "lrsd_server.h"

unsigned targetsX[5]={
	0xF999999A ,//-0.8
	0x2450481 ,//0.2837
	0x2A9C77A ,//0.3329
	0xFE63B5B2 ,//-0.2013136
	0xF1C08312 ,//-1.7810
};

unsigned targetsY[5]={
	0x1333333 ,//0.15
	0xFC4AF4F1 ,//-0.4634
	0x82602D ,//0.06366
	0xF7318091 ,//-1.100829
	0x325 ,//0.000006
};

#define DEFAULT_RANGE 0x20000000
#define MAX_RANGE 0x00400000
#define NUM_TARGETS 5
#define PAUSE_TIME 100000000
#define MAX_ITERATIONS 100
#define HOME_BUTTON 4 

unsigned range=DEFAULT_RANGE; //4
unsigned targetindex=0;

void farmOut(unsigned x, unsigned y, chanend c)
{
	unsigned xleft,yleft;
	if (range == DEFAULT_RANGE)
	{
		xleft=0xF0000000; //-2
		yleft=0xF0000000; //-2
	}
	else
	{
		xleft = targetsX[targetindex]-(range>>1);
		yleft = targetsY[targetindex]-(range>>1);
	}
	c <: 1;
	master
	{
		c <: xleft + (((x*(range>>(8)))/320)<<8);
		c <: yleft + (((2*y*(range>>(8)))/240)<<8);
		c <: yleft + ((((2*y+1)*(range>>(8)))/240)<<8);
	}
}

void lrsdwipe(chanend c_lcd, int n, int pix)
{
  for (int i=0; i < n; i++)
  {	
    LRSD_BEGIN_FRAME(c_lcd);
	  for (int x=0; x<pix; x++)
	  {
	    LRSD_PIXEL(c_lcd, x, 0);
	  }
    LRSD_END_FRAME(c_lcd);
  }

  LRSD_BEGIN_FRAME(c_lcd);
}

void createMandelbrot(chanend c_lcd,
								chanend cmbrot0, chanend cmbrot1, chanend cmbrot2, chanend cmbrot3, 
								chanend cmbrot4, chanend cmbrot5, chanend cmbrot6, chanend cmbrot7, 
								chanend cb, chanend c_xlog)
{
	timer t;
	unsigned time;
	//unsigned frame=0;
	unsigned linebuffer[120];
	int wipecount = 320*240;

  mandelbrot_register_traphandler();

	t :> time;

  LRSD_INIT(c_lcd);

	lrsdwipe(c_lcd, 5, wipecount);
	
	while (1)
	{	 


		// Calculate the frame, farming out to 8 processing threads
		for (unsigned x=0; x<320; x++)
		{
		  int readptr=8,farmPixNums[8]={0,1,2,3,4,5,6,7};
			farmOut(x, 0,cmbrot0);
			farmOut(x, 1,cmbrot1);
			farmOut(x, 2,cmbrot2);
			farmOut(x, 3,cmbrot3);
			farmOut(x, 4,cmbrot4);
			farmOut(x, 5,cmbrot5);
			farmOut(x, 6,cmbrot6);
			farmOut(x, 7,cmbrot7);
		  
		  while (readptr < 120)
		  {
		    select
		    {
		      case cmbrot0 :> linebuffer[farmPixNums[0]]:
		         farmOut(x, readptr, cmbrot0);
		         farmPixNums[0] = readptr++;
		         break;
		      case cmbrot1 :> linebuffer[farmPixNums[1]]:
		         farmOut(x, readptr, cmbrot1);
		         farmPixNums[1] = readptr++;
		         break;
		      case cmbrot2 :> linebuffer[farmPixNums[2]]:
		         farmOut(x, readptr, cmbrot2);
		         farmPixNums[2] = readptr++;
		         break;
          case cmbrot3 :> linebuffer[farmPixNums[3]]:
		         farmOut(x, readptr, cmbrot3);
		         farmPixNums[3] = readptr++;
		         break;
		      case cmbrot4 :> linebuffer[farmPixNums[4]]:
		         farmOut(x, readptr, cmbrot4);
		         farmPixNums[4] = readptr++;
		         break;
		      case cmbrot5 :> linebuffer[farmPixNums[5]]:
		         farmOut(x, readptr, cmbrot5);
		         farmPixNums[5] = readptr++;
		         break;
		      case cmbrot6 :> linebuffer[farmPixNums[6]]:
		         farmOut(x, readptr, cmbrot6);
		         farmPixNums[6] = readptr++;
		         break;
		      case cmbrot7 :> linebuffer[farmPixNums[7]]:
		         farmOut(x, readptr, cmbrot7);
		         farmPixNums[7] = readptr++;
		         break;
		    }
		 }
		 
		 // Receive the last pixels
		 cmbrot0 :> linebuffer[farmPixNums[0]];
		 cmbrot1 :> linebuffer[farmPixNums[1]];
		 cmbrot2 :> linebuffer[farmPixNums[2]];
		 cmbrot3 :> linebuffer[farmPixNums[3]];
		 cmbrot4 :> linebuffer[farmPixNums[4]];
		 cmbrot5 :> linebuffer[farmPixNums[5]];
		 cmbrot6 :> linebuffer[farmPixNums[6]];
		 cmbrot7 :> linebuffer[farmPixNums[7]];
		 			
			// Write this line to the sram
			for (int y=0; y<240; y+=2)
			{
        LRSD_PIXEL(c_lcd, x*240 + y, linebuffer[y>>1]);
        LRSD_PIXEL(c_lcd, x*240 + y + 1, linebuffer[(y>>1)]>>16);
  	  }
			
			// CC_SRAM_WordWrite(c_sram1, (frame*320 + x)*480, linebuffer, 0, 120);
    }
      select
      {
        case t when timerafter(time + PAUSE_TIME) :> time:
      		      		
	        // Zoom in
	        range >>= 1;
	        if (range <= MAX_RANGE)
	        {
		        range = DEFAULT_RANGE;
		        targetindex++;
		        if (targetindex == NUM_TARGETS)
			        targetindex=0;
	        }
		      LRSD_END_FRAME(c_lcd);
		      LRSD_BEGIN_FRAME(c_lcd);
          break;
        case cb :> int b:
			    t :> time;
			    t when timerafter(time + 1000) :> time;
			    // Shut down all 8 farms
			    cmbrot0 <: 0; cmbrot1 <: 0; cmbrot2 <: 0; cmbrot3 <: 0;
			    cmbrot4 <: 0; cmbrot5 <: 0; cmbrot6 <: 0; cmbrot7 <: 0;
  				
			    // Shut down the LCD and SRAM server
			    LRSD_END_FRAME(c_lcd);
			    LRSD_SHUTDOWN(c_lcd);
			    
			    t :> time;
			    t when timerafter(time + 100000) :> time;
			    return;
      }

	}
				
}

void dummy(chanend c)
{
	return;
}

unsigned mandelbrot(unsigned x0, unsigned y0, unsigned iterlimit);

void mandelbrotfarm(chanend c)
{
	unsigned x,y1,y2;
	unsigned multiplier = (0xFFFF/MAX_ITERATIONS);
	unsigned keepalive;
  mandelbrot_register_traphandler();
	c :> keepalive;
	while (keepalive)
	{
		slave
		{
			c :> x;
			c :> y1;
			c :> y2;
		}
		y1 =  multiplier * mandelbrot(x,y1,MAX_ITERATIONS);
		y2 =  multiplier * mandelbrot(x,y2,MAX_ITERATIONS);
		c <: (y2 << 16) | y1;
		c :> keepalive;
	}
}

// _fini hacks follow:

extern void _fini();
extern void io_reset();

void mandelbrotfarm_fini(chanend c)
{
  mandelbrotfarm(c);
#pragma stackcalls 20
  _fini();
  io_reset();
}

void mandelbrot_lrsd_server_core0_fini(chanend c_sram, chanend c_lcd)
{
  lrsd_server_core0(c_sram, c_lcd);
#pragma stackcalls 20
  _fini();
  io_reset();
}

void mandelbrot_lrsd_server_core3_fini(chanend c_lcd)
{
  lrsd_server_core3(c_lcd);
#pragma stackcalls 20
  _fini();
  io_reset();
}
