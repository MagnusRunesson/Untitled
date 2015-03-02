using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class Sprite
{
	PalettizedImageConfig m_imageConfig;

	public Sprite(PalettizedImageConfig _imageConfig )
	{
		m_imageConfig = _imageConfig;
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting sprite to " + _outfilename );

		int numFrames = m_imageConfig.GetNumFrames();

		int flags = 0x00;
		flags |= m_imageConfig.m_importAsBSprite ? 0x01 : 0x00;

		int outsize = 6 + numFrames;		// 1 extra byte per frame, for the frame time

		byte[] outBytes = new byte[ outsize ];
		Halp.Write8( outBytes, 0, m_imageConfig.GetSpriteWidth() );
		Halp.Write8( outBytes, 1, m_imageConfig.GetSpriteHeight() );
		Halp.Write8( outBytes, 2, numFrames );
		Halp.Write8( outBytes, 3, flags );
		Halp.Write16( outBytes, 4, 0xdead );	// Put file handle here!

		int iFrame;
		for( iFrame=0; iFrame<numFrames; iFrame++ )
		{
			Halp.Write8( outBytes, 6+iFrame, m_imageConfig.GetFrameTime( iFrame ));
		}

		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}
}
