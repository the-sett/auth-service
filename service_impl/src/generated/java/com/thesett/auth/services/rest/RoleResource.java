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

import com.thesett.auth.model.Role;
import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.services.RoleService;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponses;
import io.swagger.annotations.ApiResponse;

/**
 * REST API implementation for working with Role
 *
 * @author Generated Code
 */
@Path("/api/role/")
@Api(value = "/api/role/", description = "API implementation for working with Role")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class RoleResource implements RoleService {
    /** The DAO to use for persisting role. */
    private final RoleDAO roleDAO;

    /**
     * Creates the role RESTful service implementation.
     *
     * @param roleDAO The DAO to use for persisting role.
     */
    public RoleResource(RoleDAO roleDAO) {
        this.roleDAO = roleDAO;

        initHal();
    }

    /**
     * Configures HyperExpress to produce HAL for this service (experimental and not complete).
     */
    private void initHal() {
        HyperExpress.relationships()
            .forClass(RoleResource.class)
            .rel(SELF, "http://localhost:9070/api/role/hal");

        HyperExpress.relationships()
            .forClass(RoleResource.class)
            .rels("curies", "http://localhost:9070/api/role/{rel}")
            .name("role")
            .type("application/schema+json")
            .templated(true);

        HyperExpress.relationships()
            .forClass(RoleResource.class)
            .rel("role:schema", "http://localhost:9070/api/role/")
            .type("application/json");
    }

    /** {@inheritDoc} */    
    @GET
    @Path("/hal")
    @Produces("application/hal+json")
    @ApiOperation(value = "Provides a HAL description of the Role services.")
    public Resource root() {
        return HyperExpress.createResource(this, "application/hal+json");
    }        

    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")
    @ApiOperation(value = "Provides a json-schema describing Role.")
    public JsonSchema schema() {
        return JsonSchemaUtil.getJsonSchema(Role.class);
    }

    /** {@inheritDoc} */
    @GET
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Role items.")
    public List<Role> findAll() {
        return roleDAO.browse();
    }

    /** {@inheritDoc} */
    @POST
    @Path("/example")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Provides a list of all Role items that match the fields in the posted example.")        
    public List<Role> findByExample(Role example) {
        return roleDAO.findByExample(example);
    }

    /** {@inheritDoc} */
    @POST
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Creates a new Role.")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Success.", response = Role.class),        
        @ApiResponse(code = 422, message = "Invalid data supplied.")
    })
    @ApiImplicitParams({
        @ApiImplicitParam(name = "body", value = "The item to create.", required = true, dataType = "com.thesett.auth.model.Role", paramType = "body")
    })
    public Role create(Role role) throws EntityException {
        return roleDAO.create(role);
    }

    /** {@inheritDoc} */
    @GET
    @Path("/{roleId}")
    @Timed
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Retreives a Role by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message = "Success.", response = Role.class),        
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })        
    public Role retrieve(@ApiParam(value = "The id of the item to retrieve.", required = true) @PathParam("roleId") Long id) {
        return roleDAO.retrieve(id);
    }

    /** {@inheritDoc} */
    @PUT
    @UnitOfWorkWithDetach
    @Path("/{roleId}")
    @ApiOperation(value = "Replaces a Role with an updated version, match by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 422, message = "Invalid data supplied."),
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })        
    public Role update(@ApiParam(value = "The id of the item to update.", required = true) @PathParam("roleId") Long id, Role role) throws EntityException {
        return roleDAO.update(id, role);
    }

    /** {@inheritDoc} */
    @DELETE
    @UnitOfWorkWithDetach
    @Path("/{roleId}")
    @ApiOperation(value = "Deletes a Role by its id.")
    @ApiResponses(value = {
        @ApiResponse(code = 400, message = "No item found matching the supplied id.")
    })
    public void delete(@ApiParam(value = "The id of the item to delete.", required = true) @PathParam("roleId") Long id) throws EntityException {
        roleDAO.delete(id);
    }
}
