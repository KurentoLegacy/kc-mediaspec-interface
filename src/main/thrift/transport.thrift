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

struct TransportRtp {
	1: string address,
	2: i32 port,
}

struct TransportRtmp {
	1: optional string url,
	2: optional string publish,
	3: optional string play,
}

struct Transport {
	1: optional TransportRtp rtp,
	2: optional TransportRtmp rtmp,
}
