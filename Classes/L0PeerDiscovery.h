#import <Foundation/Foundation.h>

#import "L0MoverPeer.h"

@protocol L0PeerDiscoveryDelegate <NSObject>

- (void) peerFound:(L0MoverPeer*) peer;
- (void) peerLeft:(L0MoverPeer*) peer;

@end