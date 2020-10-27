# elm-keyboard-shortcut

## Why?

Listening to the keyboard without dealing with where the focus is or anything like this is a bit messy.
One way to do this to use Browser.Events.keyPressed and the like. 
However, this mean you have to keep track of subscription and to correctly interpret each key stroke in your app based on your model, etc. 

An alternative would be to listen to keyboard events directly within your views. You already have access to the model or the relevant part of the models in there and if you event is not on display then it should not capture anything. 
The main issue with that approach is the focus: only focusable element can listen to keyboard event and only when focused will those event listener be triggered. 
Hence, now you need to keep that in mind.

With this package, you get the best of both world but you need to use a custom element for it: the custom element will let you define which shortcut you'd like to listen to and listen for them directly on the document.body so you can be sure you'll get the events you're expecting. 
