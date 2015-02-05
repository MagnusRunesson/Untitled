using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class TileBank
{
	public List<Tile> m_tiles;
	public Dictionary<int,TileInstance> m_allTileInstances;

	//
	// Optimized tile bank means to remove duplicates
	//
	public TileBank( PalettizedImage _image, bool _optimized )
	{
		//
		m_tiles = new List<Tile>();

		//
		int w = _image.m_width;
		int h = _image.m_height;
		int tiles_w = w >> 3;
		int tiles_h = h >> 3;

		//
		m_allTileInstances = new Dictionary<int, TileInstance>();

		//
		// Normally I write loops that iterate on Y first and then X, but sprites on Mega Drive should actually be
		// exported Y first then X, so if we do the Y in the inner loop that means the first two tiles are at 0,0
		// and 0,8, which means Y down. So instead of reordering anything at export time I reorder here instead.
		//
		// Oooh, I just realized this probably isn't true for sprite animation frames, so I probably still need to
		// do some clever iterations and stuff here. ARGH!
		//
		int x, y;
		for( x=0; x<tiles_w; x++ )
		{
			for( y=0; y<tiles_h; y++ )
			{
				int pixel_x = x*Tile.Width;
				int pixel_y = y*Tile.Height;

				Tile newTile = new Tile( _image, pixel_x, pixel_y );

				if( _optimized )
				{
					TileInstance tileInstance = GetTileInstance( newTile );
					if( tileInstance == null )
					{
						//Debug.Log ("Adding tile from coordinates "+pixel_x+","+pixel_y );
						AddTile( newTile );

						// Get the newly created instance
						tileInstance = GetTileInstance( newTile );
					} else
					{
						//Debug.Log ("Ignoring tile from coordinates "+pixel_x+","+pixel_y );
					}
					int i = (y*tiles_w) + x;
					m_allTileInstances[ i ] = tileInstance;
				} else
				{
					// If we're not building an optimized tile bank we always export all tiles
					AddTile( newTile );

					// Get the newly created instance
					TileInstance tileInstance = GetTileInstance( newTile );
					int i = (y*tiles_w) + x;
					m_allTileInstances[ i ] = tileInstance;
				}
			}
		}

		Debug.Log ("tile instances=" + m_allTileInstances.Count );
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

	public void ExportMegaDrive( string _outfilename )
	{
		Debug.Log ("Exporting tile bank (Mega Drive) to " + _outfilename );

		int headersize = 2;

		int numTiles = m_tiles.Count;

		// Export size = number of tiles * 64 pixels / 2 (because there are 2 bytes per pixel)
		int outsize = headersize + (numTiles * 32);
		byte[] outBytes = new byte[ outsize ];

		Debug.Log ("exporting " + numTiles + " tiles");
		Halp.Write16( outBytes, 0, numTiles );

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
					outBytes[ headersize + outOffset ] = (byte)value;
				}
			}
		}

		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}

	public void ExportAmiga( string _outfilename )
	{
		Debug.Log ("Exporting tile bank (Amiga) to " + _outfilename );

		int headersize = 0;

		int numTiles = m_tiles.Count;

		// Export size = number of tiles * 64 pixels / 2 (because there are 2 bytes per pixel)
		int outsize = headersize + (numTiles * 32); // 8*8 pixels, 8 bits per bytes/only 4 bits used
		byte[] outBytes = new byte[ outsize ];
		
		Debug.Log ("exporting " + numTiles + " tiles");
		//Halp.Write16( outBytes, 0, numTiles );
		
		int iTile;
		for( iTile=0; iTile<numTiles; iTile++ )
		{
			Tile t = m_tiles[ iTile ];

			ChunkyToPlanar c2p = new ChunkyToPlanar(0, 3, 8, 4, 1);
			for(int y=0; y<Tile.Height; y++ )
			{
				c2p.ChunkyToPlanar8Pixels(t.m_pixels, 0, y, outBytes, 0, iTile*8+y);
          	}
		}
		
		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}
}
