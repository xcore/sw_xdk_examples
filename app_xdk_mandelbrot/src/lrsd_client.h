// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _lrsd_client_h_
#define _lrsd_client_h_

#include <xs1.h>
#include "lrsd_colors.h"
#include "streaming.h"

// Note: LRSD_PIXEL address must have back-to-front swapped rows
// This is to compensate for XDK screen orientation
// Reconsider including this in LRSD - it means that it has to have
// knowledge of screen arrangement, not just number of words

#define LRSD_INIT(c_client)                   { start_streaming_master(c_client); }
#define LRSD_BEGIN_FRAME(c_client)            { outuint(c_client, (unsigned)0); inuint(c_client); }
#define LRSD_PIXEL(c_client, address, colour) { outuint(c_client, (unsigned)(address)); outuint(c_client, (unsigned)(colour)); }
#define LRSD_END_FRAME(c_client)              { outuint(c_client, (unsigned)-1); }
#define LRSD_SHUTDOWN(c_client)               { outuint(c_client, (unsigned)1); inuint(c_client); stop_streaming_master(c_client); }

#endif
