using UnityEngine;
using System.Collections;

public class testobject : MonoBehaviour
{
	Vector2 m_position;

	const float refreshTimer = 0.05f;
	const float width = 16.0f;
	const float height = 16.0f;
	const float padding = 2.0f;
	const float smallObjectRadius = 8.0f;

	Vector2 debugCollisionPoint;
	Vector2 debugCollisionPoint2;
	Vector2 debugCollisionPointRelative;

	const int XXYY = 0;
	const int XN1YY = 1;
	const int X1YY = 2;
	const int X0YY = 3;
	const int XXYN1 = 4;
	const int XN1YN1 = 5;
	const int X1YN1 = 6;
	const int X0YN1 = 7;
	const int XXY1 = 8;
	const int XN1Y1 = 9;
	const int X1Y1 = 10;
	const int X0Y1 = 11;
	const int XXY0 = 12;
	const int XN1Y0 = 13;
	const int X1Y0 = 14;
	const int X0Y0 = 15;

	int[,] collisionActions = {
		/*
		{0,0,0,0,0,XN1Y1,XN1Y0,X0Y0,X0Y0,X1Y0,X1Y1,0,0,0,0,0},
		{0,0,0,XN1Y1,XN1Y0,XN1Y0,XN1Y0,X0Y0,X0Y0,X1Y0,X1Y0,X1Y0,X1Y1,0,0,0},
		{0,0,XN1Y1,XN1Y0,XN1Y0,XN1Y0,X0Y0,x0y0,X0Y0,X0Y0,X1Y0,X1Y0,X1Y0,X1Y1,0,0},
		*/
		{0,0,0,0,0,5,5,1,1,6,6,0,0,0,0,0},
		{0,0,0,5,5,5,5,1,1,6,6,6,6,0,0,0},
		{0,0,5,5,5,9,9,9,9,9,6,6,6,6,0,0},
		{0,5,5,5,9,9,9,9,9,9,9,9,6,6,6,0},
		{0,5,5,9,9,9,9,9,9,9,9,9,9,6,6,0},
		{5,5,5,9,9,9,9,9,9,9,9,9,9,6,6,6},
		{5,5,9,9,9,9,9,9,9,9,9,9,9,9,6,6},
		{3,3,9,9,9,9,9,9,9,9,9,9,9,9,4,4},
		{3,3,9,9,9,9,9,9,9,9,9,9,9,9,4,4},
		{7,7,9,9,9,9,9,9,9,9,9,9,9,9,8,8},
		{7,7,7,9,9,9,9,9,9,9,9,9,9,8,8,8},
		{0,7,7,9,9,9,9,9,9,9,9,9,9,8,8,0},
		{0,7,7,7,9,9,9,9,9,9,9,9,8,8,8,0},
		{0,0,7,7,7,7,9,9,9,9,8,8,8,8,0,0},
		{0,0,0,7,7,7,7,2,2,8,8,8,8,0,0,0},
		{0,0,0,0,0,7,7,2,2,8,8,0,0,0,0,0},
	};

	Vector2[] m_sensors =
	{
		Vector3.up*padding + Vector3.right*padding,
		Vector3.up*padding + Vector3.right*(width-padding-1),
		Vector3.up*(height-padding-1) + Vector3.right*padding,
		Vector3.up*(height-padding-1) + Vector3.right*(width-padding-1),
	};

	Vector2 m_midSensor = Vector2.up*(height/2.0f) + Vector2.right*(width/2.0f);

	float m_refreshTimeout;

	Transform m_transform;
	Worldbuilder m_worldBuilder;

	// Use this for initialization
	void Start ()
	{
		m_transform = transform;
		m_position = SwitchWorld( m_transform.position );
		m_worldBuilder = FindObjectOfType<Worldbuilder>();

		m_refreshTimeout = refreshTimer;
	}
	
