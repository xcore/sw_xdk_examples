/**
 * Module:  pong
 * Version: 1v1
 * Build:   09eb107119f1beff657cf7dc11fdadf918468539
 * File:    pong.xc
 *
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/                                   
/*
 * @Example App - Pong
 * @Description Simple two player pong demonstration, communicates with LCD SWC.
 *    pong.xc: main pong loops and frame generation
 */

#include <xs1.h>
#include "pong.h"
#include "LCD_Comp_Def.h"

void WritePixels(chanend c, unsigned pixels[])
{
   unsigned i;
   master
   {
      for (i=0; i < PONG_BUFFER_WIDTH; i++)
         c <: pixels[i];
   }
}


{unsigned,unsigned,unsigned,unsigned,unsigned,unsigned} PongReset(unsigned dir)
{
   return {(PONG_BALL_BOUND_BOTTOM+PONG_BALL_BOUND_TOP)/2,(PONG_BALL_BOUND_BOTTOM+PONG_BALL_BOUND_TOP)/2,LCD_HEIGHT_PX/2,(PONG_BALL_BOUND_BOTTOM+PONG_BALL_BOUND_TOP)/2,dir,0};
}

void pongMain(chanend c_btns, chanend c_gen)
{
  timer t;
  int StartTime=0;
  int LBatPos, RBatPos, BallX, BallY, BallModeX, BallModeY;
  int LScore=0;
  int RScore=0;
  int pause=1;
  unsigned int ButtonState=0;
  unsigned running=1;
  {LBatPos,RBatPos,BallX,BallY,BallModeX,BallModeY} = PongReset(1);

  while (running)
  {
    t :> StartTime;

    //Request button state
    c_btns <: 0;
    //Receive button state
    c_btns :> ButtonState;

    if (~ButtonState & PONG_LBAT_LEFT)
     LBatPos += BALL_MOVE;
    if (~ButtonState & PONG_LBAT_RIGHT)
     LBatPos -= BALL_MOVE;

    if (~ButtonState & PONG_RBAT_LEFT)
     RBatPos += BALL_MOVE;
    if (~ButtonState & PONG_RBAT_RIGHT)
     RBatPos -= BALL_MOVE;

    if (~ButtonState & PONG_HOME_BUTTON)
      running = 0;

     //Move Ball
     BallY += BallModeY*PONG_BALL_SPEED;
     BallX += BallModeX*PONG_BALL_SPEED;

     //Bounce off top and bottom.
     if ((BallY < PONG_BALL_BOUND_TOP) | (BallY > PONG_BALL_BOUND_BOTTOM))
       BallModeY=-BallModeY;



     //Check if Ball collided with LHS
     if (BallX < PONG_BALL_BOUND_LEFT)
     {
      // Check if left bat in the way
      if (((BallY+PONG_BALL_WIDTH) > (LBatPos - PONG_LBAT_WIDTH/2)) && ((BallY-PONG_BALL_WIDTH) < (LBatPos + PONG_LBAT_WIDTH / 2)))
      {
        if ((BallY+PONG_BALL_WIDTH) < (LBatPos - PONG_LBAT_WIDTH/2 + CHANGE_ANGLE_REGION))
          BallModeY = -1;
        else if ((BallY-PONG_BALL_WIDTH) > (LBatPos + PONG_LBAT_WIDTH / 2 - CHANGE_ANGLE_REGION))
          BallModeY = 1;
        else
          BallModeY = 0;
        BallModeX = -BallModeX;
      }
      else
      {
      RScore += 1;
      {LBatPos,RBatPos,BallX,BallY,BallModeX,BallModeY} = PongReset(1);
      if (LScore == MAX_SCORE || RScore == MAX_SCORE)
      {
        LScore=0;
        RScore=0;
        pause = 40;
      }
      BallX = PONG_BALL_BOUND_LEFT;
      pause = 10;
    }
  }

  //Check if Ball collided with RHS
  if (BallX>PONG_BALL_BOUND_RIGHT)
  {
    // Check if bat in the way
    if (((BallY+PONG_BALL_WIDTH) > (RBatPos - PONG_LBAT_WIDTH / 2)) && ((BallY-PONG_BALL_WIDTH) < (RBatPos + PONG_LBAT_WIDTH / 2)))
    {
      if ((BallY+PONG_BALL_WIDTH) < (RBatPos - PONG_LBAT_WIDTH/2 + CHANGE_ANGLE_REGION))
        BallModeY = -1;
      else if ((BallY-PONG_BALL_WIDTH) > (RBatPos + PONG_LBAT_WIDTH / 2 - CHANGE_ANGLE_REGION))
        BallModeY = 1;
      else
        BallModeY = 0;
      BallModeX = -BallModeX;
    }
    else
    {
      LScore += 1;
      {LBatPos,RBatPos,BallX,BallY,BallModeX,BallModeY} = PongReset(-1);
      if (LScore == MAX_SCORE || RScore == MAX_SCORE)
      {
        LScore=0;
        RScore=0;
        pause = 40;
      } else
        pause = 10;
      }
    }

    //Make sure bats not off screen
    if ( LBatPos < PONG_BAT_TOP )
      LBatPos = PONG_BAT_TOP;
    if ( LBatPos > PONG_BAT_BOTTOM )
      LBatPos = PONG_BAT_BOTTOM;
    if ( RBatPos < PONG_BAT_TOP )
      RBatPos = PONG_BAT_TOP;
    if ( RBatPos > PONG_BAT_BOTTOM )
      RBatPos = PONG_BAT_BOTTOM;

    t when timerafter(StartTime + PONG_PAUSE_TIME * pause) :> int temptime;

    pause = 1;

    //Update positions
    master
    {
      c_gen <: LBatPos;
      c_gen <: RBatPos;
      c_gen <: BallX;
      c_gen <: BallY;
      c_gen <: LScore;
      c_gen <: RScore;
      c_gen <: running;
    }
  }
}

