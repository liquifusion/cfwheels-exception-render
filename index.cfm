<h1>Exception Render</h1>

<p>This plugin adds a new method that can be used in <tt>/events/onerror.cfm</tt>, <tt>/events/onmaintenance</tt>, and <tt>/events/onmissingmethod.cfm</tt> to reuse the Wheels framework to render exception pages.</p>

<p>The following public methods are included by this plugin:</p>
<ul>
	<li><tt>exceptionRender(route, controller, action, key, params)</tt></li>
	<li><tt>sendExceptionEmail(exception)</tt></li>
</ul> 

<p>Call these methods as required from the files listed above to keep your error message code all within the confines of the MVC structure defined by Wheels.</p>

<p>This plugin has a couple of benefits which include:</p>

<ul>
	<li>Response codes 404 and 500 are preserved.</li>
	<li>100% reuse of your existing layouts and templates. No need to duplicate your layouts in <tt>onerror.cfm</tt> and <tt>onmissingtemplate.cfm</tt>.</li>
	<li>ColdFusion still catches errors that occur in <tt>onError()</tt> and <tt>onMissingMethod()</tt> so you application will never hang from errors created inside of the error trapping system.</li>
</ul>

<p>If you have a complex application, this can save you time because you will no longer need to duplicate layouts, templates, etc.</p>

<h2>Examples</h2>

<h3>Example 1: <tt>events/onerror.cfm</tt></h3>
<p>Most of the time in the error event, you'll want to send the exception email to yourself in addition to showing your error template to the end user.</p>
<p>Note that exception details are passed to <tt>events/onerror.cfm</tt> via the <tt>arguments</tt> scope.</p>
<pre>
&lt;cfset sendExceptionEmail(arguments)&gt;
&lt;cfoutput&gt;
	#exceptionRender(controller=&quot;exceptions&quot;, action=&quot;yourExceptionAction&quot;)#
&lt;/cfoutput&gt;</pre>

<h3>Example 2: <tt>events/onmaintenance.cfm</tt> or <tt>events/onmissingtemplate.cfm</tt></h3>
<p>On missing template, you'll probably just want to show the error page without getting an error email sent to yourself. This is entirely your choice though.</p>
<pre>
&lt;cfoutput&gt;
	#exceptionRender(controller=&quot;exceptions&quot;, action=&quot;yourExceptionAction&quot;)#
&lt;/cfoutput&gt;</pre>

<h3>Example 3: Advanced error responses in <tt>events/onerror.cfm</tt></h3>
<p>You can write whatever logic that your application requires in any of the templates. In this example, the onerror event will respond to different exceptions thrown via your own calls to <tt>&lt;cfthrow&gt;</tt> or <tt>Throw()</tt>.</h3>
<pre>
&lt;cfscript&gt;
	// Examine exeption type to trap custom exceptions
	switch (arguments.exception.cause.type)
	{
		// set the proper header and render the notFound action
		case &quot;MyCms.PageNotFound&quot;:
			$header(statusCode=404, statusText=&quot;Page Not Found&quot;);
			WriteOutput(exceptionRender(route=&quot;exceptions&quot;, action=&quot;notFound&quot;, exception=arguments));
			break;
		
		// show the content login page
		case &quot;MyCms.LoginRequired&quot;:
			WriteOutput(exceptionRender(route=&quot;sessions&quot;, action=&quot;new&quot;, exception=arguments));
			break;

		// show the access denied page
		case &quot;MyCms.AccessDenied&quot;:
			$header(statusCode=403, statusText=&quot;Access Denied&quot;);
			WriteOutput(exceptionRender(route=&quot;exceptions&quot;, action=&quot;accessDenied&quot;, exception=arguments));
			break;

		default:
			sendExceptionEmail(argumentCollection=arguments);
			WriteOutput(exceptionRender(route=&quot;exceptions&quot;, action=&quot;internalServerError&quot;, exception=arguments)); 
			break;
	}
&lt;/cfscript&gt;</pre>
<p>Now your error script can react accordingly to a call similar to this in your controller, for example:</p>
<pre>
&lt;cfcomponent extends=&quot;Controller&quot;&gt;

	&lt;cffunction name=&quot;show&quot;&gt;
		&lt;cfscript&gt;
			page = model(&quot;page&quot;).findByUrl(cgi.path_info);

			if (!IsObject(page))
				Throw(type=&quot;MyCms.PageNotFound&quot;, message=&quot;The page you were looking for could not be found.&quot;);
		&lt;/cfscript&gt;
	&lt;/cffunction&gt;

&lt;/cfcomponent&gt;</pre>

<h2>Uninstallation</h2>
<p>To uninstall this plugin simply delete the <tt>/plugins/ExceptionRender-0.1.zip</tt> file.</p>

<h2>Credits</h2>
<p>This plugin was created by <a href="http://iamjamesgibson.com/">James Gibson</a>.</p>


<p><a href="<cfoutput>#cgi.http_referer#</cfoutput>">&laquo; Go Back</a></p>