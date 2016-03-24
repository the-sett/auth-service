package com.thesett.auth.services;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.thesett.util.entity.EntityException;
import com.thesett.util.validation.model.JsonSchema;

import com.thesett.auth.services.AccountService;
import com.thesett.auth.model.Account;

import java.util.List;

/**
 * Service interface for working with Account
 *
 * @author Generated Code    
 */
@Path("/api/account/")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public interface AccountClient extends AccountService {
    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")    
    JsonSchema schema();

    /** {@inheritDoc} */
    @GET
    List<Account> findAll();

    /** {@inheritDoc} */
    @POST
    @Path("/example")      
    List<Account> findByExample(Account example);

    /** {@inheritDoc} */
    @POST
    Account create(Account account) throws EntityException;

    /** {@inheritDoc} */
    @GET
    @Path("/{accountId}")
    Account retrieve(@PathParam("accountId") Long id);

    /** {@inheritDoc} */
    @PUT
    @Path("/accountId")
    Account update(@PathParam("accountId") Long id, Account account) throws EntityException;

    /** {@inheritDoc} */
    @DELETE
    void delete(@PathParam("accountId") Long id) throws EntityException;
}
