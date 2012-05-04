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
