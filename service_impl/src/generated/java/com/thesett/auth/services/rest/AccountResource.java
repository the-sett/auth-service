/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.codahale.metrics.annotation.Timed;
import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.model.Account;
import com.thesett.auth.services.AccountService;
import com.thesett.util.entity.EntityException;
import com.thesett.util.entity.EntityNotExistsException;
import com.thesett.util.jersey.UnitOfWorkWithDetach;
import com.thesett.util.string.StringUtils;
import com.thesett.util.validation.core.JsonSchemaUtil;
import com.thesett.util.validation.model.JsonSchema;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;

/**
 * REST API implementation for working with Account
 *
 * @author Generated Code
 */
@Path("/api/account/")
@Api(value = "/api/account/", description = "API implementation for working with Account")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class AccountResource implements AccountService
{
    /** The DAO to use for persisting account. */
    private final AccountDAO accountDAO;

    /**
     * Creates the account RESTful service implementation.
     *
     * @param accountDAO The DAO to use for persisting account.
     */
    public AccountResource(AccountDAO accountDAO)
    {
        this.accountDAO = accountDAO;
    }

    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")
    @ApiOperation(value = "Provides a json-schema describing Account.")
    public JsonSchema schema()
    {
        return JsonSchemaUtil.getJsonSchema(Account.class);
    }

    /** {@inheritDoc} */
    @GET
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Account items.")
    public List<Account> findAll()
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("admin");

        return accountDAO.browse();
    }

    /** {@inheritDoc} */
    @POST
    @Path("/example")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Account items that match the fields in the posted example.")
    public List<Account> findByExample(Account example)
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("admin");

        return accountDAO.findByExample(example);
    }

    /** {@inheritDoc} */
    @POST
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Creates a new Account.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = Account.class),
                @ApiResponse(code = 422, message = "Invalid data supplied.")
            }
    )
    @ApiImplicitParams(
        {
            @ApiImplicitParam(
                name = "body", value = "The item to create.", required = true,
                dataType = "com.thesett.auth.model.Account", paramType = "body"
            )
        }
    )
    public Account create(Account account) throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("admin");

        return accountDAO.create(account);
    }

    /** {@inheritDoc} */
    @GET
    @Path("/{accountId}")
    @Timed
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Retreives a Account by its id.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = Account.class),
                @ApiResponse(code = 400, message = "No item found matching the supplied id.")
            }
    )
    public Account retrieve(
        @ApiParam(value = "The id of the item to retrieve.", required = true)
        @PathParam("accountId")
        Long id)
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("admin");

        return accountDAO.retrieve(id);
    }

    /** {@inheritDoc} */
    @POST
    @UnitOfWorkWithDetach
    @Path("/{accountId}")
    @ApiOperation(value = "Replaces a Account with an updated version, match by its id.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 422, message = "Invalid data supplied."),
                @ApiResponse(code = 400, message = "No item found matching the supplied id.")
            }
    )
    public Account update(
        @ApiParam(value = "The id of the item to update.", required = true)
        @PathParam("accountId")
        Long id, Account account) throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("admin");

        // Obtain the account to modify and confirm it exists.
        Account accountToModify = accountDAO.retrieve(id);

        if (accountToModify==null) {
            throw new EntityNotExistsException();
        }

        // Copy across the password, if it is not set.
        if (StringUtils.nullOrEmpty(account.getPassword()))
        {
            account.setPassword(accountToModify.getPassword());
        }

        // The username cannot be changed
        account.setUsername(accountToModify.getUsername());

        return accountDAO.update(id, account);
    }

    /** {@inheritDoc} */
    @DELETE
    @UnitOfWorkWithDetach
    @Path("/{accountId}")
    @ApiOperation(value = "Deletes a Account by its id.")
    @ApiResponses(value = { @ApiResponse(code = 400, message = "No item found matching the supplied id.") })
    public void delete(
        @ApiParam(value = "The id of the item to delete.", required = true)
        @PathParam("accountId")
        Long id) throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("admin");

        accountDAO.delete(id);
    }
}
