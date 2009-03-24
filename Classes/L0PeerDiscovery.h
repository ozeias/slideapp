#import <Foundation/Foundation.h>

#import "L0BeamingPeer.h"

@protocol L0PeerDiscoveryDelegate <NSObject>

- (void) peerFound:(L0BeamingPeer*) peer;
- (void) peerLeft:(L0BeamingPeer*) peer;

@end