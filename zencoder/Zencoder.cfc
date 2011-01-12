<!---/**********************************************
 * (C) Copyright 2010 SCTM Enterprises, LLC.
 * All Rights Reserved.
 **********************************************
 * Author:	Todd Schlomer
 * Date:	December 8, 2010
 **********************************************/

/**
 * This is the API for the Zencoder media encoding service (www.Zencoder.com).  See http://zencoder.com/docs/api/ for more information.
 * @author Todd Schlomer
 */--->
<cfcomponent displayname="Zencoder" extends="ZencoderHelpers" hint="This is the API for the Zencoder media encoding service (www.Zencoder.com)." output="false">
	<cfproperty name="api_key" 				type="string" 	hint="This is the API key provided by Zencoder." />
	<cfproperty name="api_base_url" 		type="string" 	hint="This is the API Base URL for the Zencoder API." />
	<cfproperty name="download_connections" type="numeric" 	hint="You can specify the number of connections to use to download a file. This may speed up download transfer times. Be aware that more connections can place a heavier load on the server. By default, Zencoder uses 5 connections. The maximum allowed is 25." />
	<cfproperty name="region" 				type="string" 	hint="You can specify a region of 'us', 'europe', or 'asia'." />
	<cfproperty name="testMode" 			type="boolean" 	hint="If true, test mode will be enabled for the API." />
	<!--- cURL properties --->
	<cfproperty name="curlPath" 			type="string"  	hint="This is the location for the cURL library." />
	<cfproperty name="curlAdditionalParms"	type="string"  	hint="This is the additional parameters for the cURL operation." />
	<cfproperty name="reverseJSONQuotes"	type="boolean" 	hint="If true, this will reverse the JSON quotes from double to single quotes.  This is required on Windows." />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="Zencoder" output="false">
			<cfargument name="api_key" 				type="string" 	required="yes" hint="This is the API key provided by Zencoder.">
			<cfargument name="api_base_url" 		type="string" 	required="no" default="https://app.zencoder.com/api"  hint="This is the API Base URL for the Zencoder API.">
			<cfargument name="download_connections" type="numeric" 	required="no" default="0" 		hint="If set to zero, it will use the Zencoder default of 5.  The maximum allowed is 25.">
			<cfargument name="region" 				type="string" 	required="no" default="us" 		hint="You can specify a region of 'us', 'europe', or 'asia'.">
			<cfargument name="testMode" 			type="boolean" 	required="no" default="false" 	hint="If true, test mode will be enabled for the API.">
			<!--- cURL parameters --->
			<cfargument name="curlPath"				type="string" 	required="no" default="/usr/bin/curl" hint="This is the location for the cURL library.">
			<cfargument name="curlAdditionalParms"	type="string" 	required="no" default="" 		hint="This is the additional parameters for the cURL operation.">
			<cfargument name="reverseJSONQuotes"	type="boolean" 	required="no" default="false"	hint="If true, this will reverse the JSON quotes from double to single quotes for cURL.  This is required on Windows.">
		<cfscript>
			// set the data to the variables scope
			variables.api_key 				= arguments.api_key;
			variables.api_base_url 			= arguments.api_base_url;
			variables.download_connections 	= arguments.download_connections;
			variables.region 				= arguments.region;
			variables.testMode			 	= arguments.testMode;
			variables.curlPath			 	= arguments.curlPath;
			variables.curlAdditionalParms 	= arguments.curlAdditionalParms;
			variables.reverseJSONQuotes 	= arguments.reverseJSONQuotes;
			
			// check parameters
			if (len(trim(variables.api_key)) == 0) {
				throw(type = "InvalidParameter", message = "The api_key parameter is not defined.");
			}
			if (len(trim(variables.api_base_url)) == 0) {
				throw(type = "InvalidParameter", message = "The api_base_url parameter is not defined.");
			}
			if ((variables.download_connections < 0) or (variables.download_connections > 25)) {
				throw(type = "InvalidParameter", message = "The download_connections parameter must be within [0,25].");
			}
			if (len(trim(variables.region)) == 0) {
				throw(type = "InvalidParameter", message = "The region parameter is not defined.");
			}
			if (len(trim(variables.curlPath)) == 0) {
				throw(type = "InvalidParameter", message = "The curlPath parameter is not defined.");
			}
			return this;
		</cfscript>
	</cffunction>
	
	<!--- createEncodingJob --->
	<cffunction name="createEncodingJob" access="public" returntype="struct" output="false" hint="This will create a transcoding job at Zencoder.">
			<cfargument name="input" 				type="string" 				required="yes" 	hint="This is the address of the media input (HTTP, HTTPS, FTP, or SFTP URL).">
			<cfargument name="output" 				type="ZencoderOutputArray" 	required="yes" 	hint="This is the array of job outputs.">
			<cfargument name="download_connections" type="numeric" 				required="no" 	default="0" 	hint="If set to zero, it will use the default value.">
		<cfscript>
			// use the default download connections if the given one isn't used
			if ((arguments.download_connections < 1) or (arguments.download_connections > 25)) {
				arguments.download_connections = variables.download_connections;
			}
			
			// build the input values
			var jobInput = structNew();
			jobInput.api_key				= variables.api_key;
			jobInput.region					= variables.region;
			jobInput.input 					= arguments.input;
			jobInput.download_connections 	= arguments.download_connections;
			jobInput.output 				= arguments.output.getData();
			if (variables.testMode) {
				jobInput.test 				= 1;
			}
			
			// perform the API call
			var result = performApiPost(
									apiMethodPath 	= "jobs",
									methodBody		= jobInput);
			result.outputs = arrayNew(1);
			if (result.success and isDefined("result.data.id")) {
				result.jobID = result.data.id;
				
				// build the output array to contain the outputID and label (don't include the URL incase there is sensitive information)
				if (isDefined("result.data.outputs") and isArray(result.data.outputs)) {
					var i = 1;
					for (; i <= arrayLen(result.data.outputs); i++) {
						arrayAppend(result.outputs, structNew());
						try {
							result.outputs[i].id 	= result.data.outputs[i].id;
							result.outputs[i].label = result.data.outputs[i].label;
						} catch (Any e) {
							result.message &= "; Output Build Error [" & i & "]: " & e.message;
							result.outputs[i].id 	= 0;
							result.outputs[i].label = "UNKNOWN";
						}
					}
				}
				
			} else {
				result.jobID = 0;
			}
			return result;
		</cfscript>
	</cffunction>
	
	<!--- getJobDetails --->
	<cffunction name="getJobDetails" access="public" returntype="struct" output="false" hint="This will get the details for a transcoding job at Zencoder.">
			<cfargument name="jobID" type="numeric" required="yes" hint="This is the job ID from Zencoder to get the details for.">
		<cfscript>
			// perform the API call
			var result = performApiGet(
									apiMethodPath 	= "jobs/" & jobID);
			return result;
		</cfscript>
	</cffunction>
	
	<!--- getJobProgress --->
	<cffunction name="getJobProgress" access="public" returntype="struct" output="false" hint="This will get the progress for a transcoding job at Zencoder.">
			<cfargument name="outputID" type="numeric" required="yes" hint="This is the job ID from Zencoder to get the details for.">
		<cfscript>
			// perform the API call
			var result = performApiGet(
									apiMethodPath 	= "outputs/" & outputID & "/progress");
			return result;
		</cfscript>
	</cffunction>
	
	<!--- performApiPost --->
	<cffunction name="performApiPost" access="public" returntype="struct" output="false" hint="This will create a transcoding job at Zencoder.">
			<cfargument name="apiMethodPath" 	type="string" 	required="yes" 	hint="This is the API method call URL path.  This value should not lead with a '/'.">
			<cfargument name="methodBody" 		type="struct" 	required="yes" 	hint="This is the API method body that will be sent as a object.">
		<cfscript>
			var result = structNew();
			result.path = "#variables.api_base_url#/#apiMethodPath#";
			
			// perform the HTTP call
			var curl = performCurlRequest(
								url = result.path, 
								data = jsonEncode(methodBody));
			structAppend(result, curl, true);
			return result;
		</cfscript>
	</cffunction>
	
	<!--- performApiGet --->
	<cffunction name="performApiGet" access="public" returntype="struct" output="false" hint="This will create a transcoding job at Zencoder.">
			<cfargument name="apiMethodPath" 	type="string" 	required="yes" 	hint="This is the API method call URL path.  This value should not lead with a '/'.">
		<cfscript>
			var result = structNew();
			result.path = "#variables.api_base_url#/#apiMethodPath#?api_key=#variables.api_key#";
			
			// perform the cURL call
			var curl = performCurlRequest(result.path);
			structAppend(result, curl, true);
			return result;
		</cfscript>
	</cffunction>
	
	<!--- performCurlRequest --->
	<cffunction name="performCurlRequest" access="private" returntype="struct" output="false" hint="This will perform the cURL HTTP request.">
			<cfargument name="url"			type="string" 	required="yes" 								hint="This is the URL to call.">
			<cfargument name="data" 		type="string" 	required="no"	default=""	 				hint="This is the data to send with the call.">
			<cfargument name="contentType" 	type="string" 	required="no"	default="application/json"	hint="This is the default content type for the HTTP request header.">
		<cfscript>
			var tick = getTickCount();
			var error = "";
			var output = "";
			var result = structNew();
			result.success 		= false;
			result.message 		= "";
			result.debug 		= "";
			result.data 		= structNew();
			result.runtime 		= 0;
			result.jsonString 	= "";
			result.statusLine 	= "";
			result.statusCode 	= 0;
			
			// build the curl arguments  (Example:  curl --data '{"api_key":"93h630j1dsyshjef620qlkavnmzui3", "input":"s3://bucket-name/file-name.avi"}' https://app.zencoder.com/api/jobs -H "Content-Type: application/json")
			result.args = "-i -H ""Content-Type: " & contentType & """";
			if (len(trim(data))) {
				if (variables.reverseJSONQuotes) {
					result.args &= " --data """ & replaceNoCase(data, """", "'", "all") & """";
				} else {
					result.args &= " --data '" & data & "'";
				}
			}
			if (len(trim(variables.curlAdditionalParms))) {
				result.args &= " " & variables.curlAdditionalParms;
			}
			result.args &= " " & url;
		</cfscript>
		<cfexecute name="#variables.curlPath#"
				arguments="#result.args#"
				timeout="20" 
				variable="output"
				errorvariable="error" />
		<cfscript>
			try {
				// parse the line numbers for the output to build the result
				var outputLines = REMatch("[^\n\r]{1,}", output);
				if (arrayLen(outputLines)) {
					result.statusLine = outputLines[1];
					try {
						result.statusCode = listGetAt(result.statusLine, 2, " ");
					} catch (Any e) {
						result.debug &= "Status Code Error: " & e.message & "; ";
					}
					result.jsonString = outputLines[arrayLen(outputLines)];
				}
				if (isJson(result.jsonString)) {
					result.data = jsonDecode(result.jsonString);
					result.success = true;
				} else {
					result.success 	= false;
					result.debug 	&= error;
					if (len(trim(output))) {
						result.message = "(" & output & ")";
					}
				}
			} catch (Any e) {
				result.success 	= false;
				result.message 	= "Error: " & e.message;
				result.debug 	&= error;
				if (len(trim(output))) {
					result.message &= " (" & output & ")";
				}
			}
			result.runtime = getTickCount() - tick;
			return result;
		</cfscript>
	</cffunction>
	
</cfcomponent>