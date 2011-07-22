/**
 * Module:  freq
 * Version: 1v1
 * Build:   b45a0fb9ab3e66156caa93683e6c6968b24e3366
 * File:    audio_host.xc
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
 */

//
// NOTES:
// This assume 16bits per audio sample and there are two, left/right channels.
// Also assume AUD_DIN is 1 bit buffered port of widith 8bits, since there is no
// 16bits buffered mode port.
//

#include <xs1.h>
#include <xclib.h>

#define NUM_BYTES_IN_SAMPLE (2)

// Internal private defines.
#define AUDIO_ADC_BUF_CTL_IDLE      (0x0)
#define AUDIO_ADC_BUF_CTL_REQ       (0x1)
#define AUDIO_ADC_BUF_CTL_RESP      (0x2)

// Size of data items to move per *transaction*, 1/4 of actual buffer size.
#define AUDIO_ADC_DATA_MOVE_SIZE    (AUDIO_ADC_BUF_SIZE >> 2)


/** This reshuffle incoming bit stream from I2S to internal 32bit Audio data structure.
 */
static unsigned int I2SToAudio(unsigned int I2SData)
{
   // NOTE: No bit shifting is required just bitresv, since XCore inShiftRight
   // matches with I2S, MSBit first.
   // reverse the bits.
   I2SData = bitrev(I2SData);

   return (I2SData);
}






extern void audio_init(port AUD_SCLK, port AUD_SDIN, buffered in port:8 AUD_DIN, buffered out port:8 AUD_DOUT, port AUD_LRCOUT, port AUD_LRCIN);




/** Audio analogue to digital interface via simple I2S.
 *  Receive Left/Right samples via I2S.
 *  NOTE: I2S input sample interface ONLY contain valid pin on *second*
 *  rising edge of LRCIN change.
 *  LRCIN pin should be clocked off from BCLK.
 */
void audio_from_host(chanend poison, chanend before, chanend left, chanend right, port AUD_LRCIN, buffered in port:8 AUD_DIN, out port led_adc)
{
    int isLeft;
    unsigned int SampleData = 0;
    int odd = 1;

    led_adc <: 0;
    isLeft = 0;
    // loop to get continuous samples.
    while (1) {
        select {
        case AUD_LRCIN when pinsneq (isLeft) :> isLeft:
            break;
        case poison :> int x:
            before <: 0x80000000;
            outuint(left, 0x80000000);
            outct(left, XS1_CT_END);
            outuint(right, 0x80000000);
            outct(right, XS1_CT_END);
            inct(left);
            inct(right);
            led_adc <: 1;
            return;
        }

        clearbuf(AUD_DIN);
        SampleData = I2SToAudio(SampleData);
        if (isLeft) {
            if (odd) {
                before <: (int)(short)SampleData;
            }
            odd = !odd;
            outuint(left, (int)(short)SampleData);
        } else {
            outuint(right, (int)(short)SampleData);
        }
        SampleData = 0;
        AUD_DIN :> >> SampleData;
        AUD_DIN :> >> SampleData;
    }
}

/** This covert the buffer data into sample data required by I2S interface.
 */
static unsigned int AudioToI2S(unsigned int AudioData)
{
    AudioData = AudioData << 16;
    AudioData = bitrev(AudioData);

    return (AudioData);
}

/** Audio Digital to Analogue interface control via I2S
 *  NOTE: To provide max. head room, LRCOUT is clocked from 100MHz, software ref. clock.
 */
void audio_to_host(chanend left, chanend right, chanend toFFT, port AUD_LRCOUT, buffered out port:8 AUD_DOUT, out port led_dac) {
    int sampleData;
    int isLeft;
    int odd = 1;
    // initialise the ctl/data
    AUD_DOUT <: 0;

    AUD_LRCOUT  when pinsneq(0) :> isLeft;

    led_dac <: 0;
    while (1) {
        if (isLeft) {                      // TODO - this ought to be temp!
            sampleData = inuint(left);
        } else {
            sampleData = inuint(right);
//            right :> sampleData;
        }
        if (sampleData == 0x80000000) {
            toFFT <: sampleData;
            if (isLeft) {
                inuint(right);
//                right :> sampleData;
            } else {
                inuint(left);
//                left :> sampleData;
            }
            inct(left);
            outct(left, XS1_CT_END);
            inct(right);
            outct(right, XS1_CT_END);
            led_dac <: 1;
            return;
        }
        if (isLeft) {
            odd = !odd;
            if (odd) {
                toFFT <: sampleData;
            }
        }
        sampleData = AudioToI2S(sampleData);
        AUD_LRCOUT  when pinsneq(isLeft) :> isLeft;
        // clear buffer to sync start up.
        clearbuf(AUD_DOUT);
        AUD_DOUT <:  >> sampleData;
        AUD_DOUT <:  >> sampleData;
    }
}

#define CODEC_DIGITAL_CTL_REG          (0x5)
#define CODEC_ANALOGE_CTL_REG          (0x4)
extern int swc_audio_codec_ctl_reg_wr(int Adrs, int WrData, port AUD_SCLK, port AUD_SDIN);


void audio_selector(chanend x, port AUD_SCLK, port AUD_SDIN) {
    while (1) {
        int cmd;
        x :> cmd;
        if (cmd == 0x80000000) {
            return;
        } else if (cmd < 0) {
            swc_audio_codec_ctl_reg_wr(CODEC_DIGITAL_CTL_REG, 0, AUD_SCLK, AUD_SDIN);
            swc_audio_codec_ctl_reg_wr(CODEC_ANALOGE_CTL_REG, 0x12, AUD_SCLK, AUD_SDIN);
        } else if (cmd > 0) {
            swc_audio_codec_ctl_reg_wr(CODEC_DIGITAL_CTL_REG, 8, AUD_SCLK, AUD_SDIN);
            swc_audio_codec_ctl_reg_wr(CODEC_ANALOGE_CTL_REG, 0x1A, AUD_SCLK, AUD_SDIN);
        } else {
            swc_audio_codec_ctl_reg_wr(CODEC_DIGITAL_CTL_REG, 8, AUD_SCLK, AUD_SDIN);
            swc_audio_codec_ctl_reg_wr(CODEC_ANALOGE_CTL_REG, 0x12, AUD_SCLK, AUD_SDIN);
        }
    }
}



void audio(chanend adc_buf, chanend before, chanend leftIn, chanend rightIn, chanend leftOut, chanend rightOut, chanend after, chanend selector, port AUD_LRCIN, port AUD_LRCOUT, buffered in port:8 AUD_DIN, buffered out port:8 AUD_DOUT, out port led_adc, out port led_dac, port AUD_SCLK, port AUD_SDIN) {
   audio_init(AUD_SCLK, AUD_SDIN, AUD_DIN, AUD_DOUT, AUD_LRCOUT, AUD_LRCIN);
   par {
       audio_from_host(adc_buf, before, leftIn, rightIn, AUD_LRCIN, AUD_DIN, led_adc);
       audio_to_host(leftOut, rightOut, after, AUD_LRCOUT, AUD_DOUT, led_dac);
       audio_selector(selector, AUD_SCLK, AUD_SDIN);
   }
}
