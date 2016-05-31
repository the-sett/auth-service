/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import com.thesett.auth.services.config.ClientSecretsConfiguration;
import io.dropwizard.hibernate.UnitOfWork;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.client.Client;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Map;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public class GoogleAuthResource extends OAuthProviderResource
{
    private final ClientSecretsConfiguration secrets;

    private final Client client;

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
        return null;
    }
}
