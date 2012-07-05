
#import <Foundation/Foundation.h>
#import "sessionSpec.h"

@interface SpecTools : NSObject

+ (NSArray*)intersectSessionSpecsAnswerer:(KisSessionSpec*)answerer
					andOfferer:(KisSessionSpec*)offerer;

#pragma mark Light creators
#pragma mark -

+ (KisSessionSpec*)createSessionSpecWithMedias:(NSArray*)medias id:(NSString*)id;
+ (KisPayloadRtp*)createPayloadRtpWithId:(int32_t)id codecName:(NSString*)codecName
							clockRate:(int32_t)clockRate;

@end
