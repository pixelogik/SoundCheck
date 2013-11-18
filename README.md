SoundCheck
==========

Playing around with the SoundCloud API

IMPORTANT:

Please do not do "pod install". I had to fix a little thing in the SoundcloudUI that caused crashes sometimes when the login vc was dismissed. The scrollview's delegate is not set to nil in SCLoginViewController's dealloc and sometimes the scrollview calls the delegate after the vc was destroyed. That's why the pods are in the repository.

WHAT IS DOES/HAS:

- You can login and logout
- When you select a track, the SoundCloud app opens if available, otherwise the track is opened in Safari
- Nice background animation with sprite kit. Does not hurt performance because avoiding the UIKit layer
- Image loading is done on a background thread and sensitive to the current search query. If you search like a monkey (typing in search terms all the time) it does not bother the app. Image views of cells are updated as the images arrive, one after one.






