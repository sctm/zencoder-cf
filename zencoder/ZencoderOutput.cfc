﻿<!---/**********************************************
 * ColdFusion Zencoder API
 * Copyright (C) 2010 SCTM Enterprises, LLC (Todd Schlomer)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **********************************************
 * Author:	Todd Schlomer
 * Date:	December 8, 2010
 **********************************************/

/**
 * This is the Zencoder output object.
 * @author Todd Schlomer
 */--->
<cfcomponent displayname="ZencoderOutput" hint="This is the Zencoder output object." output="false" accessors="true">
	
	<cfproperty name="base_url" 		type="string" 	hint="This is the base URL to export the transcoded media.  Determines a directory to put the output file in, but not the filename." />
	<cfproperty name="filename" 		type="string" 	hint="The filename of a finished file. If you supply a filename but not a base_url, Zencoder will store the file with this filename in a S3 bucket temporarily for you to download." />
	<cfproperty name="label" 			type="string" 	hint="If set to zero, it will use the Zencoder default of 5.  The maximum allowed is 25." />
	<cfproperty name="device_profile"	type="string"	hint="The device profile to use as an alternative to specifying video/audio codecs and associated attributes. Options are: mobile/advanced, mobile/baseline, mobile/legacy, v1/mobile/advanced, v1/mobile/baseline, v1/mobile/legacy, v2/mobile/legacy" />
	<cfproperty name="video_codec" 		type="string" 	hint="The output video codec to use." />
	<cfproperty name="speed" 			type="numeric" 	hint="A target transcoding speed, from 1 to 5." />
	<cfproperty name="width" 			type="numeric" 	hint="A width for the target media.  0 for not set." />
	<cfproperty name="height" 			type="numeric" 	hint="A height for the target media.  0 for not set." />
	<cfproperty name="aspect_mode" 		type="string" 	hint="If the aspect ratio of the input does not match the requested output aspect ratio, this specifies what the output resolution be." />
	<cfproperty name="quality" 			type="numeric" 	hint="The desired output video quality, from 1 to 5." />
	<cfproperty name="video_bitrate" 	type="numeric" 	hint="The desired output bitrate for a video, expressed in Kbps." />
	<cfproperty name="bitrate_cap" 		type="numeric" 	hint="The max peak bitrate throughout a video.  0 for not no setting." />
	<cfproperty name="buffer_size" 		type="numeric" 	hint="Used in conjunction with Max Bitrate. This number should be determined by the settings of your streaming server, or your targeted playback device. For example, Buffer Size should be set to 10000 for an iPhone. Default: 0 for none." />
	<cfproperty name="max_video_bitrate" type="string" 	hint="A maximum average bitrate for a movie. Overrides both the quality and video_bitrate settings to ensure that a bitrate doesn't exceed the provided number." />
	<cfproperty name="audio_codec" 		type="string" 	hint="The output audio codec to use." />
	<cfproperty name="audio_quality" 	type="numeric" 	hint="The desired output audio quality, from 1 to 5." />
	<cfproperty name="audio_bitrate" 	type="numeric" 	hint="An output bitrate setting, in Kbps. This should be a multiple of 16, and lower than 160kbps per channel (320kbps for stereo)." />
	<cfproperty name="audio_sample_rate" type="numeric" hint="Audio sample rate in Hz.  A valid sample rate. Depends on the codec; typically 8000, 11025, 12000, 16000, 22050, 32000, 44100, 48000" />
	<cfproperty name="max_frame_rate" 	type="numeric" 	hint="Rather than setting an exact frame rate, which may involve increase the frame rate (and therefore the bitrate) of some content, you can set a Max Frame Rate instead." />
	<cfproperty name="frame_rate" 		type="numeric" 	hint="The output frame rate to use, as a decimal number (e.g. 15, or 24.98). 0 for system default." />
	<cfproperty name="keyframe_interval" type="numeric" hint="Set the maximum number of frames between each keyframe. By default, a keyframe will be created at most every 250 frames. 0 to use default." />
	<cfproperty name="keyframe_rate" 	type="numeric" 	hint="Set the number of keyframes per second. So a value of 0.5 would result in one keyframe every two seconds. A value of 3 would result in three keyframes per second." />
	<cfproperty name="public" 			type="boolean" 	hint="Use the public API setting to flag a file output to S3 as being publicly readable. This is done by granting the READ permission to the AllUsers group." />
	<cfproperty name="notifications" 	type="ZencoderNotification" hint="This is the notification(s) to use for this output." />
	<cfproperty name="thumbnails" 		type="ZencoderThumbnails" 	hint="This is the thumbnail(s) to use for this output." />
	<cfproperty name="headers"		 	type="struct" 	hint="S3 supports the sending of headers with your file when it is uploaded to S3. Zencoder support setting a limited subset of the S3 headers: Cache-Control, Content-Disposition, Content-Encoding, Content-Type, Expires, x-amz-acl, x-amz-storage-class, and x-amz-meta-*." />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="ZencoderOutput" output="false" hint="Constructor method.">
			<cfargument name="base_url" 		type="string" 	required="yes" hint="This is the base URL to export the transcoded media.  Determines a directory to put the output file in, but not the filename.">
			<cfargument name="filename" 		type="string" 	required="yes" hint="The filename of a finished file. If you supply a filename but not a base_url, Zencoder will store the file with this filename in a S3 bucket temporarily for you to download.">
			<cfargument name="label" 			type="string" 	required="yes" hint="If set to zero, it will use the Zencoder default of 5.  The maximum allowed is 25.">
			<cfargument name="video_codec"		type="string" 	required="no" default="" 			hint="The output video codec to use.">
			<cfargument name="device_profile"	type="string"	required="no" default=""			hint="The device profile to use, see hint in cfproperty above or look here: https://app.zencoder.com/docs/api/encoding/general-output-settings/device-profile" />
			<cfargument name="speed"			type="numeric" 	required="no" default="2" 			hint="A target transcoding speed, from 1 to 5.">
			<cfargument name="width"			type="numeric" 	required="no" default="0" 			hint="A width for the target media.  0 for not set.">
			<cfargument name="height"			type="numeric" 	required="no" default="0" 			hint="A height for the target media.  0 for not set.">
			<cfargument name="aspect_mode"		type="string" 	required="no" default="" 			hint="If the aspect ratio of the input does not match the requested output aspect ratio, this specifies what the output resolution be.">
			<cfargument name="quality"			type="numeric" 	required="no" default="3" 			hint="The desired output video quality, from 1 to 5.">
			<cfargument name="video_bitrate"	type="numeric" 	required="no" default="0" 			hint="The desired output bitrate for a video, expressed in Kbps.">
			<cfargument name="bitrate_cap"		type="numeric" 	required="no" default="0" 			hint="The max peak bitrate throughout a video.  0 for not no setting.">
			<cfargument name="buffer_size"		type="numeric" 	required="no" default="0" 			hint="Used in conjunction with Max Bitrate. This number should be determined by the settings of your streaming server, or your targeted playback device. For example, Buffer Size should be set to 10000 for an iPhone. Default: 0 for none.">
			<cfargument name="max_video_bitrate" type="numeric" required="no" default="0" 			hint="A maximum average bitrate for a movie. Overrides both the quality and video_bitrate settings to ensure that a bitrate doesn't exceed the provided number.">
			<cfargument name="audio_codec"		type="string" 	required="no" default=""	 		hint="The output audio codec to use.">
			<cfargument name="audio_quality"	type="numeric" 	required="no" default="3" 			hint="The desired output audio quality, from 1 to 5.">
			<cfargument name="audio_bitrate"	type="numeric" 	required="no" default="0" 			hint="An output bitrate setting, in Kbps. This should be a multiple of 16, and lower than 160kbps per channel (320kbps for stereo).">
			<cfargument name="audio_sample_rate" type="numeric" required="no" default="0" 			hint="Audio sample rate in Hz.  A valid sample rate. Depends on the codec; typically 8000, 11025, 12000, 16000, 22050, 32000, 44100, 48000">
			<cfargument name="max_frame_rate"	type="numeric" 	required="no" default="0" 			hint="Rather than setting an exact frame rate, which may involve increase the frame rate (and therefore the bitrate) of some content, you can set a Max Frame Rate instead.">
			<cfargument name="frame_rate"		type="numeric" 	required="no" default="0" 			hint="The output frame rate to use, as a decimal number (e.g. 15, or 24.98). 0 for system default.">
			<cfargument name="keyframe_interval" type="numeric" required="no" default="0" 			hint="Set the maximum number of frames between each keyframe. By default, a keyframe will be created at most every 250 frames. 0 to use default.">
			<cfargument name="keyframe_rate" 	type="numeric" 	required="no" default="0" 			hint="Set the number of keyframes per second. So a value of 0.5 would result in one keyframe every two seconds. A value of 3 would result in three keyframes per second.">
			<cfargument name="public" 			type="boolean" 	required="no" default="false"		hint="Use the public API setting to flag a file output to S3 as being publicly readable. This is done by granting the READ permission to the AllUsers group.">
			<cfargument name="notifications"	type="ZencoderNotification" required="no" default="#javaCast("null", 0)#" hint="This is the notification(s) to use for this output.">
			<cfargument name="thumbnails"		type="ZencoderThumbnails" 	required="no" default="#javaCast("null", 0)#" hint="This is the thumbnail(s) to use for this output.">
			<cfargument name="headers"			type="struct" 				required="no" default="#javaCast("null", 0)#" hint="S3 supports the sending of headers with your file when it is uploaded to S3. Zencoder support setting a limited subset of the S3 headers: Cache-Control, Content-Disposition, Content-Encoding, Content-Type, Expires, x-amz-acl, x-amz-storage-class, and x-amz-meta-*.">
		<cfscript>
			// set the data to the variables scope
			variables.base_url 			= arguments.base_url;
			variables.filename 			= arguments.filename;
			variables.label 			= arguments.label;
			variables.video_codec 		= arguments.video_codec;
			variables.device_profile    = arguments.device_profile;
			variables.speed 			= arguments.speed;
			variables.width 			= arguments.width;
			variables.height 			= arguments.height;
			variables.aspect_mode 		= arguments.aspect_mode;
			variables.quality 			= arguments.quality;
			variables.video_bitrate 	= arguments.video_bitrate;
			variables.bitrate_cap 		= arguments.bitrate_cap;
			variables.buffer_size 		= arguments.buffer_size;
			variables.max_video_bitrate	= arguments.max_video_bitrate;
			variables.audio_codec 		= arguments.audio_codec;
			variables.audio_quality 	= arguments.audio_quality;
			variables.audio_bitrate 	= arguments.audio_bitrate;
			variables.audio_sample_rate	= arguments.audio_sample_rate;
			variables.max_frame_rate 	= arguments.max_frame_rate;
			variables.frame_rate 		= arguments.frame_rate;
			variables.keyframe_interval = arguments.keyframe_interval;
			variables.keyframe_rate		= arguments.keyframe_rate;
			variables.public			= arguments.public;
			if (not isNull(arguments.notifications)) {
				variables.notifications 	= arguments.notifications;
			}
			if (not isNull(arguments.thumbnails)) {
				variables.thumbnails 	= arguments.thumbnails;
			}
			if (not isNull(arguments.headers)) {
				variables.headers 	= arguments.headers;
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getData --->
	<cffunction name="getData" access="public" returntype="struct" output="false" hint="This will build the data object that will be sent to Zencoder via the API.">
		<cfscript>
			var data = structNew();
			data.base_url 			= variables.base_url;
			data.filename 			= variables.filename;
			data.label 				= variables.label;
			if (len(trim(variables.video_codec)))	{data.video_codec 		= variables.video_codec;}
			if (len(trim(variables.device_profile)))		{data.device_profile 		= variables.device_profile;}
			data.speed 				= variables.speed;
			if (variables.width) 					{data.width 			= variables.width;}
			if (variables.height) 					{data.height 			= variables.height;}
			if (len(trim(variables.aspect_mode)))	{data.aspect_mode 		= variables.aspect_mode;}
			data.quality 			= variables.quality;
			if (variables.video_bitrate) 			{data.video_bitrate 	= variables.video_bitrate;}
			if (variables.bitrate_cap) 				{data.bitrate_cap 		= variables.bitrate_cap;}
			if (variables.buffer_size) 				{data.buffer_size	 	= variables.buffer_size;}
			if (variables.max_video_bitrate)		{data.max_video_bitrate	= variables.max_video_bitrate;}
			if (len(trim(variables.audio_codec)))		{data.audio_codec 		= variables.audio_codec;}
			if (variables.audio_bitrate) {
				data.audio_bitrate 		= variables.audio_bitrate;
			} else {
				data.audio_quality 		= variables.audio_quality;
			}
			if (variables.audio_sample_rate)	{data.audio_sample_rate	= variables.audio_sample_rate;}
			if (variables.max_frame_rate) 		{data.max_frame_rate 	= variables.max_frame_rate;}
			if (variables.frame_rate) 			{data.frame_rate 		= variables.frame_rate;}
			if (variables.keyframe_interval) 	{data.keyframe_interval	= variables.keyframe_interval;}
			if (variables.keyframe_rate) 		{data.keyframe_rate		= variables.keyframe_rate;}
			if (variables.public) 				{data.public			= variables.public;}
			if (not isNull(variables.notifications)) {
				data.notifications 	= variables.notifications.getData();
			}
			if (not isNull(variables.thumbnails)) {
				data.thumbnails 	= variables.thumbnails.getData();
			}
			if (not isNull(variables.headers)) {
				data.headers 	= variables.headers;
			}
			return data;
		</cfscript>
	</cffunction>
	
</cfcomponent>