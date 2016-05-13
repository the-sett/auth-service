package com.thesett.auth.services;

import java.util.List;        

import com.thesett.util.entity.EntityException;
import com.thesett.util.entity.CRUD;
import com.thesett.util.validation.model.JsonSchema;

import com.thesett.auth.model.Permission;

/**
 * Service interface for working with Permission
 *
 * @author Generated Code
 */
public interface PermissionService extends CRUD<Permission, Long> {    
    /**
     * Provides a json-schema describing the Permission data model.
     *
     * @return A json-schema describing the Permission data model.
     */
    JsonSchema schema();

    /**
     * Lists all values.
     *
     * @return A list containing all values.
     */
    List<Permission> findAll();        

    /**
     * Lists all values that have fields that match the non-null fields in the example.
     *
     * @param example An example to match the fields of.
     *
     * @return A list of all matching values.
     */
    List<Permission> findByExample(Permission example);

    /** {@inheritDoc} */
    Permission create(Permission permission) throws EntityException;

    /** {@inheritDoc} */
    Permission retrieve(Long id);

    /** {@inheritDoc} */
    Permission update(Long id, Permission permission) throws EntityException;

    /** {@inheritDoc} */
    void delete(Long id) throws EntityException;
}
