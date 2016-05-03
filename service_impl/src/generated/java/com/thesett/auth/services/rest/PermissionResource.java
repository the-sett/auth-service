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

import com.thesett.auth.model.Permission;
import com.thesett.auth.dao.PermissionDAO;
import com.thesett.auth.services.PermissionService;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponses;
import io.swagger.annotations.ApiResponse;

/**
 * REST API implementation for working with Permission
 *
 * @author Generated Code
 */
@Path("/api/permission/")
@Api(value = "/api/permission/", description = "API implementation for working with Permission")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class PermissionResource implements PermissionService {
    /** The DAO to use for persisting permission. */
    private final PermissionDAO permissionDAO;

    /**
     * Creates the permission RESTful service implementation.
     *
     * @param permissionDAO The DAO to use for persisting permission.
     */
    public PermissionResource(PermissionDAO permissionDAO) {
        this.permissionDAO = permissionDAO;

        initHal();
    }

    /**
     * Configures HyperExpress to produce HAL for this service (experimental and not complete).
     */
    private void initHal() {
        HyperExpress.relationships()
            .forClass(PermissionResource.class)
            .rel(SELF, "http://localhost:9070/api/permission/hal");

        HyperExpress.relationships()
            .forClass(PermissionResource.class)
            .rels("curies", "http://localhost:9070/api/permission/{rel}")
            .name("permission")
            .type("application/schema+json")
            .templated(true);

        HyperExpress.relationships()
            .forClass(PermissionResource.class)
            .rel("permission:schema", "http://localhost:9070/api/permission/")
            .type("application/json");
    }

    /** {@inheritDoc} */    
    @GET
    @Path("/hal")
    @Produces("application/hal+json")
    @ApiOperation(value = "Provides a HAL description of the Permission services.")
    public Resource root() {
        return HyperExpress.createResource(this, "application/hal+json");
    }        

    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")
    @ApiOperation(value = "Provides a json-schema describing Permission.")
    public JsonSchema schema() {
        return JsonSchemaUtil.getJsonSchema(Permission.class);
    }

    /** {@inheritDoc} */
    @GET
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Permission items.")
    public List<Permission> findAll() {
        return permissionDAO.browse();
    }

    /** {@inheritDoc} */
    @POST
    @Path("/example")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Permission items that match the fields in the posted example.")        
    public List<Permission> findByExample(Permission example) {
        return permissionDAO.findByExample(example);
    }

    /** {@inheritDoc} */
    @POST
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Creates a new Permission.")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Success.", response = Permission.class),        
        @ApiResponse(code = 422, message = "Invalid data supplied.")
    })
    @ApiImplicitParams({
        @ApiImplicitParam(name = "body", value = "The item to create.", required = true, dataType = "com.thesett.auth.model.Permission", paramType = "body")
    })
    public Permission create(Permission permission) throws EntityException {
        return permissionDAO.create(permission);
    }

    /** {@inheritDoc} */
    @GET
    @Path("/{permissionId}")
    @Timed
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Retreives a Permission by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Success.", response = Permission.class),        
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })        
    public Permission retrieve(@ApiParam(value = "The id of the item to retrieve.", required = true) @PathParam("permissionId") Long id) {
        return permissionDAO.retrieve(id);
    }

    /** {@inheritDoc} */
    @PUT
    @UnitOfWorkWithDetach
    @Path("/{permissionId}")
    @ApiOperation(value = "Replaces a Permission with an updated version, match by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 422, message = "Invalid data supplied."),
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })        
    public Permission update(@ApiParam(value = "The id of the item to update.", required = true) @PathParam("permissionId") Long id, Permission permission) throws EntityException {
        return permissionDAO.update(id, permission);
    }

    /** {@inheritDoc} */
    @DELETE
    @UnitOfWorkWithDetach
    @Path("/{permissionId}")
    @ApiOperation(value = "Deletes a Permission by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })
    public void delete(@ApiParam(value = "The id of the item to delete.", required = true) @PathParam("permissionId") Long id) throws EntityException {
        permissionDAO.delete(id);
    }
}
