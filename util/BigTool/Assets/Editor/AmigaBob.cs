using UnityEngine;
using UnityEditor;
using System.Collections;
using System;

public class AmigaBob
{
	private int m_imageWidth;
	private int m_imageHeight;
	private int m_numberOfFrames;
	private int m_spriteWidth;
	private byte[] m_spriteData;
	
	public AmigaBob ( PalettizedImage _palettizedImage, PalettizedImageConfig _imageConfig )
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
		if ((m_spriteWidth % 16) != 0) {
			Debug.LogException (new UnityException ("PANIC! Amiga B-Sprites (bobs) width must be divisible by 16! Did you specify number of frames correctly?"));
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
		int planarStepPerRow = m_spriteWidth / 8 * 4; // 4 bitplanes
		int planarStepPerPlane = m_spriteWidth / 8;
		
		int dataSizePerFrame = m_imageHeight * m_spriteWidth / 8 * 4; // 8 pixels per byte, 4 bitplanes
		
		int planarDataSize = m_numberOfFrames * dataSizePerFrame; // 
		byte[] spriteData = new byte[planarDataSize];
		
		ChunkyToPlanar c2p = new ChunkyToPlanar(0, 3, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);
		
		for (int frame = 0; frame < m_numberOfFrames; frame++) {
			for (int x = 0; x < m_spriteWidth; x += 8) {
				for (int y = 0; y < m_imageHeight; y ++) {
					{
						c2p.ChunkyToPlanar8Pixels (chunkyImage, x + (frame * m_spriteWidth), y, spriteData, x, (frame * m_imageHeight) + y);										
					}
				}
			}
//			
//			int baseGrej = frame * dataSizePerFrame;
//			Halp.Write16 (spriteData, baseGrej + 0, 0x2c40);
//			Halp.Write16 (spriteData, baseGrej + 2, 0x3c00);
//			Halp.Write16 (spriteData, baseGrej - 4 + (dataSizePerFrame / 2), 0x0000);
//			Halp.Write16 (spriteData, baseGrej - 2 + (dataSizePerFrame / 2), 0x0000);
//			
//			Halp.Write16 (spriteData, baseGrej + 0 + (dataSizePerFrame / 2), 0x2c40);
//			Halp.Write16 (spriteData, baseGrej + 2 + (dataSizePerFrame / 2), 0x3c80);
//			Halp.Write16 (spriteData, baseGrej - 4 + dataSizePerFrame, 0x0000);
//			Halp.Write16 (spriteData, baseGrej - 2 + dataSizePerFrame, 0x0000);		
		}
		return spriteData;
	}
	
	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting Amiga B-Sprite (bob) to " + _outfilename );
		
		
		System.IO.File.WriteAllBytes( _outfilename, m_spriteData );
	}}