void DrawScoreCol(unsigned FrameBuffer[PONG_BUFFER_WIDTH], unsigned col, unsigned ptype)
{
  unsigned i;
  for (i=0; i<ptype; i++)
  {
    FrameBuffer[9-i]=col;
    FrameBuffer[9+i]=col;
  }
  for (; i<6; i++)
  {
    FrameBuffer[9-i]=0;
    FrameBuffer[9+i]=0;
  }
}

void DrawScore(unsigned FrameBuffer[PONG_BUFFER_WIDTH], unsigned ypos, unsigned score, unsigned col, unsigned ptype)
{
  if ((ypos & 1))
  {
    ypos >>= 1;
    if (ptype > 4)
      ptype = 8 - ptype;
    if ((score > ypos) && (ypos < MAX_SCORE))
      DrawScoreCol(FrameBuffer,col, ptype);
  }
}

void DoScore(unsigned FrameBuffer[PONG_BUFFER_WIDTH], unsigned lcd_y, unsigned LScore, unsigned RScore)
{
  DrawScoreCol(FrameBuffer, PONG_BACK_COLOUR, 9);
  DrawScore(FrameBuffer, lcd_y/8, LScore, LCD_RED, lcd_y%8);
  DrawScore(FrameBuffer, (320 - lcd_y)/8, RScore, LCD_GREEN, lcd_y%8);
  if (lcd_y > 155 && lcd_y < 165)
    DrawScoreCol(FrameBuffer,LCD_BLUE, 9);
}


