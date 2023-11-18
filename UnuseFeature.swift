//
//  UnuseFeature.swift
//  GraduateWork
//
//  Created by Sato Masayuki on 2022/09/13.
//

import Foundation
import CoreMotion

func startHeadphoneMotion() {
    let airpodsMotionManager = CMHeadphoneMotionManager() // <- need to set delegate
    guard airpodsMotionManager.isDeviceMotionAvailable else { return }
    airpodsMotionManager.startDeviceMotionUpdates(to: .main, withHandler: { motion, _ in
        //if let motion = motion {
            //self.airpodsData(motion: motion)
        //}
    })
}

func airpodsData(motion: CMDeviceMotion) {
    let data = "\(motion.userAcceleration.x)x, \(motion.userAcceleration.y)y, \(motion.userAcceleration.z)z,rotate"
    print(data)
}
