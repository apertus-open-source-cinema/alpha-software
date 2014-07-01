/**********************************************************************
**  pmem.c
**	Manipulate and Dump Physical Memory
**	Version 1.4
**
**  Copyright (C) 2013-2014 H.Poetzl
**
**	This program is free software: you can redistribute it and/or
**	modify it under the terms of the GNU General Public License
**	as published by the Free Software Foundation, either version
**	2 of the License, or (at your option) any later version.
**
**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#define	VERSION	"V1.4"

static char *cmd_name = NULL;

static uint32_t map_base = 0x18000000;
static uint32_t map_size = 0x08000000;

static uint32_t map_addr = 0x00000000;

static bool msb_comp = false;

static char *dev_mem = "/dev/mem";

static char hex[16] = "0123456789ABCDEF";



typedef long long unsigned (stoull_t)(const char *, char **, int);

long long unsigned argtoull(
	const char *str, const char **end, stoull_t stoull)
{
	int bit, inv = 0;
	long long int val = 0;
	char *eptr;

	if (!str)
	    return -1;
	if (!stoull)
	    stoull = strtoull;
	
	switch (*str) {
	case '~':
	case '!':
	    inv = 1;	/* invert */
	    str++;
	default:
	    break;
	}

	while (*str) {
	    switch (*str) {
	    case '^':
		bit = strtol(str+1, &eptr, 0);
		val ^= (1LL << bit);
		break;
	    case '&':
		val &= stoull(str+1, &eptr, 0);
		break;
	    case '|':
		val |= stoull(str+1, &eptr, 0);
		break;
	    case '-':
	    case '+':
	    case ',':
	    case '=':
	    case '/':
	    case '{':
	    case '}':
		break;
	    default:
		val = stoull(str, &eptr, 0);
		break;
	    }
	    if (eptr == str)
		break;
	    str = eptr;
	}

	if (end)
	    *end = eptr;
	return (inv)?~(val):(val);
}


const char *parse_range(const char *ptr, uint32_t *base, uint32_t *size)
{
	const char *sep = NULL;
	uint32_t atop;

	*base = argtoull(ptr, &sep, strtoull);
	switch (sep[0]) {
	case '-':
	    ptr = sep + 1;
	    atop = argtoull(ptr, &sep, strtoull);
	    *size = atop - *base;
	    break;
	    
	case '+':
	    ptr = sep + 1;
	    *size = argtoull(ptr, &sep, strtoull);
	    break;
	}

	return sep;
}

int	parse_record(const char *ptr, uint32_t *bits, uint32_t num)
{
	const char *sep = NULL;

	for (int i=0; i<num; i++) {
	    bits[i] = argtoull(ptr, &sep, strtoull);

	    if (sep[0] == '}')
		return i + 1;
	    else
		ptr = &sep[1];
	}
	return -1;
}


static inline
uint64_t byte_set(uint64_t val, uint32_t pos, uint8_t byte)
{
	return (val & ~(0xFFLL << pos)) | ((uint64_t)byte << pos);
}

static inline
uint64_t bits_get(uint64_t val, uint32_t pos, uint32_t bits)
{
	return (val >> pos) & ((1LL << bits) - 1);
}


void	dump(uint32_t base, uint32_t size,
	uint32_t cols, uint32_t *bary, uint32_t bmod)
{
	uint8_t *vp = (void *)base;
	uint64_t bsize = size*8;
	uint64_t bpos = 0;
	uint64_t val, bval = 0;
	uint32_t bcnt = 0;
	uint32_t ccnt = 0;
	uint32_t bits = bary[0];

	while (bpos + bits <= bsize) {
	    while (bcnt < bits) {
		if (msb_comp) {
		    bval = byte_set(bval, bcnt, *vp++);
		    bcnt += 8;
		} else {
		    bval = (bval << 8LL) | *vp++;
		    bcnt += 8;
		}
	    }
	    if (ccnt == 0)
		printf("%08llx: ", bpos);
	    if ((bmod > 1) && !(ccnt % bmod))
		putchar('{');
	
	    if (msb_comp) {
		val = bits_get(bval, 0, bits);
		bval >>= bits;
	    } else {
		val = bits_get(bval, bcnt - bits, bits);
	    }
	    bcnt -= bits;

	    for (int n=(bits - 1)/4; n>=0; n--)
		putchar(hex[(val >> (4LL * n)) & 0xF]);

	    if ((bmod > 1) && (ccnt % bmod == bmod - 1))
		putchar('}');
	    if (++ccnt == cols) {
		putchar('\n');
		ccnt = 0;
	    } else {
		putchar(' ');
	    }
	
	    bpos += bits;
	    bits = bary[ccnt % bmod];
	}
	putchar('\n');
}


