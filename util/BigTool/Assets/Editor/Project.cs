using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class Project : ISerializationCallbackReceiver
{
	Dictionary<string,object> m_defaultSettings;

	Dictionary<string,object> m_settings;
	string m_path;
	string m_projectFileName;
	string m_lastExportDirectory;

	public string[] m_imageFiles;
	public string[] m_mapFiles;


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

		VerifyMapFiles();
	}

	int m_exportedFileListIndex;
	public void Export( string _directory )
	{
		m_lastExportDirectory = _directory;

		//
		m_exportedFileListIndex = 0;
		
		//
		// Build data.asm and files.asm content
		//
		string asmData = "";
		string asmFileList = "";
		string asmFileMap = "FileIDMap:\n";
		
		//
		// Export all images
		//
		foreach( string imageFile in m_imageFiles )
		{
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
					string alternativeAmigaSpriteName;
					if( imageConfig.m_importAsBSprite )
					{
						alternativeAmigaSpriteName = "_sprite_bank_amiga_b_hw.bin";
					}
					else
					{
						alternativeAmigaSpriteName = "_sprite_bank_amiga_a_bob.bin";						
					}

					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite_bank.bin", outFileNameNoExt + alternativeAmigaSpriteName );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_palette.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_sprite.bin" );
				}
				else
				{
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_bank.bin", outFileNameNoExt + "_bank_amiga.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_map.bin" );
					AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_palette.bin" );
				}
			}
		}
		
		//
		// Export all maps
		//
		foreach( string mapFile in m_mapFiles )
		{
			Debug.Log( "Exporting map '" + mapFile + "'" );
			
			string outFileNameNoExt = GetOutFileNameNoExt( mapFile );

			//
			AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_map.bin" );
			AddFile( ref asmData, ref asmFileList, ref asmFileMap, outFileNameNoExt + "_collisionmap.bin" );
		}
		
		System.IO.File.WriteAllText( m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "data.asm", asmData );
		System.IO.File.WriteAllText( m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + "files.asm", asmFileList + "\n" + asmFileMap );
	}

	void AddFile( ref string _asmData, ref string _asmFileList, ref string _asmFileMap, string _filename, string _alternativeAmigaFilename = null )
	{
		//string asmFileName = System.IO.Path.GetFileNameWithoutExtension( _filename ).Replace( ' ', '_' );
		string label = GetLabelNameFromFileName( _filename );
		string constant = GetConstantNameFromFileName( _filename );
		
		// Append to data.asm
		_asmData += "\n\n; " + _filename + "\n\n";
		_asmData += "\tcnop\t\t0,_chunk_size\n";
		_asmData += label + ":\n";
		
		if (_alternativeAmigaFilename == null) 
		{
			_asmData += "\tincbin\t\"../src/incbin/" + _filename + "\"\n";
		}
		else
		{
			_asmData += "\tifd\tis_mega_drive\n";
			_asmData += "\tincbin\t\"../src/incbin/" + _filename + "\"\n";
			_asmData += "\telse\n";
			_asmData += "\tincbin\t\"../src/incbin/" + _alternativeAmigaFilename + "\"\n";
			_asmData += "\tendif\n";
		}
		
		_asmData += (label + "_pos").PadRight( 40 ) + "equ " + label + "/_chunk_size\n";
		_asmData += (label + "_length").PadRight( 40 ) +"equ ((" + label + "_end-" + label + ")+(_chunk_size-1))/_chunk_size\n";
		_asmData += label + "_end:\n";
		
		// Append to files.asm
		_asmFileList += constant.PadRight( 40 ) + "equ " + m_exportedFileListIndex + "\n";
		_asmFileMap += "\tdc.w\t" + label + "_pos," + label + "_length\n";
		m_exportedFileListIndex++;
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

	public string GetOutFileNameNoExt( string _sourceFileName )
	{
		return System.IO.Path.GetFileNameWithoutExtension( _sourceFileName ).ToLower();
	}

	public string GetOutBaseName( string _sourceFileName )
	{
		string outFileNameNoExt = GetOutFileNameNoExt( _sourceFileName );
		return m_lastExportDirectory + System.IO.Path.DirectorySeparatorChar + outFileNameNoExt;
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
