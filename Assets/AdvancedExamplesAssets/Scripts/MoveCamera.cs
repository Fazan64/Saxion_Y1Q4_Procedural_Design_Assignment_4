using UnityEngine;

public class MoveCamera : MonoBehaviour {
	public float MoveSpeed = 0.1f;

	void Update () {
		if (Input.GetMouseButton (1)) {
			transform.Rotate (0, Input.GetAxis ("Mouse X"), 0);
		}
		transform.position += (transform.forward * Input.GetAxis ("Vertical") + transform.right * Input.GetAxis ("Horizontal")) * MoveSpeed;
	}
}
