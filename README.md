# CFWheels Exception Render Plugin

This plugin adds a new method that can be used in `/events/onerror.cfm`, `/events/onmaintenance`,
and `/events/onmissingmethod.cfm` to reuse the CFWheels framework's controller system to render
exception pages.

The following public methods are included by this plugin:

-  `exceptionRender(route, controller, action, key, params)`
-  `sendExceptionEmail(exception)`

Call these methods as required from the files listed above to keep your error message code all
within the confines of the MVC structure defined by CFWheels.

This plugin has a couple of benefits which include:

-  Response codes 404 and 500 are preserved.
-  100% reuse of your existing layouts and templates. No need to duplicate your layouts in
   `onerror.cfm` and `onmissingtemplate.cfm`.
-  ColdFusion still catches errors that occur in `onError()` and `onMissingMethod()` so your
   application will never hang from errors created inside of the error trapping system.

If you have a non-trivial application, this can save you time because you will no longer need to
duplicate layouts, templates, etc.

## Examples

### Example 1: `events/onerror.cfm`

Most of the time in the error event, you'll want to send the exception email to yourself in addition
to showing your error template to the end user.

Note that exception details are passed to `events/onerror.cfm` via the `arguments` scope.

```coldfusion
<cfset sendExceptionEmail(arguments)>

<cfoutput>
#exceptionRender(controller="exceptions", action="yourExceptionAction")#
</cfoutput>
```

### Example 2: `events/onmaintenance.cfm` or `events/onmissingtemplate.cfm`

On missing template, you'll probably just want to show the error page without getting an error email
sent to yourself. This is entirely your choice though.

```coldfusion
<cfoutput>
#exceptionRender(controller="exceptions", action="yourExceptionAction")#
</cfoutput>
```

### Example 3: Advanced error responses in `events/onerror.cfm`

You can write whatever logic that your application requires in any of the templates. In this
example, the `onerror` event will respond to different exceptions thrown via your own calls to
`<cfthrow>` or `Throw()`.

```coldfusion
<cfscript>

// Examine exception type to trap custom exceptions
switch (arguments.exception.cause.type) {
  // set the proper header and render the notFound action
  case "MyCms.PageNotFound":
    $header(statusCode=404, statusText="Page Not Found");
    WriteOutput(exceptionRender(route="exceptions", action="notFound", exception=arguments));
    break;
  
  // show the content login page
  case "MyCms.LoginRequired":
    WriteOutput(exceptionRender(route="sessions", action="new", exception=arguments));
    break;

  // show the access denied page
  case "MyCms.AccessDenied":
    $header(statusCode=403, statusText="Access Denied");
    WriteOutput(exceptionRender(route="exceptions", action="accessDenied", exception=arguments));
    break;

  default:
    sendExceptionEmail(argumentCollection=arguments);
    WriteOutput(exceptionRender(route="exceptions", action="internalServerError", exception=arguments)); 
    break;
}

</cfscript>
```

Now your error script can react accordingly to a call similar to this in your controller, for
example:

```javascript
component extends="Controller" {
  function show() {
    page = model("page").findByUrl(cgi.PATH_INFO);

    if (!IsObject(page)) {
      Throw(
        type="MyCms.PageNotFound",
        message="The page you were looking for could not be found."
      );
    }
  }
}
```

## Uninstallation

To uninstall this plugin, simply delete the `/plugins/ExceptionRender-0.X.zip` file and reload your
application.

## Credits

This plugin was created by [James Gibson][1]. It is now maintained by [Chris Peters][2] with
support from [Liquifusion Studios][3].

## License

The MIT License (MIT)

Copyright (c) 2016 Liquifusion Studios


[1]: http://iamjamesgibson.com/
[2]: http://www.chrisdpeters.com/
[3]: http://www.liquifusion.com/
