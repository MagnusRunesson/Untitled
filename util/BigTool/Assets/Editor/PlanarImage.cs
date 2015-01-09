using UnityEngine;
using UnityEditor;
using System.Collections;
using System;

class PlanarImage
{
	private int m_numberOfBitPlanes;
	private int m_width;
	private int m_height;
	private byte[] m_planarData;

	public PlanarImage( PalettizedImage _palettizedImage, int _numberOfBitPlanes )
	{
		m_numberOfBitPlanes = _numberOfBitPlanes;
		m_width = _palettizedImage.m_width;
		m_height = _palettizedImage.m_height;

		SanityChecks (_palettizedImage);
		m_planarData = ChunkyToPlanar (_palettizedImage.m_image);
	}

	void SanityChecks (PalettizedImage _palettizedImage)
	{
		if ((m_width % 8) != 0) {
			Debug.LogException (new UnityException ("PANIC! PlanarImage can only handle images with: width % 8 == 0"));
		}

		int numberOfColorsUsed = 0;
		for (int c = 0; c <  _palettizedImage.m_colorUsed.Count; c++) {
			if (_palettizedImage.m_colorUsed [c]) {
				numberOfColorsUsed = c;
			}
		}
		int maxNumberOfColors = (int)Math.Pow (m_numberOfBitPlanes, 2);
		if (numberOfColorsUsed > maxNumberOfColors) {
			Debug.LogException (new UnityException (String.Format ("PANIC! Trying to create PlanarImage with more colors than _numberOfBitplanes allows [{0} > {1}]!", numberOfColorsUsed, maxNumberOfColors)));
		}
	}

