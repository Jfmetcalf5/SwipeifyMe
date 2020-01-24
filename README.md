# SelectifyMe
Custom swipe to select view. Super simple UI. Very easy to customize

# SETUP
Quick and easy

* On the ViewController you want to have the swipeified view, have your ViewController conform to both `SwipifyMeViewController` and `SwipifyMeCallbacksDelegate`

  - The Delegate will have two callback methods `successSwipeCallback()` and `failureSwipeCallback()` where you will do logic based on each callback
  - Inside `viewDidLoad()` on the view you want to swipeify, call `yourCustomView.swipeifyMe(...)`
    - The return of this method is an object containing all the info you need. Inside the closure set the property info `self.info` to the callback of the closure
    
That is all you need to do, everything else is taken care of for you.

# Properties
* `self.info: (backgroundSelectorView: UIView, circleSelectorView: UIView, startingPoint: CGPoint, endingPoint: CGPoint)!`
    - Everything the Delegate needs to set up the view properly (you can customize any of these properties by simply doing `self.info.{property to customize}`)
* `self.minimumFullSwipeValue: CGFloat`
    - This value is between 0 and 1, it's the value where if the view is greater than this value it will slide to completed/success state
* `self.tappedInSelectorView: Bool`
    - Always set this to true.  If not the user can tap anywhere in the backgroundView of your selector and the view will jump to that point, not making a very friendly user onterface