void	mem_fill(uint32_t base, uint32_t size, uint64_t val, char type)
{
	switch (type) {
	case 'B':
	case 'S':
	case 'W':
	case 'L':
	    break;
	default:
	    if (val > 0xFFFFFFFF)
		type = 'L';
	    else if (val > 0xFFFF)
		type = 'W';
	    else if (val > 0xFF)
		type = 'S';
	    else
		type = 'B';
	    break;
	}

	switch (type) {
	case 'B':
	    memset((void *)base, val, size);
	    fprintf(stderr,
		"filled 0x%lX bytes with 0x%02lX @ 0x%08lX.\n",
		(long unsigned)size, (long unsigned)val,
		(long unsigned)base);
	    break;

	case 'S':
	    for (uint16_t *vp = (void *)base;
		vp < (uint16_t *)(base + size); vp++)
		*vp = val & 0xFFFF;
	    fprintf(stderr,
		"filled 0x%lX shorts with 0x%04lX @ 0x%08lX.\n",
		(long unsigned)size/2, (long unsigned)val,
		(long unsigned)base);
	    break;

	case 'W':
	    for (uint32_t *vp = (void *)base;
		vp < (uint32_t *)(base + size); vp++)
		*vp = val & 0xFFFFFFFF;
	    fprintf(stderr,
		"filled 0x%lX words with 0x%08lX @ 0x%08lX.\n",
		(long unsigned)size/4, (long unsigned)val,
		(long unsigned)base);
	    break;

	case 'L':
	    for (uint64_t *vp = (void *)base;
		vp < (uint64_t *)(base + size); vp++)
		*vp = val;
	    fprintf(stderr,
		"filled 0x%lX longs with 0x%016llX @ 0x%08lX.\n",
		(long unsigned)size/8, (long long unsigned)val,
		(long unsigned)base);
	    break;
	}
}

void	mem_mark(uint32_t base, uint32_t size, char type)
{
	switch (type) {
	case 'B':
	case 'S':
	case 'W':
	case 'L':
	    break;
	default:
	    type = 'W';
	    break;
	}

	switch (type) {
	case 'B':
	    for (uint8_t *vp = (void *)base;
	    	vp < (uint8_t *)(base + size); vp++)
	    	*vp = (uint32_t)vp & 0xFF;
	    fprintf(stderr,
		"marked 0x%lX bytes @ 0x%08lX.\n",
		(long unsigned)size,
		(long unsigned)base);
	    break;

	case 'S':
	    for (uint16_t *vp = (void *)base;
		vp < (uint16_t *)(base + size); vp++)
		*vp = (uint32_t)vp & 0xFFFF;
	    fprintf(stderr,
		"marked 0x%lX shorts @ 0x%08lX.\n",
		(long unsigned)size/2,
		(long unsigned)base);
	    break;

	case 'W':
	    for (uint32_t *vp = (void *)base;
		vp < (uint32_t *)(base + size); vp++)
		*vp = (uint32_t)vp;
	    fprintf(stderr,
		"marked 0x%lX words @ 0x%08lX.\n",
		(long unsigned)size/4,
		(long unsigned)base);
	    break;

	case 'L':
	    for (uint64_t *vp = (void *)base;
		vp < (uint64_t *)(base + size); vp++)
		*vp = (uint32_t)vp;
	    fprintf(stderr,
		"marked 0x%lX longs @ 0x%08lX.\n",
		(long unsigned)size/8,
		(long unsigned)base);
	    break;
	}
}

void	mem_dump(uint32_t base, uint32_t size, uint32_t cols, const char *sep)
{
	uint32_t bits[64] = { 0 };
	int num;
	char type = 'W';

	if (sep[0] == '/') {
	    switch (sep[1]) {
	    case 'B': bits[0] =  8; type = sep[1]; break;
	    case 'S': bits[0] = 16; type = sep[1]; break;
	    case 'W': bits[0] = 32; type = sep[1]; break;
	    case 'L': bits[0] = 64; type = sep[1]; break;
	    default:
		bits[0] = argtoull(&sep[1], NULL, NULL);
		type = '?';
		break;
	    }
	} else if (sep[0] == '{') {
	    num = parse_record(&sep[1], bits, 64);
	    if (num < 0) {
		bits[0] = 1;
		num = 1;
	    }
	    type = '{';
	}

	switch (type) {
	case 'B':
	    bits[0] = 8;
	    dump(base, size, cols, bits, 1);
	    fprintf(stderr,
		"dumped 0x%lX bytes @ 0x%08lX.\n",
		(long unsigned)size, (long unsigned)base);
	    break;

	case 'S':
	    bits[0] = 16;
	    dump(base, size, cols, bits, 1);
	    fprintf(stderr,
		"dumped 0x%lX shorts @ 0x%08lX.\n",
		(long unsigned)size/2, (long unsigned)base);
	    break;

	case 'W':
	    bits[0] = 32;
	    dump(base, size, cols, bits, 1);
	    fprintf(stderr,
		"dumped 0x%lX words @ 0x%08lX.\n",
		(long unsigned)size/4, (long unsigned)base);
	    break;

	case 'L':
	    bits[0] = 64;
	    dump(base, size, cols, bits, 1);
	    fprintf(stderr,
		"dumped 0x%lX longs @ 0x%08lX.\n",
		(long unsigned)size/8, (long unsigned)base);
	    break;

	case '?':
	    dump(base, size, cols, bits, 1);
	    fprintf(stderr,
		"dumped 0x%llX values @ 0x%08lX.\n",
		(long long unsigned)size, (long unsigned)base);
	    break;

	case '{':
	    fprintf(stderr, "%d,%d,%d,%d,%d,%d,%d,%d [%d]\n",
		bits[0], bits[1], bits[2], bits[3],
		bits[4], bits[5], bits[6], bits[7], num);

	    dump(base, size, cols * num, bits, num);
	    fprintf(stderr,
		"dumped 0x%llX records @ 0x%08lX.\n",
		(long long unsigned)size, (long unsigned)base);
	    break;
	}
}

