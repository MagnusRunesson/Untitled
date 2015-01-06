using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Tile
{
	public const int Width = 8;
	public const int Height = 8;
	public byte[] m_pixels;

	public Tile( PalettizedImage _sourceImage, int _startX, int _startY )
	{
		// Allocate space
		m_pixels = new byte[ Width*Height ];

		// Copy from source image
		int x, y;
		for( y=0; y<Height; y++ )
		{
			for( x=0; x<Width; x++ )
			{
				int src_i = ((_startY+y)*_sourceImage.m_width)+(_startX+x);
				int dst_i = y*Width+x;
				m_pixels[ dst_i ] = _sourceImage.m_image[ src_i ];
			}
		}
	}

	public bool Equals( Tile _other, out bool _flipX, out bool _flipY )
	{
		// Assume they are identical until proven otherwise
		bool sameRegular = true;
		bool sameFlipX = true;
		bool sameFlipY = true;
		bool sameFlipXY = true;

		// 
		int x, y;
		for( y=0; y<Height; y++ )
		{
			for( x=0; x<Width; x++ )
			{
				// 
				int other_i;
				int this_i = (y*Width)+x;
				byte this_pixel = m_pixels[ this_i ];

				// Check regular
				other_i = (y*Width)+x;
				if( _other.m_pixels[ other_i ] != this_pixel )
					sameRegular = false;

				// Check flip X
				other_i = (y*Width)+(Width-1-x);
				if( _other.m_pixels[ other_i ] != this_pixel )
					sameFlipX = false;
				
				// Check flip Y
				other_i = ((Height-1-y)*Width)+x;
				if( _other.m_pixels[ other_i ] != this_pixel )
					sameFlipY = false;

				// Check flip X and Y
				other_i = ((Height-1-y)*Width)+(Width-1-x);
				if( _other.m_pixels[ other_i ] != this_pixel )
					sameFlipXY = false;

				// Check if all have failed
				if(( sameRegular == false )
				   && ( sameFlipX == false )
				   && ( sameFlipY == false )
				   && ( sameFlipXY == false ))
				{
					_flipX = false;
					_flipY = false;
					return false;
				}
			}
		}

		// This tile exist in some form. Check which form.

		// Only append the flip flag if it doesn't fit without flipping (completely blank tiles can also work as flipped so for those we avoid having any flip flags)
		if( sameRegular == false )
		{
			// Should it be flipped?
			if( sameFlipX || sameFlipXY )
				_flipX = true;
			else
				_flipX = false;

			// Should it be flipped?
			if( sameFlipY || sameFlipXY )
				_flipY = true;
			else
				_flipY = false;
		}
		else
		{
			_flipX = false;
			_flipY = false;
		}
		
		return true;
	}
}

public class TileBank
{
	public List<Tile> m_tiles;

	public TileBank( PalettizedImage _image )
	{
		//
		m_tiles = new List<Tile>();

		//
		int w = _image.m_width;
		int h = _image.m_height;
		int tiles_w = w >> 3;
		int tiles_h = h >> 3;

		//
		int x, y;
		for( y=0; y<tiles_h; y++ )
		{
			for( x=0; x<tiles_w; x++ )
			{
				int pixel_x = x*Tile.Width;
				int pixel_y = y*Tile.Height;

				Tile newTile = new Tile( _image, pixel_x, pixel_y );

				if( HaveIdenticalTile( newTile ) == false )
				{
					//Debug.Log ("Adding tile from coordinates "+pixel_x+","+pixel_y );
					AddTile( newTile );
				} else
				{
					//Debug.Log ("Ignoring tile from coordinates "+pixel_x+","+pixel_y );
				}
			}
		}
	}

	void AddTile( Tile _tile )
	{

		m_tiles.Add( _tile );
	}

	bool HaveIdenticalTile( Tile _tile )
	{
		foreach( Tile t in m_tiles )
		{
			bool a, b;
			if( t.Equals( _tile, out a, out b ))
				return true;
		}

		return false;
	}
	
	public TileInstance GetTileInstance( Tile _tile )
	{
		int i;
		for( i=0; i<m_tiles.Count; i++ )
		{
			Tile tile = m_tiles[ i ];

			bool flipX, flipY;
			if( tile.Equals( _tile, out flipX, out flipY ))
			{
				return new TileInstance( this, tile, i, flipX, flipY );
			}
		}

		return null;
	}

