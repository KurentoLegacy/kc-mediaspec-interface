namespace * com.kurento.commons.mediaspec

struct PayloadRtp {
	1: required i32 id,
	2: required string codecName,
	3: required i32 clockRate,

	4: optional i32 channels,
	5: optional i32 width,
	6: optional i32 height,
	7: optional i32 bitrate,

	50: optional map<string, string> extraParams,
}

struct Payload {
	1: optional PayloadRtp rtp,
}
