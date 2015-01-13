using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PalettizedImage
{
	public List<Color> m_palette;
	public List<bool> m_colorUsed;
	public int m_width;
	public int m_height;
	public byte[] m_image;
	public string m_fileName;
	public PalettizedImageConfig m_config;

	static public PalettizedImage LoadBMP( string _path, PalettizedImageConfig _config )
	{
		string filename = System.IO.Path.GetFileNameWithoutExtension( _path );

		byte[] imageFile = System.IO.File.ReadAllBytes( _path );
		//Debug.Log("Image header from file '"+filename+"': " + imageFile[ 0 ] + "," + imageFile[ 1 ] + "," + imageFile[ 2 ]);
		int pixelsOffset = ReadInt( imageFile, 0x0a );
		int width = ReadInt( imageFile, 0x12 );
		int height = ReadInt( imageFile, 0x16 );
		int bpp = ReadWord ( imageFile, 0x1c );

		//Debug.Log ("width=" + width + ", height=" + height + ", bpp=" + bpp + " (pixels start=" + pixelsOffset + ")" );

		PalettizedImage image = new PalettizedImage( width, height );
		image.SetConfig( _config );
		image.m_fileName = filename;
		if( image.ReadPalette( imageFile, 0x36 ) == false )
			return null;

		if( image.ReadImage( imageFile, pixelsOffset, bpp ) == false )
			return null;

		return image;
	}

	PalettizedImage( int _width, int _height )
	{
		m_width = _width;
		m_height = _height;
		m_palette = new List<Color>();
		m_colorUsed = new List<bool>();
		m_image = new byte[ m_width * m_height ];
	}

	void SetConfig( PalettizedImageConfig _config )
	{
		m_config = _config;
	}

	bool ReadPalette( byte[] _array, int _offset )
	{
		int c;
		for( c=0; c<256; c++ )
		{
			int c2 = c;
			if( m_config.m_colorRemapSourceToDest.ContainsKey( c ))
				c2 = m_config.m_colorRemapSourceToDest[ c ];

			int i = _offset+(c2*4);
			int r = _array[ i+2 ];
			int g = _array[ i+1 ];
			int b = _array[ i+0 ];
			int a = _array[ i+3 ];
			float fr = ((float)r) / 255.0f;
			float fg = ((float)g) / 255.0f;
			float fb = ((float)b) / 255.0f;
			float fa = ((float)a) / 255.0f;
			fa = 1.0f;

			/*
			if((c%16) == 0 )
				fa = 0.0f;
			else
				fa = 1.0f;
				*/

			Color col = new Color( fr, fg, fb, fa );
			m_palette.Add( col );
			m_colorUsed.Add( false );
		}

		return true;
	}

	bool ReadImage( byte[] _array, int _offset, int _bpp )
	{
		if( _bpp != 8 )
		{
			Debug.LogException( new UnityException( "Can only read 8 BPP images." ));
			return false;
		}

		int x,y;
		for( y=0; y<m_height; y++ )
		{
			for( x=0; x<m_width; x++ )
			{
				int src_i = ((m_height-1-y)*m_width)+x;
				int dst_i = (y*m_width)+x;
				byte src_c = _array[ _offset + src_i ];
				byte remapped_c = src_c;
				if( m_config.m_colorRemapSourceToDest.ContainsKey( (int)src_c ))
					remapped_c = (byte)m_config.m_colorRemapSourceToDest[ src_c ];
				m_colorUsed[ remapped_c ] = true;
				m_image[ dst_i ] = remapped_c;
			}
		}

		return true;
	}

	static int ReadInt( byte[] _array, int _offset )
	{
		int ret = _array[ _offset ] + (_array[ _offset+1 ] << 8) + (_array[ _offset+2 ]<<16) + (_array[ _offset+3 ]<<24);
		return ret;
	}

	static int ReadWord( byte[] _array, int _offset )
	{
		int ret = _array[ _offset ] + (_array[ _offset+1 ] << 8);
		return ret;
	}
}
