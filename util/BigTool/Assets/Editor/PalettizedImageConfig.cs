using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PalettizedImageConfig
{
	const int DEFAULT_FRAME_TIME = 6;		// 10 frames per second for animation when game is running at 60 FPS
	
	const string JSONKEY_COLORREMAPTABLE = "Color_Remap_Table";
	const string JSONKEY_IMPORTASSPRITE = "Import_As_Sprite";
	const string JSONKEY_IMPORTASBSPRITE = "Import_As_B_Sprite";
	const string JSONKEY_SPRITENUMFRAMES = "Sprite_Num_Frames";
	const string JSONKEY_FRAMETIMES = "Frame_Times";

	string m_fileName;

	public Dictionary<int,int> m_colorRemapSourceToDest;
	public bool m_importAsSprite;
	public bool m_importAsBSprite;
	public Dictionary<int,int> m_frameTimes;

	int m_spriteFrames;
	int m_spriteWidth;
	int m_spriteHeight;
	PalettizedImage m_imageData;

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
		LoadFrameTimes( dict );
		LoadBool( ref m_importAsSprite, JSONKEY_IMPORTASSPRITE, dict );
		LoadBool( ref m_importAsBSprite, JSONKEY_IMPORTASBSPRITE, dict);
		LoadInt( ref m_spriteFrames, JSONKEY_SPRITENUMFRAMES, dict );
	}

	public void Save()
	{
		// Create a new settings ditionary
		Dictionary<string,object> jsonDict = new Dictionary<string, object>();
		jsonDict[ JSONKEY_COLORREMAPTABLE ] = m_colorRemapSourceToDest;
		jsonDict[ JSONKEY_IMPORTASSPRITE ] = m_importAsSprite;
		jsonDict [JSONKEY_IMPORTASBSPRITE] = m_importAsBSprite;
		jsonDict[ JSONKEY_SPRITENUMFRAMES ] = m_spriteFrames;
		jsonDict[ JSONKEY_FRAMETIMES ] = m_frameTimes;

		// Generate JSON string from settings dictionary
		string jsonString = MiniJSON.Json.Serialize( jsonDict );

		System.IO.File.WriteAllText( m_fileName, jsonString );
	}

	public void SetImage( PalettizedImage _imageData )
	{
		m_imageData = _imageData;
		RefreshInternalThings();
	}

	public int GetSpriteWidth()
	{
		return m_spriteWidth;
	}
	
	public int GetSpriteHeight()
	{
		return m_spriteHeight;
	}

	public void SetNumFrames( int _newFrameCount )
	{
		m_spriteFrames = _newFrameCount;
		RefreshInternalThings();
	}

	public int GetNumFrames()
	{
		return m_spriteFrames;
	}

	public int GetFrameTime( int _frame )
	{
		// Return the given frame time of any
		if( m_frameTimes.ContainsKey( _frame ))
			return m_frameTimes[ _frame ];

		// Return default if there haven't been a frame time specified for this frame
		return DEFAULT_FRAME_TIME;
	}

	public void SetFrameTime( int _frame, int _time )
	{
		m_frameTimes[ _frame ] = _time;
	}

	void RefreshInternalThings()
	{
		m_spriteWidth = m_imageData.m_width / m_spriteFrames;
		m_spriteHeight = m_imageData.m_height;
	}

	void SetupDefaults()
	{
		//
		// Setup default mapping table
		//
		m_colorRemapSourceToDest = new Dictionary<int, int>();
		int i;
		for( i=0; i<16; i++ )
		{
			m_colorRemapSourceToDest[ i ] = i;
		}

		//
		// Sprite settings
		//
		m_importAsSprite = false;
		m_importAsBSprite = false;
		m_spriteFrames = 1;
		m_frameTimes = new Dictionary<int, int>();
	}

	void LoadColorMapTable( Dictionary<string,object> _table )
	{
		// Parse the table in the config file
		foreach( KeyValuePair<string,object> kvp in _table )
		{
			int key;
			int value;
			if( int.TryParse( kvp.Key, out key ))
			{
				value = (int)(System.Int64)kvp.Value;
				m_colorRemapSourceToDest[ value ] = key;
			}
		}
	}

	void LoadFrameTimes( Dictionary<string,object> _json )
	{
		m_frameTimes = new Dictionary<int, int>();

		// Bail out if there are no frame times in JSON
		if( _json.ContainsKey( JSONKEY_FRAMETIMES ) == false )
			return;

		// Parse the table in the config file
		Dictionary<string,object> frameTimesJson = (Dictionary<string,object>)_json[ JSONKEY_FRAMETIMES ];
		foreach( KeyValuePair<string,object> kvp in frameTimesJson )
		{
			int key;
			if( int.TryParse( kvp.Key, out key ))
			{
				m_frameTimes[ key ] = (int)(long)kvp.Value;
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

	void LoadInt( ref int _out, string _key, Dictionary<string,object> _json )
	{
		if( _json.ContainsKey( _key ))
		{
			_out = (int)(long)_json[ _key ];
		}
	}

	void LoadString( ref string _out, string _key, Dictionary<string,object> _json )
	{
		if( _json.ContainsKey( _key ))
		{
			_out = (string)_json[ _key ];
		}
	}
}
