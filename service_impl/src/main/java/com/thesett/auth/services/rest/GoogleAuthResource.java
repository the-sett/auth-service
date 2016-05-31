/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedHashMap;
import javax.ws.rs.core.MultivaluedMap;
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
public class GoogleAuthResource extends OAuthProviderResource
{
    private ClientSecretsConfiguration secrets;

    private Client client;

    public GoogleAuthResource(ClientSecretsConfiguration secrets, Client client)
    {
        this.secrets = secrets;
        this.client = client;
    }

    @POST
    @Path("google")
    @UnitOfWork
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(Payload payload, @Context HttpServletRequest request)
    {
        String accessTokenUrl = "https://accounts.google.com/o/oauth2/token";
        String peopleApiUrl = "https://www.googleapis.com/plus/v1/people/me/openIdConnect";
        Response response;

        // Exchange authorization code for access token.
        MultivaluedMap<String, String> accessData = new MultivaluedHashMap<String, String>();
        accessData.add(CLIENT_ID_KEY, payload.getClientId());
        accessData.add(REDIRECT_URI_KEY, payload.getRedirectUri());
        accessData.add(CLIENT_SECRET, secrets.getGoogle());
        accessData.add(CODE_KEY, payload.getCode());
        accessData.add(GRANT_TYPE_KEY, AUTH_CODE);
        response = client.target(accessTokenUrl).request().post(Entity.form(accessData));
        accessData.clear();

        // Retrieve profile information about the current user.
        String accessToken = (String) getResponseEntity(response).get("access_token");
        response =
            client.target(peopleApiUrl).request("text/plain").header(AUTH_HEADER_KEY,
                String.format("Bearer %s", accessToken)).get();

        Map<String, Object> userInfo = getResponseEntity(response);

        // Process the authenticated the user.
        return processUser(request, Provider.GOOGLE, userInfo.get("sub").toString(), userInfo.get("name").toString());
    }
}
