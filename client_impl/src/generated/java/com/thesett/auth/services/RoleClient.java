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

import com.thesett.auth.services.RoleService;
import com.thesett.auth.model.Role;

import java.util.List;

/**
 * Service interface for working with Role
 *
 * @author Generated Code    
 */
@Path("/api/role/")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public interface RoleClient extends RoleService {
    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")    
    JsonSchema schema();

    /** {@inheritDoc} */
    @GET
    List<Role> findAll();

    /** {@inheritDoc} */
    @POST
    @Path("/example")      
    List<Role> findByExample(Role example);

    /** {@inheritDoc} */
    @POST
    Role create(Role role) throws EntityException;

    /** {@inheritDoc} */
    @GET
    @Path("/{roleId}")
    Role retrieve(@PathParam("roleId") Long id);

    /** {@inheritDoc} */
    @PUT
    @Path("/roleId")
    Role update(@PathParam("roleId") Long id, Role role) throws EntityException;

    /** {@inheritDoc} */
    @DELETE
    void delete(@PathParam("roleId") Long id) throws EntityException;
}
