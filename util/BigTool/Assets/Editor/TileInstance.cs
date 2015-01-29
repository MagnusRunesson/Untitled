using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class TileInstance
{
	public TileInstance( TileBank _tileBank, Tile _tile, int _tileBankIndex, bool _flipX, bool _flipY )
	{
		m_tileBank = _tileBank;
		m_tile = _tile;
		m_paletteIndex = 0;
		m_tileBankIndex = _tileBankIndex;
		m_flipX = _flipX;
		m_flipY = _flipY;
	}

	public TileBank m_tileBank;
	public Tile m_tile;
	public int m_paletteIndex;
	public int m_tileBankIndex;
	public bool m_flipX;
	public bool m_flipY;

}
