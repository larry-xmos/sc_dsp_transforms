// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "stdio.h"
#include "fft.h"

void fftRealTest() {
    int re1[8] = {0, 1414000, 2000000, 1414000, 0, -1414000, -2000000, -1414000};
    int re2[8] = {0, 100000, 0, -1000000, 0, 100000, 0, -1000000};
    int im1[8], im2[8];
    int re3[8] = {0, 1414000, 2000000, 1414000, 0, -1414000, -2000000, -1414000};
    int re4[8] = {0, 100000, 0, -1000000, 0, 100000, 0, -1000000};
    int im3[8] = {0,0,0,0,0,0,0,0};
    int im4[8] = {0,0,0,0,0,0,0,0};
    timer t; int t0,t1;

    printf("FORWARDING\n");
    fftTwiddle(re3, im3, 8);
    fftForward(re3, im3, 8, FFT_SINE(8));
    fftTwiddle(re4, im4, 8);
    fftForward(re4, im4, 8, FFT_SINE(8));
t :> t0;
    fftTwoRealsForward(re1, re2, im1, im2, 8, FFT_SINE(8));
t :> t1;
    printf("Ticks: %d\n", t1-t0);
    for(int i = 0; i < 8; i++) {
        printf("%8d + %8d i = %8d + %8d i  ;  %8d + %8d i = %8d + %8d i\n",
               re1[i], im1[i], re3[i], im3[i],
               re2[i], im2[i], re4[i], im4[i]);
    }
    printf("INVERSING\n");
    fftTwiddle(re3, im3, 8);
    fftInverse(re3, im3, 8, FFT_SINE(8));
    fftTwiddle(re4, im4, 8);
    fftInverse(re4, im4, 8, FFT_SINE(8));
    fftTwoRealsInverse(re1, re2, im1, im2, 8, FFT_SINE(8));
    for(int i = 0; i < 8; i++) {
        printf("%8d + %8d i = %8d + %8d i  ;  %8d + %8d i = %8d + %8d i\n",
               re1[i], 0, re3[i], im3[i],
               re2[i], 0, re4[i], im4[i]);
    }

}



void fftTest8() {
    int re[8], im[8];
    for(int i = 0; i < 8; i++) {
        re[i] = ((i*i*i) & 255) * 1000000;//sinValue(FFT_SINE(8), i, 8, 8)>>24;
        im[i] = 0;//(737*i) & 255; //0; //cosValue(FFT_SINE(8), i, 8, 8)>>24;
    }
    for(int i = 0; i < 8; i++) {
        printf("%d  %d\n", re[i], im[i]);
    }
    fftTwiddle(re, im, 8);
    fftForward(re, im, 8, FFT_SINE(8));
    printf("Post FFT\n");
    for(int i = 0; i < 8; i++) {
        printf("%d  %d\n", re[i], im[i]);
    }
    fftTwiddle(re, im, 8);
    fftInverse(re, im, 8, FFT_SINE(8));
    printf("Post Inverse\n");
    for(int i = 0; i < 8; i++) {
        printf("%d  %d\n", re[i], im[i]);
    }
}

int sq(int x) {
    return x*x;
}

void fftTest8Large() {
    int re[8], im[8];
    int ire[8], iim[8];
    int err = 0, sig = 0;
    for(int i = 0; i < 8; i++) {
        ire[i] = re[i] = ((i*i*i*123) & 0xff) * 1000000;
        iim[i] = im[i] = ((737123*i) & 0xFF) * 1000001;
    }
    fftTwiddle(re, im, 8);
    fftForward(re, im, 8, FFT_SINE(8));
    printf("Post FFT\n");
    fftTwiddle(re, im, 8);
    fftInverse(re, im, 8, FFT_SINE(8));
    printf("Post Inverse\n");

    for(int i = 0; i < 8; i++) {
        err += sq(re[i] - ire[i]) + sq(im[i] - iim[i]);
        sig += sq(ire[i]>>15) + sq(iim[i]>>15);
    }
    printf("8 Point FFT: Sum Sig^2: %d * 10^9 Sum Err^2: %d\n", sig, err);
}

