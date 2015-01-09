using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Project
{
	Dictionary<string,object> m_settings;
	string m_projectFileName;

	public Project( string _path )
	{
		m_projectFileName = _path + System.IO.Path.DirectorySeparatorChar + "project.config";
		Debug.Log ("m_projectFileName=" + m_projectFileName );

		if( System.IO.File.Exists( m_projectFileName ))
		{
			Debug.Log ("we have a config, wohoo!" );
			string jsonString = System.IO.File.ReadAllText( m_projectFileName );
			m_settings = MiniJSON.Json.Deserialize( jsonString ) as Dictionary<string,object>;
		}
		else
		{
			m_settings = new Dictionary<string, object>();
		}

		List<int> arne = new List<int>();
		arne.Add( 3 );
		arne.Add( 5 );
		arne.Add( 4 );

		Dictionary<string,string> bosse = new Dictionary<string, string>();
		bosse[ "bil" ] = "fin";
		bosse[ "doktor" ] = "sjuk";

		m_settings[ "testint" ] = 0;
		m_settings[ "testint2" ] = 0;
		m_settings[ "testlist" ] = arne;
		m_settings[ "testdict" ] = bosse;

		Save();
	}

	public void Save()
	{
		Debug.Log ("saving config to " + m_projectFileName );
		string jsonString = MiniJSON.Json.Serialize( m_settings );
		System.IO.File.WriteAllText( m_projectFileName, jsonString );
	}
}
