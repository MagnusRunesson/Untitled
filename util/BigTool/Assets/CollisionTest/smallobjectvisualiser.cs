using UnityEngine;
using System.Collections;

public class smallobjectvisualiser : MonoBehaviour
{
	[SerializeField] Vector2 m_hotspot = new Vector2( 2.0f, 2.0f );
	void OnDrawGizmos()
	{
		Gizmos.color = Color.red;
		Vector2 pos = transform.position + testobject.SwitchWorld( m_hotspot );

		DrawCircleGizmo( pos, 2.0f );
	}

	public static void DrawCircleGizmo( Vector2 _pos, float _rad )
	{
		float cuts = 30.0f;
		float delta = 360.0f / cuts;
		float v;
		for( v=0; v<360.0f; v+=delta )
		{
			float v0 = v;
			float v1 = v0 + delta;

			Vector3 p0 = _pos;
			Vector3 p1 = _pos;
			p0.x += Mathf.Cos( v0 * Mathf.Deg2Rad ) * _rad;
			p0.y += Mathf.Sin( v0 * Mathf.Deg2Rad ) * _rad;
			p1.x += Mathf.Cos( v1 * Mathf.Deg2Rad ) * _rad;
			p1.y += Mathf.Sin( v1 * Mathf.Deg2Rad ) * _rad;

			Gizmos.DrawLine( p0, p1 );
		}
	}
}
