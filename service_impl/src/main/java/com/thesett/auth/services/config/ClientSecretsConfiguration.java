/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.config;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public class ClientSecretsConfiguration
{
    @JsonProperty
    String facebook;

    @JsonProperty
    String google;

    public String getFacebook()
    {
        return facebook;
    }

    public String getGoogle()
    {
        return google;
    }
}
