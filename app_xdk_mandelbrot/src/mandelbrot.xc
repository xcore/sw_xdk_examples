// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Example App - Mandelbrot
 * @Description Simple mandelbrot fractal algorithm
 */
 
#include <xs1.h>
 
// Receives x and y coordinates in fixed point format, one sign bit, 4 integer bits, 27 fractional bits. Returns number of iterations required, with a ceiling of iterlimit.
 
unsigned mandelbrot(unsigned x0, unsigned y0, unsigned iterlimit)
{
   unsigned lsb, msb;
   unsigned iterationcount=0;
   unsigned xy=0;
   unsigned xabs=0,yabs=0,xsq=0,ysq=0;
   unsigned xtemp=0;
   unsigned x=x0,y=y0;
   while (iterlimit != 0)
   {
      // Absolute value of x
      if (x & 0x80000000)
         xabs = ~x + 1;
      else
         xabs = x;
      
      // Absolute value of y
      if (y & 0x80000000)
         yabs = ~y + 1;
      else
         yabs = y;
         
      // If either |x| or |y| larger than 2, we're done
      if ( ((xabs & 0x70000000)==0) && ((yabs & 0x70000000) == 0))
      {
         // Square x
         {msb, lsb} = lmul ( xabs , xabs, 0 , 0 ) ;
         xsq = ((msb << 6) >> 1) | (lsb >> 27);
         // Square y
         {msb, lsb} = lmul ( yabs , yabs, 0 , 0 ) ;
         ysq = ((msb << 6) >> 1) | (lsb >> 27);
         
         // If x*x + y*y > 4, we're done
         if ( ((xsq + ysq) & 0x60000000) == 0 )
         {
         
            // Now perform an iteration
            
            // x = x*x - y*y + x0
            xtemp = xsq + x0 - ysq;
            
            // y = 2*x*y + y0
            {msb, lsb} = lmul ( xabs , yabs, 0 , 0 ) ;
            xy = (((msb << 6) >> 1) << 1) | (lsb >> 26); // = 2|x||y|
            if ((x >> 31) ^ (y >> 31))
               xy = ~xy + 1;  // Resulting xy should be negative
            y = xy + y0;
            
            x = xtemp;
            iterationcount += 1;
            iterlimit -= 1;
         }
         else
         {
            iterlimit = 0;
         }
      
      } else {
         iterlimit = 0;
      }
      
   }
   
   return iterationcount;
}
