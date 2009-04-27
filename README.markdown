# Mover

Mover is an item sharing application for iPhone. For now, it's limited to sharing images and contacts, but OH I HAVE DREAMS.

In order to build it, you need to set up its dependencies. Ideally, the included scripts should do that for you. A manual procedure for doing it is also included at the end of this file, just in case.

## Automatic setup.

**EXTREMELY IMPORTANT**: The iPhone SDK 2.2.1 package (containing Xcode 3.1.2) does **NOT** work with this script. See below under "Manual setup" instead. Later versions **do** work.

1. Clone this repository.
2. Close Xcode if it's running.
3. Execute the following in a terminal:

		cd /The/Path/Where/You/Cloned/This/Repository
		Scripts/DownloadDependencies
		open -a Xcode .

Build and you should be set.

## A few notes...

**IMPORTANT 1**: If you cloned this repository before April 27th, 2008, you'll need to run the following in a terminal before you can use the current release:

	cd /The/Path/Where/You/Cloned/This/Repository
	Scripts/CreateEmptyLocal

**IMPORTANT 2**: Simulator builds will work fine, but you need to select "(Project Settings)" rather than a Device SDK to build for the device. This is due to [this Xcode bug](http://www.openradar.me/radar?id=21402). Sigh.

Mover has already been sent to the App Store, so you don't even have to compile it on your own! [When it's up, this link will open Mover's App Store page in iTunes.](http://itunes.com/app/mover)


## Manual setup

The automatic setup above clones a few support repos and creates "local" settings for them. You can replicate this by using the **Xcode &gt; Preferences &gt; Source Trees** command from the menu. You only have to do this once you've done this in the UI, it will also work for command-line builds. (Yes, I have like a thousand in there. It's pretty sad.)

First, you have to tell the project you're going to use source trees instead of the automatic process above, by running in a terminal:

	cd /The/Path/Where/You/Cloned/This/Repository
	Scripts/CreateEmptyLocal

Then, you need to set up the source trees for the dependencies. The repos you need to clone are:

 - The ∞labs Build Tools. [http://github.com/millenomi/infinitelabs-build-tools](http://github.com/millenomi/infinitelabs-build-tools). Clone them in a directory, then create a source tree in Xcode named `INFINITELABS_TOOLS`, with a display name of "Infinite Labs - Tools", that points to that directory.
 - The MuiKit library. [http://github.com/millenomi/muikit](http://github.com/millenomi/muikit). Clone it in a directory, then create a source tree in Xcode named `INFINITELABS_LIB_MUIKIT`, with a display name of "Infinite Labs - MuiKit", that points to that directory.
