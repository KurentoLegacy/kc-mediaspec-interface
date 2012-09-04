/*
kc-mediaspect-interface: Thrift interfaces for mediaspec types
Copyright (C) 2012 Tikal Technologies

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 3
as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

namespace c_glib Kms
namespace cocoa Kis
namespace * com.kurento.mediaspec

/**
 * This class provides a description mechanism for RTP transport. It basically
 * contains the transport address, consisting of IP address and UDP port.
 * Transport instance represent the reception address for local descriptors and
 * transmission address for remote descriptors.<br>
 * Remember each peer in a communication must handle to descriptor: local,
 * specifying reception information and remote, with transmission configuration.
 * The same descriptor swaps its role on each side of the communication.
 *
 */
struct TransportRtp {
	1: string address,
	2: i32 port,
}

/**
 *
 * This class provides a description mechanism for RTMP transport channels. From
 * Kurento point of view RTMP is just transport mechanism analogous to RTP,
 * where the transport address takes the form of an RTMP URL. Play attribute
 * indicates local descriptors the reception URL and Publish attribute provides
 * the transmission URL in remote descriptors. Notice that local and remote
 * descriptor role depends on the peer.
 *
 */
struct TransportRtmp {
	1: optional string url,
	2: optional string publish,
	3: optional string play,
}

enum TransportIceCandidateType {
	HOST,
	SERVER_REFLEXIVE,
	PEER_REFLEXIVE,
	RELAYED
}

enum TransportIceCandidateTransport {
	UDP,
}

struct TransportIceCandidate {
	1: required TransportIceCandidateType type,
	2: required TransportIceCandidateTransport transport,
	3: required string address,
	4: required i32 port,
	5: optional string baseAddress,
	6: optional i32 basePort,
	7: required i32 priority,
	8: optional i32 streamId,
	9: required i32 componentId,
	10: required string foundation,
	11: required string username,
	12: required string password,
}

struct TransportIce {
	1: list<TransportIceCandidate> candidates,
}

/**
 *
 * This class provides a container to specific transport types. In a standard
 * java coding schema this class would have been declared abstract and specific
 * transport classes would ha inherit from it, but composition is used instead
 * in order to facilitate serialization.
 *
 * @see MediaSpec
 * @see TransportRtmp
 * @see TransportRtp
 */
struct Transport {
	1: optional TransportRtp rtp,
	2: optional TransportRtmp rtmp,
	3: optional TransportIce ice,
}
