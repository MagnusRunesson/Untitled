using UnityEngine;
using System.Collections;

public class testobject : MonoBehaviour
{
	Vector2 m_position;

	const float refreshTimer = 0.05f;
	const float width = 16.0f;
	const float height = 16.0f;
	const float padding = 2.0f;

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

	Vector3 SwitchWorld( Vector2 _coolPos )
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
	
	void DoCollision_Slope_UpLeftAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( (7-_in_tile_x) > _in_tile_y )
			return;
		
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
	
	void DoCollision_Slope_UpRightAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( _in_tile_x > _in_tile_y )
			return;
		
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
	
	void DoCollision_Slope_DownLeftAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( _in_tile_x < _in_tile_y )
			return;
		
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
	
	void DoCollision_Slope_DownRightAsm( int _in_tile_x, int _in_tile_y, ref int _dir_x, ref int _dir_y )
	{
		if( _in_tile_x > (7-_in_tile_y))
			return;
		
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
