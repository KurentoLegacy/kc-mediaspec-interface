namespace * com.kurento.commons.mediaspec

include "mediaSpec.thrift"

struct SessionSpec {
	1: required list<mediaSpec.MediaSpec> medias,
}
