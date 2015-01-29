using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Halp
{
	public static void Write8( byte[] _outBytes, int _offset, int _value )
	{
		_outBytes[ _offset ] = (byte)(_value & 0xff);
	}
	
	public static void Write16( byte[] _outBytes, int _offset, int _value )
	{
		_outBytes[ _offset+0 ] = (byte)((_value>>8) & 0xff);
		_outBytes[ _offset+1 ] = (byte)((_value) & 0xff);
	}
}
