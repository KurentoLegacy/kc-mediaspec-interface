namespace * com.kurento.commons.mediaspec

include "payload.thrift"
include "transport.thrift"

enum MediaType {
	AUDIO,
	VIDEO
}

struct MediaSpec {
	1: required list<payload.Payload> payloads,
	2: required set<MediaType> type,
	3: required transport.Transport transport,
}
