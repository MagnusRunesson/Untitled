

#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define DISKSIZE (0xdc000)


uint8_t image[DISKSIZE];


static void boot_chksum(uint8_t *p)
{
	uint32_t oldchk, chk = 0;
	int i;

	memset(p + 4, 0, 4);
	for (i = 0; i < 1024; i += 4) {
		oldchk = chk;
		chk += ((uint32_t)p[i + 0] << 24) | ((uint32_t)p[i + 1] << 16) |
			((uint32_t)p[i + 2] << 8) | p[i + 3];
		if (chk < oldchk)
			++chk;  /* carry */
	}

	chk = ~chk;
	p[4] = (uint8_t)((chk >> 24) & 0xff);
	p[5] = (uint8_t)((chk >> 16) & 0xff);
	p[6] = (uint8_t)((chk >> 8) & 0xff);
	p[7] = (uint8_t)(chk & 0xff);
}


int main(int argc, char *argv[])
{
	FILE *fin;
	FILE *fout;
	int rc = 1;
	size_t len;

	if (argc == 2) {
		if (fin = fopen(argv[1], "rb")) {
			len = fread(image, 1, DISKSIZE, fin);
			fclose(fin);
			if (len > 0) {
				if (len < DISKSIZE)
					memset(image + len, 0, DISKSIZE - len);
				boot_chksum(image);
				if (fout = fopen(argv[1], "wb")) {
					fwrite(image, 1, DISKSIZE, fout);
					fclose(fout);
				}
				rc = 0;
			}
			else
				fprintf(stderr, "Image read error!\n");
		}
		else
			fprintf(stderr, "Cannot open '%s'!\n", argv[1]);
	}
	else
		fprintf(stderr, "Usage: %s <image data>\n", argv[0]);

	return rc;
}