/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.codahale.metrics.annotation.Timed;
import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.model.Account;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.AccountService;
import com.thesett.common.util.Pair;
import com.thesett.util.entity.EntityDeletionException;
import com.thesett.util.entity.EntityException;
import com.thesett.util.entity.EntityNotExistsException;
import com.thesett.util.entity.EntityValidationException;
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
public class AccountResource implements AccountService, Constants
{
    /** The DAO to use for persisting account. */
    private final AccountDAO accountDAO;

    /** The DAO to use for persisting roles. */
    private final RoleDAO roleDAO;

    /** The password hasher. */
    private final PasswordHasherSha256 passwordHasher = new PasswordHasherSha256(1000);

    /**
     * Creates the account RESTful service implementation.
     *
     * @param accountDAO The DAO to use for persisting account.
     * @param roleDAO    The DAO to use for persisting roles.
     */
    public AccountResource(AccountDAO accountDAO, RoleDAO roleDAO)
    {
        this.accountDAO = accountDAO;
        this.roleDAO = roleDAO;
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
        subject.checkPermission(AUTH_ADMIN);

        List<Account> results = accountDAO.browse();

        for (Account account : results)
        {
            account = accountDAO.detach(account);
            hidePassword(account);
        }

        return results;
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
        subject.checkPermission(AUTH_ADMIN);

        List<Account> results = accountDAO.findByExample(example);

        for (Account account : results)
        {
            account = accountDAO.detach(account);
            hidePassword(account);
        }

        return results;
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
        checkNotNull(account);

        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission(AUTH_ADMIN);

        // Ensure that at least one role is set on the account.
        checkAtLeastOneRole(account);

        // Find all of the roles requested, and set them on the account.
        attachRoles(account);

        // Ensure the password is hashed.
        hashPassword(account);

        // Ensure a UUID is set on the account.
        if (StringUtils.nullOrEmpty(account.getUuid()))
        {
            UUID uuid = UUID.randomUUID();
            account.setUuid(uuid.toString());
        }

        Account result = accountDAO.create(account);

        // Null out the password.
        result = accountDAO.detach(result);
        result = hidePassword(result);

        return result;
    }

    /** {@inheritDoc} */
    @GET
    @Path("/{accountId}")
    @Timed
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Retrieves a Account by its id.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = Account.class),
                @ApiResponse(code = 400, message = "No item found matching the supplied id.")
            }
    )
    public Account retrieve(
        @ApiParam(value = "The id of the item to retrieve.", required = true) @PathParam("accountId") Long id)
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission(AUTH_ADMIN);

        Account result = accountDAO.retrieve(id);

        // Null out the password.
        if (result != null)
        {
            result = accountDAO.detach(result);
            result = hidePassword(result);
        }

        return result;
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
        @ApiParam(value = "The id of the item to update.", required = true) @PathParam("accountId") Long id,
        Account account) throws EntityException
    {
        checkNotNull(account);

        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission(AUTH_ADMIN);

        // Obtain the account to modify and confirm it exists.
        Account accountToModify = accountDAO.retrieve(id);

        if (accountToModify == null)
        {
            throw new EntityNotExistsException();
        }

        // Copy across the password, if it is not set or ensure the password is hashed if a new
        // one is being set.
        if (StringUtils.nullOrEmpty(account.getPassword()))
        {
            account.setPassword(accountToModify.getPassword());
            account.setSalt(accountToModify.getSalt());
        }
        else
        {
            hashPassword(account);
        }

        // The username cannot be changed
        account.setUsername(accountToModify.getUsername());

        // The root status cannot be changed
        account.setRoot(accountToModify.getRoot());

        // Ensure that at least one role is set on the account.
        checkAtLeastOneRole(account);

        // Find all of the roles requested, and set them on the account.
        attachRoles(account);

        Account result = accountDAO.update(id, account);

        // Null out the password.
        result = accountDAO.detach(result);
        result = hidePassword(result);

        return result;
    }

    /** {@inheritDoc} */
    @DELETE
    @UnitOfWorkWithDetach
    @Path("/{accountId}")
    @ApiOperation(value = "Deletes a Account by its id.")
    @ApiResponses(value = { @ApiResponse(code = 400, message = "No item found matching the supplied id.") })
    public void delete(
        @ApiParam(value = "The id of the item to delete.", required = true) @PathParam("accountId") Long id)
        throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission(AUTH_ADMIN);

        // Obtain the account to modify and silently failt if there is no account to delete.
        Account accountToModify = accountDAO.retrieve(id);

        if (accountToModify == null)
        {
            return;
        }

        // Accounts with 'root' status cannot be deleted.
        if (accountToModify.getRoot())
        {
            throw new EntityDeletionException("Accounts with 'root' status cannot be deleted.");
        }

        accountDAO.delete(id);
    }

    protected <O> O checkNotNull(O object)
    {
        if (object == null)
        {
            throw new IllegalArgumentException();
        }

        return object;
    }

    /**
     * Attaches existing roles to an account, instead of propagating the roles supplied with an account for database
     * update. This allows an account to specify roles by reference, not value.
     *
     * @param account The account to attach roles on.
     */
    private void attachRoles(Account account) throws EntityValidationException
    {
        Set<Role> roles = new HashSet<>();

        if (account.getRoles() != null)
        {
            for (Role role : account.getRoles())
            {
                if (role == null)
                {
                    throw new EntityValidationException("Role set on an account must not be null.");
                }

                Long roleId = role.getId();

                if (roleId == null)
                {
                    throw new EntityValidationException("Role set on an account must have an id.");
                }

                Role retrievedRole = roleDAO.retrieve(roleId);

                if (retrievedRole == null)
                {
                    throw new EntityValidationException("Role set on an account must exist.");
                }

                roles.add(retrievedRole);
            }

            account.setRoles(roles);
        }
    }

    /**
     * Checks that at least one role is set on an account.
     *
     * @param  account The account to check.
     *
     * @throws EntityValidationException Iff less than one role is set on the account.
     */
    private void checkAtLeastOneRole(Account account) throws EntityValidationException
    {
        if ((account.getRoles() == null) || (account.getRoles().size() == 0))
        {
            throw new EntityValidationException("At least one role must be set on the account.");
        }
    }

    /**
     * Clears the password from an account. Accounts returned should not expose the password.
     *
     * @param  account The account to clean.
     *
     * @return The account with the password nulled out.
     */
    private Account hidePassword(Account account)
    {
        account.setPassword(null);
        account.setSalt(null);

        return account;
    }

    /**
     * Hashes the password on an account.
     *
     * @param  account The account to hash the password of.
     *
     * @return The account with its password hashed.
     */
    private Account hashPassword(Account account)
    {
        Pair<String, String> hashAndSalt = passwordHasher.hash(account.getPassword());
        account.setPassword(hashAndSalt.getFirst());
        account.setSalt(hashAndSalt.getSecond());

        return account;

    }
}
