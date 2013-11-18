SoundCheck
==========

Playing around with the SoundCloud API

WHAT IS DOES/HAS:

- You can login and logout
- When you select a track, the SoundCloud app opens if available, otherwise the track is opened in Safari
- You can search tracks
- Nice background animation with sprite kit. Does not hurt performance because avoiding the UIKit layer
- Image loading is done on a background thread and sensitive to the current search query. If you search like a monkey (typing in search terms all the time) it does not bother the app. Image views of cells are updated as the images arrive, one after one.






