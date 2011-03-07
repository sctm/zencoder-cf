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
 * This is the Zencoder output array container object.
 * @author Todd Schlomer
 */--->
<cfcomponent displayname="ZencoderOutputArray" hint="This is the Zencoder output array container object." output="false" accessors="true">
	
	<cfproperty name="outputArray" type="array" 	hint="This is the array of Zencoder outputs." />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="ZencoderOutputArray" output="false" hint="Constructor method.">
		<cfscript>
			variables.outputArray = arrayNew(1);
			return this;
		</cfscript>
	</cffunction>
	
	<!--- addOutput --->
	<cffunction name="addOutput" access="public" returntype="ZencoderOutputArray" output="false" hint="This will add a Zencoder job output to the array.">
			<cfargument name="output" type="ZencoderOutput" required="yes" hint="This is a Zencoder job output.">
		<cfscript>
			arrayAppend(variables.outputArray, arguments.output);
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getData --->
	<cffunction name="getData" access="public" returntype="array" output="false" hint="This will build the data object that will be sent to Zencoder via the API.">
		<cfscript>
			var data = arrayNew(1);
			var i = 1;
			for (; i <= arrayLen(variables.outputArray); i++) {
				arrayAppend(data, variables.outputArray[i].getData());
			}
			return data;
		</cfscript>
	</cffunction>
	
</cfcomponent>