	private byte[] ChunkyToPlanar (byte[] m_image)
	{
		int planarDataSize = m_height * m_width * m_numberOfBitPlanes / 8;
		byte[] planarData = new byte[planarDataSize];
		for (int y = 0; y < m_height; y++) 
		{
			int yoffs = y*m_width;
			int yoffsPlane0 = (y*m_width/8)+(m_width*m_height*0/8);
			int yoffsPlane1 = (y*m_width/8)+(m_width*m_height*1/8);
			int yoffsPlane2 = (y*m_width/8)+(m_width*m_height*2/8);
			int yoffsPlane3 = (y*m_width/8)+(m_width*m_height*3/8);
			int yoffsPlane4 = (y*m_width/8)+(m_width*m_height*4/8);
			int yoffsPlane5 = (y*m_width/8)+(m_width*m_height*5/8);
			int yoffsPlane6 = (y*m_width/8)+(m_width*m_height*6/8);
			int yoffsPlane7 = (y*m_width/8)+(m_width*m_height*7/8);
//			Debug.Log (m_height);
//			Debug.Log (m_width);
//			Debug.Log (m_numberOfBitPlanes);
//			Debug.Log (planarDataSize);
//			Debug.Log (yoffs);
//			Debug.Log (yoffsPlane3);
			for (int x = 0; x < m_width; x+=8)
			{					
				byte a = m_image[yoffs+x+0]; // a7a6a5a4a3a2a1a0 
				byte b = m_image[yoffs+x+1]; // b7b6b5b4b3b2b1b0
				byte c = m_image[yoffs+x+2]; // c7c6c5c4c3c2c1c0
				byte d = m_image[yoffs+x+3]; // d7d6d5d4d3d2d1d0
				byte e = m_image[yoffs+x+4]; // e7e6e5e4e3e2e1e0
				byte f = m_image[yoffs+x+5]; // f7g6f5f4f3f2f1f0
				byte g = m_image[yoffs+x+6]; // g7g6g5g4g3g2g1g0
				byte h = m_image[yoffs+x+7]; // h7h6h5h4h3h2h1h0

//				if (m_numberOfBitPlanes >= 1) planarData[yoffsPlane0+(x/8)] = 0x01;//(byte)(((a&0x80)) | ((b&0x80)>>1) | ((c&0x80)>>2) | ((d&0x80)>>3) | ((e&0x80)>>4) | ((f&0x80)>>5) | ((g&0x80)>>6) | ((h&0x80)>>7)); // a7b7c7d7e7f7g7h7
//				if (m_numberOfBitPlanes >= 2) planarData[yoffsPlane1+(x/8)] = (byte)(((a&0x40)<<1) | ((b&0x40)) | ((c&0x40)>>1) | ((d&0x40)>>2) | ((e&0x40)>>3) | ((f&0x40)>>4) | ((g&0x40)>>5) | ((h&0x40)>>6)); // a6b6c6d6e6f6g6h6
//				if (m_numberOfBitPlanes >= 3) planarData[yoffsPlane2+(x/8)] = (byte)(((a&0x20)<<2) | ((b&0x20)<<1) | ((c&0x20)) | ((d&0x20)>>1) | ((e&0x20)>>2) | ((f&0x20)>>3) | ((g&0x20)>>4) | ((h&0x20)>>5)); // a5b5c5d5e5f5g5h5
//				if (m_numberOfBitPlanes >= 4) planarData[yoffsPlane3+(x/8)] = (byte)(((a&0x10)<<3) | ((b&0x10)<<2) | ((c&0x10)<<1) | ((d&0x10)) | ((e&0x10)>>1) | ((f&0x10)>>2) | ((g&0x10)>>3) | ((h&0x10)>>4)); // a4b4c4d4e4f4g4h4
//				if (m_numberOfBitPlanes >= 5) planarData[yoffsPlane4+(x/8)] = (byte)(((a&0x08)<<4) | ((b&0x08)<<3) | ((c&0x08)<<2) | ((d&0x08)<<1) | ((e&0x08)) | ((f&0x08)>>1) | ((g&0x08)>>2) | ((h&0x08)>>3)); // a3b3c3d3e3f3g3h3
//				if (m_numberOfBitPlanes >= 6) planarData[yoffsPlane5+(x/8)] = (byte)(((a&0x04)<<5) | ((b&0x04)<<4) | ((c&0x04)<<3) | ((d&0x04)<<2) | ((e&0x04)<<1) | ((f&0x04)) | ((g&0x04)>>1) | ((h&0x04)>>2)); // a2b2c2d2e2f2g2h2
//				if (m_numberOfBitPlanes >= 7) planarData[yoffsPlane6+(x/8)] = (byte)(((a&0x02)<<6) | ((b&0x02)<<5) | ((c&0x02)<<4) | ((d&0x02)<<3) | ((e&0x02)<<2) | ((f&0x02)<<1) | ((g&0x02)) | ((h&0x02)>>1)); // a1b1c1d1e1f1g1h1
//				if (m_numberOfBitPlanes >= 8) planarData[yoffsPlane7+(x/8)] = (byte)(((a&0x01)<<7) | ((b&0x01)<<6) | ((c&0x01)<<5) | ((d&0x01)<<4) | ((e&0x01)<<3) | ((f&0x01)<<2) | ((g&0x01)<<1) | ((h&0x01))); // a0b0c0d0e0f0g0h0

				if (m_numberOfBitPlanes >= 1) planarData[yoffsPlane0+(x/8)] = (byte)(((a&0x01)<<7) | ((b&0x01)<<6) | ((c&0x01)<<5) | ((d&0x01)<<4) | ((e&0x01)<<3) | ((f&0x01)<<2) | ((g&0x01)<<1) | ((h&0x01))); // a0b0c0d0e0f0g0h0
				if (m_numberOfBitPlanes >= 2) planarData[yoffsPlane1+(x/8)] = (byte)(((a&0x02)<<6) | ((b&0x02)<<5) | ((c&0x02)<<4) | ((d&0x02)<<3) | ((e&0x02)<<2) | ((f&0x02)<<1) | ((g&0x02)) | ((h&0x02)>>1)); // a1b1c1d1e1f1g1h1
				if (m_numberOfBitPlanes >= 3) planarData[yoffsPlane2+(x/8)] = (byte)(((a&0x04)<<5) | ((b&0x04)<<4) | ((c&0x04)<<3) | ((d&0x04)<<2) | ((e&0x04)<<1) | ((f&0x04)) | ((g&0x04)>>1) | ((h&0x04)>>2)); // a2b2c2d2e2f2g2h2
				if (m_numberOfBitPlanes >= 4) planarData[yoffsPlane3+(x/8)] = (byte)(((a&0x08)<<4) | ((b&0x08)<<3) | ((c&0x08)<<2) | ((d&0x08)<<1) | ((e&0x08)) | ((f&0x08)>>1) | ((g&0x08)>>2) | ((h&0x08)>>3)); // a3b3c3d3e3f3g3h3
				if (m_numberOfBitPlanes >= 5) planarData[yoffsPlane4+(x/8)] = (byte)(((a&0x10)<<3) | ((b&0x10)<<2) | ((c&0x10)<<1) | ((d&0x10)) | ((e&0x10)>>1) | ((f&0x10)>>2) | ((g&0x10)>>3) | ((h&0x10)>>4)); // a4b4c4d4e4f4g4h4
				if (m_numberOfBitPlanes >= 6) planarData[yoffsPlane5+(x/8)] = (byte)(((a&0x20)<<2) | ((b&0x20)<<1) | ((c&0x20)) | ((d&0x20)>>1) | ((e&0x20)>>2) | ((f&0x20)>>3) | ((g&0x20)>>4) | ((h&0x20)>>5)); // a5b5c5d5e5f5g5h5
				if (m_numberOfBitPlanes >= 7) planarData[yoffsPlane6+(x/8)] = (byte)(((a&0x40)<<1) | ((b&0x40)) | ((c&0x40)>>1) | ((d&0x40)>>2) | ((e&0x40)>>3) | ((f&0x40)>>4) | ((g&0x40)>>5) | ((h&0x40)>>6)); // a6b6c6d6e6f6g6h6
				if (m_numberOfBitPlanes >= 8) planarData[yoffsPlane7+(x/8)] = (byte)(((a&0xff)) | ((b&0x80)>>1) | ((c&0x80)>>2) | ((d&0x80)>>3) | ((e&0x80)>>4) | ((f&0x80)>>5) | ((g&0x80)>>6) | ((h&0x80)>>7)); // a7b7c7d7e7f7g7h7

			}
		}

		return planarData;
	}

	public void Export( string _outfilename )
	{
		System.IO.File.WriteAllBytes( _outfilename, m_planarData );
	}
}