#import <Foundation/Foundation.h>

#import "L0SlidePeer.h"

@protocol L0PeerDiscoveryDelegate <NSObject>

- (void) peerFound:(L0SlidePeer*) peer;
- (void) peerLeft:(L0SlidePeer*) peer;

@end