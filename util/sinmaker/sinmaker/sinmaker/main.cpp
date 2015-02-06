//
//  main.cpp
//  sinmaker
//
//  Created by Magnus Runesson on 06/02/15.
//  Copyright (c) 2015 Untitled. All rights reserved.
//

#include <stdio.h>
#include <math.h>

int main(int argc, const char * argv[])
{
	FILE* f = fopen("/Users/magnusrunesson/sintable.asm", "wt");
	
	fprintf(f, "sintable:\n");
	//
	const int tableEntries = 256;			// This is the number of entries from 0 to 360 degrees
	int entry;
	for( entry=0; entry<tableEntries; entry++ )
	{
		float angle = entry * (360.0f / ((float)tableEntries));
		float value = sinf( angle * (3.1415f/180.0f)) * 256.0f;
		int intvalue = (int)value;
		printf("entry %d: angle=%f, value=%f, intvalue=%d\n", entry, angle, value, intvalue );
		fprintf(f, "\tdc.w\t$%04x\n", intvalue & 0xffff );
	}
	fclose(f);
    return 0;
}
