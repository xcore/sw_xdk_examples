// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __streaming_h__
#define __streaming_h__

// For this legacy application we define start/stop streaming primitives.
// These are now deprecated in the main tool chain

#ifdef start_streaming_slave
#undef start_streaming_slave
#endif

#ifdef start_streaming_master
#undef start_streaming_master
#endif

#ifdef stop_streaming_slave
#undef stop_streaming_slave
#endif

#ifdef stop_streaming_master
#undef stop_streaming_master
#endif

#define start_streaming_slave(c) do {inct(c);outct(c,XS1_CT_ACK);} while (0)
#define start_streaming_master(c) do {outct(c,XS1_CT_END);inct(c);} while (0)

#define stop_streaming_slave(c) do {outct(c,XS1_CT_END);inct(c);} while (0)
#define stop_streaming_master(c) do {inct(c);outct(c,XS1_CT_END);} while (0)

#endif // __streaming_h__
