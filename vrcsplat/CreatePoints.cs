#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;

// https://github.com/cnlohr/shadertrixx?tab=readme-ov-file#triangles-from-points-examples
public class CreatePoints : MonoBehaviour
{
	[MenuItem("Tools/Create Points")]
	static void CreateMesh_()
	{
		int vertices = 131072; // Up to 4M splats
		Mesh mesh = new Mesh();
		mesh.vertices = new Vector3[1];
		mesh.bounds = new Bounds(new Vector3(0, 0, 0), new Vector3(1000, 1000, 1000));
		mesh.SetIndices(new int[vertices], MeshTopology.Points, 0, false, 0);
		AssetDatabase.CreateAsset(mesh, "Assets/vrcsplat/points.asset");
	}
}
#endif