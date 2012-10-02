
#import "SpecTools.h"

@implementation SpecTools

#pragma mark Light creators
#pragma mark -

+ (KisSessionSpec*)createSessionSpecWithMedias:(NSArray*)medias id:(NSString*)id {
	KisSessionSpec *sessionSpec = [[KisSessionSpec alloc] init];
	
	[sessionSpec setMedias:medias];
	[sessionSpec setId:id];
	
	return sessionSpec;
}

+ (KisPayloadRtp*)createPayloadRtpWithId:(int32_t)id codecName:(NSString*)codecName
							clockRate:(int32_t)clockRate {
	KisPayloadRtp *payload = [[KisPayloadRtp alloc] init];
	
	[payload setId:id];
	[payload setCodecName:codecName];
	[payload setClockRate:clockRate];
	
	return payload;
}



#pragma mark Intersections
#pragma mark -

+ (NSArray*)intersectSessionSpecsAnswerer:(KisSessionSpec*)answerer
					andOfferer:(KisSessionSpec*)offerer {
	NSArray *answererrMedias = answerer.medias;
	NSArray *offererMedias = offerer.medias;
	
	NSMutableArray *newAnswererMedias = [[NSMutableArray alloc] init];
	NSMutableArray *newOffererMedias = [[NSMutableArray alloc] init];
	NSMutableArray *usedMedias = [[NSMutableArray alloc] init];
	
	KisMediaSpec *answererMedia = nil;
	KisMediaSpec *offererMedia = nil;
	for (KisMediaSpec *offMedia in offererMedias) {
		NSArray *medias = nil;
		
		for (KisMediaSpec *ansMedia in answererrMedias) {
			if (![ansMedia.type isSubsetOfSet:offMedia.type]
					|| [usedMedias containsObject:ansMedia])
				continue;
			
			medias = [SpecTools intersectMediaSpecsAnswerer:ansMedia andOfferer:offMedia];
			if (medias != nil) {
				[usedMedias addObject:ansMedia];
				break;
			}			
		}
		
		if (medias == nil) {
			answererMedia = [[KisMediaSpec alloc] initWithPayloads:[[NSArray alloc] init]
					type:offMedia.type transport:[[KisTransport alloc] init]
					direction:Direction_INACTIVE];
			offererMedia = [[KisMediaSpec alloc] initWithPayloads:[[NSArray alloc] init]
					type:offMedia.type transport:[[KisTransport alloc] init]
					direction:Direction_INACTIVE];
		} else {
			answererMedia = [medias objectAtIndex:0];
			offererMedia = [medias objectAtIndex:1];
		}
		
		if (answererMedia != nil)
			[newAnswererMedias addObject:answererMedia];
		if (offererMedia != nil)
			[newOffererMedias addObject:offererMedia];
	}
	
	KisSessionSpec *newAnsSession = [[KisSessionSpec alloc] initWithMedias:newAnswererMedias
								id:offerer.id version:answerer.version];
	
	KisSessionSpec *newOffSession = [[KisSessionSpec alloc] initWithMedias:newOffererMedias
								id:offerer.id version:offerer.version];
	
	return [NSArray arrayWithObjects:newAnsSession, newOffSession, nil];
}

