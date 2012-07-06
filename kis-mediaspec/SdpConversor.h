
#import <Foundation/Foundation.h>
#import "sessionSpec.h"

@interface SdpConversor : NSObject

+ (NSString*)sdpFromSessionSpec:(KisSessionSpec*)ss;

@end
