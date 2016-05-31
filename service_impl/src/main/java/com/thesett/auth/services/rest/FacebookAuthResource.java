/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.client.Client;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.thesett.auth.services.config.ClientSecretsConfiguration;

import io.dropwizard.hibernate.UnitOfWork;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */
@Path("/auth/")
public class FacebookAuthResource extends OAuthProviderResource
{
    private final ClientSecretsConfiguration secrets;

    private final Client client;

    public FacebookAuthResource(ClientSecretsConfiguration secrets, Client client)
    {
        this.secrets = secrets;
        this.client = client;
    }

    @POST
    @Path("facebook")
    @UnitOfWork
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(Payload payload, @Context HttpServletRequest request)
    {
        String accessTokenUrl = "https://graph.facebook.com/v2.3/oauth/access_token";
        String graphApiUrl = "https://graph.facebook.com/v2.3/me";

        Response response;

        // Exchange authorization code for access token.
        response =
            client.target(accessTokenUrl).queryParam(CLIENT_ID_KEY, payload.getClientId()).queryParam(REDIRECT_URI_KEY,
                payload.getRedirectUri()).queryParam(CLIENT_SECRET, secrets.getFacebook()).queryParam(CODE_KEY,
                payload.getCode()).request("text/plain").accept(MediaType.TEXT_PLAIN).get();

        Map<String, Object> responseEntity = getResponseEntity(response);

        // Extract information about the user.
        response =
            client.target(graphApiUrl).queryParam("access_token", responseEntity.get("access_token")).queryParam(
                "expires_in", responseEntity.get("expires_in")).request("text/plain").get();

        Map<String, Object> userInfo = getResponseEntity(response);

        // Process the authenticated user.
        return processUser(request, Provider.FACEBOOK, userInfo.get("id").toString(), userInfo.get("name").toString());
    }
}
