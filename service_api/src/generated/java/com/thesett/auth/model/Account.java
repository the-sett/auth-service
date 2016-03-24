
package com.thesett.auth.model;

import java.io.Serializable;

import java.util.Set;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import static com.fasterxml.jackson.annotation.JsonInclude.Include;

import com.thesett.util.entity.Entity;

import io.swagger.annotations.ApiModelProperty;

    
import com.thesett.util.equality.EqualityHelper;
    

/**
 * Generated bean from catalogue model.

 *
 * <p>Equality (and hashCode) is based on the following fields:
 *
 * <table id="equality"><caption>Equality Fields</caption>
 * <tr><th> Field Name </th></tr>
* <tr><td> username </td></tr>
 * </table>    
 *
 * @author Generated Code
 */
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(Include.NON_NULL)
public class Account  implements Entity<Long>, Serializable {

    /** Holds the database surrogate id. */
    private Long id;

    /** Holds the username property. */    
    protected String username;

    /** Holds the password property. */    
    protected String password;

    /** Holds the roles property. */    
    @ApiModelProperty(hidden = true)        
    protected Set<Role> roles;

    /** No-arg constructor for serialization. */
    public Account() {
        // No-arg constructor for serialization.
    }

        

    /**
     * Gets the database surrogate id.
     *
     * @return The database surrogate id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the database surrogate id.
     *
     * @param id The database surrogate id.
     */
    public void setId(Long id) {
        this.id = id;
    }

    
    /**
     * Accepts a new value for the username property.
     *
     * @param username The username property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Account withUsername(String username) {
        this.username = username;
        return this;
    }

    /**
     * Accepts a new value for the password property.
     *
     * @param password The password property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Account withPassword(String password) {
        this.password = password;
        return this;
    }

    /**
     * Accepts a new value for the roles property.
     *
     * @param roles The roles property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Account withRoles(Set<Role> roles) {
        this.roles = roles;
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
     * Provides the password property.
     *
     * @return The password property.
     */
    public String getPassword() {
        return password;
    }

    /**
     * Provides the roles property.
     *
     * @return The roles property.
     */
    public Set<Role> getRoles() {
        return roles;
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
     * Accepts a new value for the password property.
     *
     * @param password The password property.
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * Accepts a new value for the roles property.
     *
     * @param roles The roles property.
     */
    public void setRoles(Set<Role> roles) {
        this.roles = roles;
    }

    /**
     * Determines whether an object of this type is equal to another object. To be equal the object being
     * compared to (the comparator) must be an instance of this class and have identical natural key field
     * values to this one.
     *
     * @param o The object to compare to.
     *
     * @return True if the comparator is equal to this, false otherwise.
     */
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }

        if (o == null) {
            return false;
        }

        if (o instanceof Account) {
            Account comp = (Account)o;

            return EqualityHelper.nullSafeEquals(username, comp.username);
        } else {
            return false;
        }
    }

    /**
     * Computes a hash code for the component that conforms with its equality method, being based on the same set
     * of fields that are used to compute equality.
     *
     * @return A hash code of the components equality value.
     */
    public int hashCode() {
        return EqualityHelper.nullSafeHashCode(username);
    }

    
}
