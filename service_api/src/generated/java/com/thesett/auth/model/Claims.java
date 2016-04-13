
package com.thesett.auth.model;

import java.io.Serializable;

import java.util.Set;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import static com.fasterxml.jackson.annotation.JsonInclude.Include;

import io.swagger.annotations.ApiModelProperty;

    
    

/**
 * Generated bean from catalogue model.    
 *
 * @author Generated Code
 */
@JsonIgnoreProperties(ignoreUnknown = true, value = {"componentType"})
@JsonInclude(Include.NON_NULL)
public class Claims  implements  Serializable {

    /** Holds the username property. */    
    protected String username;

    /** Holds the permissions property. */    
    @ApiModelProperty(hidden = true)        
    protected Set<String> permissions;

    /** No-arg constructor for serialization. */
    public Claims() {
        // No-arg constructor for serialization.
    }

        

    
    /**
     * Accepts a new value for the username property.
     *
     * @param username The username property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Claims withUsername(String username) {
        this.username = username;
        return this;
    }

    /**
     * Accepts a new value for the permissions property.
     *
     * @param permissions The permissions property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Claims withPermissions(Set<String> permissions) {
        this.permissions = permissions;
        return this;
    }
    /**
     * Provides the username property.
     *
     * @return The username property.
     */
    public String getUsername() {
        return username;
    }

    /**
     * Provides the permissions property.
     *
     * @return The permissions property.
     */
    public Set<String> getPermissions() {
        return permissions;
    }
    /**
     * Accepts a new value for the username property.
     *
     * @param username The username property.
     */
    public void setUsername(String username) {
        this.username = username;
    }

    /**
     * Accepts a new value for the permissions property.
     *
     * @param permissions The permissions property.
     */
    public void setPermissions(Set<String> permissions) {
        this.permissions = permissions;
    }

    
}
