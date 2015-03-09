using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GameObjectCollection
{
	const string JSONKEY_ROOT = "gameobjects";
	const string JSONKEY_IDENTIFIER = "identifier";
	const string JSONKEY_FILENAME_TILEBANK = "tiles_fileid";
	const string JSONKEY_FILENAME_SPRITEINFO = "sprite_fileid";
	const string JSONKEY_HOTSPOT_X = "hotspot_x";
	const string JSONKEY_HOTSPOT_Y = "hotspot_y";

	public class Definition
	{
		public string m_identifier;
		public string m_spriteBankFileName;
		public string m_spriteFileName;
		public int m_hotspotX;
		public int m_hotspotY;
	}
	List<Definition> m_definitions;

	public GameObjectCollection( string _fullPath )
	{
		m_definitions = new List<Definition>();

		string jsonString = System.IO.File.ReadAllText( _fullPath );
		Dictionary<string,object> jsonRoot = (Dictionary<string,object>)MiniJSON.Json.Deserialize( jsonString );
		if( jsonRoot.ContainsKey( JSONKEY_ROOT ))
		{
			List<object> objects = (List<object>)jsonRoot[ JSONKEY_ROOT ];
			foreach( Dictionary<string,object> gameObjectJson in objects )
			{
				Definition def = new Definition();

				if( gameObjectJson.ContainsKey( JSONKEY_IDENTIFIER ))
					def.m_identifier = (string)gameObjectJson[ JSONKEY_IDENTIFIER ];

				if( gameObjectJson.ContainsKey( JSONKEY_FILENAME_TILEBANK ))
					def.m_spriteBankFileName = (string)gameObjectJson[ JSONKEY_FILENAME_TILEBANK ];

				if( gameObjectJson.ContainsKey( JSONKEY_FILENAME_SPRITEINFO ))
					def.m_spriteFileName = (string)gameObjectJson[ JSONKEY_FILENAME_SPRITEINFO ];

				if( gameObjectJson.ContainsKey( JSONKEY_HOTSPOT_X ))
					def.m_hotspotX = (int)(long)gameObjectJson[ JSONKEY_HOTSPOT_X ];

				if( gameObjectJson.ContainsKey( JSONKEY_HOTSPOT_Y ))
					def.m_hotspotY = (int)(long)gameObjectJson[ JSONKEY_HOTSPOT_Y ];

				m_definitions.Add( def );
			}
		}
	}

	public void Export( string _outPath, Project _project )
	{
		int outsizePerObject = 2+2+2+2;
		byte[] outBytes = new byte[ outsizePerObject * m_definitions.Count ];

		string path = System.IO.Path.GetDirectoryName( _outPath );
		string name = System.IO.Path.GetFileNameWithoutExtension( _outPath );
		string asmOutputName = path + System.IO.Path.DirectorySeparatorChar + name + "_identifiers.asm";

		string asmOutput = ";\n; Identifiers for the game objects in the '" + name + "' collection\n;\n";

		int i;
		for( i=0; i<m_definitions.Count; i++ )
		{
			Definition def = m_definitions[ i ];
			int wrofs = i*outsizePerObject;
			WriteShort( outBytes, wrofs+0, _project.GetIDFromConstant( def.m_spriteBankFileName ));
			WriteShort( outBytes, wrofs+2, _project.GetIDFromConstant( def.m_spriteFileName ));
			WriteShort( outBytes, wrofs+4, def.m_hotspotX );
			WriteShort( outBytes, wrofs+6, def.m_hotspotY );

			asmOutput += (def.m_identifier + "_gameobject").PadRight( 40 ) + " equ " + i + "\n";
		}

		System.IO.File.WriteAllBytes( _outPath, outBytes );

		//
		// Also export an asm file with all game object identifiers
		//
		System.IO.File.WriteAllText( asmOutputName, asmOutput );
	}

	void WriteShort( byte[] _outArray, int _byteOffset, int _value )
	{
		_outArray[ _byteOffset+0 ] = (byte)((_value>>8)&0xff);
		_outArray[ _byteOffset+1 ] = (byte)(_value&0xff);
	}

	public int GetNumDefinitions()
	{
		return m_definitions.Count;
	}

	public Definition GetDefinitionFromIdentifier( string _identifier )
	{
		foreach( var def in m_definitions )
		{
			if( def.m_identifier.Equals( _identifier ))
				return def;
		}

		return null;
	}

	public string GetIdentifierFromIndex( int _index )
	{
		return m_definitions[ _index ].m_identifier;
	}

	public int GetIndexFromIdentifier( string _identifier )
	{
		int i;
		for( i=0; i<m_definitions.Count; i++ )
		{
			if( m_definitions[ i ].m_identifier.Equals( _identifier ))
				return i;
		}

		return -1;
	}
}
