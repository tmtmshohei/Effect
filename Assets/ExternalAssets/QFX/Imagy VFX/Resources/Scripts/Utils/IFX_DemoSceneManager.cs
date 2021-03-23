using UnityEngine;
using UnityEngine.SceneManagement;

// ReSharper disable once CheckNamespace
namespace QFX.IFX
{
    public class IFX_DemoSceneManager : MonoBehaviour
    {
		public void LoadScene(string sceneName)
        {
            SceneManager.LoadScene(sceneName);
        }
    }
}
