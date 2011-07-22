// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>

extern void getButtonData(chanend ch);
extern void rgbLeds(chanend ch);

int main()
{
  chan ch;
  par
  {
    on stdcore[0] : getButtonData(ch);
    on stdcore[2] : rgbLeds(ch);
  }
  return 0;
}
