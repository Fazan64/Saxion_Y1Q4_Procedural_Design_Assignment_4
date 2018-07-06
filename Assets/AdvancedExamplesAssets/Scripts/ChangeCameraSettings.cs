using UnityEngine;

public class ChangeCameraSettings : MonoBehaviour {
	void Start () {
		Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
	}
}
