/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.jtrial.web;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.thesett.auth.services.ServiceFactory;

import io.dropwizard.hibernate.UnitOfWork;
import io.dropwizard.views.View;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
 * </table></pre>
 *
 * @author Rupert Smith
 */
@Path("/")
@Produces(MediaType.TEXT_HTML)
public class WebResource
{
    private ObjectMapper mapper;

    /** The service factory. */
    private final ServiceFactory serviceFactory;

    /**
     * Creates the web UI resource.
     *
     * @param serviceFactory The service factory.
     */
    public WebResource(ServiceFactory serviceFactory)
    {
        this.serviceFactory = serviceFactory;
    }

    /**
     * Provides the auth service application.
     *
     * @return The auth service application.
     */
    @GET
    @UnitOfWork
    @Path("auth-service")
    public View getApplication()
    {
        return new AppAngularView();
    }
}
