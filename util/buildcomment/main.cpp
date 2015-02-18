//
//  main.cpp
//  crc32test
//
//  Created by Magnus Runesson on 16/02/15.
//  Copyright (c) 2015 Untitled. All rights reserved.
//

#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <stdio.h>

typedef unsigned long int uLong;


/* ========================================================================
 * Table of CRC-32's of all single-byte values (made by make_crc_table)
 */
const unsigned long int crc_table[256] =
{
	0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
	0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
	0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
	0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
	0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
	0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
	0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
	0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
	0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
	0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
	0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
	0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
	0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
	0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
	0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
	0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
	0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
	0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
	0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
	0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
	0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
	0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
	0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
	0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
	0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
	0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
	0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
	0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
	0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
	0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
	0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
	0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
	0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
	0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
	0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
	0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
	0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
	0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
	0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
	0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
	0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
	0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
	0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
	0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
	0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
	0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
	0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
	0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
	0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
	0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
	0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
	0x2d02ef8dL
};

#define DO1(buf) crc = crc_table[((int)crc ^ (*buf++)) & 0xff] ^ (crc >> 8);
#define DO2(buf)  DO1(buf); DO1(buf);
#define DO4(buf)  DO2(buf); DO2(buf);
#define DO8(buf)  DO4(buf); DO4(buf);

unsigned long int crc32( unsigned long int crc, const unsigned char* buf, unsigned int len)
{
	if (buf == NULL) return 0L;
		crc = crc ^ 0xffffffffL;
		while (len >= 8)
		{
			DO8(buf);
			len -= 8;
		}
	if (len) do {
		DO1(buf);
	} while (--len);
	return crc ^ 0xffffffffL;
}

#define LINE_LENGTH (4096)

unsigned char* inFileContent;
unsigned char currentLine[ LINE_LENGTH ];
unsigned char currentLabel[ LINE_LENGTH ];
int currentOffset;
int currentFileSize;

void openInFile( const char* _pszFileName )
{
	FILE* f = fopen( _pszFileName, "rt" );
	fseek( f, 0, SEEK_END );
	currentFileSize = (int)ftell( f );
	fseek( f, 0, SEEK_SET );

	inFileContent = new unsigned char[ currentFileSize ];
	fread( inFileContent, 1, currentFileSize, f );

	fclose( f );

	currentOffset = 0;
}

bool iseol( char _c )
{
	if( _c == 0x0a )
		return true;
	
	return false;
}

bool isWhiteSpaceCharacter(char _c)
{
	if (_c == 0x09 || _c == 0x0a || _c == 0x0d || _c == 0x20 )
		return true;

	return false;
}

unsigned char* readLine()
{
	if( currentOffset >= currentFileSize )
		return NULL;
	
	int lineOffset = 0;
	memset( currentLine, 0, LINE_LENGTH );
	do
	{
		char c = inFileContent[ currentOffset ];
		if( iseol( c ))
		{
			currentLine[ lineOffset ] = 0;
			currentOffset++;
			break;
		}
		
		if( currentOffset >= currentFileSize )
		{
			currentLine[ lineOffset ] = 0;
			break;
		}
		
		currentLine[ lineOffset ] = c;
		lineOffset++;
		currentOffset++;
	}
	while( true );
	
	return currentLine;
}

unsigned char* skipWhiteSpaceCharacters(unsigned char* _pszLine)
{
	char c = _pszLine[0];

	if (c == 0)
		return _pszLine;

	while (isWhiteSpaceCharacter(c))
	{
		_pszLine++;
		c = _pszLine[0];
		if (c == 0)
			break;
	}

	return _pszLine;
}

unsigned char* skipNonWhiteSpaceCharacters(unsigned char* _pszLine)
{
	char c = _pszLine[0];

	if (c == 0)
		return _pszLine;

	while (!isWhiteSpaceCharacter(c))
	{
		_pszLine++;
		c = _pszLine[0];
		if (c == 0)
			break;
	}

	return _pszLine;
}

unsigned char tempLabel[ LINE_LENGTH ];

unsigned char* getLabel( unsigned char* _pszLine )
{
	memset(tempLabel, 0, LINE_LENGTH);
	
	if( _pszLine[ 0 ] != 'F' )
		return NULL;	// No label on this line
	
	int lineLength = (int)strlen( (char*)_pszLine );
	int i = 15;
	bool foundLabel = false;
	while( i < lineLength )
	{
		unsigned char c = _pszLine[ i ];
		if( c == ';' )
			break;
		
		tempLabel[ i-15 ] = c;
		if( c == ':' )
		{
			tempLabel[ i-15+1 ] = 0;
			foundLabel = true;
			break;
		}
		i++;
	}
	
	if( foundLabel )
		return tempLabel;
	
	// No label on this line
	return NULL;
}

unsigned char opBuff[ 1024 ];

unsigned char hextoint( unsigned char _c )
{
	if( _c >= 'a' )
		return _c - 'a' + 10;
	
	if( _c >= 'A' )
		return _c - 'A' + 10;
	
	return _c - '0';
}

