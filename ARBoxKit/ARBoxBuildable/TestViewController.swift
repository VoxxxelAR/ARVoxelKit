//
//  TestViewController.swift
//  ARBoxBuildable
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import ARBoxKit
import ARKit
import SceneKit

class TestViewController: BKViewController {
    
    override var sceneView: ARSCNView! {
        didSet {
            print(sceneView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
