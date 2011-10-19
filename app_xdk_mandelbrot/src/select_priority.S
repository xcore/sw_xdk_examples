// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
/////////////////////////////////////////////////////////////////////////////
//
// int select_priority2(chanend a, chanend b);
//
.globl   select_priority2
.globl   select_priority2.nstackwords
.linkset select_priority2.nstackwords, 0
.text
select_priority2:
	ldap     r11, select_priority2_a
	setv     res[r0], r11
	ldap     r11, select_priority2_b
	setv     res[r1], r11
	eeu      res[r0]
	edu      res[r1]
	setsr    (1 << XS1_SR_EEBLE_SHIFT)
	clrsr    (1 << XS1_SR_EEBLE_SHIFT)
	eeu      res[r1]
	waiteu
select_priority2_a:
	ldc      r0, 0
	clrsr    (1 << XS1_SR_EEBLE_SHIFT)
	retsp    0
select_priority2_b:
	ldc      r0, 1
	retsp    0
