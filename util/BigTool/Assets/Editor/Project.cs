using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Assets.Editor;

[System.Serializable]
public class Project : ISerializationCallbackReceiver
{
	Dictionary<string,object> m_defaultSettings;

	Dictionary<string,object> m_settings;
	string m_path;
	string m_projectFileName;
	string m_lastExportDirectory;

    private FileIdConstants m_fileIdList;

	public string[] m_imageFiles;
	public string[] m_mapFiles;
	public string[] m_gameObjectCollectionFiles;
	public string[] m_roomCollectionFiles;


	public List<string> _keys = new List<string>();
	public List<object> _values = new List<object>();
	//Unity doesn't know how to serialize a Dictionary
	public void OnBeforeSerialize()
	{
		_keys.Clear();
		_values.Clear();
		foreach(var kvp in m_settings)
		{
			_keys.Add(kvp.Key);
			_values.Add(kvp.Value);
		}
	}

	public void OnAfterDeserialize()
	{
		m_settings = new Dictionary<string,object>();
		if((_keys != null) && (_values != null))
		{
			for (int i=0; i!= System.Math.Min(_keys.Count,_values.Count); i++)
				m_settings.Add(_keys[i],_values[i]);
		}
	}

	public Project( string _path )
	{
		m_defaultSettings = new Dictionary<string, object>{{"hej",0},{"hopp",1}};

		/*
		Debug.Log( "default settings:" );
		foreach( var kvp in m_defaultSettings )
		{
			Debug.Log (kvp.Key + "=" + kvp.Value );
		}
		*/

		m_path = _path;
		m_projectFileName = m_path + System.IO.Path.DirectorySeparatorChar + "project.config";
		Debug.Log ("m_projectFileName=" + m_projectFileName );

		Load();
		Save();
		
		//
		ScanFiles();
	}

	//
	//
	//
	public void Save()
	{
		Debug.Log ("saving config to " + m_projectFileName );
		string jsonString = MiniJSON.Json.Serialize( m_settings );
		System.IO.File.WriteAllText( m_projectFileName, jsonString );
	}

	//
	//
	//
	void Load()
	{
		//
		m_settings = new Dictionary<string, object>();

		// Load settings from JSON file
		Dictionary<string,object> loadedSettings = null;
		if( System.IO.File.Exists( m_projectFileName ))
		{
			Debug.Log ("we have a config, wohoo!" );
			string jsonString = System.IO.File.ReadAllText( m_projectFileName );
			loadedSettings = MiniJSON.Json.Deserialize( jsonString ) as Dictionary<string,object>;
		}
		else
		{
			loadedSettings = new Dictionary<string, object>();
		}

		// At this point the json variable is either a loaded json or a completely empty dictionary
		foreach( var defaultKvp in m_defaultSettings )
		{
			// For each default setting we ask the JSON if they have any overrides.
			// If it doesn't have an override we'll use the default setting.

			string key = defaultKvp.Key;
			object value = defaultKvp.Value;
			if( loadedSettings.ContainsKey( key ))
			{

				value = loadedSettings[ key ];
			}

			m_settings.Add( key, value );
		}

		Debug.Log("settings");
		foreach( var kvp in m_settings )
		{
			Debug.Log (kvp.Key + "=" + kvp.Value );
		}
	}

	//
	//
	//
	public void ScanFiles()
	{
		List<string> imageFiles = new List<string>();
		imageFiles.AddRange( System.IO.Directory.GetFiles( m_path, "*.bmp" ));
		imageFiles.AddRange( System.IO.Directory.GetFiles( m_path, "*.png" ));
		m_imageFiles = imageFiles.ToArray();
		m_mapFiles = System.IO.Directory.GetFiles( m_path, "*.json" );
		m_gameObjectCollectionFiles = System.IO.Directory.GetFiles( m_path, "*.goc" );
		m_roomCollectionFiles = System.IO.Directory.GetFiles( m_path, "*.rc" );

		VerifyMapFiles();
		BuildFileList();
	}

