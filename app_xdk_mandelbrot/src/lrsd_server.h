// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _lrsd_server_h_
#define _lrsd_server_h_

void lrsd_server_core0(chanend c_client, chanend c_lcd);
void lrsd_server_core3(chanend c_lcd);

#endif
