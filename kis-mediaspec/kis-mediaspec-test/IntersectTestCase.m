
#import "IntersectTestCase.h"
#import "SpecTools.h"

#import "TBinaryProtocol.h"
#import "TMemoryBuffer.h"

@implementation IntersectTestCase

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSessionSpecSerialization {
	NSMutableArray *medias = [[NSMutableArray alloc] init];
	
	{
		NSMutableArray *payloads = [[NSMutableArray alloc] init];
		NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_VIDEO]];
		
		KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:2323];
		KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
		
		KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:96 codecName:@"MP4V-ES" clockRate:90000];
		[payRtp setBitrate:384];
		KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
		[payloads addObject:pay];
		
		KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
		[medias addObject:media];
	}
	
	{
		NSMutableArray *payloads = [[NSMutableArray alloc] init];
		NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_AUDIO]];
		
		KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:3434];
		KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
		
		KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:8 codecName:@"PCMA" clockRate:90000];
		KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
		[payloads addObject:pay];
		
		KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
		[medias addObject:media];
	}
	
	KisSessionSpec *sessionSpec = [SpecTools createSessionSpecWithMedias:medias id:@"12345"];
	
	id<TTransport> transport = [[TMemoryBuffer alloc] initWithData:[NSData data]];
	id<TProtocolFactory> protocolFactory = [TBinaryProtocolFactory sharedFactory];
	id<TProtocol> protocol = [protocolFactory newProtocolOnTransport:transport];
	[sessionSpec write:protocol];
	
	KisSessionSpec *sessionSpecDes = [[KisSessionSpec alloc] init];
	[sessionSpecDes read:protocol]; 
	
	NSLog(@"sessionSpec: %@", sessionSpec);
	NSLog(@"sessionSpecDes: %@", sessionSpecDes);
	STAssertTrue(sessionSpec != sessionSpecDes,
		       @"Serialized and deserialized session spects are no equals.");
	STAssertTrue([sessionSpec.description isEqualToString:sessionSpecDes.description],
		     @"Descriptions of serialized and deserialized session spects must be equals.");
}


- (void)testSessionSpecIntersection {
	KisSessionSpec *ssOfferer;
	{
		NSMutableArray *medias = [[NSMutableArray alloc] init];
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_VIDEO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:2221];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
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
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:8 codecName:@"PCMA" clockRate:90000];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		ssOfferer = [SpecTools createSessionSpecWithMedias:medias id:@"99991"];
	}
	
	KisSessionSpec *ssAnswerer;
	{
		NSMutableArray *medias = [[NSMutableArray alloc] init];
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_VIDEO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.2" port:2222];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:96 codecName:@"MP4V-ES" clockRate:90000];
			[payRtp setBitrate:200];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			payRtp = [SpecTools createPayloadRtpWithId:97 codecName:@"H264" clockRate:90000];
			[payRtp setBitrate:200];
			pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_AUDIO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.2" port:3332];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:98 codecName:@"AMR" clockRate:8000];
			[payRtp setChannels:1];
			[payRtp setBitrate:13];
			[payRtp setExtraParams:[NSDictionary dictionaryWithObject:@"1" forKey:@"octet-align"]];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		ssAnswerer = [SpecTools createSessionSpecWithMedias:medias id:@"99992"];
	}
	
	
	KisSessionSpec *ssExpectedAnswererResult;
	{
		NSMutableArray *medias = [[NSMutableArray alloc] init];
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_VIDEO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.2" port:2222];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:97 codecName:@"MP4V-ES" clockRate:90000];
			[payRtp setBitrate:200];
			[payRtp setExtraParams:[[NSDictionary alloc] init]];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_AUDIO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.2" port:3332];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_INACTIVE];
			[medias addObject:media];
		}
		
		ssExpectedAnswererResult = [SpecTools createSessionSpecWithMedias:medias id:@"99991"];
	}
	
	KisSessionSpec *ssExpectedOffererResult;
	{
		NSMutableArray *medias = [[NSMutableArray alloc] init];
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_VIDEO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:2221];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisPayloadRtp *payRtp = [SpecTools createPayloadRtpWithId:97 codecName:@"MP4V-ES" clockRate:90000];
			[payRtp setBitrate:200];
			[payRtp setExtraParams:[[NSDictionary alloc] init]];
			KisPayload *pay = [[KisPayload alloc] initWithRtp:payRtp];
			[payloads addObject:pay];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_SENDRECV];
			[medias addObject:media];
		}
		
		{
			NSMutableArray *payloads = [[NSMutableArray alloc] init];
			NSSet *types = [NSSet setWithObject:[NSNumber numberWithInt:MediaType_AUDIO]];
			
			KisTransportRtp *tRtp = [[KisTransportRtp alloc] initWithAddress:@"127.0.0.1" port:3331];
			KisTransport *transport = [[KisTransport alloc] initWithRtp:tRtp rtmp:nil];
			
			KisMediaSpec *media = [[KisMediaSpec alloc] initWithPayloads:payloads type:types transport:transport direction:Direction_INACTIVE];
			[medias addObject:media];
		}
		
		ssExpectedOffererResult = [SpecTools createSessionSpecWithMedias:medias id:@"99991"];
	}
	
	
	
	
	NSArray *ssIntersectResult = [SpecTools intersectSessionSpecsAnswerer:ssAnswerer
									andOfferer:ssOfferer];
	
	NSLog(@"ssOfferer: %@", ssOfferer);
	NSLog(@"ssAnswerer: %@", ssAnswerer);
	NSLog(@"ssIntersectResult: %@", ssIntersectResult);
	
	STAssertTrue([[[ssIntersectResult objectAtIndex:0] description] isEqualToString:ssExpectedAnswererResult.description],
		     @"Answerer result fails");
	STAssertTrue([[[ssIntersectResult objectAtIndex:1] description] isEqualToString:ssExpectedOffererResult.description],
		     @"Offerer result fails");
}

@end
