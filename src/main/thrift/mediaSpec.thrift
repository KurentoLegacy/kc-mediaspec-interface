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

include "payload.thrift"
include "transport.thrift"

enum MediaType {
	AUDIO,
	VIDEO
}

/**
 * The media channel Direction.
 */
enum Direction {
	/**
	 * Only sends media
	 */
	SENDONLY,
	/**
	 * Only receives media
	 */
	RECVONLY,
	/**
	 * Sends and receives media
	 */
	SENDRECV,
	/**
	 * Inactive channel no media is sent nor received
	 */
	INACTIVE,
}

/**
 * <p>
 * MediaSpec represents a channel media descriptor. it contains one payload
 * descriptor for each supported format and one unique transport descriptor to
 * specify the media delivery layer.
 * </p>
 *
 * @see SessionSpec
 * @see Payload
 * @see Transport
 */
struct MediaSpec {
	1: required list<payload.Payload> payloads,
	2: required set<MediaType> type,
	3: required transport.Transport transport,
	/**
	 * The channel Direction.
	 */
	4: required Direction direction,
}
