//
//  ViewController.swift
//  SelectifyMe
//
//  Created by Jacob Metcalf on 1/22/20.
//  Copyright © 2020 JfMetcalf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var circleSelectorView: UIView!
  
  var startingPoint: CGPoint!
  var completePoint: CGPoint!
  let minimumFullSwipeValue: CGFloat = 0.8
  var tappedInSelectorView: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    <#ViewToTurnIntoSelector#>.selectifyMe(selectorSize: <#SelectorSize#>, selectorColor: <#UIColor#>, backgroundColor: <#UIColor#>) { (selectorView, startPoint, selectorPoint) in
      self.circleSelectorView = selectorView
      self.startingPoint = startPoint
      self.completePoint = selectorPoint
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleSliderStart(with: touches, backgroundView: <#ViewToTurnIntoSelector#>, selectorView: circleSelectorView)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleSliderMoved(with: touches, backgroundView: <#ViewToTurnIntoSelector#>, selectorView: circleSelectorView)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleSliderStopped()
  }
  
  func handleSliderStart(with touches: Set<UITouch>, backgroundView: UIView, selectorView: UIView) {
    if let touchPoint = touches.first?.location(in: backgroundView) {
      if backgroundView.bounds.contains(touchPoint) && isWithinBounds(touchPoint: touchPoint) {
        tappedInSelectorView = true
      } else {
        tappedInSelectorView = false
      }
    }
  }
  
  func handleSliderMoved(with touches: Set<UITouch>, backgroundView: UIView, selectorView: UIView) {
    if let touchPoint = touches.first?.location(in: backgroundView) {
      if tappedInSelectorView && isWithinBounds(touchPoint: touchPoint) {
        selectorView.center.x = touchPoint.x
      }
    }
  }
  
  func handleSliderStopped() {
    let endingPoint = circleSelectorView.center
    if endingPoint.x < completePoint.x * minimumFullSwipeValue {
      animateToStart {
        //Logic for not full swpie here
      }
    } else {
      animateToEnding {
        //Logic for full swipe here
        
        //Call this method when logic completed for full swipe
        //self.animateToStart {}
      }
    }
    tappedInSelectorView = false
  }
  
  func animateToEnding(completion: @escaping () -> ()) {
    UIView.animate(withDuration: 0.2, animations: {
      self.circleSelectorView.center.x = self.completePoint.x
    }) { (_) in
      completion()
    }
  }
  func animateToStart(completion: @escaping () -> ()) {
    UIView.animate(withDuration: 0.2, animations: {
      self.circleSelectorView.center.x = self.startingPoint.x
    }) { (_) in
      completion()
    }
  }
  
  func isWithinBounds(touchPoint: CGPoint) -> Bool {
    if touchPoint.x < startingPoint.x || touchPoint.x > completePoint.x {
      return false
    }
    return true
  }
  
}

extension UIView {
  
  enum SelectorSize: Double {
    case small, meduim, large, filled
  }
  
  /// Rounds the edges of the view and adds a 'selector' circle view like a swipe to confirm view of sorts
  func selectifyMe(selectorSize: SelectorSize, selectorColor: UIColor, backgroundColor: UIColor, view: @escaping ((selectorView: UIView, startingPoint: CGPoint, endingPoint: CGPoint)) -> ()) {
    self.backgroundColor = backgroundColor
    let selectorView = UIView()
    selectorView.backgroundColor = selectorColor
    self.addSubview(selectorView)
    selectorView.translatesAutoresizingMaskIntoConstraints = false
    
    var multiplier: CGFloat = 1
    switch selectorSize {
    case .small: multiplier = 0.4
    case .meduim: multiplier = 0.7
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
    let selectedPoint = CGPoint(x: self.frame.width - (self.frame.height / 2), y: self.center.y)
    view((selectorView, startingPoint, selectedPoint))
  }
  
}