+ (NSArray*)intersectMediaSpecsAnswerer:(KisMediaSpec*)answerer
					andOfferer:(KisMediaSpec*)offerer {
	if (![SpecTools checkTransportCompatibleAnswerer:answerer andOfferer:offerer])
		return nil;
	if (![answerer.type isSubsetOfSet:offerer.type])
		return nil;
	
	NSArray *transports = [SpecTools intersectTransportsAnswerer:answerer.transport
							     offerer:offerer.transport];
	if (transports == nil)
		return nil;
	
	NSMutableArray *answererPayloads = [[NSMutableArray alloc] init];
	NSMutableArray *offererPayloads = [[NSMutableArray alloc] init];
	
	for (KisPayload *ansPayload in answerer.payloads) {
		for (KisPayload *offPayload in offerer.payloads) {
			KisPayload *intersection = [SpecTools intersectPayloadsAnswerer:ansPayload
									     andOfferer:offPayload];
			if (intersection != nil) {
				[answererPayloads addObject:intersection];
				[offererPayloads addObject:[SpecTools createPayloadCopy:intersection]];
				break;
			}
		}
	}
	
	enum KisDirection answererDirection = answerer.direction;
	enum KisDirection offererDirection = offerer.direction;
	
	if ([answererPayloads count] == 0) {
		answererDirection = Direction_INACTIVE;
		offererDirection = Direction_INACTIVE;
	} else if (answererDirection == Direction_INACTIVE ||
		   offererDirection == Direction_INACTIVE ||
		   (answererDirection == Direction_RECVONLY
		    && offererDirection == Direction_RECVONLY) ||
		   (answererDirection == Direction_SENDONLY
		    && offererDirection == Direction_SENDONLY)) {
			   answererDirection = Direction_INACTIVE;
			   offererDirection = Direction_INACTIVE;
	} else if (answererDirection == Direction_SENDONLY ||
	      offererDirection == Direction_RECVONLY) {
		answererDirection = Direction_SENDONLY;
		offererDirection = Direction_RECVONLY;
	} else if (answererDirection == Direction_RECVONLY ||
	      offererDirection == Direction_SENDONLY) {
		answererDirection = Direction_RECVONLY;
		offererDirection = Direction_SENDONLY;
	} else {
		answererDirection = Direction_SENDRECV;
		offererDirection = Direction_SENDRECV;
	}
	
	KisMediaSpec *newAns = [[KisMediaSpec alloc] initWithPayloads:answererPayloads
				type:answerer.type transport:[transports objectAtIndex:0]
							    direction:answererDirection];
	KisMediaSpec *newOff = [[KisMediaSpec alloc] initWithPayloads:offererPayloads
				type:offerer.type transport:[transports objectAtIndex:1]
							    direction:offererDirection];
	
	return [NSArray arrayWithObjects:newAns, newOff, nil];
}

+ (BOOL)checkTransportCompatibleAnswerer:(KisMediaSpec*)answerer
					andOfferer:(KisMediaSpec*)offerer {
	BOOL ret = NO;
	
	ret = (answerer.transport.rtmp != nil) && (offerer.transport.rtmp != nil);
	ret |= (answerer.transport.rtp != nil) && (offerer.transport.rtp != nil);
	
	return ret;
}

+ (KisPayload*)intersectPayloadsAnswerer:(KisPayload*)answerer
						andOfferer:(KisPayload*)offerer {
	if (answerer == nil || offerer == nil)
		return nil;
	KisPayload *intersection = [[KisPayload alloc] init];
	[intersection setRtp:[SpecTools intersectPayloadsRtpAnswerer:answerer.rtp
							  andOfferer:offerer.rtp]];
	
	if (intersection.rtp == nil)
		return nil;
	return intersection;
}

static int32_t
select_minor(int32_t a, int32_t b) {
	return a < b ? a : b;
}

+ (KisPayloadRtp*)intersectPayloadsRtpAnswerer:(KisPayloadRtp*)answerer
					andOfferer:(KisPayloadRtp*)offerer {
	if (answerer == nil || offerer == nil)
		return nil;
	
	if ([answerer.codecName caseInsensitiveCompare:offerer.codecName] != NSOrderedSame
	    || answerer.clockRate != offerer.clockRate)
		return nil;
	
	int32_t channels = select_minor(answerer.channels, offerer.channels);
	int32_t width = select_minor(answerer.channels, offerer.channels);
	int32_t height = select_minor(answerer.height, offerer.height);
	int32_t bitrate = select_minor(answerer.bitrate, offerer.bitrate);
	KisFraction *framerate = [SpecTools intersectFractionsAnswerer:answerer.framerate
							       offerer:offerer.framerate];
	
	KisPayloadRtp *rtp = [[KisPayloadRtp alloc] initWithId:offerer.id codecName:offerer.codecName clockRate:offerer.clockRate channels:channels width:width height:height bitrate:bitrate framerate:framerate extraParams:nil];
	
	NSMutableDictionary *extraParams = [NSMutableDictionary dictionaryWithDictionary:offerer.extraParams];
	for (NSString *key in answerer.extraParams) {
		if ([extraParams objectForKey:key] != nil)
			[extraParams setObject:[answerer.extraParams objectForKey:key] forKey:key];
	}
	
	[rtp setExtraParams:extraParams];
	
	return rtp;
}

