/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.jtrial.web;

import com.thesett.util.views.handlebars.Layout;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public class TestView extends Layout
{
    public TestView()
    {
        super("/test.hbs", "/standard.hbs");
    }
}
