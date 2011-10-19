// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>

.globl io_reset
.globl io_reset.nstackwords
.globl io_reset.maxthreads
.linkset io_reset.nstackwords,0
.linkset io_reset.maxthreads,1
.text
.align 4
io_reset:
  ldc           r1, 0
  ldap          r11, io_reset_portlist
  mov           r2, r11
  ldc           r3, XS1_CLKBLK_REF
io_reset_loop:
  ldw           r0, r2[r1]
  bf            r0, io_reset_done
  setc          res[r0], XS1_SETC_INUSE_OFF
  setc          res[r0], XS1_SETC_INUSE_ON
  setclk        res[r0], r3
  setc          res[r0], XS1_SETC_INUSE_OFF
  add           r1, r1, 1
  bu            io_reset_loop
io_reset_done:
  retsp         0
.align 4
io_reset_portlist:
.word XS1_PORT_1A
.word XS1_PORT_1B
.word XS1_PORT_1C
.word XS1_PORT_1D
.word XS1_PORT_1E
.word XS1_PORT_1F
.word XS1_PORT_1G
.word XS1_PORT_1H
.word XS1_PORT_1I
.word XS1_PORT_1J
.word XS1_PORT_1K
.word XS1_PORT_1L
.word XS1_PORT_1M
.word XS1_PORT_1N
.word XS1_PORT_1O
.word XS1_PORT_1P
.word XS1_PORT_4A
.word XS1_PORT_4B
.word XS1_PORT_4C
.word XS1_PORT_4D
.word XS1_PORT_4E
.word XS1_PORT_4F
.word XS1_PORT_8A
.word XS1_PORT_8B
.word XS1_PORT_8C
.word XS1_PORT_8D
.word XS1_PORT_16A
.word XS1_PORT_16B
.word XS1_PORT_32A
.word 0
