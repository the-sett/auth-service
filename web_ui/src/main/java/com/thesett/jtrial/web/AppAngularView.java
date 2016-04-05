/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.jtrial.web;

import com.thesett.util.views.handlebars.Layout;

/**
 * AppAngularView provides a standard template for an angular application.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Provide the angular app name. </td></tr>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public class AppAngularView extends Layout
{
    private String appName;

    public AppAngularView()
    {
        super("/app-angular.hbs", "/angular.hbs");
        appName = "authService";
    }

    public String getAppName()
    {
        return appName;
    }
}
