//
//  PullToRefresh.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-29.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

protocol RefreshViewAnimator {
  func animateState(state: State)
}



enum RefreshState:Equatable, CustomStringConvertible {
  case Initial, Loading, Finished
  case Releasing(progress: CGFloat)
  
  var description: String {
    switch self {
      case .Initial: return "Initial"
      case .Loading: return "Loading"
      case .Finished: return "Finished"
      case .Releasing(let progress): return "Releasing:\(progress)"
    }
  }
}

func ==(a: RefreshState, b: RefreshState) -> Bool {
  switch(a, b) {
    case (.Initial, .Initial) : return true
    case (.Loading, .Loading) : return true
    case (.Releasing, .Releasing) : return true
    case (.Finished, .Finished) : return true
    default: return false
  }
}
