# ARVoxelKit
Lightweight Framework for Voxel graphic using AR + SceneKit

[![Build Status](https://travis-ci.org/VoxxxelAR/ARVoxelKit.svg?branch=master)](https://travis-ci.org/VoxxxelAR/ARVoxelKit)

## Requirements
ARVoxelKit requires iOS 11, and supports the following devices:
- iPhone 6S and upwards
- iPhone SE
- iPad (2017)
- All iPad Pro models

## Usage

1. Import libraries as follows:

``` swift
import ARVoxelKit
import ARKit
import SceneKit
```

2. Setup your ARSCNView with VKSceneManager manager in you ViewContoller:

``` swift
var sceneManager: VKSceneManager?

@IBOutlet open var sceneView: ARSCNView! {
    didSet { sceneManager = VKSceneManager(with: sceneView) }
}

override open func viewDidLoad() {
    super.viewDidLoad()
    sceneManager.delegate = self
}

override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    sceneManager?.launchSession()
}

override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneManager?.pauseSession()
}
```
3. Conform your delegate instance to VKSceneManagerDelegate:

``` swift
public protocol VKSceneManagerDelegate: class {
    var voxelSize: CGFloat { get }

    func vkSceneManager(_ manager: VKSceneManager, shouldResetSessionFor state: VKARSessionState) -> Bool
    func vkSceneManager(_ manager: VKSceneManager, didUpdateState state: VKARSessionState)

    func vkSceneManager(_ manager: VKSceneManager, didFocus surface: VKPlatformNode)
    func vkSceneManager(_ manager: VKSceneManager, didDefocus surface: VKPlatformNode?)

    func vkSceneManager(_ manager: VKSceneManager, didFocus voxel: VKVoxelNode, face: VKVoxelFace)
    func vkSceneManager(_ manager: VKSceneManager, didDefocus voxel: VKVoxelNode?)

    func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int
    func vkSceneManager(_ manager: VKSceneManager, voxelFor index: Int) -> VKVoxelNode
}
```
