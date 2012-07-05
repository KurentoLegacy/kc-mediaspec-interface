
#import <Foundation/Foundation.h>
#import "sessionSpec.h"

@interface SpecTools : NSObject

+ (NSArray*)intersectSessionSpecsAnswerer:(KisSessionSpec*)answerer
					andOfferer:(KisSessionSpec*)offerer;
+ (NSArray*)intersectMediaSpecsAnswerer:(KisMediaSpec*)answerer
					andOfferer:(KisMediaSpec*)offerer;

@end
