using UnityEngine;

public class ApplyShaderAsImageEffect : MonoBehaviour {
	public Material EffectMaterial;

	void OnRenderImage(RenderTexture source, RenderTexture destination) {
		Graphics.Blit (source, destination, EffectMaterial);
	}
}
