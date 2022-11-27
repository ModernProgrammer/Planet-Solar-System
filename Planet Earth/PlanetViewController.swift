//
//  PlanetViewController.swift
//  Planet Earth
//
//  Created by Diego Bustamante on 11/26/22.
//

import UIKit
import ARKit

class PlanetViewController: UIViewController {
    // MARK: - ARKit
    let configuration = ARWorldTrackingConfiguration()
    
    // MARK: - Views
    weak var sceneView: ARSCNView? = {
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [
            //ARSCNDebugOptions.showFeaturePoints,
            //ARSCNDebugOptions.showWorldOrigin
        ]
        return sceneView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard (sceneView != nil) else { return }
        createSolarSystem()
    }
    
    /// Initialize the planets
    private func createSolarSystem() {
        let centerPosition = SCNVector3(0, 0, -1)
        let fullRotation: CGFloat = CGFloat(360.degreesToRadians)
        
        let sun = createPlanet(
            geometry: SCNSphere(radius: 0.35),
            diffuse: UIImage(named: "Sun Diffuse"),
            position: centerPosition)
        
        let earthMoon = createPlanet(
            geometry: SCNSphere(radius: 0.05),
            diffuse: UIImage(named: "Moon Surface"),
            position: SCNVector3(0, 0, -0.3))
        
        let earthParent = createPlanet(
            geometry: SCNGeometry(),
            position: centerPosition)
        
        let venusParent = createPlanet(
            geometry: SCNGeometry(),
            position: centerPosition)

        sceneView?.scene.rootNode.addChildNode(sun)
        sceneView?.scene.rootNode.addChildNode(earthParent)
        sceneView?.scene.rootNode.addChildNode(venusParent)

        let earth = createPlanet(
            geometry: SCNSphere(radius: 0.2),
            diffuse: UIImage(named: "Earth Day"),
            specular: UIImage(named: "Earth Specular Map"),
            emission: UIImage(named: "Earth Clouds"),
            normal: UIImage(named: "Earth Normal"),
            position: SCNVector3(1.2, 0, 0))
        
        let venus = createPlanet(
            geometry: SCNSphere(radius: 0.2),
            diffuse: UIImage(named: "Venus Surface"),
            emission: UIImage(named: "Venus Atmosphere"),
            position: SCNVector3(1.8, 0, 0))
        
        earth.addChildNode(earthMoon)
        earthParent.addChildNode(earth)
        venusParent.addChildNode(venus)
        
        createActionRotation(
            y: fullRotation,
            duration: 8,
            for: sun)
        
        createActionRotation(
            y: fullRotation,
            duration: 12,
            for: earthParent)
        
        createActionRotation(
            y: fullRotation,
            duration: 16,
            for: earth)
        
        createActionRotation(
            y: fullRotation,
            duration: 16,
            for: venusParent)
        
        createActionRotation(
            y: fullRotation,
            duration: 16,
            for: venus)
        
    }
    
    /// Creates a rotation action for a node
    /// - Parameters:
    ///   - x: x-axis
    ///   - y: y-axis
    ///   - z: z-axis
    ///   - duration: time for a full rotation
    ///   - node: the node that will instantiate the action
    private func createActionRotation(
        x: CGFloat = 0,
        y: CGFloat = 0,
        z: CGFloat = 0,
        duration: CGFloat,
        for node: SCNNode
    ) {
        let action = SCNAction.rotateBy(x: x, y: y, z: z, duration: duration)
        let infiniteAction = SCNAction.repeatForever(action)
        node.runAction(infiniteAction)
    }
    
    /// Creates a SCNode Planet
    /// - Parameters:
    ///   - geometry: Node shape and size
    ///   - diffuse: Surface of the node
    ///   - specular: the amount and color of light reflected by the material directly toward the viewer
    ///   - emission: Texture on top of the node
    ///   - normal: Texture on the node
    ///   - position: The position of the node
    /// - Returns: a SCNNode
    private func createPlanet(
        geometry: SCNGeometry,
        diffuse: UIImage? = nil,
        specular: UIImage? = nil,
        emission: UIImage? = nil,
        normal: UIImage? = nil,
        position: SCNVector3) -> SCNNode {
            let node = SCNNode()
            node.geometry = geometry
            node.geometry?.firstMaterial?.diffuse.contents = diffuse
            node.geometry?.firstMaterial?.specular.contents = specular
            node.geometry?.firstMaterial?.emission.contents = emission
            node.geometry?.firstMaterial?.normal.contents = normal
            node.position = position
            return node
    }
}

// MARK: - ARKit UI Functions
extension PlanetViewController {
    /// Sets up scene for `ARKit`
    private func setupScene() {
        guard let sceneView = sceneView else { return }
        sceneView.session.run(configuration)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
        view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - ARKit Functions
extension PlanetViewController {
    /// Checks if user tapped on a object in the `SceneView`
    /// - Parameter sender: tap data
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("Didnt Touch anything")
        } else {
            let results = hitTest.first!
            guard let geometry = results.node.geometry else { return }
            print("Touched: \(String(describing: geometry))")
        }
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}


