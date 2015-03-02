using UnityEngine;
using UnityEditor;
using System.Collections;
using System;

[System.Serializable]
class PlanarImage
{
	private int m_width;
	private int m_height;
	private byte[] m_planarData;

	public PlanarImage( PalettizedImage _palettizedImage )
	{
		m_width = _palettizedImage.m_width;
		m_height = _palettizedImage.m_height;

		SanityChecks (_palettizedImage);

		//m_planarData = ChunkyToPlanarImageInterleaved (_palettizedImage.m_image);
		m_planarData = ChunkyToPlanarTilesInterleaved (_palettizedImage.m_image);
	}

	void SanityChecks (PalettizedImage _palettizedImage)
	{
		if ((m_width % 8) != 0) {
			Debug.LogException (new UnityException ("PANIC! PlanarImage can only handle images with: width % 8 == 0"));
		}

//		int numberOfColorsUsed = 0;
//		for (int c = 0; c <  _palettizedImage.m_colorUsed.Count; c++) {
//			if (_palettizedImage.m_colorUsed [c]) {
//				numberOfColorsUsed = c;
//			}
//		}
//		int maxNumberOfColors = (int)Math.Pow (4, 2);
//		if (numberOfColorsUsed > maxNumberOfColors) {
//			Debug.LogException (new UnityException (String.Format ("PANIC! Trying to create PlanarImage with more colors than _numberOfBitplanes allows [{0} > {1}]!", numberOfColorsUsed, maxNumberOfColors)));
//		}
	}
	
	private byte[] ChunkyToPlanarImageSequential (byte[] chunkyImage)
	{
		int chunkyStepPerRow = m_width;
		int planarStepPerRow = m_width/8;
		int planarStepPerPlane = planarStepPerRow*m_height;
//		Debug.Log ("chunkyStepPerRow: " + chunkyStepPerRow);
//		Debug.Log ("planarStepPerRow: " + planarStepPerRow);
//		Debug.Log ("planarStepPerPlane: " + planarStepPerPlane);

		ChunkyToPlanar c2p = new ChunkyToPlanar(0, 3, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);

        return ChunkyToPlanarImage(chunkyImage, c2p);
	}
	
	private byte[] ChunkyToPlanarImageInterleaved (byte[] chunkyImage)
	{
		int chunkyStepPerRow = m_width;
		int planarStepPerRow = m_width/8*4;
		int planarStepPerPlane = m_width/8;
//		Debug.Log ("chunkyStepPerRow: " + chunkyStepPerRow);
//		Debug.Log ("planarStepPerRow: " + planarStepPerRow);
//		Debug.Log ("planarStepPerPlane: " + planarStepPerPlane);
		ChunkyToPlanar c2p = new ChunkyToPlanar(0, 3, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);
        return ChunkyToPlanarImage(chunkyImage, c2p);
	}
	
	private byte[] ChunkyToPlanarImage (byte[] chunkyImage, ChunkyToPlanar c2p)
	{
		int planarDataSize = m_height * m_width * 4 / 8;	
		byte[] planarData = new byte[planarDataSize];
		
		//			Debug.Log (m_height);
		//			Debug.Log (m_width);
		//			Debug.Log (m_numberOfBitPlanes);
		//			Debug.Log (planarDataSize);
		//			Debug.Log (chunkyYOffs);
		//			Debug.Log (yoffsPlane3);
		for (int y = 0; y < m_height; y++) 
		{		
			for (int x = 0; x < m_width; x+=8)
			{		
				c2p.ChunkyToPlanar8Pixels (chunkyImage, x, y, planarData, x, y);						
			}
		}

		return planarData;
	}

	private byte[] ChunkyToPlanarTilesInterleaved (byte[] chunkyImage)
	{
		int chunkyStepPerRow = m_width;
		int planarStepPerRow = 4;
		int planarStepPerPlane = 1;
		//		Debug.Log ("chunkyStepPerRow: " + chunkyStepPerRow);
		//		Debug.Log ("planarStepPerRow: " + planarStepPerRow);
		//		Debug.Log ("planarStepPerPlane: " + planarStepPerPlane);
		ChunkyToPlanar c2p = new ChunkyToPlanar(0, 3, chunkyStepPerRow, planarStepPerRow, planarStepPerPlane);
		
		int planarDataSize = m_height * m_width * 4 / 8;	
		byte[] planarData = new byte[planarDataSize];
		
		//			Debug.Log (m_height);
		//			Debug.Log (m_width);
		//			Debug.Log (m_numberOfBitPlanes);
		//			Debug.Log (planarDataSize);
		//			Debug.Log (chunkyYOffs);
		//			Debug.Log (yoffsPlane3);
		int tile = 0;
        for (int x = 0; x < m_width; x += 8)
        {
            for (int y = 0; y < m_height; y += 8)
            {
                for (int yInner = 0; yInner < 8; yInner++)
                {
                    c2p.ChunkyToPlanar8Pixels(chunkyImage, x, y + yInner, planarData, 0, (tile * 8) + yInner);
                }
                tile++;
            }
        }

		return planarData;
	}

	public void Export( string _outfilename )
	{
		Debug.Log ("Exporting planar image to " + _outfilename );

		System.IO.File.WriteAllBytes( _outfilename, m_planarData );
	}
}