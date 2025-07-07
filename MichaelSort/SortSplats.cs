using UnityEngine;
using UdonSharp;
using VRC.SDKBase;
using VRC.SDK3.Rendering;

[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class SortSplats : UdonSharpBehaviour
{
    public RenderTexture tex0, tex1, texBins, texOrder;
    // public Texture texMeans;
    // public RenderTexture texDebug;
    public Material mat;
    private Vector3 _prevPhotoCameraPos; 

    void Start()
    {
        Material splatMat = GetComponent<MeshRenderer>().material;
        splatMat.SetTexture("_TexOrder", texOrder);
        Texture texMeans = splatMat.GetTexture("_TexMeans");
        mat.SetTexture("_TexMeans", texMeans);
        mat.SetTexture("_TexBins", texBins);
        mat.SetInt("_N", texMeans.width * texMeans.height);
    }

    void Update()
    {
        Sort(VRCCameraSettings.ScreenCamera.Position, 0);

        VRCCameraSettings photoCam = VRCCameraSettings.PhotoCamera;
        if (photoCam != null && photoCam.Active && photoCam.Position != _prevPhotoCameraPos)
        {
            _prevPhotoCameraPos = photoCam.Position;
            Sort(photoCam.Position, 1);
        }
    }

    void Sort(Vector3 cameraPos, int slice)
    {
        mat.SetVector("_CameraPos", transform.InverseTransformPoint(cameraPos));
        VRCGraphics.Blit(tex1, tex0, mat, 0);
        for (int i = 0; i < 4; i++)
        {
            mat.SetInt("_D", 4 * i);
            VRCGraphics.Blit(tex0, texBins, mat, 1);
            VRCGraphics.Blit(tex0, tex1, mat, 2);
            mat.SetInt("_D", 4 * i + 2);
            VRCGraphics.Blit(tex1, texBins, mat, 1);
            VRCGraphics.Blit(tex1, tex0, mat, 2);
        }
        VRCGraphics.Blit(tex0, texOrder, 0, slice);
        // VRCGraphics.Blit(tex0, texDebug, mat, 3);
    }
}
