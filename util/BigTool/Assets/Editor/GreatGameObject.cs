using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GreatGameObject
{
	const string JSONKEY_FILENAME_TILEBANK = "tiles_fileid";
	const string JSONKEY_FILENAME_SPRITEINFO = "sprite_fileid";
	const string JSONKEY_HOTSPOT_X = "hotspot_x";
	const string JSONKEY_HOTSPOT_Y = "hotspot_y";

	string m_spriteBankFileName;
	string m_spriteFileName;
	int m_hotspotX;
	int m_hotspotY;

	public GreatGameObject( string _fullPath )
	{
		string jsonString = System.IO.File.ReadAllText( _fullPath );
		Dictionary<string,object> json = (Dictionary<string,object>)MiniJSON.Json.Deserialize( jsonString );
		foreach( var kvp in json )
		{
			Debug.Log ("key=" + kvp.Key + ", value=" + kvp.Value );
		}

		if( json.ContainsKey( JSONKEY_FILENAME_TILEBANK ))
		{
			m_spriteBankFileName = (string)json[ JSONKEY_FILENAME_TILEBANK ];
		}
		
		if( json.ContainsKey( JSONKEY_FILENAME_SPRITEINFO ))
		{
			m_spriteFileName = (string)json[ JSONKEY_FILENAME_SPRITEINFO ];
		}
		
		if( json.ContainsKey( JSONKEY_HOTSPOT_X ))
		{
			m_hotspotX = (int)(long)json[ JSONKEY_HOTSPOT_X ];
		}
		
		if( json.ContainsKey( JSONKEY_HOTSPOT_Y ))
		{
			m_hotspotY = (int)(long)json[ JSONKEY_HOTSPOT_Y ];
		}
	}

	public void Export( string _outPath, Project _project )
	{
		int outsize = 2+2+2+2;
		byte[] outBytes = new byte[ outsize ];

		WriteShort( outBytes, 0, _project.GetIDFromConstant( m_spriteBankFileName ));
		WriteShort( outBytes, 2, _project.GetIDFromConstant( m_spriteFileName ));
		WriteShort( outBytes, 4, m_hotspotX );
		WriteShort( outBytes, 6, m_hotspotY );

		System.IO.File.WriteAllBytes( _outPath, outBytes );
	}

	void WriteShort( byte[] _outArray, int _byteOffset, int _value )
	{
		_outArray[ _byteOffset+0 ] = (byte)((_value>>8)&0xff);
		_outArray[ _byteOffset+1 ] = (byte)(_value&0xff);
	}
}
