using UnityEngine;
using UnityEditor;
using System.Collections;

public class bmp2tile : EditorWindow
{
	const string PPKEY_PROJECT_PATH = "bmp2tile_project_path";
	const string PPKEY_LAST_OPEN_DIRECTORY = "bmp2tile_last_open_directory";
	const string PPKEY_LAST_EXPORT_DIRECTORY = "bmp2tile_last_export_directory";

	PalettizedImage m_imageData;
	PalettizedImageConfig m_imageConfig;

	string m_lastOpenDirectory;
	string m_lastExportDirectory;
	Texture2D m_imageTexture;

	string m_openImageName;
	Project m_project;

	TileBank m_tileBank;
	TileMap m_tileMap;
	TilePalette m_tilePalette;
	PlanarImage m_planarImage;

	Rect m_tileBankWindowRect;
	Rect m_paletteRemapRect;
	Rect m_imageSettingsRect;
	Rect m_projectWindowRect;

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
		m_imageData = null;
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
			m_tileBankWindowRect = GUI.Window( 0, m_tileBankWindowRect, OnDrawTileBank, m_openImageName );
			m_paletteRemapRect = GUI.Window( 1, m_paletteRemapRect, OnDrawColorRemapTable, "Color remap" );
			m_imageSettingsRect = GUI.Window( 2, m_imageSettingsRect, OnDrawImageSettings, "Image settings" );
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

	void OnDrawImageSettings( int _id )
	{
		bool dirty = false;

		bool before = m_imageConfig.m_importAsSprite;
		m_imageConfig.m_importAsSprite = GUILayout.Toggle( before, "Import as sprite" );
		if( m_imageConfig.m_importAsSprite != before )
			dirty = true;

		if( dirty )
		{
			m_imageConfig.Save();
		}
	}

	void OnDrawProject( int _id )
	{
		string[] imageFiles = m_project.m_imageFiles;
		foreach( string fullPath in imageFiles )
		{
			string name = System.IO.Path.GetFileName( fullPath );
			if( GUILayout.Button( name ))
			{
				LoadBMP( fullPath );
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
		m_imageConfig = new PalettizedImageConfig( _path + ".config" );
		
		m_imageData = PalettizedImage.LoadBMP( _path, m_imageConfig );
		if( m_imageData != null )
		{
			m_openImageName = System.IO.Path.GetFileNameWithoutExtension( _path );
			m_tileBankWindowRect = new Rect( m_projectWindowWidth + (m_windowPadding*2.0f), m_windowTop, m_imageData.m_width*2.0f+10.0f, m_imageData.m_height*2.0f+10.0f+15.0f );
			m_imageSettingsRect = new Rect( m_tileBankWindowRect.x + m_tileBankWindowRect.width + m_windowPadding, m_tileBankWindowRect.y, 200.0f, 100.0f );
			m_paletteRemapRect = new Rect( m_imageSettingsRect.x + m_imageSettingsRect.width + m_windowPadding, m_imageSettingsRect.y, 100.0f, 15.0f + (16.0f * 30.0f) );

			//
			int numberOfBitplanesIsHardcodedForNow = 4;
			m_planarImage = new PlanarImage( m_imageData, numberOfBitplanesIsHardcodedForNow);
			bool OptimizedTilebank = (m_imageConfig.m_importAsSprite == false); // If we import the image as a sprite we should not optimize the tile bank
			m_tileBank = new TileBank( m_imageData, OptimizedTilebank );
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
			PalettizedImage imageData = PalettizedImage.LoadBMP( imageFile, imageConfig );

			//
			if( imageData != null )
			{
				// Convert to tile banks / planar images
				int numberOfBitplanesIsHardcodedForNow = 4;
				PlanarImage planarImage = new PlanarImage( imageData, numberOfBitplanesIsHardcodedForNow);
				TileBank tileBank = new TileBank( imageData, (imageConfig.m_importAsSprite==false) );
				TileMap tileMap = new TileMap( tileBank, imageData );
				TilePalette tilePalette = new TilePalette( imageData );

				// Export it
				if( imageConfig.m_importAsSprite )
				{
					tileBank.Export( outBaseName + "_sprite_chunky.bin" );
					tilePalette.Export( outBaseName + "_palette.bin" );
					planarImage.Export( outBaseName + "_sprite_planar.bin" );

					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite_chunky.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_palette.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite_planar.bin" );
				}
				else
				{
					tileBank.Export( outBaseName + "_bank.bin" );
					tileMap.Export( outBaseName + "_map.bin" );
					tilePalette.Export( outBaseName + "_palette.bin" );
					planarImage.Export( outBaseName + "_planar.bin" );

					//
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_bank.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_map.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_palette.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_planar.bin" );
				}
			}
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
			int numberOfBitplanesIsHardcodedForNow = 4;
			m_planarImage = new PlanarImage( m_imageData, numberOfBitplanesIsHardcodedForNow);
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


