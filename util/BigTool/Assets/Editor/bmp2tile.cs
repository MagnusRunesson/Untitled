using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

public class bmp2tile : EditorWindow
{
	const string PPKEY_PROJECT_PATH = "bmp2tile_project_path";
	const string PPKEY_LAST_OPEN_DIRECTORY = "bmp2tile_last_open_directory";
	const string PPKEY_LAST_EXPORT_DIRECTORY = "bmp2tile_last_export_directory";

	PalettizedImage m_currentImageData;
	PalettizedImageConfig m_currentImageConfig;
	string m_currentFramesString;
	Dictionary<int,string> m_currentFrameTimesString;

	string m_lastOpenDirectory;
	string m_lastExportDirectory;
	Texture2D m_imageTexture;
	Texture2D m_mapTexture;

	string m_openImageName;
	string m_openMapName;

	Project m_project;

	TileBank m_tileBank;
	TileMap m_tileMap;
	TilePalette m_tilePalette;
//	PlanarImage m_planarImage;

	Rect m_tileBankWindowRect;
	Rect m_paletteRemapRect;
	Rect m_imageSettingsRect;
	Rect m_projectWindowRect;
	Vector2 m_spriteFrameTimeScroll;
	Rect m_mapWindowRect;

	const float m_windowTop = 30.0f;
	const float m_windowPadding = 10.0f;
	const float m_projectWindowWidth = 250.0f;

	int m_exportedFileListIndex;

	[MenuItem("Untitled/bmp2tile %e")]
	static public void OpenWindow()
	{
		bmp2tile wnd = EditorWindow.GetWindow( typeof( bmp2tile ), false, "Untitled 2 Data" ) as bmp2tile;
		wnd.Init();
	}

	public void Init()
	{
		m_project = null;
		if( PlayerPrefs.HasKey( PPKEY_PROJECT_PATH ))
		{
			LoadProject( PlayerPrefs.GetString( PPKEY_PROJECT_PATH ));
			//m_project = new Project( PlayerPrefs.GetString( PPKEY_PROJECT_PATH ));
		}

		if( PlayerPrefs.HasKey( PPKEY_LAST_OPEN_DIRECTORY ))
			m_lastOpenDirectory = PlayerPrefs.GetString( PPKEY_LAST_OPEN_DIRECTORY );
		else
			m_lastOpenDirectory = Application.dataPath;

		if( PlayerPrefs.HasKey( PPKEY_LAST_EXPORT_DIRECTORY ))
			m_lastExportDirectory = PlayerPrefs.GetString( PPKEY_LAST_EXPORT_DIRECTORY );
		else
			m_lastExportDirectory = Application.dataPath;

		m_imageTexture = null;
		m_currentImageData = null;
		m_tileBank = null;
		m_tileMap = null;
	}

