/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */

public enum Provider
{
    FACEBOOK("facebook"), GOOGLE("google"), LINKEDIN("linkedin"), GITHUB("github"), FOURSQUARE("foursquare"),
    TWITTER("twitter");

    String name;

    Provider(final String name)
    {
        this.name = name;
    }

    public String getName()
    {
        return this.name;
    }
}