	// Update is called once per frame
	void Update ()
	{
		m_refreshTimeout -= Time.deltaTime;
		if( m_refreshTimeout > 0.0f )
			return;

		m_refreshTimeout += refreshTimer;
		Vector2 direction = Vector2.zero;
		if( Input.GetKey( KeyCode.UpArrow ))	direction += Vector2.up * -1.0f;
		if( Input.GetKey( KeyCode.DownArrow ))	direction += Vector2.up;
		if( Input.GetKey( KeyCode.LeftArrow ))	direction += Vector2.right * -1.0f;
		if( Input.GetKey( KeyCode.RightArrow ))	direction += Vector2.right;

		direction = CheckCollisionAsm( direction );
		direction = CheckCollisionSmallObjectsAsm( direction );

		m_position += direction;// * Time.deltaTime;

		m_transform.position = SwitchWorld( m_position );
	}

	void OnDrawGizmos()
	{
		Gizmos.color = Color.red;
		Vector3 pos = transform.position;
		foreach( Vector2 v in m_sensors )
		{
			Vector3 v3 = SwitchWorld( v );
			Gizmos.DrawCube( pos + v3 + (Vector3.down+Vector3.right)*0.5f, Vector3.one );
		}

		Gizmos.color = Color.green;
		Vector3 msv3 = SwitchWorld( m_midSensor );
		Gizmos.DrawCube( pos + msv3 + (Vector3.down+Vector3.right)*0.5f, Vector3.one );

		pos += SwitchWorld( new Vector2( width/2.0f, height/2.0f ));
		smallobjectvisualiser.DrawCircleGizmo( pos, smallObjectRadius );

		Vector3 collworld = SwitchWorld( debugCollisionPoint );
		Gizmos.DrawCube( collworld + (Vector3.down+Vector3.right)*0.5f, Vector3.one );

		collworld = SwitchWorld( debugCollisionPoint2 );
		Gizmos.color = Color.white;
		//Gizmos.DrawCube( collworld + (Vector3.down+Vector3.right)*0.5f, Vector3.one );
		
		collworld = transform.position + SwitchWorld( debugCollisionPointRelative );
		Gizmos.color = Color.cyan;
		Gizmos.DrawCube( collworld + (Vector3.down+Vector3.right)*0.5f, Vector3.one );
	}

	int GetIntDistance( int x, int y )
	{
		return Mathf.FloorToInt( (new Vector2( x, y )).magnitude );
	}

	void LerpHaxxor( int _x_no_fp, int _y_no_fp, int _delta_x_no_fp, int _delta_y_no_fp, int _i_fp1616, out int _x, out int _y )
	{
		_x_no_fp <<= 16;
		_y_no_fp <<= 16;
		_delta_x_no_fp <<= 16;
		_delta_y_no_fp <<= 16;
		_x = _x_no_fp + ((_delta_x_no_fp>>8) * (_i_fp1616>>8));
		_y = _y_no_fp + ((_delta_y_no_fp>>8) * (_i_fp1616>>8));
		_x >>= 16;
		_y >>= 16;
	}

