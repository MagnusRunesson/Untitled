using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class TilePalette
{
	Color[] m_colors;

	public TilePalette( PalettizedImage _sourceImage )
	{
		m_colors = new Color[ 16 ];

		int iCol;
		for( iCol=0; iCol<16; iCol++ )
		{
			Color c = _sourceImage.m_palette[ iCol ];
			Color qc = Quantize( c );
			m_colors[ iCol ] = qc;
		}
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting palette to " + _outfilename );

		int outsize = 16*2;
		byte[] outBytes = new byte[ outsize ];

		int i;
		for( i=0; i<16; i++ )
		{
			int r = (((int)(m_colors[ i ].r*255.0f)) >> 4) & 0x0f;
			int g = (((int)(m_colors[ i ].g*255.0f)) >> 4) & 0x0f;
			int b = (((int)(m_colors[ i ].b*255.0f)) >> 4) & 0x0f;

			//int value = (r<<8) + (g<<4) + (b<<0);

			int wrOfs = i*2;
			//outBytes[ wrOfs+0 ] = (byte)(value&0xff);
			//outBytes[ wrOfs+1 ] = (byte)((value>>8)&0xff);
			outBytes[ wrOfs+0 ] = (byte)(b);
			outBytes[ wrOfs+1 ] = (byte)((g<<4)+r);

			/*

Rött
			outBytes[ wrOfs+0 ] = 0x00;
			outBytes[ wrOfs+1 ] = 0x0e;

grönt
			outBytes[ wrOfs+0 ] = 0x00;//(byte)((g<<4)+(b));
			outBytes[ wrOfs+1 ] = 0xe0;//(byte)(r);

blått
			outBytes[ wrOfs+0 ] = 0x0e;//(byte)((g<<4)+(b));
			outBytes[ wrOfs+1 ] = 0x00;//(byte)(r);

			 			*/
		}

		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}

	Color Quantize( Color _in )
	{
		Color ret = new Color( Quantize( _in.r ), Quantize( _in.g ), Quantize( _in.b ), Quantize( _in.a ));
		return ret;
	}

	float Quantize( float _i )
	{
		int a = (int)(_i*255.0f);
		a /= 32;
		a *= 32;
		return ((float)a) / 255.0f;
	}
}
