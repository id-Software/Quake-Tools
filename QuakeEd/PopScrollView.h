#import <appkit/appkit.h>

@interface PopScrollView : ScrollView
{
	id	button1, button2;
}

- initFrame:(const NXRect *)frameRect button1: b1 button2: b2;
- tile;

@end