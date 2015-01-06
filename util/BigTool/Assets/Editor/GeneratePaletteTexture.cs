using UnityEngine;
using UnityEditor;
using System.Collections;

public class GeneratePaletteTexture : MonoBehaviour
{
	static float[] colorTable =
	{
		0.0f,
		25.0f,
		51.0f,
		80.0f,
		113.0f,
		148.0f,
		186.0f,
		225.0f
	};
	/*
	static float[] colorTable =
	{
		0.0f,
		0.1f,
		0.2f,
		0.315f,
		0.445f,
		0.58f,
		0.73f,
		0.88f,
	};
	*/

	[MenuItem("Mega Drive/Generate Palette Texture")]
	public static void MakeTexture()
	{
		Texture2D t = new Texture2D( 8, 64, TextureFormat.RGB24, false );
		Color c = new Color();
		int r, g, b;
		int x = 0;
		int y = 0;
		for( r=0; r<8; r++ )
		{
			for( g=0; g<8; g++ )
			{
				for( b=0; b<8; b++ )
				{
					c.r = (colorTable[ r ]+5.0f) / 255.0f;
					c.g = (colorTable[ g ]+5.0f) / 255.0f;
					c.b = (colorTable[ b ]+5.0f) / 255.0f;
					t.SetPixel( x, y, c );

					x++;
					if( x >= t.width )
					{
						x = 0;
						y++;
					}
				}
			}
		}

		byte[] bytes = t.EncodeToPNG();
		//File.WriteAllBytes( PathBuilder.instance.GetFilePath( FileType.Certificate ) + _nameMesh.text +"'s certificate (" +_percentMesh.text + ")" +".png", bytes);
		Debug.Log ("EditorApplication.applicationContentsPath=" + EditorApplication.applicationContentsPath );
		Debug.Log ("EditorApplication.applicationPath="+EditorApplication.applicationPath );
		Debug.Log ("Application.dataPath=" + Application.dataPath );
		Debug.Log ("Application.persistentDataPath=" + Application.persistentDataPath );
		Debug.Log ("Application.streamingAssetsPath=" + Application.streamingAssetsPath );

		System.IO.File.WriteAllBytes( Application.dataPath + System.IO.Path.PathSeparator + "MegaDrivePalette3.png", bytes );

	}
}
