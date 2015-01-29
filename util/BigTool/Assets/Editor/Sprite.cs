using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Sprite
{
	PalettizedImage m_imageData;
	PalettizedImageConfig m_imageConfig;

	public Sprite( PalettizedImage _imageData, PalettizedImageConfig _imageConfig )
	{
		m_imageData = _imageData;
		m_imageConfig = _imageConfig;

	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting sprite to " + _outfilename );

		int numFrames = m_imageConfig.GetNumFrames();
		int outsize = 6 + numFrames;		// 1 extra byte per frame, for the frame time

		byte[] outBytes = new byte[ outsize ];
		Halp.Write8( outBytes, 0, m_imageConfig.GetSpriteWidth() );
		Halp.Write8( outBytes, 1, m_imageConfig.GetSpriteHeight() );
		Halp.Write8( outBytes, 2, numFrames );
		Halp.Write8( outBytes, 3, 0 ); // To pad to 4 bytes
		Halp.Write16( outBytes, 4, 0xdead );	// Put file handle here!

		int iFrame;
		for( iFrame=0; iFrame<numFrames; iFrame++ )
		{
			Halp.Write8( outBytes, 6+iFrame, m_imageConfig.GetFrameTime( iFrame ));
		}

		System.IO.File.WriteAllBytes( _outfilename, outBytes );
	}
}
