namespace * com.kurento.commons.mediaspec

include "mediaSpec.thrift"

struct SessionSpec {
	1: required list<mediaSpec.MediaSpec> medias,
	2: required string id;
	3: optional string version;
}
