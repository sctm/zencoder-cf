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
 * Date:	March 6, 2011
 **********************************************/

/**
 * This is the Zencoder thumbnails component for the output object.
 * @author Todd Schlomer
 */--->
<cfcomponent displayname="ZencoderThumbnails" hint="This is the Zencoder thumbnails object" output="false" accessors="true">
	
	<cfproperty name="thumbnailArray" type="array" 	hint="This is the array of thumbnails." />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="ZencoderThumbnails" output="false" hint="Constructor method.">
		<cfscript>
			variables.thumbnailArray = arrayNew(1);
			return this;
		</cfscript>
	</cffunction>
	
	<!--- addThumbnail --->
	<cffunction name="addThumbnail" access="public" returntype="ZencoderThumbnails" output="false" hint="This will add a thumbnail to the array.">
			<cfargument name="thumbnail" type="struct" required="yes" hint="This is a thumbnail object.  The definition can be obtained from the Zencoder API.">
		<cfscript>
			arrayAppend(variables.thumbnailArray, arguments.thumbnail);
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getData --->
	<cffunction name="getData" access="public" returntype="array" output="false" hint="This will build the data object that will be sent to Zencoder via the API.">
		<cfscript>
			var data = arrayNew(1);
			var i = 1;
			for (; i <= arrayLen(variables.thumbnailArray); i++) {
				arrayAppend(data, variables.thumbnailArray[i]);
			}
			return data;
		</cfscript>
	</cffunction>
	
</cfcomponent>