	Vector2 CheckCollisionSmallObjectsAsm( Vector2 _direction )
	{
		int wanted_dir_x = (int)_direction.x;
		int wanted_dir_y = (int)_direction.y;

		int my_pos_x = (int)m_position.x + 8 + wanted_dir_x;
		int my_pos_y = (int)m_position.y + 8 + wanted_dir_y;

		int new_dir_x = wanted_dir_x;
		int new_dir_y = wanted_dir_y;

		int[,] smallObjects = m_worldBuilder.GetSmallObjects();
		int numObjects = smallObjects.GetLength( 0 );
		int iObject;
		for( iObject=0; iObject<numObjects; iObject++ )
		{
			int small_object_x = smallObjects[ iObject, 0 ] + 2;
			int small_object_y = smallObjects[ iObject, 1 ] + 2;
			int delta_x = small_object_x-my_pos_x;
			int delta_y = small_object_y-my_pos_y;
			int distance = GetIntDistance( delta_x, delta_y );
			if( distance < 10 )
			{
				int coll_x, coll_y;
				int i = (8 << 16) / (10);

				LerpHaxxor( my_pos_x, my_pos_y, delta_x, delta_y, i, out coll_x, out coll_y );

				debugCollisionPoint = new Vector2( coll_x, coll_y );

				coll_x -= my_pos_x;
				coll_y -= my_pos_y;
				coll_x += 8;
				coll_y += 8;

				debugCollisionPointRelative = new Vector2( coll_x, coll_y );

				int routine = collisionActions[ coll_y, coll_x ];

				if( routine == 1 )
					DoCollision_DownRightAsm( ref new_dir_y );
				else if( routine == 2 )
					DoCollision_UpLeftAsm( ref new_dir_y );
				else if( routine == 3 )
					DoCollision_DownRightAsm( ref new_dir_x );
				else if( routine == 4 )
					DoCollision_UpLeftAsm( ref new_dir_x );
				else if( routine == 5 )
					DoCollision_Slide_DownRightAsm( ref new_dir_x, ref new_dir_y );
				else if( routine == 6 )
					DoCollision_Slide_DownLeftAsm( ref new_dir_x, ref new_dir_y );
				else if( routine == 7 )
					DoCollision_Slide_UpRightAsm( ref new_dir_x, ref new_dir_y );
				else if( routine == 8 )
					DoCollision_Slide_UpLeftAsm( ref new_dir_x, ref new_dir_y );
				else if( routine == 9 )
				{
					new_dir_x = 0;
					new_dir_y = 0;
				}

				Debug.Log ("routine=" + routine + ", new dir x=" + new_dir_x + ", new dir y=" + new_dir_y );
			}
		}

		return new Vector2( new_dir_x, new_dir_y );
	}

	Vector2 CheckCollisionSmallObjects( Vector2 _direction )
	{
		Vector2 mypos = SwitchWorld( m_transform.position );
		mypos += _direction;
		mypos.x += width/2.0f;
		mypos.y += height/2.0f;

		int[,] smallObjects = m_worldBuilder.GetSmallObjects();
		int numObjects = smallObjects.GetLength( 0 );
		int iObject;
		for( iObject=0; iObject<numObjects; iObject++ )
		{
			int sox = smallObjects[ iObject, 0 ] + 2;
			int soy = smallObjects[ iObject, 1 ] + 2;
			Vector2 sop = new Vector2( sox, soy );

			float distance = (mypos-sop).magnitude;
			if( distance < 10.0f )
			{
				debugCollisionPoint = Vector2.Lerp( mypos, sop, 8.0f / 11.0f );
				Vector2 argh = SwitchWorld( m_transform.position );
				debugCollisionPointRelative = debugCollisionPoint-argh;
				debugCollisionPointRelative.x = Mathf.Floor( debugCollisionPointRelative.x );
				debugCollisionPointRelative.y = Mathf.Floor( debugCollisionPointRelative.y );
				//float atan2 = Mathf.Atan2( mypos.y-sop.y, mypos.x-sop.x );
				//Debug.Log ( "Distance=" + distance + "Atan2=" + atan2 );
				_direction = Vector2.zero;
				//_direction.x = -(int)(Mathf.Sin( atan2 ) * 1.47f);
				//_direction.y = (int)(Mathf.Cos( atan2 ) * 1.47f);
				//Debug.Log ("new direction=" + _direction );
			}
		}

		return _direction;
	}

