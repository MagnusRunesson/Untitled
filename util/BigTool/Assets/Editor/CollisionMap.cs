using UnityEngine;
using System.Collections;

/*
		if( coll_tile_index == 1 )
			DoCollision_UpLeftAsm( ref new_dir_y );
		else if( coll_tile_index == 2 )
			DoCollision_DownRightAsm( ref new_dir_y );
		else if( coll_tile_index == 3 )
			DoCollision_UpLeftAsm( ref new_dir_x );
		else if( coll_tile_index == 4 )
			DoCollision_DownRightAsm( ref new_dir_x );
		else if( coll_tile_index == 5 )
			DoCollision_Slope_UpLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 6 )
			DoCollision_Slope_UpRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 7 )
			DoCollision_Slope_DownLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 8 )
			DoCollision_Slope_DownRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 10 )
			DoCollision_Corner_UpLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 11 )
			DoCollision_Corner_UpRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 12 )
			DoCollision_Corner_DownLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 13 )
			DoCollision_Corner_DownRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 9 )
 */
public class CollisionMap
{
	int m_width;
	int m_height;

	int[,] m_tiles;

	static int[][] m_collisionToVisual = new int[][]
	{
		/* 0=no collision */			new int[]{},
		/* 1=collision from above */	new int[]{ 24, 25 },
		/* 2=collision from below */	new int[]{ 72, 73 },
		/* 3=collision from left */		new int[]{ 39, 55 },
		/* 4=collision from right */	new int[]{ 42, 58 },
		/* 5=slope from up left */		new int[]{ 23 },
		/* 6=slope from up right */		new int[]{ 26 },
		/* 7=slope from down left */	new int[]{ 71 },
		/* 8=slope from down right */	new int[]{ 74 },
		/* 9=full collision */			new int[]{ 27, 28, 43, 44, 40, 41, 56, 57 },
		/* 10=corner from up left */	new int[]{  },
		/* 11=corner from up right */	new int[]{  },
		/* 12=corner from down left */	new int[]{  },
		/* 13=corner from down right */	new int[]{  },
	};

	public CollisionMap( TileMap _sourceMap )
	{
		m_width = _sourceMap.GetWidth();
		m_height = _sourceMap.GetHeight();
		m_tiles = new int[ m_width, m_height ];

		int x, y;
		for( y=0; y<m_height; y++ )
		{
			for( x=0; x<m_width; x++ )
			{
				int visualTileID;
				if( _sourceMap.GetRawTile( x, y, out visualTileID ) == false )
				{
					Debug.LogException( new UnityException( "Couldn't find raw tile, boo!" ));
					continue;
				}

				int collisionTileID = GetCollisionTileIndexFromVisualIndex( visualTileID );
				m_tiles[ x, y ] = collisionTileID;
			}
		}
	}

	// There should really be a table to convert this, some how
	public static int GetCollisionTileIndexFromVisualIndex( int _visualIndex )
	{
		int iCollision;
		for( iCollision=0; iCollision<m_collisionToVisual.Length; iCollision++ )
		{
			int[] visualsForThisCollision = m_collisionToVisual[ iCollision ];
			foreach( int visual in visualsForThisCollision )
			{
				if( visual == _visualIndex )
					return iCollision;
			}
		}

		return 0;
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting collision map to " + _outfilename );
		
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
				int wrOfs = headersize + ((y*m_width)+x);
				outBytes[ wrOfs ] = (byte)m_tiles[ x, y ];
			}
		}
		
		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}
}
