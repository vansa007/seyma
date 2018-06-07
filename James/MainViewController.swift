//
//  MainViewController.swift
//  James
//
//  Created by Vansa Pha on 5/30/18.
//  Copyright © 2018 Vansa Pha. All rights reserved.
//

import UIKit
import CoreMotion
import LocalAuthentication

class MainViewController: UITabBarController {
    
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var playerView: UIView!
    var animator: UIDynamicAnimator?
    var motionManager = CMMotionManager()
    var gravity = UIGravityBehavior()
    let motionQueue = OperationQueue()
    lazy var authView: UIView = {
        let av = UIView()
        av.translatesAutoresizingMaskIntoConstraints = false
        av.backgroundColor = .red
        return av
    }()
    lazy var authLb: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.text = "Please pass authentication for playing game with Seyma."
        lb.numberOfLines = 0
        lb.font = UIFont.boldSystemFont(ofSize: 15)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    @IBAction func motionSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            startGravityAction()
        }else {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        addAuthCoverView()
    }
    
    private func addAuthCoverView() {
        self.view.addSubview(authView)
        authView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        authView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        authView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        authView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        authView.addSubview(authLb)
        authLb.centerXAnchor.constraint(equalTo: authView.centerXAnchor).isActive = true
        authLb.centerYAnchor.constraint(equalTo: authView.centerYAnchor).isActive = true
        authLb.leadingAnchor.constraint(equalTo: authView.leadingAnchor, constant: 16).isActive = true
        authLb.trailingAnchor.constraint(equalTo: authView.trailingAnchor, constant: -16).isActive = true
        
        popUpAuthentication()
    }
    
    private func goAnimate() {
        DispatchQueue.main.async {
            self.authView.removeFromSuperview()
            self.gravity = UIGravityBehavior(items: [self.playerView])
            self.animator = UIDynamicAnimator(referenceView: self.view)
            self.addSub()
            self.addGravity()
        }
    }
    
    private func popUpAuthentication() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "ក្មួយជាម្ចាស់ទូរស័ព្ទមានទេ?"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (succes, error) in
                if succes {
                    self.goAnimate()
                }else {
                    self.showAlertController("កុំប្អូនកុំ ទុកទូរស័ព្ទឲ្យម្ចាស់គេ គេលេងវិញ។")
                }
            }
        }
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startGravityAction()
    }
    
    private func startGravityAction() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: gravityUpdated)
    }
    
    func gravityUpdated(motion: CMDeviceMotion!, error: Error!) {
        let grav : CMAcceleration = motion.gravity;
        
        let x = CGFloat(grav.x);
        let y = CGFloat(grav.y);
        var p = CGPoint(x: x, y: y)
        
        if error != nil {
            NSLog("\(error)")
        }
        
        // Have to correct for orientation.
        DispatchQueue.main.async {
            let orientation = UIApplication.shared.statusBarOrientation
            if(orientation == UIInterfaceOrientation.landscapeLeft) {
                let t = p.x
                p.x = 0 - p.y
                p.y = t
            } else if (orientation == UIInterfaceOrientation.landscapeRight) {
                let t = p.x
                p.x = p.y
                p.y = 0 - t
            } else if (orientation == UIInterfaceOrientation.portraitUpsideDown) {
                p.x *= -1
                p.y *= -1
            }
            
            let v = CGVector(dx: p.x, dy: 0 - p.y)
            self.gravity.gravityDirection = v;
        }
    }
    
    private func addGravity() {
        let direction = CGVector(dx: 0, dy: 1)
        gravity.gravityDirection = direction
        //collision
        let boundries = UICollisionBehavior(items: [playerView])
        boundries.translatesReferenceBoundsIntoBoundary = true
        //elasticity
        let bounce = UIDynamicItemBehavior(items: [playerView])
        bounce.elasticity = 0.5
        
        animator?.addBehavior(bounce)
        animator?.addBehavior(boundries)
        animator?.addBehavior(gravity)
    }
    
    private func addSub() {
        let panGuesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        playerView.addGestureRecognizer(panGuesture)
        playerView.backgroundColor = .red
        playerView.layer.cornerRadius = 50

        self.view.addSubview(playerView)
        
        //switch
        switcher.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(switcher)
        switcher.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        switcher.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        switcher.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            if playerView.frame.contains(view.center) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gif"), object: nil)
            }else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "regif"), object: nil)
            }
        }
    }
}
