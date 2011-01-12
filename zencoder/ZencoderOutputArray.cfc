<!---/**********************************************
 * (C) Copyright 2010 SCTM Enterprises, LLC.
 * All Rights Reserved.
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
	<cffunction name="addOutput" access="public" returntype="void" output="false" hint="This will add a Zencoder job output to the array.">
			<cfargument name="output" type="ZencoderOutput" required="yes" hint="This is a Zencoder job output.">
		<cfscript>
			arrayAppend(variables.outputArray, arguments.output);
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