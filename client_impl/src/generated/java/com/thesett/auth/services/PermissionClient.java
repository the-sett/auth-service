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

import com.thesett.auth.services.PermissionService;
import com.thesett.auth.model.Permission;

import java.util.List;

/**
 * Service interface for working with Permission
 *
 * @author Generated Code    
 */
@Path("/api/permission/")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public interface PermissionClient extends PermissionService {
    /** {@inheritDoc} */
    @GET
    @Path("/schema")
    @Produces("application/schema+json")    
    JsonSchema schema();

    /** {@inheritDoc} */
    @GET
    List<Permission> findAll();

    /** {@inheritDoc} */
    @POST
    @Path("/example")      
    List<Permission> findByExample(Permission example);

    /** {@inheritDoc} */
    @POST
    Permission create(Permission permission) throws EntityException;

    /** {@inheritDoc} */
    @GET
    @Path("/{permissionId}")
    Permission retrieve(@PathParam("permissionId") Long id);

    /** {@inheritDoc} */
    @PUT
    @Path("/permissionId")
    Permission update(@PathParam("permissionId") Long id, Permission permission) throws EntityException;

    /** {@inheritDoc} */
    @DELETE
    void delete(@PathParam("permissionId") Long id) throws EntityException;
}
