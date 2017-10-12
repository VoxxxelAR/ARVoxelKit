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
    func vkSceneManager(_ manager: VKSceneManager, didFocus node: VKDisplayable, face: VKVoxelFace)
    func vkSceneManager(_ manager: VKSceneManager, didDefocus node: VKDisplayable?)
    func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int
    func vkSceneManager(_ manager: VKSceneManager, voxelFor index: Int) -> VKVoxelNode
}
```

4. You can add/remove voxels by calling:
``` swift
public func add(new voxel: VKVoxelNode)
public func add(new voxel: VKVoxelNode, to otherVoxel: VKVoxelNode, face: VKVoxelFace)
public func add(new voxel: VKVoxelNode, to tile: VKTileNode)
public func remove(_ voxel: VKVoxelNode)
```

5. Edit surfaces, tiles, voxels using paint command: 
``` swift
public enum VKPaintCommand {
    
    case color(content: UIColor)
    case faceColor(content: UIColor, face: VKVoxelFace)
    case colors(contents: [UIColor])
    
    case image(content: UIImage)
    case faceImage(content: UIImage, face: VKVoxelFace)
    case images(contents: [UIImage])
    
    case gradient(contents: [UIColor], start: CGPoint, end: CGPoint)
    case faceGradient(contents: [UIColor], start: CGPoint, end: CGPoint, face: VKVoxelFace)
    
    case transparency(value: CGFloat)
    case faceTransparency(value: CGFloat, face: VKVoxelFace)
}
```
for example:
``` swift
voxel.apply([.color(content: VKConstants.defaultFaceColor),
             .transparency(value: 1)], animated: true)
```
6. Change default setup by changing VKConstants values

## Example

You can check demo, running ARVoxelKitExample target
