#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.IO;


[System.Serializable]
public class VRCSplatMetadata
{
    public Vector3 scalesMin, scalesMax;
    public float shNMin, shNMax;
}


class VRCSplatPostProcessor : AssetPostprocessor
{
    static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths, bool didDomainReload)
    {
        foreach (string path in importedAssets)
        {
            if (Path.GetFileName(path) == "vrcsplat.json")
            {
                PostProcessVRCSplat(path);
            }
        }
    }

    static void PostProcessVRCSplat(string path)
    {
        string dirName = Path.GetDirectoryName(path);
        Material mat = new Material(Shader.Find("vrcsplat/GaussianSplattingAB"));

        (string fname, string propname, TextureImporterFormat format)[] T = {
            ("means.exr",         "_TexMeans",       TextureImporterFormat.RGBAHalf),
            ("quats.png",         "_TexQuats",       TextureImporterFormat.RGB24),
            ("scales.png",        "_TexScales",      TextureImporterFormat.RGB24),
            ("colors.png",        "_TexColors",      TextureImporterFormat.RGBA32),
            ("shN_centroids.png", "_TexShCentroids", TextureImporterFormat.RGB24)
        };
        foreach (var t in T)
        {
            string texPath = Path.Combine(dirName, t.fname);
            TextureImporter importer = AssetImporter.GetAtPath(texPath) as TextureImporter;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.sRGBTexture = false;
            importer.mipmapEnabled = false;
            TextureImporterPlatformSettings platformSettings = new TextureImporterPlatformSettings();
            platformSettings.name = UnityEditor.Build.NamedBuildTarget.Standalone.TargetName;
            platformSettings.format = t.format;
            platformSettings.maxTextureSize = 16384;
            platformSettings.overridden = true;
            importer.SetPlatformTextureSettings(platformSettings);
            importer.SaveAndReimport();

            Texture2D tex = (Texture2D)AssetDatabase.LoadAssetAtPath(texPath, typeof(Texture2D));
            mat.SetTexture(t.propname, tex);
        }

        string metaText = ((TextAsset)AssetDatabase.LoadAssetAtPath(path, typeof(TextAsset))).ToString();
        VRCSplatMetadata meta = JsonUtility.FromJson<VRCSplatMetadata>(metaText);
        mat.SetVector("_ScalesMin", meta.scalesMin);
        mat.SetVector("_ScalesMax", meta.scalesMax);
        mat.SetFloat("_ShMin", meta.shNMin);
        mat.SetFloat("_ShMax", meta.shNMax);

        string matPath = Path.Combine(dirName, Path.GetFileName(dirName) + ".mat");
        AssetDatabase.CreateAsset(mat, matPath);
    }
}
#endif
