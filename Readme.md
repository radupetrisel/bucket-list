# BucketList

This is project 14 of 100 Days of SwiftUI by Paul Hudson (link [here](https://www.hackingwithswift.com/books/ios-swiftui/bucket-list-introduction)). The project is an app that lets the user build a private list of places on the map that they intend to visit one day, add a description for that place, look up interesting places that are nearby, and save it all to the iOS storage for later.

As usual, at the end of the guided tutorial there will be three challenges for me to implement by myself.

## Challenges

**Challenge #1**: Our + button is rather hard to tap. Try moving all its modifiers to the image inside the button – what difference does it make, and can you think why?

*Answer*: The clickable area on the button is determined by the size of its label - in this case, the image inside it. Changing the button's shape and size later on will affect its looks, but not the clickable area.
