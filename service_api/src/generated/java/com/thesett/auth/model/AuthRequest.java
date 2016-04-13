
package com.thesett.auth.model;

import java.io.Serializable;


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
public class AuthRequest  implements  Serializable {

    /** Holds the username property. */    
    protected String username;

    /** Holds the password property. */    
    protected String password;

    /** No-arg constructor for serialization. */
    public AuthRequest() {
        // No-arg constructor for serialization.
    }

        

    
    /**
     * Accepts a new value for the username property.
     *
     * @param username The username property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public AuthRequest withUsername(String username) {
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
    public AuthRequest withPassword(String password) {
        this.password = password;
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

    
}
