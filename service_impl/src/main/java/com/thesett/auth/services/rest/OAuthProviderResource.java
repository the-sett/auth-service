/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.io.IOException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.client.Client;
import javax.ws.rs.core.Response;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.thesett.auth.services.config.ClientSecretsConfiguration;

/**
 * OAuthProviderResource provides a base class for implementing the interactions with OAuth providers.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Associate a user account with an OAuth provider with a local account.
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

    public static final ObjectMapper MAPPER = new ObjectMapper();

    /** Provides client secrets for interacting with OAuth providers. */
    protected final ClientSecretsConfiguration secrets;

    /** Provides an HTTP client for interacting with OAuth providers. */
    protected final Client client;

    /**
     * Builds the base resource for interacting with an OAuth provider.
     *
     * @param secrets The client secrets for interacting with OAuth providers.
     * @param client  An HTTP client for interacting with OAuth providers.
     */
    public OAuthProviderResource(ClientSecretsConfiguration secrets, Client client)
    {
        this.secrets = secrets;
        this.client = client;
    }

    public static Map<String, Object> getResponseEntity(Response response)
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

    protected Response processUser(HttpServletRequest request, Provider provider, String id, String displayName)
    {
        System.out.println("=========================");
        System.out.println("provider = " + provider);
        System.out.println("id = " + id);
        System.out.println("displayName = " + displayName);

        String token = "";

        return Response.ok().entity(token).build();
    }
}
