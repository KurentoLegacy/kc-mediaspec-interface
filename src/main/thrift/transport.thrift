namespace c_glib Kms
namespace * com.kurento.commons.mediaspec

struct TransportRtp {
	1: string address,
	2: i32 port,
}

struct Transport {
	1: optional TransportRtp rtp,
}
