using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ChunkyToPlanar
{
	private int m_firstPlane;
	private int m_lastPlane;
    private int m_chunkyStepPerRow;
    private int m_planarStepPerRow;
    private int m_planarStepPerPlane;

    public ChunkyToPlanar(int _firstPlane, int _lastPlane, int _chunkyStepPerRow, int _planarStepPerRow, int _planarStepPerPlane)
    {
		m_firstPlane = _firstPlane;
		m_lastPlane = _lastPlane;
        m_chunkyStepPerRow = _chunkyStepPerRow;
        m_planarStepPerRow = _planarStepPerRow;
        m_planarStepPerPlane = _planarStepPerPlane;
    }

    public void ChunkyToPlanar8Pixels(byte[] _chunkyImage, int _chunkyX, int _chunkyY,
                            byte[] _planarData, int _planarX, int _planarY)
    {
        int chunkyYOffs = _chunkyY * m_chunkyStepPerRow;
        byte a = _chunkyImage[chunkyYOffs + _chunkyX + 0]; // a7a6a5a4a3a2a1a0 
        byte b = _chunkyImage[chunkyYOffs + _chunkyX + 1]; // b7b6b5b4b3b2b1b0
        byte c = _chunkyImage[chunkyYOffs + _chunkyX + 2]; // c7c6c5c4c3c2c1c0
        byte d = _chunkyImage[chunkyYOffs + _chunkyX + 3]; // d7d6d5d4d3d2d1d0
        byte e = _chunkyImage[chunkyYOffs + _chunkyX + 4]; // e7e6e5e4e3e2e1e0
        byte f = _chunkyImage[chunkyYOffs + _chunkyX + 5]; // f7g6f5f4f3f2f1f0
        byte g = _chunkyImage[chunkyYOffs + _chunkyX + 6]; // g7g6g5g4g3g2g1g0
        byte h = _chunkyImage[chunkyYOffs + _chunkyX + 7]; // h7h6h5h4h3h2h1h0

		int planarYOffsPlane0 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (0-m_firstPlane));
		int planarYOffsPlane1 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (1-m_firstPlane));
		int planarYOffsPlane2 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (2-m_firstPlane));
		int planarYOffsPlane3 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (3-m_firstPlane));
		int planarYOffsPlane4 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (4-m_firstPlane));
		int planarYOffsPlane5 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (5-m_firstPlane));
		int planarYOffsPlane6 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (6-m_firstPlane));
		int planarYOffsPlane7 = (_planarY * m_planarStepPerRow) + (m_planarStepPerPlane * (7-m_firstPlane));

		if ((m_firstPlane<=0) && (m_lastPlane>=0)) _planarData[planarYOffsPlane0 + _planarX] = (byte)(((a & 0x01) << 7) | ((b & 0x01) << 6) | ((c & 0x01) << 5) | ((d & 0x01) << 4) | ((e & 0x01) << 3) | ((f & 0x01) << 2) | ((g & 0x01) << 1) | ((h & 0x01))); // a0b0c0d0e0f0g0h0
		if ((m_firstPlane<=1) && (m_lastPlane>=1)) _planarData[planarYOffsPlane1 + _planarX] = (byte)(((a & 0x02) << 6) | ((b & 0x02) << 5) | ((c & 0x02) << 4) | ((d & 0x02) << 3) | ((e & 0x02) << 2) | ((f & 0x02) << 1) | ((g & 0x02)) | ((h & 0x02) >> 1)); // a1b1c1d1e1f1g1h1
		if ((m_firstPlane<=2) && (m_lastPlane>=2)) _planarData[planarYOffsPlane2 + _planarX] = (byte)(((a & 0x04) << 5) | ((b & 0x04) << 4) | ((c & 0x04) << 3) | ((d & 0x04) << 2) | ((e & 0x04) << 1) | ((f & 0x04)) | ((g & 0x04) >> 1) | ((h & 0x04) >> 2)); // a2b2c2d2e2f2g2h2
		if ((m_firstPlane<=3) && (m_lastPlane>=3)) _planarData[planarYOffsPlane3 + _planarX] = (byte)(((a & 0x08) << 4) | ((b & 0x08) << 3) | ((c & 0x08) << 2) | ((d & 0x08) << 1) | ((e & 0x08)) | ((f & 0x08) >> 1) | ((g & 0x08) >> 2) | ((h & 0x08) >> 3)); // a3b3c3d3e3f3g3h3
		if ((m_firstPlane<=4) && (m_lastPlane>=4)) _planarData[planarYOffsPlane4 + _planarX] = (byte)(((a & 0x10) << 3) | ((b & 0x10) << 2) | ((c & 0x10) << 1) | ((d & 0x10)) | ((e & 0x10) >> 1) | ((f & 0x10) >> 2) | ((g & 0x10) >> 3) | ((h & 0x10) >> 4)); // a4b4c4d4e4f4g4h4
		if ((m_firstPlane<=5) && (m_lastPlane>=5)) _planarData[planarYOffsPlane5 + _planarX] = (byte)(((a & 0x20) << 2) | ((b & 0x20) << 1) | ((c & 0x20)) | ((d & 0x20) >> 1) | ((e & 0x20) >> 2) | ((f & 0x20) >> 3) | ((g & 0x20) >> 4) | ((h & 0x20) >> 5)); // a5b5c5d5e5f5g5h5
		if ((m_firstPlane<=6) && (m_lastPlane>=6)) _planarData[planarYOffsPlane6 + _planarX] = (byte)(((a & 0x40) << 1) | ((b & 0x40)) | ((c & 0x40) >> 1) | ((d & 0x40) >> 2) | ((e & 0x40) >> 3) | ((f & 0x40) >> 4) | ((g & 0x40) >> 5) | ((h & 0x40) >> 6)); // a6b6c6d6e6f6g6h6
		if ((m_firstPlane<=7) && (m_lastPlane>=7)) _planarData[planarYOffsPlane7 + _planarX] = (byte)(((a & 0x80)) | ((b & 0x80) >> 1) | ((c & 0x80) >> 2) | ((d & 0x80) >> 3) | ((e & 0x80) >> 4) | ((f & 0x80) >> 5) | ((g & 0x80) >> 6) | ((h & 0x80) >> 7)); // a7b7c7d7e7f7g7h7
    }
}