void fftTest1024Large() {
    int re[1024], im[1024];
    int ire[1024], iim[1024];
    int err = 0, sig = 0;
    for(int i = 0; i < 1024; i++) {
        ire[i] = re[i] = (i*i*i*1234567) & 0xFFFFFF;//sinValue(FFT_SINE(1024), i, 1024, 1024)>>24;
        iim[i] = im[i] = (737123*i) & 0xFFFFFF; //0; //cosValue(FFT_SINE(1024), i, 1024, 1024)>>24;
    }
    fftTwiddle(re, im, 1024);
    fftForward(re, im, 1024, FFT_SINE(1024));
    printf("Post FFT\n");
    fftTwiddle(re, im, 1024);
    fftInverse(re, im, 1024, FFT_SINE(1024));
    printf("Post Inverse\n");

    for(int i = 0; i < 1024; i++) {
        err += sq(re[i] - ire[i]) + sq(im[i] - iim[i]);
        sig += sq(ire[i]>>15) + sq(iim[i]>>15);
    }
    printf("1024 Point FFT: Sum Sig^2: %d * 10^9 Sum Err^2: %d\n", sig, err);
}


void fftTest32() {
    timer t;
    int t0, t1;

    int re[32], im[32];
    for(int i = 0; i < 32; i++) {
        re[i] = (i*i*i) & 255;//sinValue(FFT_SINE(32), i, 32, 32)/0x1000000;
        im[i] = (737*i) & 255; //0; //cosValue(FFT_SINE(32), i, 32, 32)>>24;
    }
    for(int i = 0; i < 32; i++) {
        printf("%d  %d\n", re[i], im[i]);
    }
    fftTwiddle(re, im, 32);
    t :> t0;
    fftForward(re, im, 32, FFT_SINE(32));
    t :> t1;
    printf("Post FFT (%d)\n", t1-t0);
    for(int i = 0; i < 32; i++) {
        printf("%d  %d\n", re[i], im[i]);
    }
    fftTwiddle(re, im, 32);
    t :> t0;
    fftInverse(re, im, 32, FFT_SINE(32));
    t :> t1;
    printf("Post Inverse (%d)\n", t1-t0);
    for(int i = 0; i < 32; i++) {
        printf("%d  %d\n", re[i], im[i]);
    }
}

void fftTest64() {
    timer t;
    int t0, t1;

    int re[64], im[64], ire[64], iim[64];
    int err = 0, sig = 0;

    for(int i = 0; i < 64; i++) {
        ire[i] = re[i] = (i*i*i*12345) & 65535;//sinValue(FFT_SINE(64), i, 64, 64)/0x1000000;
        iim[i] = im[i] = (73117*i) & 65535; //0; //cosValue(FFT_SINE(64), i, 64, 64)>>24;
    }
    t :> t0;
    fftTwiddle(re, im, 64);
    t :> t1;
    printf("Post 64 twiddle (%d ticks)\n", t1-t0);
    t :> t0;
    fftForward(re, im, 64, FFT_SINE(64));
    t :> t1;
    printf("Post 64 FFT (%d ticks)\n", t1-t0);
    fftTwiddle(re, im, 64);
    t :> t0;
    fftInverse(re, im, 64, FFT_SINE(64));
    t :> t1;
    printf("Post 64 Inverse (%d ticks)\n", t1-t0);
    for(int i = 0; i < 64; i++) {
        err += sq(re[i] - ire[i]) + sq(im[i] - iim[i]);
        sig += sq(ire[i]>>15) + sq(iim[i]>>15);
    }
    printf("1024 Point FFT: Sum Sig^2: %d * 10^9 Sum Err^2: %d\n", sig, err);
}

void fftTest1024() {
    timer t;
    int t0, t1;

    int re[1024], im[1024];
    for(int i = 0; i < 1024; i++) {
        re[i] = (i*i*i) & 255;//sinValue(FFT_SINE(1024), i, 1024, 1024)/0x1000000;
        im[i] = (737*i) & 255; //0; //cosValue(FFT_SINE(1024), i, 1024, 1024)>>24;
    }
    t :> t0;
    fftTwiddle(re, im, 1024);
    t :> t1;
    printf("Post 1024 twiddle (%d ticks)\n", t1-t0);
    t :> t0;
    fftForward(re, im, 1024, FFT_SINE(1024));
    t :> t1;
    printf("Post 1024 FFT (%d ticks)\n", t1-t0);
    fftTwiddle(re, im, 1024);
    t :> t0;
    fftInverse(re, im, 1024, FFT_SINE(1024));
    t :> t1;
    printf("Post 1024 Inverse (%d ticks)\n", t1-t0);
}

int main(void) {
    fftRealTest();
    fftTest64();
    fftTest8();
    fftTest8Large();
    fftTest1024();
    fftTest1024Large();
    return 0;
}
