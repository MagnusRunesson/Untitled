using UnityEngine;
using UnityEditor;
using System.Collections;
using System;

public class AmigaSprite
{
	private int m_imageWidth;
	private int m_imageHeight;
	private int m_spriteWidth;
	private byte[] m_spriteData;

	public AmigaSprite( PalettizedImage _palettizedImage, PalettizedImageConfig _imageConfig )
	{
		m_imageWidth = _palettizedImage.m_width;
		m_spriteWidth = m_imageWidth / _imageConfig.GetNumFrames ();
		m_imageHeight = _palettizedImage.m_height;
		
		SanityChecks (_palettizedImage, _imageConfig);

		m_spriteData = ChunkyToPlanarTilesInterleaved (_palettizedImage.m_image);
	}
	
	void SanityChecks (PalettizedImage _palettizedImage, PalettizedImageConfig _imageConfig)
	{
		if ((m_spriteWidth % 16) != 0) {
			Debug.LogException (new UnityException ("PANIC! PlanarImage can only handle images with: spriteWidth % 16 == 0"));
		}
		
//		int numberOfColorsUsed = 0;
//		for (int c = 0; c <  _palettizedImage.m_colorUsed.Count; c++) {
//			if (_palettizedImage.m_colorUsed [c]) {
//				numberOfColorsUsed = c;
//			}
//		}
//		int maxNumberOfColors = (int)Math.Pow (m_numberOfBitPlanes, 2);
//		if (numberOfColorsUsed > maxNumberOfColors) {
//			Debug.LogException (new UnityException (String.Format ("PANIC! Trying to create PlanarImage with more colors than _numberOfBitplanes allows [{0} > {1}]!", numberOfColorsUsed, maxNumberOfColors)));
//		}
	}

	private byte[] ChunkyToPlanarTilesInterleaved (byte[] chunkyImage)
	{
		int chunkyStepPerRow = m_imageWidth;
		int planarStepPerRow = 4;
		int planarStepPerPlane = 1;
		//		Debug.Log ("chunkyStepPerRow: " + chunkyStepPerRow);
		//		Debug.Log ("planarStepPerRow: " + planarStepPerRow);
		//		Debug.Log ("planarStepPerPlane: " + planarStepPerPlane);
		ChunkyToPlanar c2p = new ChunkyToPlanar(0, 3, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);
		
		int planarDataSize = m_imageHeight * m_imageWidth * 4 / 8;	
		byte[] spriteData = new byte[planarDataSize];
		
		//			Debug.Log (m_height);
		//			Debug.Log (m_width);
		//			Debug.Log (m_numberOfBitPlanes);
		//			Debug.Log (planarDataSize);
		//			Debug.Log (chunkyYOffs);
		//			Debug.Log (yoffsPlane3);
		int tile = 0;
		for (int x = 0; x < m_imageWidth; x += 8)
		{
			for (int y = 0; y < m_imageHeight; y += 8)
			{
				for (int yInner = 0; yInner < 8; yInner++)
				{
					c2p.ChunkyToPlanar8Pixels(chunkyImage, x, y + yInner, spriteData, 0, (tile * 8) + yInner);
				}
				tile++;
			}
		}

		return spriteData;
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting Amiga Sprite to " + _outfilename );


		System.IO.File.WriteAllBytes( _outfilename, m_spriteData );
	}
}