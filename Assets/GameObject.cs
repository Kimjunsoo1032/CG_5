using UnityEngine;
public class GameObject : MonoBehaviour
{
    public Material mat;
    public float speed = 1f;

    void Update()
    {
        float d = Mathf.PingPong(Time.time * speed, 1.0f);
        mat.SetFloat("_Dissolve", d);
    }
}