// These are UTIs backported from Mac OS X
// that we use in the app.

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
	#import <MobileCoreServices/MobileCoreServices.h>
#else

	#define kUTTypeTIFF @"public.tiff"
	#define kUTTypeJPEG @"public.jpeg"
	#define kUTTypeGIF @"com.compuserve.gif"
	#define kUTTypePNG @"public.png"
	#define kUTTypeBMP @"com.microsoft.bmp"
	#define kUTTypeICO @"com.microsoft.ico"

#endif