	public string GetOutFileNameNoExt( string _sourceFileName )
	{
		return System.IO.Path.GetFileNameWithoutExtension( _sourceFileName ).ToLower();
	}
	
	public string GetOutBaseName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + outFileNameNoExt;
	}

	public string GetSpriteTileName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_sprite_bank.bin";
	}

    public string GetSpriteTileNameAmiga(string _sourceFileName)
    {
        //"_sprite_bank_amiga_b_hw.bin"
        //"_sprite_bank_amiga_a_bob.bin";

        string outFileNameNoExt = GetOutFileNameNoExt(_sourceFileName);
        return outFileNameNoExt + "_sprite_bank_amiga.bin";
    }

	public string GetSpriteName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_sprite.bin";
	}

	public string GetTileBankName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_bank.bin";
	}

    public string GetTileBankNameAmiga(string _sourceFileName)
    {
        string outFileNameNoExt = GetOutFileNameNoExt(_sourceFileName);
        return outFileNameNoExt + "_bank_amiga.bin";
    }

	public string GetTileMapName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_map.bin";
	}

	public string GetCollisionMapName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_collisionmap.bin";
	}

	public string GetPaletteName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_palette.bin";
	}

	public string GetGreatGameObjectName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_goc.bin";
	}

	public string GetRoomCollectionName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return outFileNameNoExt + "_rc.bin";
	}

    public int GetIDFromConstant( string _constant )
    {
        return m_fileIdList.GetIDFromConstant(_constant);
    }

	public void Export( string _directory, bool _dryRun = false )
	{
		m_lastExportDirectory = _directory;

		//
		// Build data.asm and files.asm content
		//
        m_fileIdList = new FileIdConstants();
        var megadriveFileData = new FileData();
        var amigaFileData = new FileData();
		
		//
		// Export all images
		//
		foreach( string imageFile in m_imageFiles )
		{
			if( _dryRun == false )
				Debug.Log( "Exporting file '" + imageFile + "'" );
			
			string outFileNameNoExt = GetOutFileNameNoExt( imageFile );
			//string outBaseName = GetOutBaseName( imageFile );
			
			//
			PalettizedImageConfig imageConfig = new PalettizedImageConfig( imageFile + ".config" );
			PalettizedImage imageData = PalettizedImage.LoadImage( imageFile, imageConfig );
			
			//
			if( imageData != null )
			{
				// Export it
				if( imageConfig.m_importAsSprite )
				{
                    //string alternativeAmigaSpriteName;
                    //if( imageConfig.m_importAsBSprite )
                    //{
                    //    alternativeAmigaSpriteName = "_sprite_bank_amiga_b_hw.bin";
                    //}
                    //else
                    //{
                    //    alternativeAmigaSpriteName = "_sprite_bank_amiga_a_bob.bin";						
                    //}

                    m_fileIdList.AddFile(GetSpriteTileName(outFileNameNoExt));
                    megadriveFileData.AddDynamicFile(GetSpriteTileName(outFileNameNoExt));
                    amigaFileData.AddDynamicFile(GetSpriteTileNameAmiga(outFileNameNoExt));
                    m_fileIdList.AddFile(GetPaletteName(outFileNameNoExt));
                    megadriveFileData.AddDynamicFile(GetPaletteName(outFileNameNoExt));
                    amigaFileData.AddDynamicFile(GetPaletteName(outFileNameNoExt));
                    m_fileIdList.AddFile(GetSpriteName(outFileNameNoExt));
                    megadriveFileData.AddStaticFile(GetSpriteName(outFileNameNoExt));
                    amigaFileData.AddDynamicFile(GetSpriteName(outFileNameNoExt));
				}
				else
				{
                    m_fileIdList.AddFile(GetTileBankName(outFileNameNoExt));
                    megadriveFileData.AddDynamicFile(GetTileBankName(outFileNameNoExt));
                    amigaFileData.AddDynamicFile(GetTileBankNameAmiga(outFileNameNoExt)); 
                    m_fileIdList.AddFile(GetTileMapName(outFileNameNoExt));
                    megadriveFileData.AddDynamicFile(GetTileMapName(outFileNameNoExt));
                    amigaFileData.AddDynamicFile(GetTileMapName(outFileNameNoExt));
                    m_fileIdList.AddFile(GetPaletteName(outFileNameNoExt));
                    megadriveFileData.AddDynamicFile(GetPaletteName(outFileNameNoExt));
                    amigaFileData.AddDynamicFile(GetPaletteName(outFileNameNoExt));
				}
			}
		}
		
		//
		// Export all maps
		//
		foreach( string mapFile in m_mapFiles )
		{
			if( _dryRun == false )
				Debug.Log( "Exporting map '" + mapFile + "'" );
			
			string outFileNameNoExt = GetOutFileNameNoExt( mapFile );

			//
            m_fileIdList.AddFile(GetTileMapName(outFileNameNoExt));
            megadriveFileData.AddDynamicFile(GetTileMapName(outFileNameNoExt));
            amigaFileData.AddDynamicFile(GetTileMapName(outFileNameNoExt));
            m_fileIdList.AddFile(GetCollisionMapName(outFileNameNoExt));
            megadriveFileData.AddDynamicFile(GetCollisionMapName(outFileNameNoExt));
            amigaFileData.AddDynamicFile(GetCollisionMapName(outFileNameNoExt));
		}

		//
		// Export all game objects
		//
		foreach( string goFile in m_gameObjectCollectionFiles )
		{
			if( _dryRun == false )
				Debug.Log( "Exporting file '" + goFile + "'" );
			
			string outFileNameNoExt = GetOutFileNameNoExt( goFile );
			//string outBaseName = GetOutBaseName( imageFile );
			
			GameObjectCollection ggo = new GameObjectCollection(  goFile );
			
			//
			m_fileIdList.AddFile(GetGreatGameObjectName(outFileNameNoExt));
			megadriveFileData.AddStaticFile(GetGreatGameObjectName(outFileNameNoExt));
			amigaFileData.AddStaticFile(GetGreatGameObjectName(outFileNameNoExt));
		}
		
		//
		// Export all room collections
		//
		foreach( string rcFile in m_roomCollectionFiles )
		{
			if( _dryRun == false )
				Debug.Log( "Exporting file '" + rcFile + "'" );
			
			string outFileNameNoExt = GetOutFileNameNoExt( rcFile );
			//string outBaseName = GetOutBaseName( imageFile );
			
			RoomCollection rc = new RoomCollection(  rcFile );
			
			//
			m_fileIdList.AddFile( GetRoomCollectionName( outFileNameNoExt ));
			megadriveFileData.AddStaticFile( GetRoomCollectionName( outFileNameNoExt ));
			amigaFileData.AddStaticFile( GetRoomCollectionName( outFileNameNoExt ));
		}
		
		//
		// Generate assembly files that tie everything together
		//
		if( _dryRun == false )
		{			
            m_fileIdList.ExportAsm(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "files.asm");

            megadriveFileData.ExportFileIdMap(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "fileidmap_md.asm");
            megadriveFileData.ExportDynamicDataFile(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "datadyn_md.asm");
            megadriveFileData.ExportStaticDataFile(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "datasta_md.asm");

            amigaFileData.ExportFileIdMap(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "fileidmap_adf.asm");
            amigaFileData.ExportDynamicDataFile(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "datadyn_adf.asm");
            amigaFileData.ExportStaticDataFile(m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "datasta_adf.asm");  
		}
	}


	void BuildFileList()
	{
		Export( null, _dryRun:true );
	}
	




	// Filter out all found JSON files that aren't Tiled data
	void VerifyMapFiles()
	{
		List<string> actualMapFiles = new List<string>();

		foreach( string mapFile in m_mapFiles )
		{
			string jsonString = System.IO.File.ReadAllText( mapFile );
			Dictionary<string,object> json = (Dictionary<string,object>)MiniJSON.Json.Deserialize( jsonString );
			if( json.ContainsKey( "tilesets" ))
				actualMapFiles.Add( mapFile );
		}

		//
		m_mapFiles = actualMapFiles.ToArray();
	}
}
