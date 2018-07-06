using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class XRayScript : MonoBehaviour {
	Renderer myRenderer;
	Collider myCollider;

	void Start () {
		myRenderer = GetComponent<Renderer> ();
		myCollider = GetComponent<Collider> ();
	}
	
	void Update () {
		RaycastHit hit;
		Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);
		if (Physics.Raycast(ray, out hit) && hit.collider == myCollider) {
			myRenderer.material.SetVector("_ScanPoint", hit.point);
		} else {
			myRenderer.material.SetVector("_ScanPoint", transform.position + new Vector3(0,1000,0)); // This should be far enough away...
		}
	}
}
