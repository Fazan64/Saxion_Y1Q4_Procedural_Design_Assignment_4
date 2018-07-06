using UnityEngine;

public class Rotate : MonoBehaviour {
	public float YRotationDegreesPerSecond=90;

	void Update () {
		transform.Rotate (0, YRotationDegreesPerSecond * Time.deltaTime, 0);
	}
}