	Vector2 CheckCollisionAsm( Vector2 _direction )
	{
		int obj_pos_x = (int)m_position.x;
		int obj_pos_y = (int)m_position.y;
		int wanted_dir_x = (int)_direction.x;
		int wanted_dir_y = (int)_direction.y;

		int new_dir_x = wanted_dir_x;
		int new_dir_y = wanted_dir_y;

		int wanted_pos_x;
		int wanted_pos_y;
		int sensor_x;
		int sensor_y;
		int tile_x;
		int tile_y;
		int coll_tile_index;

		int i_sensor;

		i_sensor = 0;

	Loop_Sensors_A:
		sensor_x = (int)m_sensors[ i_sensor ].x;
		sensor_y = (int)m_sensors[ i_sensor ].y;
		wanted_pos_x = obj_pos_x + sensor_x + new_dir_x;
		wanted_pos_y = obj_pos_y + sensor_y + new_dir_y;

		tile_x = wanted_pos_x>>3;
		tile_y = wanted_pos_y>>3;
		coll_tile_index = m_worldBuilder.GetTileAt( tile_x, tile_y );

		tile_x = wanted_pos_x & 7;
		tile_y = wanted_pos_y & 7;

		if( coll_tile_index == 1 )
			DoCollision_UpLeftAsm( ref new_dir_y );
		else if( coll_tile_index == 2 )
			DoCollision_DownRightAsm( ref new_dir_y );
		else if( coll_tile_index == 3 )
			DoCollision_UpLeftAsm( ref new_dir_x );
		else if( coll_tile_index == 4 )
			DoCollision_DownRightAsm( ref new_dir_x );
		else if( coll_tile_index == 9 )
		{
			new_dir_x = 0;
			new_dir_y = 0;
		}

		i_sensor++;
		if( i_sensor < m_sensors.Length )
			goto Loop_Sensors_A;



		i_sensor = 0;
		
	Loop_Sensors_B:
		sensor_x = (int)m_sensors[ i_sensor ].x;
		sensor_y = (int)m_sensors[ i_sensor ].y;
		wanted_pos_x = obj_pos_x + sensor_x + new_dir_x;
		wanted_pos_y = obj_pos_y + sensor_y + new_dir_y;
		
		tile_x = wanted_pos_x>>3;
		tile_y = wanted_pos_y>>3;
		coll_tile_index = m_worldBuilder.GetTileAt( tile_x, tile_y );
		
		tile_x = wanted_pos_x & 7;
		tile_y = wanted_pos_y & 7;
		
		if( coll_tile_index == 5 )
			DoCollision_Slope_UpLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 6 )
			DoCollision_Slope_UpRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 7 )
			DoCollision_Slope_DownLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 8 )
			DoCollision_Slope_DownRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 10 )
			DoCollision_Corner_UpLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 11 )
			DoCollision_Corner_UpRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 12 )
			DoCollision_Corner_DownLeftAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );
		else if( coll_tile_index == 13 )
			DoCollision_Corner_DownRightAsm( tile_x, tile_y, ref new_dir_x, ref new_dir_y );

		i_sensor++;
		if( i_sensor < m_sensors.Length )
			goto Loop_Sensors_B;


		return new Vector2( new_dir_x, new_dir_y );
	}

	Vector2 CheckCollision( Vector2 _direction )
	{
		Vector2 newDir = _direction;

		foreach( Vector2 v in m_sensors )
		{
			Vector2 t0 = m_position + v;
			Vector2 t1 = t0 + _direction;
			int tileX = ((int)t1.x)>>3;
			int tileY = ((int)t1.y)>>3;
			int collTileIndex = m_worldBuilder.GetTileAt( tileX, tileY );

			Vector2 inTile = new Vector2( t1.x - (tileX*8), t1.y - (tileY*8));

			switch( collTileIndex )
			{
			case 1: newDir = DoCollision_Up( inTile, newDir ); break;
			case 2: newDir = DoCollision_Down( inTile, newDir ); break;
			case 3: newDir = DoCollision_Left( inTile, newDir ); break;
			case 4: newDir = DoCollision_Right( inTile, newDir ); break;

			case 5: newDir = DoCollision_UpLeft( inTile, newDir ); break;
			case 6: newDir = DoCollision_UpRight( inTile, newDir ); break;
			case 7: newDir = DoCollision_DownLeft( inTile, newDir ); break;
			case 8: newDir = DoCollision_DownRight( inTile, newDir ); break;

			case 9: newDir = DoCollision_Full( inTile, newDir ); break;
			}
		}

		return newDir;
	}

	static public Vector3 SwitchWorld( Vector2 _coolPos )
	{
		return new Vector3( _coolPos.x, -_coolPos.y, 0.0f );
	}

	// No collision
	Vector2 DoCollision_None( Vector2 _pos, Vector2 _dir )
	{
		return _dir;
	}

	// Up
	Vector2 DoCollision_Up( Vector2 _pos, Vector2 _dir )
	{
		if( _dir.y > 0 ) _dir.y = 0;
		return _dir;
	}

	// Down
	Vector2 DoCollision_Down( Vector2 _pos, Vector2 _dir )
	{
		if( _dir.y < 0 ) _dir.y = 0;
		return _dir;
	}

	// Up
	void DoCollision_UpLeftAsm( ref int _val )
	{
		if( _val > 0 ) _val = 0;
	}
	
	void DoCollision_DownRightAsm( ref int _val )
	{
		if( _val < 0 ) _val = 0;
	}
	
	// Left
	Vector2 DoCollision_Left( Vector2 _pos, Vector2 _dir )
	{
		if( _dir.x > 0 ) _dir.x = 0;
		return _dir;
	}
	
	// Right
	Vector2 DoCollision_Right( Vector2 _pos, Vector2 _dir )
	{
		if( _dir.x < 0 ) _dir.x = 0;
		return _dir;
	}

	// Up / left
	Vector2 DoCollision_UpLeft( Vector2 _pos, Vector2 _dir )
	{
		if( (7-_pos.x) > _pos.y )
			return _dir;

		if( _dir.x+_dir.y == 2.0f )
			return Vector2.zero;

		if( _dir.x > 0 )
			_dir.y = -1;

		if( _dir.y > 0 )
			_dir.x = -1;

		return _dir;
	}
	
	// Up / right
	Vector2 DoCollision_UpRight( Vector2 _pos, Vector2 _dir )
	{
		if( _pos.x > _pos.y )
			return _dir;
		
		if( _dir.x-_dir.y == -2.0f )
			return Vector2.zero;
		
		if( _dir.x < 0 )
			_dir.y = -1;
		
		if( _dir.y > 0 )
			_dir.x = 1;
		
		return _dir;
	}

	// Down / left
	Vector2 DoCollision_DownLeft( Vector2 _pos, Vector2 _dir )
	{
		if( _pos.x < _pos.y )
			return _dir;

		if( _dir.x-_dir.y == 2.0f )
			return Vector2.zero;
		
		if( _dir.y < 0 )
			_dir.x = -1;
		
		if( _dir.x > 0 )
			_dir.y = 1;
		
		return _dir;
	}
	
	// Down / right
	Vector2 DoCollision_DownRight( Vector2 _pos, Vector2 _dir )
	{
		if( _pos.x > (7-_pos.y))
			return _dir;

		if( _dir.x+_dir.y == -2.0f )
			return Vector2.zero;

		if( _dir.y < 0 )
			_dir.x = 1;

		if( _dir.x < 0 )
			_dir.y = 1;
		
		return _dir;
	}

	//
	Vector2 DoCollision_Full( Vector2 _pos, Vector2 _dir )
	{
		return Vector2.zero;
	}

	void DoCollision_Slide_UpLeftAsm( ref int _dir_x, ref int _dir_y )
	{
		if( _dir_x+_dir_y == 2 )
		{
			_dir_x = 0;
			_dir_y = 0;
			return;
		}
		
		if((_dir_x>0) && (_dir_y<0))
		{
			_dir_x = 0;
			_dir_y = -1;
			return;
		}
		
		if((_dir_x<0) && (_dir_y>0))
		{
			_dir_x = -1;
			_dir_y = 0;
			return;
		}
		
		if( _dir_x > 0 ) _dir_y = -1;
		if( _dir_y > 0 ) _dir_x = -1;
	}

	void DoCollision_Slope_UpLeftAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( (7-_in_tile_x) > _in_tile_y )
			return;

		DoCollision_Slide_UpLeftAsm( ref _dir_x, ref _dir_y );
	}

	void DoCollision_Slide_UpRightAsm( ref int _dir_x, ref int _dir_y )
	{
		if( _dir_x-_dir_y == -2 )
		{
			_dir_x = 0;
			_dir_y = 0;
			return;
		}
		
		if((_dir_x<0) && (_dir_y<0))
		{
			_dir_x = 0;
			_dir_y = -1;
			return;
		}
		
		if((_dir_x>0) && (_dir_y>0))
		{
			_dir_x = 1;
			_dir_y = 0;
			return;
		}
		
		if( _dir_x < 0 ) _dir_y = -1;
		if( _dir_y > 0 ) _dir_x = 1;
	}

	void DoCollision_Slope_UpRightAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( _in_tile_x > _in_tile_y )
			return;

		DoCollision_Slide_UpRightAsm( ref _dir_x, ref _dir_y );
	}

	void DoCollision_Slide_DownLeftAsm( ref int _dir_x, ref int _dir_y )
	{
		if( _dir_x-_dir_y == 2 )
		{
			_dir_x = 0;
			_dir_y = 0;
			return;
		}
		
		if((_dir_x>0) && (_dir_y>0))
		{
			_dir_x = 0;
			_dir_y = 1;
			return;
		}
		
		if((_dir_x<0) && (_dir_y<0))
		{
			_dir_x = -1;
			_dir_y = 0;
			return;
		}
		
		if( _dir_y < 0 ) _dir_x = -1;
		if( _dir_x > 0 ) _dir_y = 1;
	}

	void DoCollision_Slope_DownLeftAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( _in_tile_x < _in_tile_y )
			return;

		DoCollision_Slide_DownLeftAsm( ref _dir_x, ref _dir_y );
	}

	void DoCollision_Slide_DownRightAsm( ref int _dir_x, ref int _dir_y )
	{
		if( _dir_x+_dir_y == -2 )
		{
			_dir_x = 0;
			_dir_y = 0;
			return;
		}
		
		if((_dir_x<0) && (_dir_y>0))
		{
			_dir_x = 0;
			_dir_y = 1;
			return;
		}
		
		if((_dir_x>0) && (_dir_y<0))
		{
			_dir_x = 1;
			_dir_y = 0;
			return;
		}
		
		if( _dir_y < 0 ) _dir_x = 1;
		if( _dir_x < 0 ) _dir_y = 1;
	}

	void DoCollision_Slope_DownRightAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( _in_tile_x > (7-_in_tile_y))
			return;

		DoCollision_Slide_DownRightAsm( ref _dir_x, ref _dir_y );
	}

	void DoCollision_Corner_UpLeftAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if((_in_tile_x == 0) && (_dir_x > 0))
			_dir_x = 0;

		if((_in_tile_y == 0) && (_dir_y > 0))
			_dir_y = 0;

		if( _in_tile_x > 0 )
			_dir_y = 0;

		if( _in_tile_y > 0 )
			_dir_x = 0;
	}

	void DoCollision_Corner_UpRightAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if((_in_tile_x == 7) && (_dir_x < 0))
			_dir_x = 0;
		
		if((_in_tile_y == 0) && (_dir_y > 0))
			_dir_y = 0;
		
		if( _in_tile_x < 7 )
			_dir_y = 0;
		
		if( _in_tile_y > 0 )
			_dir_x = 0;
	}
	
	void DoCollision_Corner_DownLeftAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if((_in_tile_x == 0) && (_dir_x > 0))
			_dir_x = 0;
		
		if((_in_tile_y == 7) && (_dir_y < 0))
			_dir_y = 0;
		
		if( _in_tile_x > 0 )
			_dir_y = 0;
		
		if( _in_tile_y < 7 )
			_dir_x = 0;
	}
	
	void DoCollision_Corner_DownRightAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if((_in_tile_x == 7) && (_dir_x < 0))
			_dir_x = 0;
		
		if((_in_tile_y == 7) && (_dir_y < 0))
			_dir_y = 0;
		
		if( _in_tile_x < 7 )
			_dir_y = 0;
		
		if( _in_tile_y < 7 )
			_dir_x = 0;
	}
}
