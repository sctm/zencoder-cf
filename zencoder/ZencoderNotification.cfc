<!---/**********************************************
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