int	main(int argc, char *argv[])
{
	extern int optind;
	extern char *optarg;
	int c, err_flag = 0;

#define	OPTIONS "hmB:S:A:"

	cmd_name = argv[0];
	while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
	    switch (c) {
	    case 'h':
		fprintf(stderr,
		    "This is %s " VERSION "\n"
		    "options are:\n"
		    "-h        print this help message\n"
		    "-m        msb composite\n"
		    "-B <val>  memory mapping base\n"
		    "-S <val>  memory mapping size\n"
		    "-A <val>  memory mapping address\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'm':
		msb_comp = true;
		break;
	    case 'B':
		map_base = argtoull(optarg, NULL, NULL);
		break;
	    case 'S':
		map_size = argtoull(optarg, NULL, NULL);
		break;
	    case 'A':
		map_addr = argtoull(optarg, NULL, NULL);
		break;
	    case '?':
	    default:
		err_flag++;
		break;
	    }
	}
	if (err_flag) {
	    fprintf(stderr, 
		"Usage: %s -[" OPTIONS "] path ...\n"
		"%s -h for help.\n",
		cmd_name, cmd_name);
	    exit(2);
	}


	int fd = open(dev_mem, O_RDWR | O_SYNC);
	if (fd == -1) {
	    fprintf(stderr,
		"error opening >%s<.\n%s\n",
		dev_mem, strerror(errno));
	    exit(1);
	}

	if (map_addr == 0)
	    map_addr = map_base;

	void *base = mmap((void *)map_addr, map_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, map_base);
	if (base == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)map_base, (long)map_size, (long)map_addr,
		strerror(errno));
	    exit(2);
	}

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)map_base, (long unsigned)map_size,
	    (long unsigned)base);

	for (; optind < argc; optind++) {
	    const char *cmd = argv[optind];
	    const char *ptr = cmd;
	    const char *sep;

	    uint32_t addr_base = map_base;
	    uint32_t addr_size = map_size;
	    uint64_t val;
	    ssize_t len;

	    switch (cmd[0]) {
	    case 'R':		/* Read */
		ptr = parse_range(&cmd[1], &addr_base, &addr_size);
		len = write(1,
		    (void *)((addr_base - map_base) + map_addr),
		    addr_size);
		fprintf(stderr,
		    "read 0x%lX bytes @ 0x%08lX. [%s]\n",
		    (long unsigned)len, (long unsigned)addr_base,
		    strerror(errno));
		break;
		
	    case 'W':		/* Write */
		ptr = parse_range(&cmd[1], &addr_base, &addr_size);
		len = read(0,
		    (void *)((addr_base - map_base) + map_addr),
		    addr_size);
		fprintf(stderr,
		    "wrote 0x%lX bytes @ 0x%08lX. [%s]\n",
		    (long unsigned)len, (long unsigned)addr_base,
		    strerror(errno));
		break;

	    case 'D':		/* Dump */
		ptr = parse_range(&cmd[1], &addr_base, &addr_size);
		switch (ptr[0]) {
		case ',':
		    val = argtoull(&ptr[1], &sep, NULL);
		    ptr = sep;
		    break;
		default:
		    val = 0;
		}
		mem_dump(((addr_base - map_base) + map_addr),
		    addr_size, val, ptr);
		break;

	    case 'F':		/* Fill */
		ptr = parse_range(&cmd[1], &addr_base, &addr_size);
		switch (ptr[0]) {
		case ',':
		case '=':
		    val = argtoull(&ptr[1], &sep, NULL);
		    break;
		default:
		    val = ~0L;
		}
		if (sep[0] == '/')
		    sep++;
		mem_fill(((addr_base - map_base) + map_addr),
		    addr_size, val, sep[0]);
		break;

	    case 'M':		/* Mark */
		ptr = parse_range(&cmd[1], &addr_base, &addr_size);
		if (ptr[0] == '/')
		    ptr++;
		mem_mark(((addr_base - map_base) + map_addr),
		    addr_size, ptr[0]);
		break;

	    case 'Z':		/* Zero */
		ptr = parse_range(&cmd[1], &addr_base, &addr_size);
		memset((void *)((addr_base - map_base) + map_addr),
		    0, addr_size);
		fprintf(stderr,
		    "zeroed 0x%lX bytes @ 0x%08lX.\n",
		    (long unsigned)addr_size, (long unsigned)addr_base);
		break;

	    default:
		printf(">%s<\n", cmd);
		break;
	    }
	}

	exit((err_flag)?1:0);
}

