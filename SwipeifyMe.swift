//
//  ViewController.swift
//  SelectifyMe
//
//  Created by Jacob Metcalf on 1/22/20.
//  Copyright © 2020 JfMetcalf. All rights reserved.
//

import UIKit

extension UIView {
  
  enum SelectorSize: Double {
    ///0.2 the size of the height of the background view
    case petite
    ///0.5 the size of the height of the background view
    case small
    ///0.8 the size of the height of the background view
    case meduim
    ///0.9 the size of the height of the background view
    case large
    ///Full size of the height of the background view
    case filled
  }
  
  /// Rounds the edges of the view and adds a 'selector' circle view like a swipe to confirm view of sorts
  func swipeifyMe(selectorSize: SelectorSize, selectorColor: UIColor, backgroundColor: UIColor, view: @escaping ((backgroundSelectorView: UIView, circleSelectorView: UIView, startingPoint: CGPoint, endingPoint: CGPoint)) -> ()) {
    self.backgroundColor = backgroundColor
    let selectorView = UIView()
    selectorView.backgroundColor = selectorColor
    self.addSubview(selectorView)
    selectorView.translatesAutoresizingMaskIntoConstraints = false
    
    var multiplier: CGFloat = 1
    switch selectorSize {
    case .petite: multiplier = 0.2
    case .small: multiplier = 0.5
    case .meduim: multiplier = 0.8
    case .large: multiplier = 0.9
    case .filled: multiplier = 1
    }
    let leftOver = 1 - multiplier
    selectorView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: multiplier).isActive = true
    selectorView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: multiplier).isActive = true
    selectorView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
    selectorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.height/2 * leftOver).isActive = true
    
    self.layer.cornerRadius = self.frame.height/2
    self.clipsToBounds = true
    selectorView.layer.cornerRadius = self.frame.height/2 - (self.frame.height/2 * leftOver)
    selectorView.clipsToBounds = true
    let startingPoint = CGPoint(x: self.frame.height / 2, y: self.center.y)
    let endingPoint = CGPoint(x: self.frame.width - (self.frame.height / 2), y: self.center.y)
    let info = (self, selectorView, startingPoint, endingPoint)
    view(info)
  }
  
}

protocol SwipifyMeCallbacksDelegate: class {
  func successSwipeCallback()
  func failureSwipeCallback()
}

class SwipifyMeViewController: UIViewController, SwipeToSelectDelegate {
  
  var info: (backgroundSelectorView: UIView, circleSelectorView: UIView, startingPoint: CGPoint, endingPoint: CGPoint)!
  var minimumFullSwipeValue: CGFloat = 0.8
  var tappedInSelectorView: Bool = false
  
  var swipeUpdatesDelegate: SwipifyMeCallbacksDelegate?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleSliderBegan(with: touches, backgroundView: info.backgroundSelectorView)
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleSliderMoved(with: touches, backgroundView: info.backgroundSelectorView)
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleSliderEnded(notFullSwipe: {
      self.swipeUpdatesDelegate?.failureSwipeCallback()
    }) {
      self.swipeUpdatesDelegate?.successSwipeCallback()
    }
  }
  
}

protocol SwipeToSelectDelegate: class {
  ///The info chunk!
  var info: (backgroundSelectorView: UIView, circleSelectorView: UIView, startingPoint: CGPoint, endingPoint: CGPoint)! {get set}
  ///The percentage where it will complete the swipe and animate to the ending point
  var minimumFullSwipeValue: CGFloat {get set}
  ///Always set this to false
  var tappedInSelectorView: Bool {get set}
  
  ///User this method in the touchesBegan callback on the viewcontroller
  func handleSliderBegan(with touches: Set<UITouch>, backgroundView: UIView)
  ///Use this method in the touchesMoved callback on the viewcontroller
  func handleSliderMoved(with touches: Set<UITouch>, backgroundView: UIView)
  ///User this method in the touchesEnded callback on the viewcontroller
  func handleSliderEnded(notFullSwipe: @escaping () -> (), fullSwipe: @escaping () -> ())
  ///Brings the selector view back to the starting position
  func animateToStart(completion: @escaping () -> ())
  ///Brings the selector view back to the ending position
  func animateToEnding(completion: @escaping () -> ())
  ///Makes sure the swipeifiedView's X value contains the touchPoint's X value
  func isWithinBounds(touchPoint: CGPoint) -> Bool
}

extension SwipeToSelectDelegate {
  
  func handleSliderBegan(with touches: Set<UITouch>, backgroundView: UIView) {
    if let touchPoint = touches.first?.location(in: backgroundView) {
      if backgroundView.bounds.contains(touchPoint) && isWithinBounds(touchPoint: touchPoint) {
        tappedInSelectorView = true
      } else {
        tappedInSelectorView = false
      }
    }
  }
  
  func handleSliderMoved(with touches: Set<UITouch>, backgroundView: UIView) {
    if let touchPoint = touches.first?.location(in: backgroundView) {
      if tappedInSelectorView && isWithinBounds(touchPoint: touchPoint) {
        info.circleSelectorView.center.x = touchPoint.x
      }
    }
  }
  
  func handleSliderEnded(notFullSwipe: @escaping () -> (), fullSwipe: @escaping () -> ()) {
    let circleEndingPoint = self.info.circleSelectorView.center
    if circleEndingPoint.x < self.info.endingPoint.x * minimumFullSwipeValue {
      animateToStart() {
        notFullSwipe()
      }
    } else {
      animateToEnding() {
        fullSwipe()
      }
    }
    tappedInSelectorView = false
  }
  
  func animateToStart(completion: @escaping () -> ()) {
    UIView.animate(withDuration: 0.2, animations: {
      self.info.circleSelectorView.center.x = self.info.startingPoint.x
    }) { (_) in
      completion()
    }
  }
  func animateToEnding(completion: @escaping () -> ()) {
    UIView.animate(withDuration: 0.2, animations: {
      self.info.circleSelectorView.center.x = self.info.endingPoint.x
    }) { (_) in
      completion()
    }
  }
  
  func isWithinBounds(touchPoint: CGPoint) -> Bool {
    if touchPoint.x < info.startingPoint.x || touchPoint.x > info.endingPoint.x {
      return false
    }
    return true
  }
}
