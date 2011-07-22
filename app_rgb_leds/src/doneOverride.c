// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

void _done(void)
{
	void (*fp)(void) = (void(*)(void))0xffffc000;
	
	(*fp)();
}