void pongFrameGen(chanend c_pong, chanend c_lcd)
{
  unsigned FrameBuffer[PONG_BUFFER_WIDTH];
  int x=0;
  int LBatPos=100,RBatPos=100,BallX=20,BallY=20,RScore=0,LScore=0;
  unsigned int i=0, lcd_y=0, time;
  timer t;
  unsigned running = 1;
  while (running)
  {
    t :> time;
    select
    {
      case slave {
                  c_pong :> LBatPos;
                  c_pong :> RBatPos;
                  c_pong :> BallX;
                  c_pong :> BallY;
                  c_pong :> LScore;
                  c_pong :> RScore;
                  c_pong :> running;
                 } :
        break;
      case t when timerafter(time+5000) :> int time2:
        break;
    }
    FrameBuffer[0] = -2;
    WritePixels(c_lcd, FrameBuffer);

    for (x=0; x<PONG_BUFFER_WIDTH; x+=1)
      FrameBuffer[x] = PONG_BACK_COLOUR;

    FrameBuffer[(PONG_BALL_BOUND_TOP-PONG_BALL_WIDTH)-6]=LCD_BLUE;
    FrameBuffer[(PONG_BALL_BOUND_TOP-PONG_BALL_WIDTH)-7]=LCD_BLUE;


    for (lcd_y=0; lcd_y<PONG_LBAT_X-PONG_LBAT_HEIGHT / 2; lcd_y++)
    {
      DoScore(FrameBuffer, lcd_y, LScore, RScore);
      WritePixels(c_lcd, FrameBuffer);
    }

    for (x=(LBatPos-PONG_LBAT_WIDTH / 2); x<(LBatPos+PONG_LBAT_WIDTH / 2); x++)
      FrameBuffer[x] = PONG_LBAT_COLOUR;

    for (i=0; i<PONG_LBAT_HEIGHT; i++)
    {
      lcd_y++;
      DoScore(FrameBuffer, lcd_y, LScore, RScore);
      WritePixels(c_lcd, FrameBuffer);
    }

    for (x=(LBatPos-PONG_LBAT_WIDTH/2); x<(LBatPos+PONG_LBAT_WIDTH / 2); x++)
      FrameBuffer[x] = PONG_BACK_COLOUR;

    for (; lcd_y<PONG_RBAT_X; lcd_y++)
    {
      if ((lcd_y >= BallX - PONG_BALL_WIDTH/2) && (lcd_y <= BallX + PONG_BALL_WIDTH/2))
      {
        for (x=(BallY - PONG_BALL_WIDTH/2) ; x <= (BallY + PONG_BALL_WIDTH/2) ; x++)
          FrameBuffer[x] = PONG_BALL_COLOUR;
      }
      else
      {
        for (x=(BallY - PONG_BALL_WIDTH/2) ; x <= (BallY + PONG_BALL_WIDTH/2) ; x++)
          FrameBuffer[x] = PONG_BACK_COLOUR;
      }

      // Score stuff
      DoScore(FrameBuffer, lcd_y, LScore, RScore);
      WritePixels(c_lcd, FrameBuffer);
    }

    for (x=(BallY - PONG_BALL_WIDTH/2) ; x <= (BallY + PONG_BALL_WIDTH/2) ; x++)
      FrameBuffer[x] = PONG_BACK_COLOUR;

    // Right BAT
    for (x=(RBatPos-PONG_LBAT_WIDTH / 2); x<(RBatPos+PONG_LBAT_WIDTH / 2); x++)
      FrameBuffer[x] = PONG_RBAT_COLOUR;
    for (i=0; i<PONG_LBAT_HEIGHT; i++)
    {
      lcd_y++;
      DoScore(FrameBuffer, lcd_y, LScore, RScore);
      WritePixels(c_lcd, FrameBuffer);
    }
    for (x=(RBatPos-PONG_LBAT_WIDTH / 2); x<(RBatPos+PONG_LBAT_WIDTH / 2); x++)
      FrameBuffer[x] = PONG_BACK_COLOUR;

    for (; lcd_y < LCD_HEIGHT_PX; lcd_y++)
    {
      DoScore(FrameBuffer, lcd_y, LScore, RScore);
      WritePixels(c_lcd, FrameBuffer);
    }
  }
  FrameBuffer[0] = -1;
  WritePixels(c_lcd, FrameBuffer);
}


