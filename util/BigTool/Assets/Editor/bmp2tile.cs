using UnityEngine;
using UnityEditor;
using System.Collections;

public class bmp2tile : EditorWindow
{
	const string PPKEY_LAST_OPEN_DIRECTORY = "bmp2tile_last_open_directory";
	const string PPKEY_LAST_EXPORT_DIRECTORY = "bmp2tile_last_export_directory";

	PalettizedImage m_imageData;
	PalettizedImageConfig m_imageConfig;

	string m_lastOpenDirectory;
	string m_lastExportDirectory;
	Texture2D m_imageTexture;

	TileBank m_tileBank;
	TileMap m_tileMap;
	TilePalette m_tilePalette;
	PlanarImage m_planarImage;

	Rect m_tileBankWindowRect;
	Rect m_paletteRemapRect;

	[MenuItem("Untitled/bmp2tile %e")]
	static public void OpenWindow()
	{
		bmp2tile wnd = EditorWindow.GetWindow( typeof( bmp2tile ), false, "bmp2tile" ) as bmp2tile;
		wnd.Init();
	}

	public void Init()
	{
		if( PlayerPrefs.HasKey( PPKEY_LAST_OPEN_DIRECTORY ))
			m_lastOpenDirectory = PlayerPrefs.GetString( PPKEY_LAST_OPEN_DIRECTORY );
		else
			m_lastOpenDirectory = Application.dataPath;

		if( PlayerPrefs.HasKey( PPKEY_LAST_EXPORT_DIRECTORY ))
			m_lastExportDirectory = PlayerPrefs.GetString( PPKEY_LAST_EXPORT_DIRECTORY );
		else
			m_lastExportDirectory = Application.dataPath;

		m_imageTexture = null;
		m_imageData = null;
		m_tileBank = null;
		m_tileMap = null;
	}

	void OnGUI()
	{
		GUILayout.BeginHorizontal();

		if( GUILayout.Button( "Load BMP" ))
		{
			string path = EditorUtility.OpenFilePanel( "Open BMP file to convert into tilebank", m_lastOpenDirectory, "bmp" );
			m_lastOpenDirectory = System.IO.Path.GetDirectoryName( path );
			SaveLastOpenDirectory();

			// Load corresponding config first as it have information on how the image should be loaded
			m_imageConfig = new PalettizedImageConfig( path + ".config" );

			m_imageData = PalettizedImage.LoadBMP( path, m_imageConfig );
			if( m_imageData != null )
			{
				m_tileBankWindowRect = new Rect( 5.0f, 30.0f, m_imageData.m_width*2.0f+10.0f, m_imageData.m_height*2.0f+10.0f+15.0f );
				m_paletteRemapRect = new Rect( m_tileBankWindowRect.x + m_tileBankWindowRect.width + 5.0f, m_tileBankWindowRect.y, 100.0f, 15.0f + (16.0f * 30.0f) );

				//
				int numberOfBitplanesIsHardcodedForNow = 4;
				m_planarImage = new PlanarImage( m_imageData, numberOfBitplanesIsHardcodedForNow);
				m_tileBank = new TileBank( m_imageData );
				m_tileMap = new TileMap( m_tileBank, m_imageData );
				m_tilePalette = new TilePalette( m_imageData );

				//
				int w, h;
				w = m_imageData.m_width;
				h = m_imageData.m_height;

				//
				m_imageTexture = new Texture2D( w, h, TextureFormat.ARGB32, false );
				m_imageTexture.filterMode = FilterMode.Point;

				//
				int x, y;
				for( y=0; y<h; y++ )
				{
					for( x=0; x<w; x++ )
					{
						int ii = ((h-1-y)*w)+x;
						int ic = m_imageData.m_image[ ii ];
						Color col = m_imageData.m_palette[ ic ];
						m_imageTexture.SetPixel( x, y, col );
					}
				}

				//
				m_imageTexture.Apply();
			}
		}

		//
		if((m_tileBank != null) && (m_tileMap != null))
		{
			if( GUILayout.Button( "Export" ))
			{
				//
				string outFileName = EditorUtility.SaveFilePanel( "Select folder to export to", m_lastExportDirectory, m_imageData.m_fileName, "bin" );
				
				//
				m_lastExportDirectory = System.IO.Path.GetDirectoryName( outFileName );
				SaveLastExportDirectory();
				
				//
				m_tileBank.Export( outFileName + ".bank" );
				m_tileMap.Export( outFileName + ".map" );
				m_tilePalette.Export( outFileName + ".palette" );
				m_planarImage.Export( outFileName + ".planar" );
			}
		}

		BeginWindows();
		if( m_tileBank != null )
		{
			m_tileBankWindowRect = GUI.Window( 0, m_tileBankWindowRect, OnDrawTileBank, "Original image" );
			m_paletteRemapRect = GUI.Window( 1, m_paletteRemapRect, OnDrawColorRemapTable, "Color remap" );
		}
		EndWindows();

		GUILayout.EndHorizontal();
	}

