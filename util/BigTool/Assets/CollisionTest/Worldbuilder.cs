using UnityEngine;
using System.Collections;

public class Worldbuilder : MonoBehaviour
{
	[SerializeField] GameObject[] m_debugPrefabs;
	[SerializeField] GameObject m_smallObjectPrefab;

	[HideInInspector] public int m_width;
	[HideInInspector] public int m_height;
	int[,] m_world = new int[13,14]
	{
		{ 9, 9, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9, 9},
		{ 9, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 9},
		{ 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		{ 4, 0, 0,10,11, 0, 0, 0, 5, 1, 6, 0, 0, 3},
		{ 4, 0, 0,12,13, 0, 0, 0, 3, 9, 4, 0, 0, 3},
		{ 4, 0, 0, 0, 0, 0, 0, 0, 7, 2, 8, 0, 0, 3},
		{ 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		{ 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		{ 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		{ 9, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3},
		{ 9, 9, 1, 1, 6, 0, 0, 0, 0, 0, 0, 5, 1, 9},
		{ 9, 9, 9, 9, 4, 0, 0, 0, 0, 0, 0, 3, 9, 9},
		{ 9, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 9, 9, 9},
	};

	int[,] m_smallObjects = new int[1,2]
	{
		{ 55, 63 },
	};

	// Use this for initialization
	void Start ()
	{
		m_height = m_world.GetLength( 0 );
		m_width = m_world.GetLength( 1 );

		Debug.Log ("width=" + m_width + ", height=" + m_height );

		int x, y;
		for( y=0; y<m_height; y++ )
		{
			for( x=0; x<m_width; x++ )
			{
				int iPrefab = m_world[ y, x ];
				GameObject go = (GameObject)Instantiate( m_debugPrefabs[ iPrefab ]);
				go.transform.position = new Vector3( x*8, (-y)*8, 0 );
			}
		}

		int iObject;
		for( iObject=0; iObject<m_smallObjects.GetLength( 0 ); iObject++ )
		{
			x = m_smallObjects[ iObject, 0 ];
			y = m_smallObjects[ iObject, 1 ];

			GameObject go = (GameObject)Instantiate( m_smallObjectPrefab );
			go.transform.position = new Vector3( x, -y, 0 );
		}
	}
	
	// Update is called once per frame
	void Update ()
	{
	
	}

	public int GetTileAt( int _x, int _y )
	{
		if((_x<0) || (_x>=m_width))
			return 9;	// Full collision

		if((_y<0) || (_y>=m_height))
			return 9;	// Full collision

		return m_world[ _y, _x ];
	}

	public int GetTile( int _index )
	{
		int y = (_index >> 8) & 0xff;
		int x = _index & 0xff;
		return GetTileAt( x, y );
	}

	public int[,] GetSmallObjects()
	{
		return m_smallObjects;
	}
}
