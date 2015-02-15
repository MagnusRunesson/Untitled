using UnityEngine;
using System.Collections;

public class testobject : MonoBehaviour
{
	Vector2 m_position;

	const float refreshTimer = 0.2f;
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

		direction = CheckCollision( direction );

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
}
