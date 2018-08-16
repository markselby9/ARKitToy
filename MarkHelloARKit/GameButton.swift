//
//  GameButton.swift
//  MarkHelloARKit
//
//  Created by 冯超逸 on 2018/8/16.
//  Copyright © 2018 Mark Feng. All rights reserved.
//

import Foundation
import UIKit

class GameButton : UIButton {
    var timer : Timer!
    var callback : () -> ()
    
    init(frame: CGRect, callback: @escaping () -> ()) {
        self.callback = callback;
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.callback()
        })
        
    }
    
    @objc override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.invalidate()
    }
}
