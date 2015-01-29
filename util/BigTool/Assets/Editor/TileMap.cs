using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class TileMap
{
	public TileMap( TileBank _bank, PalettizedImage _sourceImage )
	{
		//
		m_tileBank = _bank;

		//
		int w = _sourceImage.m_width;
		int h = _sourceImage.m_height;
		m_width = 64;//(_sourceImage.m_width+7) >> 3;
		m_height = 32;//(_sourceImage.m_height+7) >> 3;
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

	static public TileMap LoadJson( string _fileName )
	{
		string jsonString = System.IO.File.ReadAllText( _fileName );
		Dictionary<string,object> json = (Dictionary<string,object>)MiniJSON.Json.Deserialize( jsonString );

		// Load tile bank
		List<object> tilesetsJson = (List<object>)json[ "tilesets" ];
		Dictionary<string,object> tilesetJson = (Dictionary<string,object>)tilesetsJson[ 0 ];
		string imageFileName = (string)tilesetJson[ "image" ];
		string imageFullPath = System.IO.Path.GetDirectoryName( _fileName ) + System.IO.Path.DirectorySeparatorChar + imageFileName;
		//LoadBMP( imageFullPath );

		PalettizedImageConfig imageConfig  = new PalettizedImageConfig( imageFullPath + ".config" );
		
		PalettizedImage imageData = PalettizedImage.LoadImage( imageFullPath, imageConfig );
		TileBank tileBank = null;
		if( imageData != null )
		{
			//
			imageConfig.SetImage( imageData );

			bool optimizeBank = (imageConfig.m_importAsSprite==false);	// Optimize bank when we're not loading the image as a sprite (i.e. optimize when we're loading as a tile bank)
			tileBank = new TileBank( imageData, optimizeBank );
		}

		// Create map texture
		int map_tiles_w = ((int)(long)json[ "width" ]);
		int map_tiles_h = ((int)(long)json[ "height" ]);
		int map_pixels_w = map_tiles_w * 8;
		int map_pixels_h = map_tiles_h * 8;

		TileMap ret = new TileMap( map_tiles_w, map_tiles_h );

		// Find each layer
		List<object> layersJson = (List<object>)json[ "layers" ];
		Dictionary<string,object> layerJson = (Dictionary<string,object>)layersJson[ 0 ];
		List<object> layerData = (List<object>)layerJson[ "data" ];
		int tile_x, tile_y;
		for( tile_y=0; tile_y<map_tiles_h; tile_y++ )
		{
			for( tile_x=0; tile_x<map_tiles_w; tile_x++ )
			{
				int i = tile_y*map_tiles_w + tile_x;
				int tile_id = (int)(long)layerData[i];
				tile_id--;
				TileInstance tileInstance = tileBank.m_allTileInstances[ tile_id ];
				
				//
				ret.SetTile( tile_x, tile_y, tileInstance );
			}
		}

		return ret;
	}

	public TileMap( int _width, int _height )
	{
		m_width = _width;
		m_height = _height;
		m_tiles = new TileInstance[ m_width, m_height ];
	}

	void SetTile( int _x, int _y, TileInstance _tile )
	{
		m_tiles[ _x, _y ] = _tile;
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting tile map to " + _outfilename );

		int headersize = 2;

		// Export size = width * height * 2 (each tile in the map is 2 bytes)
		int outsize = m_width*m_height*2;
		byte[] outBytes = new byte[ headersize+outsize ];

		outBytes[ 0 ] = (byte)m_width;
		outBytes[ 1 ] = (byte)m_height;

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
				
				int wrOfs = headersize + (((y*m_width)+x) * 2);
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
