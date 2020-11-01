# elm-keyboard-shortcut

![GitHub Page example](https://github.com/leojpod/elm-keyboard-shortcut/workflows/GitHub%20Page%20example/badge.svg?branch=master)

## Why?

Listening to the keyboard without dealing with where the focus is or anything like this is a bit messy.
One way to do this to use Browser.Events.keyPressed and the like.
However, this means you have to keep track of subscription and to correctly interpret each keystroke in your app based on your model, etc.

An alternative would be to listen to keyboard events directly within your views. You already have access to the model or the relevant part of the models in there and if your event-listener is not on display then it should not capture anything.
The main issue with that approach is the focus: only focusable element can listen to keyboard event and only when focused will those event listeners be triggered.
Hence, you now need to keep that in your mind when developing.

With this package, you get the best of both world but you need to use a custom element for it.
The custom element will let you define which shortcut you'd like to listen to and to listen for them directly on the document.body so you can be sure you'll get the events you're expecting.

As with anything, there are drawbacks.
If you have nested shortcut listener, e.g. you have a modal inside another modal and you'd like both to be cleared by pressing ESC - this is a bad design but anyhow -, then you may end up with one press on ESC to be caught by both shortcut listener.
The best way to handle this is probably to remove the ESC shortcut from the listener of the first modal when the second one is open.


## How?

For an example of how to use this shortcut package, please have a look at the example section.

## Installation

To use this in your project:

- Start by installing the elm package: `elm install leojpod/elm-keyboard-shortcut`

- Then install the companion JS package: `npm install elm-keyboard-shortcut` or `yarn elm-keyboard-shortcut`

- Finaly import the package in your project and that should do it: `import 'elm-keyboard-shortcut'`

