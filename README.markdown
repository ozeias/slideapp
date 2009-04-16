# Mover

Mover is an item sharing application for iPhone. For now, it's limited to sharing images and contacts, but OH I HAVE DREAMS.

In order to build it, you need to clone a few support repos and create source trees for them using the **Xcode &gt; Preferences &gt; Source Trees** command from the menu. Once you've done this in the UI, it will also work for command-line builds. (Yes, I have like a thousand in there. It's pretty sad.)

The repos are:

 - The ∞labs Build Tools. [http://github.com/millenomi/infinitelabs-build-tools](http://github.com/millenomi/infinitelabs-build-tools). Clone them in a location and create a source tree in Xcode named `INFINITELABS_TOOLS`, with a display name of "Infinite Labs - Tools", that points to that directory.
 - The MuiKit library. [http://github.com/millenomi/muikit](http://github.com/millenomi/muikit). Clone it in a location and create a source tree in Xcode named `INFINITELABS_LIB_MUIKIT`, with a display name of "Infinite Labs - MuiKit", that points to that directory.

Also, **IMPORTANT**: Simulator builds will work fine, but you need to select "(Project Settings)" rather than a Device SDK to build for the device. This is due to [this Xcode bug](http://www.openradar.me/radar?id=21402). Sigh.

Mover has already been sent to the App Store, so you don't even have to compile it on your own! [When it's up, this link will open Mover's App Store page in iTunes.](http://itunes.com/app/mover)