	public void Export( string _outfilename )
	{
		int numTiles = m_tiles.Count;
		// Export size = number of tiles * 64 pixels / 2 (because there are 2 bytes per pixel)
		int outsize = numTiles * 32;
		byte[] outBytes = new byte[ outsize ];

		int iTile;
		for( iTile=0; iTile<numTiles; iTile++ )
		{
			int x, y;
			for( y=0; y<Tile.Height; y++ )
			{
				for( x=0; x<Tile.Width/2; x++ )
				{
					int value = 0;

					Tile t = m_tiles[ iTile ];
					int ofs = (y*Tile.Width) + (x*2);

					value += (t.m_pixels[ ofs+0 ] & 0xf) << 4;
					value += (t.m_pixels[ ofs+1 ] & 0xf) << 0;

					int outOffset = (iTile*32) + (y*Tile.Width/2) + x;
					outBytes[ outOffset ] = (byte)value;
				}
			}
		}

		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}
}

public class TileMap
{
	public TileMap( TileBank _bank, PalettizedImage _sourceImage )
	{
		//
		m_tileBank = _bank;

		//
		int w = _sourceImage.m_width;
		int h = _sourceImage.m_height;
		m_width = (_sourceImage.m_width+7) >> 3;
		m_height = (_sourceImage.m_height+7) >> 3;
		int sourceWidth = w >> 3;
		int sourceHeight = h >> 3;

		//
		m_tiles = new TileInstance[ m_width, m_height ];

		//
		int x, y;
		for( y=0; y<sourceHeight; y++ )
		{
			string str = y.ToString() + "=(";
			for( x=0; x<sourceWidth; x++ )
			{
				int pixel_x = x*Tile.Width;
				int pixel_y = y*Tile.Height;

				Tile srcTile = new Tile( _sourceImage, pixel_x, pixel_y );
				TileInstance tileInstance = m_tileBank.GetTileInstance( srcTile );
				if( tileInstance == null )
				{
					Debug.LogException( new UnityException( "PANIC! Couldn't find tile instance for tile at coordinates "+pixel_x+","+pixel_y ));
					return;
				}

				//
				m_tiles[ x, y ] = tileInstance;
				str += tileInstance.m_tileBankIndex;
				if( tileInstance.m_flipX ) str += "x";
				if( tileInstance.m_flipY ) str += "y";
				if( x<sourceWidth-1 )
					str += ",";
			}

			str += ")";
			//Debug.Log( str );
		}
	}

	public void Export( string _outfilename )
	{
		// Export size = width * height * 2 (each tile in the map is 2 bytes)
		int outsize = m_width*m_height*2;
		byte[] outBytes = new byte[ outsize ];

		int x, y;
		for( y=0; y<m_height; y++ )
		{
			for( x=0; x<m_width; x++ )
			{
				TileInstance tile = m_tiles[ x, y ];

				if( tile == null )
					tile = new TileInstance( null, null, 0, false, false );	// Create a clear tile instance for where there are none

				int prio = 0;						// 1 bit. Can be 0 or 1
				int paletteIndex = 0;				// 2 bits. 0-3
				int vf = (tile.m_flipY==true)?1:0;	// 1 bit. Flip X?
				int hf = (tile.m_flipX==true)?1:0;	// 1 bit. Flip Y?
				int index = tile.m_tileBankIndex;	// 11 bits. 0-2047

				int value = ((prio&1)<<15) + ((paletteIndex&3)<<13) + ((vf&1)<<12) + ((hf&1)<<11) + (index&0x7ff);
				
				int wrOfs = ((y*m_width)+x) * 2;
				outBytes[ wrOfs+0 ] = (byte)((value>>8)&0xff);
				outBytes[ wrOfs+1 ] = (byte)(value&0xff);
			}
		}

		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}

	TileBank m_tileBank;
	TileInstance[,] m_tiles;

	int m_width;
	int m_height;
}

public class TileInstance
{
	public TileInstance( TileBank _tileBank, Tile _tile, int _tileBankIndex, bool _flipX, bool _flipY )
	{
		m_tileBank = _tileBank;
		m_tile = _tile;
		m_paletteIndex = 0;
		m_tileBankIndex = _tileBankIndex;
		m_flipX = _flipX;
		m_flipY = _flipY;
	}

	public TileBank m_tileBank;
	public Tile m_tile;
	public int m_paletteIndex;
	public int m_tileBankIndex;
	public bool m_flipX;
	public bool m_flipY;

}

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
