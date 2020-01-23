# SelectifyMe
Custom swipe to select view. Super simple UI. Very easy to customize

# SETUP
Quick and easy

* Add or copy/paste the SwipefyMe.swift file into your project
* On whichever ViewController you want to have the SwipeifiedView, conform the the SwipeifyMeDelegate, call swipefyMe(...) on the view you want, and set the properties of the delegate to the return value of the swipefyMe(...) call
* In the touchesBegan, touchesMoved, and touchesEnded callback on the ViewController itself, call the appropriate haneldSlider... methods.

There you have it, a fully functional swipe to select view!
