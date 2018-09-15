//
//  SCNNode.swift
//  AR Sound Sculptures
//
//  Created by Matthew Chiang on 9/13/18.
//  Copyright © 2018 Matthew Chiang. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func parentWithName(_ name: String) -> SCNNode?{
        
        var currentNode: SCNNode? = self.parent
        
        while currentNode != nil {
            
            if (currentNode!.name == name) {
                return currentNode
            }
            
            currentNode = currentNode!.parent
        }
        
        return nil
    }
}
