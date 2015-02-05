using UnityEngine;
using UnityEditor;
using System.Collections;
using System;

public class AmigaSprite
{
	private int m_imageWidth;
	private int m_imageHeight;
	private int m_numberOfFrames;
	private int m_spriteWidth;
	private byte[] m_spriteData;

	public AmigaSprite( PalettizedImage _palettizedImage, PalettizedImageConfig _imageConfig )
	{
		m_imageWidth = _palettizedImage.m_width;
		m_imageHeight = _palettizedImage.m_height;
		m_numberOfFrames = _imageConfig.GetNumFrames ();
		m_spriteWidth = m_imageWidth / m_numberOfFrames;

		SanityChecks (_palettizedImage, _imageConfig);

		m_spriteData = ChunkyToPlanarSpriteFrames (_palettizedImage.m_image);
	}
	
	void SanityChecks (PalettizedImage _palettizedImage, PalettizedImageConfig _imageConfig)
	{
		if (m_spriteWidth != 16) {
			Debug.LogException (new UnityException ("PANIC! AmigaSprites must be 16 pixels wide! Did you specify number of frames correctly?"));
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

	private byte[] ChunkyToPlanarSpriteFrames (byte[] chunkyImage)
	{
		int chunkyStepPerRow = m_imageWidth;
		int planarStepPerRow = 2;
		int planarStepPerPlane = 1;
		//		Debug.Log ("chunkyStepPerRow: " + chunkyStepPerRow);
		//		Debug.Log ("planarStepPerRow: " + planarStepPerRow);
		//		Debug.Log ("planarStepPerPlane: " + planarStepPerPlane);

		int dataSizeForSingleSprite = m_imageHeight * m_imageWidth * 4 / 8; // 4 bitplanes data, 8 bits per byte
		int headerAndEndSizeForSingleSprite = 8;

		int planarDataSize = 2 * (headerAndEndSizeForSingleSprite+dataSizeForSingleSprite); // 2 sprites=16 colors "attached" sprite
		byte[] spriteData = new byte[planarDataSize];

		ChunkyToPlanar c2p1 = new ChunkyToPlanar(0, 1, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);
		ChunkyToPlanar c2p2 = new ChunkyToPlanar(2, 3, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);

		for (int frame = 0; frame < m_numberOfFrames; frame++) {
						for (int x = 0; x < m_spriteWidth; x += 8) {
								for (int y = 0; y < m_imageHeight; y += 8) {
										for (int yInner = 0; yInner < 8; yInner++) {
												c2p1.ChunkyToPlanar8Pixels (chunkyImage, x, y + yInner, spriteData, 0, 1 + (frame * (m_imageHeight+2)) + yInner);
												c2p2.ChunkyToPlanar8Pixels (chunkyImage, x, y + yInner, spriteData, 0, 3 + m_imageHeight + (frame * (m_imageHeight+2)) + yInner);
										}
								}
						}
				}

		Halp.Write16 (spriteData, 0, 0x2c40);
		Halp.Write16 (spriteData, 2, 0x3c00);
		Halp.Write16 (spriteData, 4+dataSizeForSingleSprite, 0x0000);
		Halp.Write16 (spriteData, 6+dataSizeForSingleSprite, 0x0000);

		Halp.Write16 (spriteData, 8+dataSizeForSingleSprite, 0x2c40);
		Halp.Write16 (spriteData, 10+dataSizeForSingleSprite, 0x3c80);
		Halp.Write16 (spriteData, 12+dataSizeForSingleSprite*2, 0x0000);
		Halp.Write16 (spriteData, 14+dataSizeForSingleSprite*2, 0x0000);

		return spriteData;
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting Amiga Sprite to " + _outfilename );


		System.IO.File.WriteAllBytes( _outfilename, m_spriteData );
	}
}