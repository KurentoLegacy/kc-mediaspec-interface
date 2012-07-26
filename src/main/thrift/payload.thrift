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
 * Provides accurate presentation of rational numbers as num/denom.
 */
struct Fraction {
	1: required i32 num,
	2: required i32 denom,
}

/**
 *
 * PayloadRtp represents a RTP payload descriptor. it contains the specification
 * of an RTP payload, including:
 * <ul>
 * <li>Payload number (id).
 * <li>Media codec name.
 * <li>Media sample rate.
 * <li>Stream bit rate.
 * <li>Codec frame rate. This is applicable only to VIDEO type.
 * <li>Video format: width x height.
 * </ul>
 *
 */
struct PayloadRtp {
	1: required i32 id,
	2: required string codecName,
	3: required i32 clockRate,

	4: optional i32 channels,
	5: optional i32 width,
	6: optional i32 height,
	7: optional i32 bitrate,
	8: optional Fraction framerate,

	50: optional map<string, string> extraParams,
}

/**
 *
 * This class provides a container to specific payload types. In a standard java
 * coding schema this class would have been declared abstract, and specific
 * payload classes would ha inherit from it, but composition is used instead in
 * order to facilitate serialization.
 *
 * @see MediaSpec
 * @see PayloadRtp
 *
 */
struct Payload {
	1: optional PayloadRtp rtp,
}
