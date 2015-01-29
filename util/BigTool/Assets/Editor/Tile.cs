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





