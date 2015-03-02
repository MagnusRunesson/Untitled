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
