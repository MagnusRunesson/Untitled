using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PalettizedImageConfig
{
	const string JSONKEY_COLORREMAPTABLE = "Color_Remap_Table";

	public Dictionary<int,int> m_colorRemapSourceToDest;

	public PalettizedImageConfig( string _path )
	{
		SetupDefaults();

		// Verify that file exist
		if( System.IO.File.Exists( _path ) == false )
			return;

		string jsonString = System.IO.File.ReadAllText( _path );

		var dict = MiniJSON.Json.Deserialize( jsonString ) as Dictionary<string,object>;

		LoadColorMapTable( (Dictionary<string,object>)dict[ JSONKEY_COLORREMAPTABLE ]);

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
	
	void SetupDefaults()
	{
		//
		m_colorRemapSourceToDest = new Dictionary<int, int>();
		
		// Setup default mapping table
		int i;
		for( i=0; i<16; i++ )
		{
			m_colorRemapSourceToDest[ i ] = i;
		}
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
				if( int.TryParse( (string)kvp.Value, out value ))
				{
					Debug.Log ("Index " + key + " remap to " + value );
					m_colorRemapSourceToDest[ value ] = key;
				}
			}
		}
	}
}
