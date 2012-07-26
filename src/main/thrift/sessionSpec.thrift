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

include "mediaSpec.thrift"

/**
 * SessionSpec is designed to extend <a
 * href="http://www.ietf.org/rfc/rfc2327.txt">SDP</a> with new transports and
 * media types, providing a generic mechanism for Session Description
 * specification. Figure below shows data model components and their
 * interaction.
 * <p>
 *
 * <img src="doc-files/classdiagram.svg"/>
 *
 * <p>
 *
 * SessionSpec is intended to be directly used in multimedia negotiation. For
 * that purpose an intersection feature is implemented to calculate common
 * capabilities on both sides of a communication.
 *
 * <p>
 *
 * SessionSpec data model design has avoided inheritance in order to facilitate
 * object serialization and transfer in a multi-platform environment. Many
 * protocols can be used for delivery, including: THRIFT, JSON or even SDP (only
 * with RTP channels). Kurento provides a set of <a href="??">Conversion
 * utilities</a> for this purpose
 *
 * @see MediaSpec
 *
 */
struct SessionSpec {
	1: required list<mediaSpec.MediaSpec> medias,
	2: required string id;
	3: optional string version;
}
