package com.thesett.auth.services.rest;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.List;

import com.codahale.metrics.annotation.Timed;
import com.strategicgains.hyperexpress.HyperExpress;
import static com.strategicgains.hyperexpress.RelTypes.SELF;
import com.strategicgains.hyperexpress.domain.Resource;

import com.thesett.util.entity.EntityException;
import com.thesett.util.jersey.UnitOfWorkWithDetach;
import com.thesett.util.validation.core.JsonSchemaUtil;
import com.thesett.util.validation.model.JsonSchema;

import com.thesett.auth.model.Account;
import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.services.AccountService;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponses;
import io.swagger.annotations.ApiResponse;

/**
 * REST API implementation for working with Account
 *
 * @author Generated Code
 */
@Path("/api/account/")
@Api(value = "/api/account/", description = "API implementation for working with Account")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class AccountResource implements AccountService {
    /** The DAO to use for persisting account. */
    private final AccountDAO accountDAO;

    /** Defines the name of the entity this service works with. */
    private static final String ENTITY_NAME = "account";

    /**
     * Creates the account RESTful service implementation.
     *
     * @param accountDAO The DAO to use for persisting account.
     */
    public AccountResource(AccountDAO accountDAO) {
        this.accountDAO = accountDAO;

        initHal();
    }

    /**
     * Configures HyperExpress to produce HAL for this service (experimental and not complete).
     */
    private void initHal() {
        HyperExpress.relationships()
            .forClass(AccountResource.class)
            .rel(SELF, "http://localhost:9070/api/account/hal");

        HyperExpress.relationships()
            .forClass(AccountResource.class)
            .rels("curies", "http://localhost:9070/api/account/{rel}")
            .name("account")
            .type("application/schema+json")
            .templated(true);

        HyperExpress.relationships()
            .forClass(AccountResource.class)
            .rel("account:schema", "http://localhost:9070/api/account/")
            .type("application/json");
    }

    /** {@inheritDoc} */    
    @GET
    @Path("/hal")
    @Produces("application/hal+json")
    @ApiOperation(value = "Provides a HAL description of the Account services.")
    public Resource root() {
        return HyperExpress.createResource(this, "application/hal+json");
    }        

    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")
    @ApiOperation(value = "Provides a json-schema describing Account.")
    public JsonSchema schema() {
        return JsonSchemaUtil.getJsonSchema(Account.class);
    }

    /** {@inheritDoc} */
    @GET
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Account items.")
    public List<Account> findAll() {
        return accountDAO.browse(ENTITY_NAME);
    }

    /** {@inheritDoc} */
    @POST
    @Path("/example")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Account items that match the fields in the posted example.")        
    public List<Account> findByExample(Account example) {
        return accountDAO.findByExample(example, ENTITY_NAME);
    }

    /** {@inheritDoc} */
    @POST
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Creates a new Account.")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Success.", response = Account.class),        
        @ApiResponse(code = 422, message = "Invalid data supplied.")
    })
    @ApiImplicitParams({
        @ApiImplicitParam(name = "body", value = "The item to create.", required = true, dataType = "com.thesett.auth.model.Account", paramType = "body")
    })
    public Account create(Account account) throws EntityException {
        return accountDAO.create(account);
    }

    /** {@inheritDoc} */
    @GET
    @Path("/{accountId}")
    @Timed
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Retreives a Account by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Success.", response = Account.class),        
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })        
    public Account retrieve(@ApiParam(value = "The id of the item to retrieve.", required = true) @PathParam("accountId") Long id) {
        return accountDAO.retrieve(id);
    }

    /** {@inheritDoc} */
    @PUT
    @UnitOfWorkWithDetach
    @Path("/{accountId}")
    @ApiOperation(value = "Replaces a Account with an updated version, match by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 422, message = "Invalid data supplied."),
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })        
    public Account update(@ApiParam(value = "The id of the item to update.", required = true) @PathParam("accountId") Long id, Account account) throws EntityException {
        return accountDAO.update(id, account);
    }

    /** {@inheritDoc} */
    @DELETE
    @UnitOfWorkWithDetach
    @Path("/{accountId}")
    @ApiOperation(value = "Deletes a Account by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })
    public void delete(@ApiParam(value = "The id of the item to delete.", required = true) @PathParam("accountId") Long id) throws EntityException {
        accountDAO.delete(id);
    }
}
