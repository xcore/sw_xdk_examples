/**
 * Module:  freq
 * Version: 1v1
 * Build:   b45a0fb9ab3e66156caa93683e6c6968b24e3366
 * File:    audio_init.xc
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
 * @ModuleName Audio A to D converter interface via I2S slave.
 * @Description: Audio A to D converter interface via I2S slave.
 *
 */

//
// NOTES:
// This assume 16bits per audio sample and there are two, left/right channels.
// Also assume AUD_DIN is 1 bit buffered port of widith 8bits, since there is no
// 16bits buffered mode port.
//

#include <xs1.h>
#include <xclib.h>
#include <platform.h>

/*** Private Definitions ***/

#define CTL_SCLK_PERIOD_LOW_TICKS      (1000)
#define CTL_SCLK_PERIOD_HIGH_TICKS     (1000)

// Device address and R/W fixed to write only.
// 0011_0100
#define DEVICE_ADRS                    (0x34)

// Valid register address.
#define LIVCTL_REG      (0x00)
#define RIVCTL_REG      (0x01)
#define LHPVCTL_REG     (0x02)
#define RHPVCTL_REG     (0x03)
#define AAPCTL_REG      (0x04)
#define DAPCTL_REG      (0x05)
#define PDCTL_REG       (0x06)
#define DAIF_REG        (0x07)
#define SRC_REG         (0x08)
#define DIA_REG         (0x09)
#define RESET_REG       (0x0F)

/** This send simple write command to the DAC chip via 2wire interface.
 */
int swc_audio_codec_ctl_reg_wr(int Adrs, int WrData, port AUD_SCLK, port AUD_SDIN)
{
    int Result;
   timer gt;
   unsigned time;
   int Temp, CtlAdrsData, i;
   // three device ACK
   int DeviceACK[3];

   // sanity checking
   // only 9bits of data.
   if ((WrData & 0xFFFFFE00) != 0)
   {
      return -1;
   }
   // only valid address.
   switch (Adrs)
   {
      case LIVCTL_REG: case RIVCTL_REG: case LHPVCTL_REG: case RHPVCTL_REG:
      case AAPCTL_REG: case DAPCTL_REG: case PDCTL_REG: case DAIF_REG:
      case SRC_REG: case DIA_REG: case RESET_REG:
         break;
      default:
         return -1;
         break;
   }
   // initial values.
   AUD_SCLK <: 1;
   AUD_SDIN  <: 1;
   sync(AUD_SDIN);
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS + CTL_SCLK_PERIOD_LOW_TICKS;
   gt when timerafter(time) :> int _;
   // start bit on SDI
   AUD_SCLK <: 1;
   AUD_SDIN  <: 0;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 0;
   // shift 7bits of address and 1bit R/W (fixed to write).
   // WARNING: Assume MSB first.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (DEVICE_ADRS >> (7 - i)) & 0x1;
      AUD_SDIN <: Temp;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> int _;
      AUD_SCLK <: 1;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> int _;
      AUD_SCLK <: 0;
   }
   // turn the data to input
   AUD_SDIN :> Temp;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 1;
   // sample first ACK.
   AUD_SDIN :> DeviceACK[0];
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 0;
   // this build funny TI data format
   CtlAdrsData = ((Adrs & 0x7F) << 9) | (WrData & 0x1FF);
   // shift first 8 bits.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (CtlAdrsData >> (15 - i)) & 0x1;
      AUD_SDIN <: Temp;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> int _;
      AUD_SCLK <: 1;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> int _;
      AUD_SCLK <: 0;
   }
   // turn the data to input
   AUD_SDIN :> Temp;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 1;
   // sample second ACK.
   AUD_SDIN :> DeviceACK[1];
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 0;
   // shift second 8 bits.
   for (i = 0; i < 8; i += 1)
   {
      Temp = (CtlAdrsData >> (7 - i)) & 0x1;
      AUD_SDIN <: Temp;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> int _;
      AUD_SCLK <: 1;
      gt :> time;
      time += CTL_SCLK_PERIOD_HIGH_TICKS;
      gt when timerafter(time) :> int _;
      AUD_SCLK <: 0;
   }
   // turn the data to input
   AUD_SDIN :> Temp;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 1;
   // sample second ACK.
   AUD_SDIN :> DeviceACK[2];
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 0;
   gt :> time;
   time += CTL_SCLK_PERIOD_HIGH_TICKS;
   gt when timerafter(time) :> int _;
   AUD_SCLK <: 1;
   // put the data to a good value for next round.
   AUD_SDIN  <: 1;
   // validate all items are ACK properly.
   Result = 0;
   for (i = 0; i < 3; i += 1)
   {
      if (DeviceACK[i] != 0)
      {
         Result = 1;
      }
   }

   return(Result);
}


// I2S based two channel Audio in/out.
on stdcore[3]: port AUD_BCLK       = XS1_PORT_1C;    // X3D10

on stdcore[3]: clock AUD_BIT_CLOCK = XS1_CLKBLK_3;



