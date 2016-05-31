/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.io.IOException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.Response;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * OAuthProviderResource provides a base class for implementing the interactions with OAuth providers.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public abstract class OAuthProviderResource
{
    public static final String CLIENT_ID_KEY = "client_id";
    public static final String REDIRECT_URI_KEY = "redirect_uri";
    public static final String CLIENT_SECRET = "client_secret";
    public static final String CODE_KEY = "code";
    public static final String GRANT_TYPE_KEY = "grant_type";
    public static final String AUTH_CODE = "authorization_code";
    public static final String AUTH_HEADER_KEY = "Authorization";
    public static final String CONFLICT_MSG = "There is already a %s account that belongs to you";
    public static final String NOT_FOUND_MSG = "User not found";
    public static final String LOGING_ERROR_MSG = "Wrong email and/or password";
    public static final String UNLINK_ERROR_MSG = "Could not unlink %s account because it is your only sign-in method";

    public static final ObjectMapper MAPPER = new ObjectMapper();

    protected Response processUser(HttpServletRequest request, Provider provider, String id, String displayName)
    {
        System.out.println("=========================");
        System.out.println("provider = " + provider);
        System.out.println("id = " + id);
        System.out.println("displayName = " + displayName);

        String token = "";

        return Response.ok().entity(token).build();
    }

    protected Map<String, Object> getResponseEntity(Response response)
    {
        try
        {
            return MAPPER.readValue(response.readEntity(String.class), new TypeReference<Map<String, Object>>()
                {
                });
        }
        catch (IOException e)
        {
            throw new IllegalStateException(e);
        }
    }
}