unsigned char* getOpCodeBuffer( unsigned char* _pszLine, int* _outBuffLen )
{
	_pszLine += 30;
	int numcodes = (int)(strlen( (char*)_pszLine )+1) / 3;

	//printf("op codes: %s (%i)\n", _pszLine, *_outBuffLen );
	//printf("op codes: ");
	int icode;
	for( icode=0; icode<numcodes; icode++ )
	{
		int code = hextoint(*_pszLine++)*0x10;
		code += hextoint(*_pszLine++);
		opBuff[ icode ] = code;
		_pszLine++;		// Also skip the space character
		//printf( "%02x ", opBuff[ icode ]);
	}
	//printf("\n");

	*_outBuffLen = numcodes;
	return opBuff;
}

unsigned int getAddress( unsigned char* _pszLine )
{
	int address = 0;
	_pszLine += 19;
	int i;
	unsigned int mull = 0x10000000;
	for( i=0; i<8; i++ )
	{
		unsigned char c = *_pszLine;
		c = hextoint( c );
		address += (c)*mull;
		_pszLine++;
		mull >>= 4;
	}
	return address;
}

unsigned char pszOriginalCode[ LINE_LENGTH ];

unsigned char* getOriginalCode( unsigned char* _pszLine )
{
	_pszLine += 15;
	if( *_pszLine != '\t' )
		return NULL;

	_pszLine++;
	
	memset( pszOriginalCode, 0, LINE_LENGTH );
	int i;
	for( i=0; i<strlen( (char*)_pszLine ); i++ )
	{
		unsigned char c = _pszLine[ i ];
		if( c == '<' )
		{
			strcat( (char*)&pszOriginalCode[i], "&lt;");
			i += 3;
		}
		else if( c == '>' )
		{
			strcat( (char*)&pszOriginalCode[i], "&gt;");
			i += 3;
		}
		else if( c == '&' )
		{
			strcat( (char*)&pszOriginalCode[i], "&amp;");
			i += 4;
		}
 		else if( c == '\"' )
		{
			strcat( (char*)&pszOriginalCode[i], "&quot;");
			i += 5;
		}
		else
		{
			pszOriginalCode[ i ] = c;
		}
	}
	
	return pszOriginalCode;
}

unsigned char pszLastLabel[ LINE_LENGTH ];
unsigned char pszLastLine[ LINE_LENGTH ];

int main(int argc, const char * argv[])
{
	if( argc < 4 )
	{
		printf("FAIL! Not enough parameter. Usage:\n\tmakecmt <in: listing file> <out: comment file> <system name>\n");
		return 0;
	}
	
	char* pszInFile = (char*)argv[ 1 ];
	char* pszOutFile = (char*)argv[ 2 ];
	char *pszSystemName = (char*)argv[ 3 ];
	
	printf("input file=%s\noutputfile=%s\n", pszInFile, pszOutFile );

	openInFile( pszInFile );
	
	FILE* outFile = fopen( pszOutFile, "wt" );
	
	fprintf(outFile, "<?xml version=\"1.0\"?>\n");
	fprintf(outFile, "<!-- This file is autogenerated; comments and unknown tags will be stripped -->\n");
	fprintf(outFile, "<mamecommentfile version=\"1\">\n" );
	fprintf(outFile, "    <system name=\"");
	fprintf(outFile, pszSystemName);
	fprintf(outFile, "\">\n");
	fprintf(outFile, "        <cpu tag=\":maincpu\">\n" );
	
	int iLine = 0;
	unsigned char* pszLine = NULL;
	bool haveLabel = false;
	while( (pszLine = readLine()) != NULL )
	{
		unsigned char* label = getLabel( pszLine );
		if( label != NULL)
		{
			strcpy( (char*)pszLastLabel, (const char*)label);
			haveLabel = true;
		}
		
		if( memcmp( pszLine, "               S", 16) == 0 )
		{
			int opbufflen;
			unsigned char* opcodes = getOpCodeBuffer( pszLine, &opbufflen );
			unsigned long int crc = crc32( 0, opcodes, opbufflen );
			unsigned int address = getAddress( pszLine );
			
			
			if( haveLabel )
			{
				fprintf(outFile, "            <comment address=\"%i\" color=\"16711680\" crc=\"%08x\">\n", address, (unsigned int)crc );
				fprintf(outFile, "                %s\n", pszLastLabel);
				haveLabel = false;
				fprintf(outFile, "            </comment>\n");
			}
			else
			{
				unsigned char* src = getOriginalCode( pszLastLine );
				if( src != NULL )
				{
					fprintf(outFile, "            <comment address=\"%i\" color=\"16711680\" crc=\"%08x\">\n", address, (unsigned int)crc );
					fprintf(outFile, "                %s\n", src );
					fprintf(outFile, "            </comment>\n");
				}
			}
		}
		
		strcpy( (char*)pszLastLine, (const char*)pszLine);
		iLine++;
	}
	
	fprintf(outFile, "        </cpu>\n");
    fprintf(outFile, "    </system>\n");
	fprintf(outFile, "</mamecommentfile>\n");
	
    return 0;
}
