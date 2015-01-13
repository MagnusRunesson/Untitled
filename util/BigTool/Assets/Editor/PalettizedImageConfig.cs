using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PalettizedImageConfig
{
	const string JSONKEY_COLORREMAPTABLE = "Color_Remap_Table";
	const string JSONKEY_IMPORTASSPRITE = "Import_As_Sprite";

	string m_fileName;

	public Dictionary<int,int> m_colorRemapSourceToDest;
	public bool m_importAsSprite;

	public PalettizedImageConfig( string _path )
	{
		m_fileName = _path;
		SetupDefaults();

		// Verify that file exist
		if( System.IO.File.Exists( _path ) == false )
			return;

		string jsonString = System.IO.File.ReadAllText( _path );

		var dict = MiniJSON.Json.Deserialize( jsonString ) as Dictionary<string,object>;

		LoadColorMapTable( (Dictionary<string,object>)dict[ JSONKEY_COLORREMAPTABLE ]);
		LoadBool( ref m_importAsSprite, JSONKEY_IMPORTASSPRITE, dict );

		/*
		Debug.Log("deserialized: " + dict.GetType());
		Debug.Log("dict['array'][0]: " + ((List<object>) dict["array"])[0]);
		Debug.Log("dict['string']: " + (string) dict["string"]);
		Debug.Log("dict['float']: " + (double) dict["float"]); // floats come out as doubles
		Debug.Log("dict['int']: " + (long) dict["int"]); // ints come out as longs
		Debug.Log("dict['unicode']: " + (string) dict["unicode"]);
		*/

		//return image;
	}

	public void Save()
	{
		// Create a new settings ditionary
		Dictionary<string,object> jsonDict = new Dictionary<string, object>();
		jsonDict[ JSONKEY_COLORREMAPTABLE ] = m_colorRemapSourceToDest;
		jsonDict[ JSONKEY_IMPORTASSPRITE ] = m_importAsSprite;

		// Generate JSON string from settings dictionary
		string jsonString = MiniJSON.Json.Serialize( jsonDict );

		System.IO.File.WriteAllText( m_fileName, jsonString );
	}

	void SetupDefaults()
	{
		// Setup default mapping table
		m_colorRemapSourceToDest = new Dictionary<int, int>();
		int i;
		for( i=0; i<16; i++ )
		{
			m_colorRemapSourceToDest[ i ] = i;
		}

		//
		m_importAsSprite = false;
	}

	void LoadColorMapTable( Dictionary<string,object> _table )
	{
		// Parse the table in the config file
		foreach( KeyValuePair<string,object> kvp in _table )
		{
			//Debug.Log ("key='" + kvp.Key + "' Value='"+kvp.Value+"'" );
			int key;
			int value;
			if( int.TryParse( kvp.Key, out key ))
			{
				value = (int)(System.Int64)kvp.Value;
				m_colorRemapSourceToDest[ value ] = key;
			}
		}
	}

	void LoadBool( ref bool _out, string _key, Dictionary<string,object> _json )
	{
		if( _json.ContainsKey( _key ))
		{
			_out = (bool)_json[ _key ];
		}
	}
}
