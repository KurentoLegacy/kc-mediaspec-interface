
#import "SdpConversor.h"

NSString *PROTO_VERSION_FIELD = @"v=";
NSString *ORIGIN_FIELD = @"o=";
NSString *SESSION_NAME_FIELD = @"s=";
NSString *CONNECTION_FIELD = @"c=";
NSString *TIME_FIELD = @"t=";
NSString *MEDIA_FIELD = @"m=";
NSString *ATTRIBUTE_FIELD = @"a=";
NSString *BANDWIDTH_FIELD = @"b=";

NSString *IN = @"IN";
NSString *IPV4 = @"IP4";

NSString *RTP_AVP = @"RTP/AVP";
NSString *RTPMAP = @"rtpmap";
NSString *FMTP = @"fmtp";
NSString *AS = @"AS";

NSString *ENDLINE = @"\r\n";
NSString *DEFAULT_SDP_VERSION = @"0";
NSString *DEFAULT_VERSION = @"12345";
NSString *DEFAULT_NAME = @"-";
NSString *DEFAULT_SESSION_NAME = @"-";
NSString *CHANGE = @"";

@implementation SdpConversor

+ (NSString*)sdpFromSessionSpec:(KisSessionSpec*)ss {
	if (ss == nil)
		return @"";
	
	NSMutableString *str = [[NSMutableString alloc] init];
	NSString *address = [SdpConversor adressFromSessionSpec:ss];
	
	[str appendFormat:@"%@%@%@", PROTO_VERSION_FIELD, DEFAULT_SDP_VERSION, ENDLINE];
	[str appendFormat:@"%@%@ %@ %@ %@ %@%@", ORIGIN_FIELD, DEFAULT_NAME, ss.id,
					DEFAULT_VERSION, IPV4, address, ENDLINE];
	[str appendFormat:@"%@%@%@", SESSION_NAME_FIELD, DEFAULT_SESSION_NAME, ENDLINE];
	[str appendFormat:@"%@%@ %@ %@%@", CONNECTION_FIELD, IN, IPV4, address, ENDLINE];
	[str appendFormat:@"%@0 0%@", TIME_FIELD, ENDLINE];
	
	for (KisMediaSpec *ms in ss.medias) {
		[str appendFormat:@"%@", [SdpConversor sdpFromMediaSpec:ms]];
	}
	
	return str;
}

+ (NSString*)sdpFromMediaSpec:(KisMediaSpec*)ms {
	NSMutableString *str = [[NSMutableString alloc] init];
	
	KisTransportRtp *transport = ms.transport.rtp;
	if (transport == nil)
		return @"";
	
	if ([ms.type count] != 1)
		return @"";
	
	[str appendFormat:@"%@%@ ", MEDIA_FIELD, [SdpConversor strFromMediaType:[ms.type anyObject]]];
	if ([ms.payloads count] == 0)
		[str appendFormat:@"0"];
	else
		[str appendFormat:@"%d", transport.port];
	
	[str appendFormat:@" %@", RTP_AVP];
	
	
	NSMutableString *payloadStr = [[NSMutableString alloc] init];
	int bitrate = -1;
	
	for (KisPayload *payload in ms.payloads) {
		if ([payload rtpIsSet]) {
			KisPayloadRtp *rtp = payload.rtp;
			[str appendFormat:@" %d", rtp.id];
			[payloadStr appendFormat:@"%@", [SdpConversor sdpFromPayloadRtp:rtp]];
			if ([rtp bitrateIsSet]) {
				if (rtp.bitrate != -1 &&
				    (rtp.bitrate < bitrate || bitrate == -1)) {
					bitrate = rtp.bitrate;
				}
			}
		}
	}
	
	[str appendFormat:@"%@", ENDLINE];
	[str appendFormat:@"%@", payloadStr];
	
	[str appendFormat:@"%@", ATTRIBUTE_FIELD];
	if ([ms.payloads count] == 0)
		[str appendFormat:@"%@", [SdpConversor strFromDirection:Direction_INACTIVE]];
	else
		[str appendFormat:@"%@", [SdpConversor strFromDirection:ms.direction]];
	[str appendFormat:@"%@", ENDLINE];
	if (bitrate > 0)
		[str appendFormat:@"%@%@:%d%@", BANDWIDTH_FIELD, AS, bitrate, ENDLINE];
	
	return str;
}
			 
+ (NSString*)sdpFromPayloadRtp:(KisPayloadRtp*)pr {
	NSMutableString *str = [[NSMutableString alloc] init];
	
	[str appendFormat:@"%@%@:%d %@/%d", ATTRIBUTE_FIELD, RTPMAP, pr.id,
							pr.codecName, pr.clockRate];
	if ([pr channelsIsSet])
		[str appendFormat:@"/%d", pr.channels];
	[str appendFormat:@"%@", ENDLINE];
	
	[str appendFormat:@"%@", [SdpConversor formatParametersFromPayloadRtp:pr]];
	
	return str;
}

+ (NSString*)formatParametersFromPayloadRtp:(KisPayloadRtp*)pr {
	NSMutableString *str = [[NSMutableString alloc] init];
	
	if ([pr.codecName caseInsensitiveCompare:@"AMR"] == NSOrderedSame) {
		NSString *value = [pr.extraParams objectForKey:@"octet-align"];
		if (value != nil)
			[str appendFormat:@"octet-align=%@", value];
	}
	if ([str length] != 0)
		return [NSString stringWithFormat:@"%@%@:%d %@%@", ATTRIBUTE_FIELD,
							FMTP, pr.id, str, ENDLINE];
	else
		return @"";
}

+ (NSString*)adressFromSessionSpec:(KisSessionSpec*)ss {
	NSString *address = nil;
	for (KisMediaSpec *ms in ss.medias) {
		KisTransportRtp *tr = ms.transport.rtp;
		if (tr == nil)
			continue;
		
		if (address == nil)
			address = tr.address;
		else if (![address isEqualToString:tr.address])
			@throw [NSException exceptionWithName:@"SdpException"
				reason:@"Address does not match on all medias" userInfo:nil];
	}
	
	if (address == nil)
		@throw [NSException exceptionWithName:@"SdpException"
				reason:@"Address not found" userInfo:nil];
	
	return address;
}

static char* media_types[] = {
	"audio",
	"video" };

+ (NSString*)strFromMediaType:(id)type {
	enum KisMediaType t = [[type description] intValue];
	return [NSString stringWithFormat:@"%s", media_types[t]];
}

static char* directions[] = {
	"sendonly",
	"recvonly",
	"sendrecv",
	"inactive" };

+ (NSString*)strFromDirection:(enum KisDirection)dir {
	return [NSString stringWithFormat:@"%s", directions[dir]];
}

@end
