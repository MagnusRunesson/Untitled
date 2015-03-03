﻿using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Hjg.Pngcs;
using Hjg.Pngcs.Chunks;

[System.Serializable]
public class PalettizedImage
{
	public List<Color> m_palette;
	public List<bool> m_colorUsed;
	public int m_width;
	public int m_height;
	public byte[] m_image;
	public string m_fileName;
	public PalettizedImageConfig m_config;
	int m_coloursInPalette;

	static public PalettizedImage LoadImage( string _path, PalettizedImageConfig _config )
	{
		string ext = System.IO.Path.GetExtension( _path ).ToLower();
		if( ext.Equals( ".bmp" ))
			return LoadBMP( _path, _config );

		if( ext.Equals( ".png" ))
			return LoadPNG( _path, _config );

		return null;
	}

	static public PalettizedImage LoadPNG( string _path, PalettizedImageConfig _config )
	{
		PngReader pngr = FileHelper.CreatePngReader( _path );
		if( !pngr.ImgInfo.Indexed )
		{
			Debug.LogException( new UnityException( "Image wasn't indexed" ));
			return null;
		}

		PngChunkPLTE palette = pngr.GetMetadata().GetPLTE();

		PalettizedImage image = new PalettizedImage( pngr.ImgInfo.Cols, pngr.ImgInfo.Rows, palette.GetNentries());
		image.SetConfig( _config );
		image.m_fileName = System.IO.Path.GetFileNameWithoutExtension( _path );

		image.ReadPalette( palette );
		image.ReadImage( pngr );

		return image;
	}

	static public PalettizedImage LoadBMP( string _path, PalettizedImageConfig _config )
	{
		string filename = System.IO.Path.GetFileNameWithoutExtension( _path );

		byte[] imageFile = System.IO.File.ReadAllBytes( _path );
		//Debug.Log("Image header from file '"+filename+"': " + imageFile[ 0 ] + "," + imageFile[ 1 ] + "," + imageFile[ 2 ]);
		int pixelsOffset = ReadInt( imageFile, 0x0a );
		int width = ReadInt( imageFile, 0x12 );
		int height = ReadInt( imageFile, 0x16 );
		int bpp = ReadWord ( imageFile, 0x1c );
		int coloursInPalette = ReadWord ( imageFile, 0x2e );
		//Debug.Log ("width=" + width + ", height=" + height + ", bpp=" + bpp + " (pixels start=" + pixelsOffset + ") Colours in palette=" + coloursInPalette );

		if( coloursInPalette == 0 )
			coloursInPalette = 256;
		PalettizedImage image = new PalettizedImage( width, height, coloursInPalette );
		image.SetConfig( _config );
		image.m_fileName = filename;
		if( image.ReadPalette( imageFile, 0x36 ) == false )
			return null;

		if( image.ReadImage( imageFile, pixelsOffset, bpp ) == false )
			return null;

		return image;
	}

	PalettizedImage( int _width, int _height, int _coloursInPalette )
	{
		m_width = _width;
		m_height = _height;
		m_palette = new List<Color>();
		m_colorUsed = new List<bool>();
		m_image = new byte[ m_width * m_height ];
		m_coloursInPalette = _coloursInPalette;
	}

	void SetConfig( PalettizedImageConfig _config )
	{
		m_config = _config;
	}

	bool ReadPalette( byte[] _array, int _offset )
	{
		int c;
		for( c=0; c<m_coloursInPalette; c++ )
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

		while( c < 16 )
		{
			m_palette.Add( new Color( 1.0f, 0.0f, 1.0f, 1.0f ));
			m_colorUsed.Add( false );
			c++;
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

	bool ReadPalette( PngChunkPLTE _palette )
	{
		int[] rgb = new int[ 4 ];
		int c;
		for( c=0; c<m_coloursInPalette; c++ )
		{
			int c2 = c;
			if( m_config.m_colorRemapSourceToDest.ContainsKey( c ))
				c2 = m_config.m_colorRemapSourceToDest[ c ];

			_palette.GetEntryRgb( c2, rgb );
			float fr = ((float)rgb[ 0 ]) / 255.0f;
			float fg = ((float)rgb[ 1 ]) / 255.0f;
			float fb = ((float)rgb[ 2 ]) / 255.0f;
			//float fa = ((float)a) / 255.0f;
			float fa = 1.0f;
			
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
		
		while( c < 16 )
		{
			m_palette.Add( new Color( 1.0f, 0.0f, 1.0f, 1.0f ));
			m_colorUsed.Add( false );
			c++;
		}
		
		return true;
	}
	
	bool ReadImage( PngReader _png )
	{
		/*
		ImageLine line = pngr.ReadRowInt( y );
		int[] scanline = line.Scanline;
		
		string l = "";
		for( int x=0; x<scanline.Length; x++ )
		{
			int ci = scanline[ x ];
			l += ci.ToString() + ",";
		}
		
		Debug.Log ("line " + y + ": " + l );
		*/


		int x,y;
		for( y=0; y<m_height; y++ )
		{
			ImageLine line = _png.ReadRowByte( y );
			//byte[] lineBytes = _png.ReadRowByte( y );
			byte[] lineBytes = line.ScanlineB;// GetScanlineInt();

			for( x=0; x<m_width; x++ )
			{
				byte src_c = lineBytes[ x ];
				byte remapped_c = src_c;
				if( m_config.m_colorRemapSourceToDest.ContainsKey( (int)src_c ))
					remapped_c = (byte)m_config.m_colorRemapSourceToDest[ src_c ];
				m_colorUsed[ remapped_c ] = true;

				int dst_i = (y*m_width)+x;
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
