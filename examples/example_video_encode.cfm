<!---/**********************************************
 * (C) Copyright 2011 Paragon Principles, LLC.
 * All Rights Reserved.
 **********************************************
 * Author:	Todd Schlomer
 * Date:	2011
 **********************************************/--->

<!--- buildMediaDetailsFromJobCreation --->
<cffunction name="buildMediaDetailsFromJobCreation" access="private" returntype="struct" output="false" hint="This is a helper method to build the media details from the job creation result.">
		<cfargument name="jobID" 	type="numeric" 	required="true" 	hint="This is the job ID from Zencoder to build the details for.">
		<cfargument name="outputs" 	type="array" 	required="true" 	hint="This is the outputs from Zencoder that were created">
	<cfscript>
		var i = 1;
		var mediaDetails 	= structNew();
		var jobDetails 		= structNew();
		
		// setup the job details
		jobDetails.id		 		= jobID;
		jobDetails.state 			= "processing";
		jobDetails.progress 		= 0;
		jobDetails.outputs 			= structNew();
		jobDetails.totalOutputs 	= arrayLen(outputs);
		jobDetails.outputsCompleted	= 0;
		jobDetails.outputsFailed	= 0;
		
		// loop to add all the outputs
		for (; i <= jobDetails.totalOutputs; i++) {
			var output = structNew();
			output.id		 	= outputs[i].id;
			output.label	 	= outputs[i].label;
			output.state 		= "processing";
			output.progress 	= 0;
			output.message 		= "";
			output.errorLink	= "";
			structInsert(jobDetails.outputs, numberFormat(output.id, "9"), output);
		}
		structInsert(mediaDetails, numberFormat(jobID, "9"), jobDetails);
		return mediaDetails;
	</cfscript>
</cffunction>

<cfscript>
	//=============================================================================================
	// setup initial settings for formats
	sourceFileURL 	= "s3://MY_S3_BUCKET_URL/source/";
	base_url 		= "s3://MY_S3_BUCKET_URL/video/";
	notifyUrl		= "http://URL_FOR_NOTIFICATIONS";		// this can be an email address as well
	fileKey			= "FILE_NAME_KEY";
	
	// video information
	width	= 640;
	height	= 360;
	
	// setup the Zencoder API reference
	zencoderApi = new zencoder.Zencoder(argumentCollection = {
			api_key 				= "MY_API_KEY_HERE",
			download_connections 	= 25,
			testMode				= true});
	
	// check for the video aspect ratio
	is_16x9_aspect = ((width / 16) == (height / 9));
	
	// set the keyframe rate
	keyframe_rate = 1;		// 1 keyframe every second
	
	// setup the zencoder notifications for the outputs
	zencoderNotification = new zencoder.ZencoderNotification();
	zencoderNotification.addNotification(notifyUrl);
	
	// setup the zencoder output array (this is where all the outputs will be placed)
	zencoderOutputArr = new zencoder.ZencoderOutputArray();
	
	// 240p
	zencoderOutputArr.addOutput(new zencoder.ZencoderOutput(
			base_url 			= base_url,
			filename 			= "240_" & fileKey & ".mp4",
			label 				= "240",
			video_codec			= "h264",
			speed				= 2,
			height				= (is_16x9_aspect ? 216 : 240),
			aspect_mode			= "preserve",
			quality				= 4,
			max_video_bitrate 	= 512,
			audio_codec			= "aac",
			audio_quality		= 3,
			max_frame_rate		= 30,
			keyframe_rate		= keyframe_rate,
			public				= true,
			notifications		= zencoderNotification,
			thumbnails			= new zencoder.ZencoderThumbnails().addThumbnail({
					label					= "main",
					base_url 				= base_url & "/thumbs/" & fileKey,
					prefix					= "main",
					number					= 1,
					start_at_first_frame	= 1,
					size					= "#width#x#height#",
					public					= 1
			}).addThumbnail({
					label					= "thumb",
					base_url 				= base_url & "/thumbs/" & fileKey,
					prefix					= "thumb",
					number					= 1,
					start_at_first_frame	= 1,
					size					= "#int((50 / height) * width)#x50",
					public					= 1
			})));
	
	// 360p
	zencoderOutputArr.addOutput(new zencoder.ZencoderOutput(
			base_url 			= base_url,
			filename 			= "360_" & fileKey & ".mp4",
			label 				= "360",
			video_codec			= "h264",
			speed				= 2,
			height				= 360,
			aspect_mode			= "preserve",
			quality				= 4,
			max_video_bitrate 	= 1000,
			audio_codec			= "aac",
			audio_quality		= 3,
			max_frame_rate		= 30,
			public				= true,
			keyframe_rate		= keyframe_rate,
			notifications		= zencoderNotification));
	
	// perform the API call
	zencoderResult = zencoderApi.createEncodingJob(
			input 	= sourceFileURL,
			output 	= zencoderOutputArr);
	
	if (zencoderResult.success) {
		writeOutput("ZENCODER CALL SUCCESSFUL<br />");
		writeOutput("JOB_ID: " & zencoderResult.jobID & "<br />");
		writeOutput("JOB DETAILS:<br />");
		writeDump(buildMediaDetailsFromJobCreation(jobID = zencoderResult.jobID, outputs = zencoderResult.outputs));
		
	} else {
		writeOutput("ZENCODER CALL FAILED<br />");
		writeOutput("MESSAGE: " & zencoderResult.message & "<br />");
	}
</cfscript>