SoundCheck
==========

Playing around with the SoundCloud API

First do "pod install" (CocoaPods), then work on workspace.

WHAT IS DOES/HAS:

- You can login and logout
- When you select a track, the SoundCloud app opens if available, otherwise the track is opened in Safari
- You can search tracks
- Nice background animation with SpriteKit that does not hurt the performance because it's avoiding the UIKit layer
- Image loading is done on a background thread and sensitive to the current search query. If you search like a monkey (typing in search terms all the time) it does not bother the app. Image views of cells are updated as the images arrive, one after one.

Please run tests on simulator for now.