	void OnDrawTileBank( int _id )
	{
		if( m_imageTexture != null )
		{
			float left = 5.0f;
			float top = 20.0f;
			
			float draw_scale = 2.0f;
			float src_w = m_imageTexture.width;
			float src_h = m_imageTexture.height;
			float draw_w = src_w * draw_scale;
			float draw_h = src_h * draw_scale;
			Rect r = new Rect( left, top, draw_w, draw_h );
			GUI.DrawTexture( r, m_imageTexture );
			
			Color c = Color.gray;
			c.a = 0.25f;
			
			int numTilesW = (int)src_w;
			int numTilesH = (int)src_h;
			numTilesW >>= 3;
			numTilesH >>= 3;
			int tx, ty;
			for( ty=0; ty<numTilesH; ty++ )
			{
				for( tx=0; tx<numTilesW; tx++ )
				{
					float dx = tx*8.0f*draw_scale;
					float dy = ty*8.0f*draw_scale;
					Rect r2 = new Rect( left+dx, top+dy, 8.0f*draw_scale, 8.0f*draw_scale );
					GUI.Box( r2, "" );
				}
			}
		}

		GUI.DragWindow();
	}

	void OnDrawColorRemapTable( int _id )
	{
		float topy = 15.0f + 15.0f;
		float height = 30.0f;
		Rect r1 = new Rect( 70.0f, 15.0f, 30.0f, height );
		Rect r2 = new Rect( 0.0f, r1.y, r1.width, r1.height );

		Vector3 v1 = new Vector3( 30.0f, 0.0f, 0.0f );
		Vector3 v2 = new Vector3( 70.0f, 0.0f, 0.0f );
		//Vector3 l = new Vector2( -1.0f, 0.0f );
		//Vector3 r = new Vector2( 1.0f, 0.0f );

		int i1;
		for( i1=0; i1<16; i1++ )
		{
			int i2 = m_imageConfig.m_colorRemapSourceToDest[ i1 ];

			Color c1 = m_imageData.m_palette[ i1 ];
			if( c1.a > 0.5f )
				EditorGUI.DrawRect( r1, c1 );
			else
				GUI.Box( r1, "" );

			Color c2 = m_imageData.m_palette[ i2 ];
			if( c2.a > 0.5f )
				EditorGUI.DrawRect( r2, c2 );
			else
				GUI.Box( r2, "" );

			float y1 = topy + (i1*r1.height);
			float y2 = topy + (i2*r2.height);

			v1.y = y2;
			v2.y = y1;

			//Handles.DrawBezier( v1, v2, Vector2.zero, Vector2.zero, Color.white, null, 2.0f );
			//Handles.DrawLine( v1, v2 );
			Handles.DrawBezier( v1, v2, v1+Vector3.right*30.0f, v2+Vector3.left*30.0f, Color.white, null, 2.0f );

			if( m_imageData.m_colorUsed[ i1 ] == false )
			{
				Handles.color = Color.red;
				Handles.DrawLine( new Vector2( r1.x, r1.y ), new Vector2( r1.x+r1.width, r1.y+r1.height ));
			}
			
			if( m_imageData.m_colorUsed[ i2 ] == false )
			{
				Handles.color = Color.red;
				Handles.DrawLine( new Vector2( r2.x, r2.y ), new Vector2( r2.x+r2.width, r2.y+r2.height ));
			}

			r1.y += r1.height;
			r2.y += r2.height;
		}
		
		GUI.DragWindow();
	}

	void SaveLastOpenDirectory()
	{
		PlayerPrefs.SetString( PPKEY_LAST_OPEN_DIRECTORY, m_lastOpenDirectory );
		PlayerPrefs.Save();
	}
	
	void SaveLastExportDirectory()
	{
		Debug.Log( "m_lastExportDirectory=" + m_lastExportDirectory );
		PlayerPrefs.SetString( PPKEY_LAST_EXPORT_DIRECTORY, m_lastExportDirectory );
		PlayerPrefs.Save();
	}
}
