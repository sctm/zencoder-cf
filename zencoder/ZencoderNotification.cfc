<!---/**********************************************
 * (C) Copyright 2010 SCTM Enterprises, LLC.
 * All Rights Reserved.
 **********************************************
 * Author:	Todd Schlomer
 * Date:	December 8, 2010
 **********************************************/

/**
 * This is the Zencoder notification object
 * @author Todd Schlomer
 */--->
<cfcomponent displayname="ZencoderNotification" hint="This is the Zencoder notification object" output="false" accessors="true">
	
	<cfproperty name="notificationArray" type="array" 	hint="This is the array of notification strings." />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="ZencoderNotification" output="false" hint="Constructor method.">
		<cfscript>
			variables.notificationArray = arrayNew(1);
			return this;
		</cfscript>
	</cffunction>
	
	<!--- addNotification --->
	<cffunction name="addNotification" access="public" returntype="void" output="false" hint="This will add a notification to the array.">
			<cfargument name="notification" type="string" required="yes" hint="This is a notification.  This can be an email or a http URL.">
		<cfscript>
			arrayAppend(variables.notificationArray, arguments.notification);
		</cfscript>
	</cffunction>
	
	<!--- getData --->
	<cffunction name="getData" access="public" returntype="array" output="false" hint="This will build the data object that will be sent to Zencoder via the API.">
		<cfscript>
			var data = arrayNew(1);
			var i = 1;
			for (; i <= arrayLen(variables.notificationArray); i++) {
				if (compareNoCase("http", left(trim(variables.notificationArray[i]), 4)) == 0) {
					arrayAppend(data, {
						format 	= "json",
						url 	= trim(variables.notificationArray[i])
					});
				} else {
					arrayAppend(data, trim(variables.notificationArray[i]));
				}
			}
			return data;
		</cfscript>
	</cffunction>
	
</cfcomponent>