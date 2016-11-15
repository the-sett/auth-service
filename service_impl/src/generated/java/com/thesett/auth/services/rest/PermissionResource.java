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
import com.thesett.auth.dao.PermissionDAO;
import com.thesett.auth.model.Permission;
import com.thesett.auth.services.PermissionService;
import com.thesett.util.entity.EntityException;
import com.thesett.util.jersey.UnitOfWorkWithDetach;
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
 * REST API implementation for working with Permission
 *
 * @author Generated Code
 */
@Path("/api/permission/")
@Api(value = "/api/permission/", description = "API implementation for working with Permission")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class PermissionResource implements PermissionService, Constants
{
    /** The DAO to use for persisting permission. */
    private final PermissionDAO permissionDAO;

    /**
     * Creates the permission RESTful service implementation.
     *
     * @param permissionDAO The DAO to use for persisting permission.
     */
    public PermissionResource(PermissionDAO permissionDAO)
    {
        this.permissionDAO = permissionDAO;
    }

    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")
    @ApiOperation(value = "Provides a json-schema describing Permission.")
    public JsonSchema schema()
    {
        return JsonSchemaUtil.getJsonSchema(Permission.class);
    }

    /** {@inheritDoc} */
    @GET
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Permission items.")
    public List<Permission> findAll()
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission(AUTH_ADMIN);

        return permissionDAO.browse();
    }

    /** {@inheritDoc} */
    @POST
    @Path("/example")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Permission items that match the fields in the posted example.")
    public List<Permission> findByExample(Permission example)
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("auth-admin");

        return permissionDAO.findByExample(example);
    }

    /** {@inheritDoc} */
    @POST
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Creates a new Permission.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = Permission.class),
                @ApiResponse(code = 422, message = "Invalid data supplied.")
            }
    )
    @ApiImplicitParams(
        {
            @ApiImplicitParam(
                name = "body", value = "The item to create.", required = true,
                dataType = "com.thesett.auth.model.Permission", paramType = "body"
            )
        }
    )
    public Permission create(Permission permission) throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("auth-admin");

        return permissionDAO.create(permission);
    }

    /** {@inheritDoc} */
    @GET
    @Path("/{permissionId}")
    @Timed
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Retreives a Permission by its id.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = Permission.class),
                @ApiResponse(code = 400, message = "No item found matching the supplied id.")
            }
    )
    public Permission retrieve(
        @ApiParam(value = "The id of the item to retrieve.", required = true) @PathParam("permissionId") Long id)
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("auth-admin");

        return permissionDAO.retrieve(id);
    }

    /** {@inheritDoc} */
    @PUT
    @UnitOfWorkWithDetach
    @Path("/{permissionId}")
    @ApiOperation(value = "Replaces a Permission with an updated version, match by its id.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 422, message = "Invalid data supplied."),
                @ApiResponse(code = 400, message = "No item found matching the supplied id.")
            }
    )
    public Permission update(
        @ApiParam(value = "The id of the item to update.", required = true) @PathParam("permissionId") Long id,
        Permission permission) throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("auth-admin");

        return permissionDAO.update(id, permission);
    }

    /** {@inheritDoc} */
    @DELETE
    @UnitOfWorkWithDetach
    @Path("/{permissionId}")
    @ApiOperation(value = "Deletes a Permission by its id.")
    @ApiResponses(value = { @ApiResponse(code = 400, message = "No item found matching the supplied id.") })
    public void delete(
        @ApiParam(value = "The id of the item to delete.", required = true) @PathParam("permissionId") Long id)
        throws EntityException
    {
        // Check that the caller has permission to do this.
        Subject subject = SecurityUtils.getSubject();
        subject.checkPermission("auth-admin");

        permissionDAO.delete(id);
    }
}
