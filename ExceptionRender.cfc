<cfcomponent output="false">

	<cffunction name="init" output="false" access="public" returntype="any">
		<cfset this.version = "1.0,1.1" />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="internalRedirect" output="false" access="public" returntype="string" mixin="application,controller,dispatch">
		<cfreturn exceptionRender(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="exceptionRender" output="false" access="public" returntype="string" mixin="application,dispatch,controller">
		<cfargument name="route" type="string" required="false" default="" hint="See documentation for @URLFor" />
		<cfargument name="controller" type="string" required="false" default="" hint="See documentation for @URLFor" />
		<cfargument name="action" type="string" required="false" default="" hint="See documentation for @URLFor" />
		<cfargument name="key" type="any" required="false" default="" hint="See documentation for @URLFor" />
		<cfargument name="params" type="string" required="false" default="" hint="See documentation for @URLFor" />
		<cfscript>
			var loc = {};
			
			// make sure we are only passing simple values to URLFor()
			loc.urlArgs = Duplicate(arguments);
			for (loc.item in loc.urlArgs)
				if (!IsSimpleValue(loc.urlArgs[loc.item]))
					StructDelete(loc.urlArgs, loc.item, false);
				
			loc.url = ReplaceList(URLFor(argumentCollection=loc.urlArgs), "/index.cfm,/rewrite.cfm", "");
			
			if (!StructKeyExists(request, "wheels") || !StructKeyExists(request.wheels, "params"))
				request.wheels.params = {};
			
			request.exceptionRender = Duplicate(request.wheels.params);
			request.cgi.path_info = loc.url;
			loc.structDeleteItems = { action="action", controller="controller", route="route", format="format" };
			
			for (loc.item in loc.structDeleteItems)
			{
				StructDelete(url, loc.structDeleteItems[loc.item], false);
				StructDelete(form, loc.structDeleteItems[loc.item], false);
			}
		</cfscript>
		<cfreturn application.wheels.dispatch.$request() />
	</cffunction>
	
	<cffunction name="sendExceptionEmail" returntype="void" access="public" output="false" mixin="application,dispatch">
		<cfargument name="exception" type="any" required="true">
		<cfscript>	
			var loc = {};
					
			if (application.wheels.sendEmailOnError)
			{
				loc.mailArgs = {};
				$args(name="sendEmail", args=arguments);
				if (StructKeyExists(application.wheels, "errorEmailServer") && Len(application.wheels.errorEmailServer))
					loc.mailArgs.server = application.wheels.errorEmailServer;
				loc.mailArgs.from = application.wheels.errorEmailAddress;
				loc.mailArgs.to = application.wheels.errorEmailAddress;
				loc.mailArgs.subject = application.wheels.errorEmailSubject;
				loc.mailArgs.type = "html";
				loc.mailArgs.tagContent = $includeAndReturnOutput($template="wheels/events/onerror/cfmlerror.cfm", exception=arguments.exception);
				StructDelete(loc.mailArgs, "layouts", false);
				StructDelete(loc.mailArgs, "detectMultiPart", false);
				$mail(argumentCollection=loc.mailArgs);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="$runOnError" returntype="string" access="public" output="false" mixin="application,dispatch">
		<cfargument name="exception" type="any" required="true">
		<cfargument name="eventName" type="any" required="true">
		<cfscript>
			var loc = {};
	
			if (StructKeyExists(application, "wheels") && StructKeyExists(application.wheels, "initialized"))
			{
				if (application.wheels.showErrorInformation)
				{
					if (StructKeyExists(arguments.exception, "rootCause") && Left(arguments.exception.rootCause.type, 6) == "Wheels")
						loc.wheelsError = arguments.exception.rootCause;
					else if (StructKeyExists(arguments.exception, "cause") && StructKeyExists(arguments.exception.cause, "rootCause") && Left(arguments.exception.cause.rootCause.type, 6) == "Wheels") 
						loc.wheelsError = arguments.exception.cause.rootCause;
					if (StructKeyExists(loc, "wheelsError"))
					{
						loc.returnValue = $includeAndReturnOutput($template="wheels/styles/header.cfm");
						loc.returnValue = loc.returnValue & $includeAndReturnOutput($template="wheels/events/onerror/wheelserror.cfm", wheelsError=loc.wheelsError);
						loc.returnValue = loc.returnValue & $includeAndReturnOutput($template="wheels/styles/footer.cfm");
					}
					else
					{
						$throw(object=arguments.exception);
					}
				}
				else
				{
					loc.returnValue = $includeAndReturnOutput($template="#application.wheels.eventPath#/onerror.cfm", exception=arguments.exception, eventName=arguments.eventName);
				}
			}
			else
			{
				$throw(object=arguments.exception);
			}
		</cfscript>
		<cfreturn loc.returnValue>
	</cffunction>

</cfcomponent>