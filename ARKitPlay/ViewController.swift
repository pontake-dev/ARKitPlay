//
//  ViewController.swift
//  ARKitPlay
//
//  Created by pontake on 2017/12/02.
//  Copyright © 2017年 pontake. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        //tapGesture
        sceneView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(self.tapView(sender:))))
        //TODO: ドラッグは上手くいってないのでのちほど
//        sceneView.addGestureRecognizer(UIPanGestureRecognizer(
//            target: self, action: #selector(self.dragView(sender:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        //検知対象を指定する。現在は水平のみ指定可能。
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("\(self.classForCoder)/" + #function)
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        //sceneとnodeを読み込み
        guard let scene = SCNScene(named: "Bear_Brown.scn", inDirectory: "art.scnassets/bear") else {fatalError()}
        guard let bearNode = scene.rootNode.childNode(withName: "Bear", recursively: true) else {fatalError()}
        // nodeのスケールを調整する
        let (min, max) = bearNode.boundingBox
        let w = CGFloat(max.x - min.x)
        // 1mを基準にした縮尺を計算
        let magnification = 1.0 / w
        bearNode.scale = SCNVector3(magnification, magnification, magnification)
        // nodeのポジションを設定
        bearNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)

        //作成したノードを追加
        DispatchQueue.main.async(execute: {
            node.addChildNode(bearNode)
        })

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("\(self.classForCoder)/" + #function)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc func tapView(sender: UIGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        if !results.isEmpty {
            if let result = results.first ,
                let anchor = result.anchor ,
                let node = sceneView.node(for: anchor) {
                
                let action1 = SCNAction.rotateBy(x: CGFloat(-90 * (Float.pi / 180)), y: 0, z: 0, duration: 0.5)
                let action2 = SCNAction.wait(duration: 1)

                DispatchQueue.main.async(execute: {
                    node.runAction(
                        SCNAction.sequence([
                        action1,
                        action2,
                        action1.reversed()
                        ])
                    )
                })
                
            }
        }
    }
    
    @objc func dragView(sender: UIGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        
        let results = sceneView.hitTest(tapPoint, types: .existingPlane)
        if !results.isEmpty {
            if let result = results.first ,
                let anchor = result.anchor ,
                let node = sceneView.node(for: anchor) {
                
                DispatchQueue.main.async(execute: {
                    // 実世界の座標をSCNVector3で返したものを反映
                    node.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                })
            }
        }
    }
    
}
