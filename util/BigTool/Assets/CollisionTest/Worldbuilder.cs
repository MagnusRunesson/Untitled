using UnityEngine;
using System.Collections;

public class Worldbuilder : MonoBehaviour
{
	[SerializeField] GameObject[] m_debugPrefabs;

	[HideInInspector] public int m_width;
	[HideInInspector] public int m_height;
	int[,] m_world = new int[10,10]
	{
		{9,9,2,2,2,2,2,2,9,9},
		{9,8,0,0,0,0,0,0,7,9},
		{4,0,0,0,0,0,0,0,0,3},
		{4,0,0,0,5,6,0,0,0,3},
		{4,0,0,0,7,8,0,0,0,3},
		{4,0,0,0,0,0,0,0,0,3},
		{9,6,0,0,0,0,0,0,0,3},
		{9,9,1,1,6,0,0,5,1,9},
		{9,9,9,9,4,0,0,3,9,9},
		{9,9,9,9,9,1,1,9,9,9},
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
}
