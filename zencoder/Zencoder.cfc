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
	<cfproperty name="api_timeout" 			type="numeric" 	hint="This is the API timeout time in seconds." />
	<cfproperty name="testMode" 			type="boolean" 	hint="If true, test mode will be enabled for the API." />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="Zencoder" output="false">
			<cfargument name="api_key" 				type="string" 	required="yes" hint="This is the API key provided by Zencoder.">
			<cfargument name="api_base_url" 		type="string" 	required="no" default="https://app.zencoder.com/api"  hint="This is the API Base URL for the Zencoder API.">
			<cfargument name="download_connections" type="numeric" 	required="no" default="0" 		hint="If set to zero, it will use the Zencoder default of 5.  The maximum allowed is 25.">
			<cfargument name="region" 				type="string" 	required="no" default="us" 		hint="You can specify a region of 'us', 'europe', or 'asia'.">
			<cfargument name="api_timeout" 			type="numeric" 	required="no" default="10" 		hint="This is the API timeout time in seconds.">
			<cfargument name="testMode" 			type="boolean" 	required="no" default="false" 	hint="If true, test mode will be enabled for the API.">
		<cfscript>
			// set the data to the variables scope
			variables.api_key 				= arguments.api_key;
			variables.api_base_url 			= arguments.api_base_url;
			variables.download_connections 	= arguments.download_connections;
			variables.region 				= arguments.region;
			variables.api_timeout			= arguments.api_timeout;
			variables.testMode			 	= arguments.testMode;
			
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
			var result = performApiCall(
									apiMethodPath 	= "jobs",
									httpMethod		= "post",
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
			var result = performApiCall(
									apiMethodPath 	= "jobs/" & jobID);
			return result;
		</cfscript>
	</cffunction>
	
	<!--- getJobProgress --->
	<cffunction name="getJobProgress" access="public" returntype="struct" output="false" hint="This will get the progress for a transcoding job at Zencoder.">
			<cfargument name="outputID" type="numeric" required="yes" hint="This is the job ID from Zencoder to get the details for.">
		<cfscript>
			// perform the API call
			var result = performApiCall(
									apiMethodPath 	= "outputs/" & outputID & "/progress");
			return result;
		</cfscript>
	</cffunction>
	
	<!--- performApiCall --->
	<cffunction name="performApiCall" access="private" returntype="struct" output="false" hint="This will perform the API call to Zencoder.">
			<cfargument name="apiMethodPath" 	type="string" 	required="yes" 									hint="This is the API method call URL path.  This value should not lead with a '/'.">
			<cfargument name="httpMethod" 		type="string" 	required="no" 	default="get"					hint="This is the HTPT method that will be used to perform the API call.">
			<cfargument name="methodBody" 		type="struct" 	required="no" 	default="#javaCast("null", 0)#"	hint="This is the API method body that will be sent as a object.">
		<cfscript>
			var result = structNew();
			result.path = "#variables.api_base_url#/#apiMethodPath#";
		</cfscript>
		
		<!--- Remove the JsafeJCE security provider and add it back after done: http://forums.adobe.com/message/2312598, http://www.coldfusionjedi.com/index.cfm/2011/1/12/Diagnosing-a-CFHTTP-issue--peer-not-authenticated --->
		<cfset var providerMethods = CreateObject('java','java.security.Security') />
		<cfset var jSafeProvider = providerMethods.getProvider('JsafeJCE') />
		<cfset providerMethods.removeProvider('JsafeJCE') />
		
		<!--- perform the API call --->
		<cftry>
			<cfhttp url="#variables.api_base_url#/#apiMethodPath#" timeout="#variables.api_timeout#" method="#httpMethod#">
				<cfhttpparam type="header" name="Content-Type" 	value="application/json" />
				<cfhttpparam type="header" name="Accept" 		value="application/json" />
				<cfif not isNull(methodBody)>
					<cfhttpparam type="Body" value="#jsonEncode(methodBody)#" />
				</cfif>
			</cfhttp>
		<cffinally>
			<!--- reinsert the jSafeProvider type --->
			<cftry>
				<cfset providerMethods.insertProviderAt(jSafeProvider, 1) />
			<cfcatch type="any">
			</cfcatch>
			</cftry>
		</cffinally>
		</cftry>
		<cfscript>
			if ((cfhttp.Responseheader.Status_Code == 201) or (cfhttp.Responseheader.Status_Code == 200)) {
				result.data = jsonDecode(cfhttp.FileContent);
				result.success = true;
			} else {
				result.success = false;
				result.statusCode = cfhttp.statusCode;
				result.message = cfhttp.FileContent;
				result.cfhttp = cfhttp;
				if (not isNull(methodBody)) {
					result.body = jsonEncode(methodBody);
				}
			}
			return result;
		</cfscript>
	</cffunction>
	
</cfcomponent>