	void OnGUI()
	{
		GUILayout.BeginHorizontal();

		//if( m_project == null )
		{
			if( GUILayout.Button( "Load project" ))
			{
				string path = EditorUtility.OpenFolderPanel( "Open project folder", Application.dataPath, "" );

				//
				PlayerPrefs.SetString( PPKEY_PROJECT_PATH, path );
				PlayerPrefs.Save();

				//
				LoadProject( path );
			}
		}

		if( m_project != null )
		{
			if( GUILayout.Button( "Export all" ))
			{
				ExportAll();
			}
		}

		/*
		if( GUILayout.Button( "Load BMP" ))
		{
			string path = EditorUtility.OpenFilePanel( "Open BMP file to convert into tilebank", m_lastOpenDirectory, "bmp" );
			m_lastOpenDirectory = System.IO.Path.GetDirectoryName( path );
			SaveLastOpenDirectory();

			LoadBMP( path );
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
				string outFileNameNoExt = System.IO.Path.GetFileNameWithoutExtension( outFileName ).ToLower();
				string outBaseName = m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + outFileNameNoExt;

				//
				m_tileBank.Export( outBaseName + "_bank.bin" );
				m_tileMap.Export( outBaseName + "_map.bin" );
				m_tilePalette.Export( outBaseName + "_palette.bin" );
				m_planarImage.Export( outBaseName + "_planar.bin" );
			}
		}
		*/

		BeginWindows();
		if( m_tileBank != null )
		{
			m_tileBankWindowRect = GUI.Window( 0, m_tileBankWindowRect, OnDrawTileBank, "Tiles: " + m_openImageName );
			m_paletteRemapRect = GUI.Window( 1, m_paletteRemapRect, OnDrawColorRemapTable, "Color remap" );
			m_imageSettingsRect = GUI.Window( 2, m_imageSettingsRect, OnDrawImageSettings, "Image settings" );
		}

		if( m_mapTexture != null )
		{
			m_mapWindowRect = GUI.Window( 200, m_mapWindowRect, OnDrawMapWindow, "Map: " + m_openMapName );
		}

		if( m_project != null )
		{
			// Show the project window.
			m_projectWindowRect = GUI.Window( 100, m_projectWindowRect, OnDrawProject, "Project" );
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
			GUI.color = c;

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

	void OnDrawMapWindow( int _id )
	{
		if( m_mapTexture != null )
		{
			float left = 5.0f;
			float top = 20.0f;
			
			float draw_scale = 1.0f;
			float src_w = m_mapTexture.width;
			float src_h = m_mapTexture.height;
			float draw_w = src_w * draw_scale;
			float draw_h = src_h * draw_scale;
			Rect r = new Rect( left, top, draw_w, draw_h );
			GUI.DrawTexture( r, m_mapTexture );

			/*
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
			*/
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
			int i2 = m_currentImageConfig.m_colorRemapSourceToDest[ i1 ];

			Color c1 = m_currentImageData.m_palette[ i1 ];
			if( c1.a > 0.5f )
				EditorGUI.DrawRect( r1, c1 );
			else
				GUI.Box( r1, "" );

			Color c2 = m_currentImageData.m_palette[ i2 ];
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

			if( m_currentImageData.m_colorUsed[ i1 ] == false )
			{
				Handles.color = Color.red;
				Handles.DrawLine( new Vector2( r1.x, r1.y ), new Vector2( r1.x+r1.width, r1.y+r1.height ));
			}
			
			if( m_currentImageData.m_colorUsed[ i2 ] == false )
			{
				Handles.color = Color.red;
				Handles.DrawLine( new Vector2( r2.x, r2.y ), new Vector2( r2.x+r2.width, r2.y+r2.height ));
			}

			r1.y += r1.height;
			r2.y += r2.height;
		}
		
		GUI.DragWindow();
	}

	void OnDrawImageSettings( int _id )
	{
		m_spriteFrameTimeScroll = GUILayout.BeginScrollView( m_spriteFrameTimeScroll );
		bool dirty = false;

		bool before = m_currentImageConfig.m_importAsSprite;
		m_currentImageConfig.m_importAsSprite = GUILayout.Toggle( before, "Import as sprite" );
		if( m_currentImageConfig.m_importAsSprite != before )
			dirty = true;

		if( m_currentImageConfig.m_importAsSprite )
		{
			GUILayout.Label( "Sprite w=" + m_currentImageConfig.GetSpriteWidth() + ", h=" + m_currentImageConfig.GetSpriteHeight() );

			GUILayout.BeginHorizontal();
			GUILayout.Label( "Num frames" );
			string beforeString = m_currentFramesString;
			string newstring = GUILayout.TextField( beforeString );
			GUILayout.EndHorizontal();
			m_currentFramesString = newstring;

			if( beforeString.CompareTo( newstring ) != 0 )
			{
				int newint;
				if( int.TryParse( newstring, out newint ))
				{
					m_currentImageConfig.SetNumFrames( newint );
					dirty = true;
				}
			}

			GUILayout.Label("");
			GUILayout.Label("Frame times");

			int i;
			for( i=0; i<m_currentImageConfig.GetNumFrames(); i++ )
			{
				int time = m_currentImageConfig.GetFrameTime( i );

				GUILayout.BeginHorizontal();
				GUILayout.Label ("Frame " + i + ":" );
				if( m_currentFrameTimesString.ContainsKey( i ) == false )
				{
					m_currentFrameTimesString[ i ] = m_currentImageConfig.GetFrameTime( i ).ToString();
				}
				beforeString = m_currentFrameTimesString[ i ];
				string newString = GUILayout.TextField( beforeString );;
				m_currentFrameTimesString[ i ] = newString;
				if( beforeString != newString )
				{
					int newValue;
					if( int.TryParse( newString, out newValue ))
					{
						m_currentImageConfig.SetFrameTime( i, newValue );
						dirty = true;
					}
				}
				GUILayout.EndHorizontal();
			}
		}

		if( dirty )
		{
			m_currentImageConfig.Save();
		}
		GUI.DragWindow();

		GUILayout.EndScrollView();
	}

	void OnDrawProject( int _id )
	{
		GUILayout.Label( "Images:" );
		string[] imageFiles = m_project.m_imageFiles;
		foreach( string fullPath in imageFiles )
		{
			string name = System.IO.Path.GetFileName( fullPath );
			if( GUILayout.Button( name ))
			{
				m_mapTexture = null;
				LoadBMP( fullPath );
			}
		}

		GUILayout.Label( "Tile maps: ");
		string[] mapFiles = m_project.m_mapFiles;
		foreach( string fullPath in mapFiles )
		{
			string name = System.IO.Path.GetFileName( fullPath );
			if( GUILayout.Button( name ))
			{
				LoadMapPreview( fullPath );
			}
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

	void LoadProject( string _path )
	{
		m_project = new Project( _path );
		m_projectWindowRect = new Rect( m_windowPadding, m_windowTop, m_projectWindowWidth, 600.0f );
	}

	void LoadBMP( string _path )
	{
		m_openImageName = "<Untitled>";

		// Load corresponding config first as it have information on how the image should be loaded
		m_currentImageConfig = new PalettizedImageConfig( _path + ".config" );

		m_currentImageData = PalettizedImage.LoadImage( _path, m_currentImageConfig );
		if( m_currentImageData != null )
		{
			//
			m_currentImageConfig.SetImage( m_currentImageData );
			
			//
			m_currentFramesString = m_currentImageConfig.GetNumFrames().ToString();
			m_currentFrameTimesString = new Dictionary<int, string>();
			int iFrame;
			for( iFrame=0; iFrame<m_currentImageConfig.GetNumFrames(); iFrame++ )
			{
				m_currentFrameTimesString[ iFrame ] = m_currentImageConfig.GetFrameTime( iFrame ).ToString();
			}

			//
			m_openImageName = System.IO.Path.GetFileNameWithoutExtension( _path );
			m_tileBankWindowRect = new Rect( m_projectWindowWidth + (m_windowPadding*2.0f), m_windowTop, m_currentImageData.m_width*2.0f+10.0f, m_currentImageData.m_height*2.0f+10.0f+15.0f );
			m_imageSettingsRect = new Rect( m_tileBankWindowRect.x + m_tileBankWindowRect.width + m_windowPadding, m_tileBankWindowRect.y, 200.0f, 200.0f );
			m_paletteRemapRect = new Rect( m_imageSettingsRect.x + m_imageSettingsRect.width + m_windowPadding, m_imageSettingsRect.y, 100.0f, 15.0f + (16.0f * 30.0f) );

			//
//			m_planarImage = new PlanarImage( m_currentImageData);
			bool OptimizedTilebank = (m_currentImageConfig.m_importAsSprite == false); // If we import the image as a sprite we should not optimize the tile bank
			m_tileBank = new TileBank( m_currentImageData, OptimizedTilebank );
			m_tileMap = new TileMap( m_tileBank, m_currentImageData );
			m_tilePalette = new TilePalette( m_currentImageData );
			
			//
			int w, h;
			w = m_currentImageData.m_width;
			h = m_currentImageData.m_height;
			
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
					int ic = m_currentImageData.m_image[ ii ];
					Color col = m_currentImageData.m_palette[ ic ];
					m_imageTexture.SetPixel( x, y, col );
				}
			}
			
			//
			m_imageTexture.Apply();
		}
	}

	void LoadMapPreview( string _path )
	{
		string jsonString = System.IO.File.ReadAllText( _path );
		Dictionary<string,object> json = (Dictionary<string,object>)MiniJSON.Json.Deserialize( jsonString );
		m_mapTexture = null;

		m_openMapName = System.IO.Path.GetFileNameWithoutExtension( _path );
		if( json.ContainsKey( "tilesets" ) == false )
			return;

		//
		// Load tile bank (only one tile bank for each map for now)
		//
		List<object> tilesetsJson = (List<object>)json[ "tilesets" ];
		Dictionary<string,object> tilesetJson = (Dictionary<string,object>)tilesetsJson[ 0 ];
		//Debug.Log ("we have tilesets" );
		//Debug.Log ("tilesets=" + tilesetsJson );
		//Debug.Log ("tileset=" + tilesetJson );
		string imageFileName = (string)tilesetJson[ "image" ];
		string imageFullPath = System.IO.Path.GetDirectoryName( _path ) + System.IO.Path.DirectorySeparatorChar + imageFileName;
		//Debug.Log ("image file name=" + imageFileName + ", imagefullpath=" + imageFullPath );
		LoadBMP( imageFullPath );

		// Create map texture
		int map_tiles_w = ((int)(long)json[ "width" ]);
		int map_tiles_h = ((int)(long)json[ "height" ]);
		int map_pixels_w = map_tiles_w * 8;
		int map_pixels_h = map_tiles_h * 8;
		m_mapTexture = new Texture2D( map_pixels_w, map_pixels_h, TextureFormat.ARGB32, false );
		m_mapTexture.filterMode = FilterMode.Point;
		m_mapWindowRect = new Rect( m_tileBankWindowRect.x, m_tileBankWindowRect.y, 10+map_pixels_w, 25+map_pixels_h );
		float add = m_mapWindowRect.x + m_mapWindowRect.width - m_projectWindowWidth - m_windowPadding;
		m_tileBankWindowRect.x += add;
		m_paletteRemapRect.x += add;
		m_imageSettingsRect.x += add;
		//m_projectWindowRect.x += add;

		// Find each layer
		List<object> layersJson = (List<object>)json[ "layers" ];
		Dictionary<string,object> layerJson = (Dictionary<string,object>)layersJson[ 0 ];
		List<object> layerData = (List<object>)layerJson[ "data" ];
		int tile_x, tile_y;
		for( tile_y=0; tile_y<map_tiles_h; tile_y++ )
		{
			for( tile_x=0; tile_x<map_tiles_w; tile_x++ )
			{
				int i = tile_y*map_tiles_w + tile_x;
				int tile_id = (int)(long)layerData[i];
				tile_id--;
				TileInstance tileInstance = m_tileBank.m_allTileInstances[ tile_id ];

				int tile_pixel_x;
				int tile_pixel_y;
				for( tile_pixel_y=0; tile_pixel_y<8; tile_pixel_y++ )
				{
					for( tile_pixel_x=0; tile_pixel_x<8; tile_pixel_x++ )
					{
						int tile_pixel_i = (tile_pixel_y*8)+tile_pixel_x;
						byte palindex = tileInstance.m_tile.m_pixels[ tile_pixel_i ];
						Color col = m_currentImageData.m_palette[ palindex ];

						int dst_x = (tile_x*8) + tile_pixel_x;
						int dst_y = (tile_y*8) + tile_pixel_y;

						m_mapTexture.SetPixel( dst_x, map_pixels_h - 1 - dst_y, col );
					}
				}
			}
		}

		m_mapTexture.Apply();


		/*
		m_openImageName = "<Untitled>";
		
		// Load corresponding config first as it have information on how the image should be loaded
		m_currentImageConfig = new PalettizedImageConfig( _path + ".config" );
		
		m_currentImageData = PalettizedImage.LoadBMP( _path, m_currentImageConfig );
		if( m_currentImageData != null )
		{
			//
			m_currentImageConfig.SetImage( m_currentImageData );
			
			//
			m_currentFramesString = m_currentImageConfig.GetNumFrames().ToString();
			
			//
			m_openImageName = System.IO.Path.GetFileNameWithoutExtension( _path );
			m_tileBankWindowRect = new Rect( m_projectWindowWidth + (m_windowPadding*2.0f), m_windowTop, m_currentImageData.m_width*2.0f+10.0f, m_currentImageData.m_height*2.0f+10.0f+15.0f );
			m_imageSettingsRect = new Rect( m_tileBankWindowRect.x + m_tileBankWindowRect.width + m_windowPadding, m_tileBankWindowRect.y, 200.0f, 100.0f );
			m_paletteRemapRect = new Rect( m_imageSettingsRect.x + m_imageSettingsRect.width + m_windowPadding, m_imageSettingsRect.y, 100.0f, 15.0f + (16.0f * 30.0f) );
			
			//
			m_planarImage = new PlanarImage( m_currentImageData);
			bool OptimizedTilebank = (m_currentImageConfig.m_importAsSprite == false); // If we import the image as a sprite we should not optimize the tile bank
			m_tileBank = new TileBank( m_currentImageData, OptimizedTilebank );
			m_tileMap = new TileMap( m_tileBank, m_currentImageData );
			m_tilePalette = new TilePalette( m_currentImageData );
			
			//
			int w, h;
			w = m_currentImageData.m_width;
			h = m_currentImageData.m_height;
			
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
					int ic = m_currentImageData.m_image[ ii ];
					Color col = m_currentImageData.m_palette[ ic ];
					m_imageTexture.SetPixel( x, y, col );
				}
			}
			
			//
			m_imageTexture.Apply();
		}
		*/
	}

	//
	void ExportAll()
	{
		//
		m_exportedFileListIndex = 0;

		//
		string outFileName = EditorUtility.SaveFilePanel( "Select folder to export to", m_lastExportDirectory, "filenameignored", "bin" );
		
		//
		m_lastExportDirectory = System.IO.Path.GetDirectoryName( outFileName );
		SaveLastExportDirectory();

		//
		// Build data.asm and files.asm content
		//
		string asmData = "";
		string asmFileList = "";
		string asmFileMap = "FileIDMap:\n";

		//
		// Export all images
		//
		string[] imageFiles = m_project.m_imageFiles;
		foreach( string imageFile in imageFiles )
		{
			Debug.Log( "Exporting file '" + imageFile + "'" );

			string outFileNameNoExt = System.IO.Path.GetFileNameWithoutExtension( imageFile ).ToLower();
			string outBaseName = m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + outFileNameNoExt;

			//
			PalettizedImageConfig imageConfig = new PalettizedImageConfig( imageFile + ".config" );
			PalettizedImage imageData = PalettizedImage.LoadImage( imageFile, imageConfig );

			//
			if( imageData != null )
			{
				//
				imageConfig.SetImage( imageData );

				// Convert to tile banks / planar images
//				PlanarImage planarImage = new PlanarImage( imageData);
				TileBank tileBank = new TileBank( imageData, (imageConfig.m_importAsSprite==false) );
				TilePalette tilePalette = new TilePalette( imageData );

				// Export it
				if( imageConfig.m_importAsSprite )
				{
					Sprite sprite = new Sprite( imageConfig );
					AmigaSprite amigaSprite = new AmigaSprite( imageData, imageConfig);
					tileBank.ExportMegaDrive( outBaseName + "_sprite_chunky.bin" );
					amigaSprite.Export( outBaseName + "_sprite_amiga.bin" );
					tilePalette.Export( outBaseName + "_palette.bin" );
					sprite.Export( outBaseName + "_sprite.bin" );
					//planarImage.Export( outBaseName + "_sprite_planar.bin" );

					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite_chunky.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite_amiga.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_palette.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite.bin" );
					//AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite_planar.bin" );
				}
				else
				{
					TileMap tileMap = new TileMap( tileBank, imageData );

					tileBank.ExportMegaDrive( outBaseName + "_bank.bin" );
					tileBank.ExportAmiga( outBaseName + "_bank_amiga.bin" );
					tileMap.Export( outBaseName + "_map.bin" );
					tilePalette.Export( outBaseName + "_palette.bin" );
//					planarImage.Export( outBaseName + "_bank_amiga.bin" );

					//
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_bank.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_bank_amiga.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_map.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_palette.bin" );
				}
			}
		}

		//
		// Export all maps
		//
		string[] mapFiles = m_project.m_mapFiles;
		foreach( string mapFile in mapFiles )
		{
			Debug.Log( "Exporting map '" + mapFile + "'" );
			
			string outFileNameNoExt = System.IO.Path.GetFileNameWithoutExtension( mapFile ).ToLower();
			string outBaseName = m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + outFileNameNoExt;
			
			//
			TileMap tileMap = TileMap.LoadJson( mapFile );
			tileMap.Export( outBaseName + "_map.bin" );

			//
			AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_map.bin" );
		}

		System.IO.File.WriteAllText( m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "data.asm", asmData );
		System.IO.File.WriteAllText( m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "files.asm", asmFileList + "\n" + asmFileMap );

		/*
		//
		string outFileNameNoExt = System.IO.Path.GetFileNameWithoutExtension( outFileName ).ToLower();
		string outBaseName = m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + outFileNameNoExt;

		// Load corresponding config first as it have information on how the image should be loaded
		m_imageConfig = new PalettizedImageConfig( _path + ".config" );
		
		m_imageData = PalettizedImage.LoadBMP( _path, m_imageConfig );
		if( m_imageData != null )
		{
			m_openImageName = System.IO.Path.GetFileNameWithoutExtension( _path );
			m_tileBankWindowRect = new Rect( m_projectWindowWidth + (m_windowPadding*2.0f), m_windowTop, m_imageData.m_width*2.0f+10.0f, m_imageData.m_height*2.0f+10.0f+15.0f );
			m_paletteRemapRect = new Rect( m_tileBankWindowRect.x + m_tileBankWindowRect.width + m_windowPadding, m_tileBankWindowRect.y, 100.0f, 15.0f + (16.0f * 30.0f) );
			
			//
			m_planarImage = new PlanarImage( m_imageData);
			m_tileBank = new TileBank( m_imageData );
			m_tileMap = new TileMap( m_tileBank, m_imageData );
			m_tilePalette = new TilePalette( m_imageData );
		}

		//
		m_tileBank.Export( outBaseName + "_bank.bin" );
		m_tileMap.Export( outBaseName + "_map.bin" );
		m_tilePalette.Export( outBaseName + "_palette.bin" );
		m_planarImage.Export( outBaseName + "_planar.bin" );
		*/

        Debug.Log("Export is finished!");
	}

	void AddFile( ref string _asmData, ref string _asmFileList, ref string _asmFileMap, string _filename )
	{
		//string asmFileName = System.IO.Path.GetFileNameWithoutExtension( _filename ).Replace( ' ', '_' );
		string label = GetLabelNameFromFileName( _filename );
		string constant = GetConstantNameFromFileName( _filename );

		// Append to data.asm
		_asmData += "\n\n; " + _filename + "\n\n";
		_asmData += "\tcnop\t\t0,_chunk_size\n";
		_asmData += label + ":\n";
		_asmData += "\tincbin\t\"../src/incbin/" + _filename + "\"\n";
		_asmData += (label + "_pos").PadRight( 40 ) + "equ " + label + "/_chunk_size\n";
		_asmData += (label + "_length").PadRight( 40 ) +"equ ((" + label + "_end-" + label + ")+(_chunk_size-1))/_chunk_size\n";
		_asmData += label + "_end:\n";

		// Append to files.asm
		_asmFileList += constant.PadRight( 40 ) + "equ " + m_exportedFileListIndex + "\n";
		_asmFileMap += "\tdc.w\t" + label + "_pos," + label + "_length\n";
		m_exportedFileListIndex++;
/*
 * This is what we want to output to data.asm

	cnop		0,_chunk_size

_data_untitled_splash_bank:
	incbin	"../src/incbin/untitled_splash_bank.bin"
_data_untitled_splash_bank_pos				equ _data_untitled_splash_bank/_chunk_size
_data_untitled_splash_bank_length			equ ((_data_untitled_splash_bank_end-_data_untitled_splash_bank)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_bank_end:

*/
	}

	string GetLabelNameFromFileName( string _sourceFileName )
	{
		string ret = "_data_";
		ret += System.IO.Path.GetFileNameWithoutExtension( _sourceFileName );
		ret = ret.Replace( ' ', '_' );
		ret = ret.ToLower();
		
		return ret;
	}

	string GetConstantNameFromFileName( string _sourceFileName )
	{
		string ret = "fileid_";
		ret += System.IO.Path.GetFileNameWithoutExtension( _sourceFileName );
		ret = ret.Replace( ' ', '_' );
		ret = ret.ToLower();

		return ret;
	}
}