+ (KisFraction*)intersectFractionsAnswerer:(KisFraction*)answerer
						offerer:(KisFraction*)offerer {
	if (answerer == nil)
		return offerer;
	if (offerer == nil)
		return answerer;

	if ((answerer.num * offerer.denom) < (offerer.num * answerer.denom))
		return [[KisFraction alloc] initWithNum:answerer.num denom:answerer.denom];
	else
		return [[KisFraction alloc] initWithNum:offerer.num denom:offerer.denom];
}

+ (NSArray*)intersectTransportsAnswerer:(KisTransport*)answerer
						offerer:(KisTransport*)offerer {
	KisTransport *intAns = [SpecTools createTransportCopy:answerer];
	KisTransport *intOff = [SpecTools createTransportCopy:offerer];
	
	
	KisTransportRtmp *rtmpAns = intAns.rtmp;
	KisTransportRtmp *rtmpOff = intOff.rtmp;
	
	NSArray *rtmps = [SpecTools intersectTransportsRtmpAnswerer:rtmpAns offerer:rtmpOff];
	if (rtmps != nil) {	
		intAns.rtmp = [rtmps objectAtIndex:0];
		intOff.rtmp = [rtmps objectAtIndex:1];
	} else {
		intAns.rtmp = nil;
		intOff.rtmp = nil;
	}
	
	if ((intAns.rtmp == nil && intAns.rtp == nil) ||
				(intOff.rtmp == nil && intOff.rtp == nil))
		return nil;
	
	return [NSArray arrayWithObjects:intAns, intOff, nil];
}

+ (NSArray*)intersectTransportsRtmpAnswerer:(KisTransportRtmp*)answerer
					offerer:(KisTransportRtmp*)offerer {
	KisTransportRtmp *intAns = [SpecTools createTransportRtmpCopy:answerer];
	KisTransportRtmp *intOff = [SpecTools createTransportRtmpCopy:offerer];
	
	if (intOff.publish != nil)
		intAns.play = intOff.publish;
	else
		return nil;
	
	if (intAns.publish != nil)
		intOff.play = intAns.publish;
	else
		return nil;
	
	if (intOff.url != nil)
		intAns.url = intOff.url;
	else if (intAns.url != nil)
		intOff.url = intAns.url;
	else
		return nil;
	
	return [NSArray arrayWithObjects:intAns, intOff, nil];
}


#pragma mark Copy creators
#pragma mark -

+ (KisPayload*)createPayloadCopy:(KisPayload*)payload {
	return [[KisPayload alloc] initWithRtp:[SpecTools createPayloadRtpCopy:payload.rtp]];
}

+ (KisPayloadRtp*)createPayloadRtpCopy:(KisPayloadRtp*)rtp {
	if (rtp == nil)
		return nil;
	KisFraction *framerate = nil;
	if (rtp.framerate != nil)
		framerate = [[KisFraction alloc] initWithNum:rtp.framerate.num denom:rtp.framerate.denom];
	
	return [[KisPayloadRtp alloc] initWithId:rtp.id codecName:rtp.codecName clockRate:rtp.clockRate
		channels:rtp.channels width:rtp.width height:rtp.height bitrate:rtp.bitrate
		framerate:framerate extraParams:[NSDictionary dictionaryWithDictionary:rtp.extraParams]];
}


+ (KisTransport*)createTransportCopy:(KisTransport*)transport {
	KisTransportRtp *rtp = [SpecTools createTransportRtpCopy:transport.rtp];
	KisTransportRtmp *rtmp = [SpecTools createTransportRtmpCopy:transport.rtmp];
	
	KisTransport *transportCopy = [[KisTransport alloc] init];
	[transportCopy setRtp:rtp];
	[transportCopy setRtmp:rtmp];

	return transportCopy;
}

+ (KisTransportRtp*)createTransportRtpCopy:(KisTransportRtp*)rtp {
	return [[KisTransportRtp alloc]initWithAddress:rtp.address port:rtp.port];
}

+ (KisTransportRtmp*)createTransportRtmpCopy:(KisTransportRtmp*)rtmp {
	return [[KisTransportRtmp alloc] initWithUrl:rtmp.url publish:rtmp.publish play:rtmp.play];
}

@end
