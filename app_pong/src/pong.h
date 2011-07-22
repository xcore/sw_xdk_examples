// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Example App - Pong
 * @Description Simple two player pong demonstration, communicates with LCD SWC.
 *    pong.h: Pong defines
 */

#ifndef __PONG_H__
#define __PONG_H__

// Colour defines
#define WHITE       0x0000FFFE
#define BLACK       0x00000000
#define RED         0x0000003E
#define GREEN       0x000007C0
#define BLUE        0xF800F800

#define NUM_PACKETS     239
#define BAT_MOVE      7
#define BALL_MOVE     4
#define LOWER_BORDER_TOP  295
#define LOWER_BORDER_BOTTOM 301
#define SCORE_TOP     305
#define SCORE_BOTTOM    315
#define FRAMEBUFFERSIZE   80
#define UPPER_BALL_BOUND_BOX 4
#define LOWER_BALL_BOUND_BOX 286
#define SELECT_PAUSE    1000


#define BALL_HEIGHT_HALF  1
#define BALL_WIDTH      8
#define BALL_WIDTH_HALF   4
#define PAUSE_TIME      100000000
#define CHANGE_ANGLE_REGION 15


#define PONG_LBAT_LEFT     0x1
#define PONG_LBAT_RIGHT    0x2
#define PONG_HOME_BUTTON   0x4
#define PONG_RBAT_LEFT     0x10
#define PONG_RBAT_RIGHT    0x8

#define PONG_PAUSE_TIME 125000
#define PONG_BUFFER_WIDTH 240

#define PONG_BALL_BOUND_TOP       29
#define PONG_BALL_BOUND_BOTTOM   226
#define PONG_BALL_BOUND_LEFT     (PONG_LBAT_X+PONG_LBAT_WIDTH/2)-PONG_BALL_WIDTH
#define PONG_BALL_BOUND_RIGHT    (PONG_RBAT_X-PONG_RBAT_WIDTH/2)+PONG_BALL_WIDTH+PONG_BALL_WIDTH
#define MAX_SCORE                10
#define PONG_BALL_SPEED          8
#define PONG_BALL_WIDTH          4

#define PONG_BAT_TOP       40
#define PONG_BAT_BOTTOM   220
#define PONG_LBAT_WIDTH    30
#define PONG_LBAT_X        18
#define PONG_RBAT_WIDTH    30
#define PONG_RBAT_X        302
#define PONG_LBAT_HEIGHT   10

#define PONG_BACK_COLOUR LCD_BLACK
#define PONG_LBAT_COLOUR LCD_RED
#define PONG_RBAT_COLOUR LCD_GREEN
#define PONG_BALL_COLOUR LCD_WHITE

#endif /* __PONG_H__ */

