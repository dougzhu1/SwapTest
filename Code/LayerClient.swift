//
//  LayerClient.swift
//  Layer-Parse-iOS-Swift-Example
//
//  Created by Manudeep N.s on 7/24/15.
//  Copyright (c) 2015 layer. All rights reserved.
//

import Foundation

class LayerClient {
    let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/7efd2f08-2e82-11e5-a710-42906a01766d")
    var layerClient: LYRClient!
    init() {
        self.layerClient = LYRClient(appID: LayerAppIDString)
        layerClient.autodownloadMaximumContentSize = 1024 * 100
        layerClient.autodownloadMIMETypes = NSSet(object: "image/jpeg") as Set<NSObject>
    }
    
}

var mainLayerClient = LayerClient()