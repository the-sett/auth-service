
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
public class AuthResponse  implements  Serializable {

    /** Holds the token property. */    
    protected String token;

    /** Holds the refreshToken property. */    
    protected String refreshToken;

    /** No-arg constructor for serialization. */
    public AuthResponse() {
        // No-arg constructor for serialization.
    }

        

    
    /**
     * Accepts a new value for the token property.
     *
     * @param token The token property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public AuthResponse withToken(String token) {
        this.token = token;
        return this;
    }

    /**
     * Accepts a new value for the refreshToken property.
     *
     * @param refreshToken The refreshToken property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public AuthResponse withRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
        return this;
    }
    /**
     * Provides the token property.
     *
     * @return The token property.
     */
    public String getToken() {
        return token;
    }

    /**
     * Provides the refreshToken property.
     *
     * @return The refreshToken property.
     */
    public String getRefreshToken() {
        return refreshToken;
    }
    /**
     * Accepts a new value for the token property.
     *
     * @param token The token property.
     */
    public void setToken(String token) {
        this.token = token;
    }

    /**
     * Accepts a new value for the refreshToken property.
     *
     * @param refreshToken The refreshToken property.
     */
    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    
}
