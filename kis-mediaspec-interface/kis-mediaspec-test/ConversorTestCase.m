
#import "ConversorTestCase.h"
#import "SdpConversor.h"
#import "SpecTools.h"

@implementation ConversorTestCase

- (void)testSessionSpec2Sdp {
	NSString *sdpStr = @"v=0\r\n"
			"o=- 99991 12345 IP4 127.0.0.1\r\n"
			"s=-\r\n"
			"c=IN IP4 127.0.0.1\r\n"
			"t=0 0\r\n"
			"m=video 2221 RTP/AVP 96 97\r\n"
			"a=rtpmap:96 H263-1998/90000\r\n"
			"a=rtpmap:97 MP4V-ES/90000\r\n"
			"a=sendrecv\r\n"
			"b=AS:384\r\n"
			"m=audio 3331 RTP/AVP 8 98\r\n"
			"a=rtpmap:8 PCMA/90000\r\n"
			"a=rtpmap:98 AMR/8000/1\r\n"
			"a=fmtp:98 octet-align=1\r\n"
			"a=sendrecv\r\n"
			"b=AS:13\r\n";
	
	KisSessionSpec *ss;
	{
		NSMutableArray *medias = [[NSMutableArray alloc] init];
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_VIDEO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:2221];
			KisTransport *transport = [[KisTransport alloc] init];
			[transport setRtp:tRtp];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:96 codecName:@"H263-1998" clockRate:90000];
			[payRtp setBitrate:384];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			payRtp = [SpecTools createPayloadRtpWithId:97 codecName:@"MP4V-ES" clockRate:90000];
			[payRtp setBitrate:384];
			pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_AUDIO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:3331];
			KisTransport *transport = [[KisTransport alloc] init];
			[transport setRtp:tRtp];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:8 codecName:@"PCMA" clockRate:90000];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			payRtp = [SpecTools createPayloadRtpWithId:98 codecName:@"AMR" clockRate:8000];
			[payRtp setChannels:1];
			[payRtp setBitrate:13];
			[payRtp setExtraParams:[NSDictionary dictionaryWithObject:@"1" forKey:@"octet-align"]];
			pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		ss = [SpecTools createSessionSpecWithMedias:medias id:@"99991"];
	}
	
	NSLog(@"SDP:\n%@", [SdpConversor sdpFromSessionSpec:ss]);
	NSLog(@"\n\nExpected SDP:\n%@", sdpStr);
	STAssertTrue([sdpStr isEqualToString:[SdpConversor sdpFromSessionSpec:ss]], @"Conversion fails");
}

@end
