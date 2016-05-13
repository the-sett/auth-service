package com.thesett.auth.services;

import java.util.List;        

import com.thesett.util.entity.EntityException;
import com.thesett.util.entity.CRUD;
import com.thesett.util.validation.model.JsonSchema;

import com.thesett.auth.model.Role;

/**
 * Service interface for working with Role
 *
 * @author Generated Code
 */
public interface RoleService extends CRUD<Role, Long> {    
    /**
     * Provides a json-schema describing the Role data model.
     *
     * @return A json-schema describing the Role data model.
     */
    JsonSchema schema();

    /**
     * Lists all values.
     *
     * @return A list containing all values.
     */
    List<Role> findAll();        

    /**
     * Lists all values that have fields that match the non-null fields in the example.
     *
     * @param example An example to match the fields of.
     *
     * @return A list of all matching values.
     */
    List<Role> findByExample(Role example);

    /** {@inheritDoc} */
    Role create(Role role) throws EntityException;

    /** {@inheritDoc} */
    Role retrieve(Long id);

    /** {@inheritDoc} */
    Role update(Long id, Role role) throws EntityException;

    /** {@inheritDoc} */
    void delete(Long id) throws EntityException;
}
