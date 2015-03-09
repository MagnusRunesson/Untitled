using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class RoomCollection
{
	const string JSONKEY_ROOT = "rooms";
	const string JSONKEY_IDENTIFIER = "identifier";
	const string JSONKEY_FILEID_TILEBANK = "tilebank_fileid";
	const string JSONKEY_FILEID_PALETTE = "palette_fileid";
	const string JSONKEY_FILEID_TILEMAP = "tilemap_fileid";
	const string JSONKEY_FILEID_COLLISIONMAP = "collisionmap_fileid";

	public class RoomDefinition
	{
		public string m_identifier;
		public string m_tileBankFileName;
		public string m_paletteFileName;
		public string m_tileMapFileName;
		public string m_collisionMapFileName;
	}
	List<RoomDefinition> m_rooms;
	
	public RoomCollection( string _fullPath )
	{
		m_rooms = new List<RoomDefinition>();
		
		string jsonString = System.IO.File.ReadAllText( _fullPath );
		Dictionary<string,object> jsonRoot = (Dictionary<string,object>)MiniJSON.Json.Deserialize( jsonString );
		if( jsonRoot.ContainsKey( JSONKEY_ROOT ))
		{
			List<object> objects = (List<object>)jsonRoot[ JSONKEY_ROOT ];
			foreach( Dictionary<string,object> roomJson in objects )
			{
				RoomDefinition def = new RoomDefinition();
				
				if( roomJson.ContainsKey( JSONKEY_IDENTIFIER ))
					def.m_identifier = (string)roomJson[ JSONKEY_IDENTIFIER ];
				
				if( roomJson.ContainsKey( JSONKEY_FILEID_TILEBANK ))
					def.m_tileBankFileName = (string)roomJson[ JSONKEY_FILEID_TILEBANK ];
				
				if( roomJson.ContainsKey( JSONKEY_FILEID_PALETTE ))
					def.m_paletteFileName = (string)roomJson[ JSONKEY_FILEID_PALETTE ];
				
				if( roomJson.ContainsKey( JSONKEY_FILEID_TILEMAP ))
					def.m_tileMapFileName = (string)roomJson[ JSONKEY_FILEID_TILEMAP ];
				
				if( roomJson.ContainsKey( JSONKEY_FILEID_COLLISIONMAP ))
					def.m_collisionMapFileName = (string)roomJson[ JSONKEY_FILEID_COLLISIONMAP ];

				m_rooms.Add( def );

				/*
				Debug.Log ("Loaded room." );
				Debug.Log ("identifier=" + def.m_identifier );
				Debug.Log ("Tile bank file=" + def.m_tileBankFileName );
				Debug.Log ("Palette file=" + def.m_paletteFileName );
				Debug.Log ("Tile map file=" + def.m_tileMapFileName );
				Debug.Log ("Collision map file=" + def.m_collisionMapFileName );
				*/
			}
		}
	}
	
	public void Export( string _outPath, Project _project, GameObjectCollection _gomCollection )
	{
		int maxOutSide = 7*1024*1024;
		byte[] outBytes = new byte[ maxOutSide ];
		
		string path = System.IO.Path.GetDirectoryName( _outPath );
		string name = System.IO.Path.GetFileNameWithoutExtension( _outPath );
		string asmOutputName = path + System.IO.Path.DirectorySeparatorChar + name + "_identifiers.asm";
		
		string asmOutput = ";\n; Identifiers for the rooms in the '" + name + "' collection\n;\n";

		int wrofs = 0;
		int i;
		for( i=0; i<m_rooms.Count; i++ )
		{
			RoomDefinition def = m_rooms[ i ];
			wrofs += WriteShort( outBytes, wrofs, _project.GetIDFromConstant( def.m_tileBankFileName ));
			wrofs += WriteShort( outBytes, wrofs, _project.GetIDFromConstant( def.m_paletteFileName ));
			wrofs += WriteShort( outBytes, wrofs, _project.GetIDFromConstant( def.m_tileMapFileName ));
			wrofs += WriteShort( outBytes, wrofs, _project.GetIDFromConstant( def.m_collisionMapFileName ));

			asmOutput += (def.m_identifier + "_gameobject").PadRight( 40 ) + " equ " + i + "\n";
		}

		// Make a smaller byte array to write to disk, since I don't know of a way to write a range from a byte array, I only know of the WriteAllBytes
		byte[] actualOut = new byte[ wrofs ];
		for( i=0; i<wrofs; i++ )
			actualOut[ i ] = outBytes[ i ];

		// Dump to disk
		System.IO.File.WriteAllBytes( _outPath, actualOut );
		
		//
		// Also export an asm file with all game object identifiers
		//
		System.IO.File.WriteAllText( asmOutputName, asmOutput );
	}
	
	int WriteShort( byte[] _outArray, int _byteOffset, int _value )
	{
		_outArray[ _byteOffset+0 ] = (byte)((_value>>8)&0xff);
		_outArray[ _byteOffset+1 ] = (byte)(_value&0xff);
		return 2;
	}
	
	public int GetNumDefinitions()
	{
		return m_rooms.Count;
	}
	
	public RoomDefinition GetDefinitionFromIdentifier( string _identifier )
	{
		foreach( var def in m_rooms )
		{
			if( def.m_identifier.Equals( _identifier ))
				return def;
		}
		
		return null;
	}
	
	public string GetIdentifierFromIndex( int _index )
	{
		return m_rooms[ _index ].m_identifier;
	}
	
	public int GetIndexFromIdentifier( string _identifier )
	{
		int i;
		for( i=0; i<m_rooms.Count; i++ )
		{
			if( m_rooms[ i ].m_identifier.Equals( _identifier ))
				return i;
		}
		
		return -1;
	}
}