#define CODEC_LEFT_LINE_IN_CTL_REG     (0x0)
#define CODEC_RIGHT_LINE_IN_CTL_REG    (0x1)
#define CODEC_LEFT_HPONE_CTL_REG       (0x2)
#define CODEC_RIGHT_HPONE_CTL_REG      (0x3)
#define CODEC_ANALOGE_CTL_REG          (0x4)
#define CODEC_DIGITAL_CTL_REG          (0x5)
#define CODEC_POWER_DOWN_CTL_REG       (0x6)
#define CODEC_DIG_IF_FORMAT_CTL_REG    (0x7)
#define CODEC_SAMPLE_RATE_CTL_REG      (0x8)
#define CODEC_DIF_IF_ACT_CTL_REG       (0x9)
#define CODEC_RESET_REG                (0x0f)

void audio_init(port AUD_SCLK, port AUD_SDIN, buffered in port:8 AUD_DIN, buffered out port:8 AUD_DOUT, port AUD_LRCOUT, port AUD_LRCIN) {
   int WrData;

   // I2S based two channel Audio in/out.
   // Generate bit clock block from pin
   configure_clock_src(AUD_BIT_CLOCK, AUD_BCLK);
   // configure ports with required clock source.
   configure_in_port_no_ready(AUD_DIN, AUD_BIT_CLOCK);
   configure_out_port_no_ready(AUD_DOUT, AUD_BIT_CLOCK, 0);
   configure_out_port_no_ready(AUD_LRCOUT, AUD_BIT_CLOCK, 0);
   configure_in_port_no_ready(AUD_LRCIN, AUD_BIT_CLOCK);
   // start the ports and clock ports.
   start_port(AUD_BCLK);
   start_port(AUD_LRCIN);
   start_port(AUD_LRCOUT);
   start_port(AUD_DIN);
   start_port(AUD_DOUT);
   // start clock.
   start_clock(AUD_BIT_CLOCK);
   // Initialise the ports.
   // control interface simple
   AUD_SCLK <: 1;
   AUD_SDIN <: 1;


   // write to codec with reset register.
   WrData = 0;
   swc_audio_codec_ctl_reg_wr(CODEC_RESET_REG, WrData, AUD_SCLK, AUD_SDIN);


   // Left Line input ctl
   // a. Simultaneous update    : Enable.
   // b. Left line input        : Normal.
   // c. Left line input volume : b1011 : 0db Default
   WrData = 0x117;
   swc_audio_codec_ctl_reg_wr(CODEC_LEFT_LINE_IN_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);

   // Right Line input ctl
   // a. Simultaneous update    : Enable.
   // b. Right line input        : Normal.
   // c. Right line input volume : b1011 : 0db Default
   WrData = 0x117;
   swc_audio_codec_ctl_reg_wr(CODEC_RIGHT_LINE_IN_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);

   // ***** NOTE *****
   // Left/Right HeadPhone interface is disabled.

   // Analoge Audio path contorl .
   // a. STA[2:0] & STE          : F&*$ knows!
   // b. DAC                     : DAC selected
   // c. Bypass                  : Disabled.
   // d. INSEL                   : Line Input.
   // e. MICM                    : Microphone muted.
   // f. MICB                    : 0db

   // TESSSSST:
   // Bypass enabled.
   WrData = 0x12; // 1A; !!!  12: disabled.
   swc_audio_codec_ctl_reg_wr(CODEC_ANALOGE_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);

   // Digital Audio Path Control Reg.
   // a. DAC Soft Mute           : Enable
   // b. DEEMP[1:0] De-emphasis  : Disabled
   // c. ADC high pass filter    : Enable.
   WrData = 0x0; // 0x8; !!
   swc_audio_codec_ctl_reg_wr(CODEC_DIGITAL_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);


   // Power Down Control register.
   // a. Device power            : ON
   // b. Clock                   : ON
   // c. Oscillator              : ON
   // d. Outputs                 : ON
   // e. DAC                     : ON
   // f. ADC                     : ON
   // g. MIC                     : OFF
   // h. LINE                    : ON
   WrData = 0x2;
   swc_audio_codec_ctl_reg_wr(CODEC_POWER_DOWN_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);

   // Digital Audio Interface Format control.s
   // a. Master/Slave            : MASTER.
   // b. LRSWAP                  : Disabled.
   // c. LRP                     : 0
   // d. IWL[1:0] InputBitLength : 16bit
   // e. FOR[1:0] DataFormat     : I2S
   WrData = 0x42;
   swc_audio_codec_ctl_reg_wr(CODEC_DIG_IF_FORMAT_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);


   // Sample Rate Control register. (MCLK = 16.9344 MHz and 44.1KHz for both ADC/DAC)
   // a. CLKOUT                  : MCLK
   // b. CLKIN                   : MCLK
   // c. SR[3:0]                 : 4'b1000
   // d. BOSR                    : 1'b1
   // e. USB/Normal              : Normal
   WrData = 0x22;
   swc_audio_codec_ctl_reg_wr(CODEC_SAMPLE_RATE_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);


   // Digital Interface Activation reg.
   // a. ACT                     : Enable
   WrData = 0x1;
   swc_audio_codec_ctl_reg_wr(CODEC_DIF_IF_ACT_CTL_REG, WrData, AUD_SCLK, AUD_SDIN);

}




