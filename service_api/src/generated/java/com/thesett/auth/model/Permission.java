
package com.thesett.auth.model;

import java.io.Serializable;


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
* <tr><td> name </td></tr>
 * </table>    
 *
 * @author Generated Code
 */
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(Include.NON_NULL)
public class Permission  implements Entity<Long>, Serializable {

    /** Holds the database surrogate id. */
    private Long id;

    /** Holds the name property. */    
    protected String name;

    /** No-arg constructor for serialization. */
    public Permission() {
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
     * Accepts a new value for the name property.
     *
     * @param name The name property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Permission withName(String name) {
        this.name = name;
        return this;
    }
    /**
     * Provides the name property.
     *
     * @return The name property.
     */
    public String getName() {
        return name;
    }
    /**
     * Accepts a new value for the name property.
     *
     * @param name The name property.
     */
    public void setName(String name) {
        this.name = name;
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

        if (o instanceof Permission) {
            Permission comp = (Permission)o;

            return EqualityHelper.nullSafeEquals(name, comp.name);
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
        return EqualityHelper.nullSafeHashCode(name);
    }

    
}
