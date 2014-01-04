/**
 * CMV12000_sRGB: Commandline converter for CMV12000 raw to sRGB images.
 *
 *
 * Copyright (c) 2013 Gabriel Colburn
 *
 * CMV12000_sRGB is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * CMV12000_sRGB is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Adapted from bayer2rgb by Jeff Thomas. See copyright beneath.
 **/

/**
 * bayer2rgb: Comandline converter for bayer grid to rgb images.
 * This file is part of bayer2rgb.
 *
 * Copyright (c) 2009 Jeff Thomas
 *
 * bayer2rgb is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * bayer2rgb is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 **/
#include <iostream>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <math.h>
#include "../bayer/bayer.h"
using namespace std;

#define TIFF_HDR_NUM_ENTRY 8
#define TIFF_HDR_SIZE 10+TIFF_HDR_NUM_ENTRY*12
uint8_t tiff_header[TIFF_HDR_SIZE] = {
		// I     I     42
		0x49, 0x49, 0x2a, 0x00,
		// ( offset to tags, 0 )
		0x08, 0x00, 0x00, 0x00,
		// ( num tags )
		0x08, 0x00,
		// ( newsubfiletype, 0 full-image )
		0xfe, 0x00, 0x04, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// ( image width )
		0x00, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// ( image height )
		0x01, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// ( bits per sample )
		0x02, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		// ( Photometric Interpretation, 2 = RGB )
		0x06, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,
		// ( Strip offsets, 8 )
		0x11, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00,
		// ( samples per pixel, 3 - RGB)
		0x15, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
		// ( Strip byte count )
		0x17, 0x01, 0x04, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

uint8_t * put_tiff(void * rgb_in, uint32_t width, uint32_t height, uint16_t bpp)
{
	uint8_t *rgb = (uint8_t*)rgb_in;
	uint32_t ulTemp=0;
	uint16_t sTemp=0;
	memcpy(rgb, tiff_header, TIFF_HDR_SIZE);

	sTemp = TIFF_HDR_NUM_ENTRY;
	memcpy(rgb + 8, &sTemp, 2);

	memcpy(rgb + 10 + 1*12 + 8, &width, 4);
	memcpy(rgb + 10 + 2*12 + 8, &height, 4);
	memcpy(rgb + 10 + 3*12 + 8, &bpp, 2);

	// strip byte count
	ulTemp = width * height * (bpp / 8) * 3;
	memcpy(rgb + 10 + 7*12 + 8, &ulTemp, 4);

	//strip offset
	sTemp = TIFF_HDR_SIZE;
	memcpy(rgb + 10 + 5*12 + 8, &sTemp, 2);

	return rgb + TIFF_HDR_SIZE;
};

uint16_t clip16bit(float value) {
	if( value > 65535.0 )
		return 65535;
	else if( value < 0.0 )
		return 0;

	return (uint16_t)value;
}

float clip1f( float value) {
	if( value > 1.0f )
		value = 1.0f;
	else if (value < 0.0f)
		value = 0.0f;
	return value;
}

float camToXYZ[3][3] = {{0.70812437, 0.54507749, 0.29126889},
		{0.37017565, 1.28072110,-0.22049857},
		{0.16001888, 0.08233973, 2.03384932}};

float XYZtoLinSRGB[3][3] = {{ 3.2406, -1.5372, -0.4986},
		{-0.9689,  1.8758,  0.0415},
		{ 0.0557, -0.2040,  1.0570}};

// Alternative in one step
float camToLinSRGB[3][3] = {{1.64599803,-0.24326936, 0.26884016},
		{0.01493516, 1.87764304,-0.61132345},
		{0.13303648, -0.14394397, 2.21110193}};

// Lut is Cam to sRGB
int LUT[3][3][65536];
// Lut is linear sRGB to sRGB
uint16_t GAMMA_LUT[65536];

void initLUT() {
	printf("Building LUT...\n");

	for( unsigned int i = 0; i <= 65535; i++) {
		for( unsigned int x = 0; x < 3; x++) {
			for( unsigned int y = 0; y < 3; y++ ) {
				LUT[x][y][i] = camToLinSRGB[x][y]*i;
			}
		}
	}

	printf("LUT built.\n");
}

void initGAMMA_LUT() {
	float f;
	printf("Building GAMMA LUT...\n");
	for( unsigned int i = 0; i <= 65535; i++) {
		// Normalize values to be between 0-1.0
		f = i/65535.0;

		// sRGB Gamma
		if( f <= 0.0031308 )
			f *= 12.92;
		else
			f = (1+0.055)*pow(f,1.0/2.4)-0.055;

		// Scale to 16 bit
		f *= 65535.0;

		// Clip
		GAMMA_LUT[i] = clip16bit(f);
	}
	printf("GAMMA lut BUILT.\n");
}

void cameraToSRGB_LUT(uint16_t* r, uint16_t* g, uint16_t* b) {
	int r2 = LUT[0][0][*r] + LUT[0][1][*g] + LUT[0][2][*b];
	int g2 = LUT[1][0][*r] + LUT[1][1][*g] + LUT[1][2][*b];
	int b2 = LUT[2][0][*r] + LUT[2][1][*g] + LUT[2][2][*b];

	*r = GAMMA_LUT[clip16bit(r2)];
	*g = GAMMA_LUT[clip16bit(g2)];
	*b = GAMMA_LUT[clip16bit(b2)];
}

void cameraToSRGB(uint16_t* r, uint16_t* g, uint16_t* b) {
	float fr, fg, fb, fr2, fg2, fb2;
	// Note Camera to XYZ and XYZ to sRGB matrices
	// could be combined into one matrix

	/* Uncomment to apply transforms separately
	// Camera to XYZ
	fr = camToXYZ[0][0]* (*r) + camToXYZ[0][1]* (*g) + camToXYZ[0][2]* (*b);
	fg = camToXYZ[1][0]* (*r) + camToXYZ[1][1]* (*g) + camToXYZ[1][2]* (*b);
	fb = camToXYZ[2][0]* (*r) + camToXYZ[2][1]* (*g) + camToXYZ[2][2]* (*b);

	// XYZ to sRGB
	fr2 = XYZtoLinSRGB[0][0]* fr + XYZtoLinSRGB[0][1]* fg + XYZtoLinSRGB[0][2]* fb;
	fg2 = XYZtoLinSRGB[1][0]* fr + XYZtoLinSRGB[1][1]* fg + XYZtoLinSRGB[1][2]* fb;
	fb2 = XYZtoLinSRGB[2][0]* fr + XYZtoLinSRGB[2][1]* fg + XYZtoLinSRGB[2][2]* fb;*/

	// Apply transforms in one step
	fr2 = camToLinSRGB[0][0]* (*r) + camToLinSRGB[0][1]* (*g) + camToLinSRGB[0][2]* (*b);
	fg2 = camToLinSRGB[1][0]* (*r) + camToLinSRGB[1][1]* (*g) + camToLinSRGB[1][2]* (*b);
	fb2 = camToLinSRGB[2][0]* (*r) + camToLinSRGB[2][1]* (*g) + camToLinSRGB[2][2]* (*b);

	// Normalize values to be between 0-1.0
	fr2 /= 65535;
	fg2 /= 65535;
	fb2 /= 65535;

	clip1f(fr2);
	clip1f(fg2);
	clip1f(fb2);

	// sRGB Gamma
	if( fr2 <= 0.0031308 )
		fr2 *= 12.92;
	else
		fr2 = (1+0.055)*pow(fr2,1.0/2.4)-0.055;

	if( fg2 <= 0.0031308 )
		fg2 *= 12.92;
	else
		fg2 = (1+0.055)*pow(fg2,1.0/2.4)-0.055;

	if( fb2 <= 0.0031308 )
		fb2 *= 12.92;
	else
		fb2 = (1+0.055)*pow(fb2,1.0/2.4)-0.055;

	// Scale to 16 bit and clip
	fr2 *= 65535;
	fg2 *= 65535;
	fb2 *= 65535;

	*r = clip16bit(fr2);
	*g = clip16bit(fg2);
	*b = clip16bit(fb2);
}

int main (int argc, const char **argv) {
	const char* ifname = argv[1];
	const char* ofname = argv[2];

	char *image;
	uint32_t BPP = 16; // Bits per Pixel
	uint32_t WIDTH = 4096;
	uint32_t HEIGHT = 3072;
	uint32_t IMAGE_SIZE = BPP/8*WIDTH*HEIGHT;
	uint32_t OUT_FILE_SIZE = IMAGE_SIZE*3 + TIFF_HDR_SIZE;

	int input_fd = 0;
	int output_fd = 0;
	void * bayer = NULL;
	void * rgb = NULL, *rgb_start = NULL;
	dc1394color_filter_t first_color = DC1394_COLOR_FILTER_GBRG;
	dc1394bayer_method_t method = DC1394_BAYER_METHOD_VNG;

	input_fd = open(ifname, O_RDONLY);
	if(input_fd < 0)
	{
		printf("Problem opening input: %s\n", ifname);
		return 1;
	}

	lseek(input_fd, 0, 0);

	output_fd = open(ofname, O_RDWR | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH );
	if(output_fd < 0)
	{
		printf("Problem opening output: %s\n", ofname);
		return 1;
	}
	printf("Files Opened\n");
	ftruncate(output_fd, OUT_FILE_SIZE );

	bayer = mmap(NULL, IMAGE_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE /*| MAP_POPULATE*/, input_fd, 0);
	if( bayer == MAP_FAILED )
	{
		perror("Faild mmaping input");
		return 1;
	}
	rgb_start = rgb = mmap(NULL, OUT_FILE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED /*| MAP_POPULATE*/, output_fd, 0);
	if( rgb == MAP_FAILED )
	{
		perror("Faild mmaping output");
		return 1;
	}
	printf("Mapped\n");
	rgb_start = put_tiff(rgb, WIDTH, HEIGHT, BPP);
	printf("Tiff header\n");

	printf("Debayering...\n");
	dc1394_bayer_decoding_16bit((const uint16_t*)bayer, (uint16_t*)rgb_start, WIDTH, HEIGHT, first_color, method, BPP);

	printf("Debayering complete. Converting to sRGB.\n");

	uint16_t *r,*g,*b;
	uint16_t *ptr = (uint16_t*)rgb_start;

	initLUT();
	initGAMMA_LUT();
	for( int i = 0; i < WIDTH*HEIGHT; i++) {
		r = ptr++;
		g = ptr++;
		b = ptr++;

		// Uncomment to use matrix
		cameraToSRGB(r,g,b);

		// Uncomment to use LUT
		//cameraToSRGB_LUT(r,g,b);
	}
	munmap(bayer,IMAGE_SIZE);
	close(input_fd);
	if( msync(rgb, OUT_FILE_SIZE, MS_INVALIDATE|MS_SYNC) != 0 )
		perror("Problem msyncing");
	munmap(rgb,OUT_FILE_SIZE);
	if( fsync(output_fd) != 0 )
		perror("Problem fsyncing");
	close(output_fd);

	printf("Tiff created\n");
	return 0;
}


