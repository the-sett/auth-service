
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
public class Verifier  implements  Serializable {

    /** Holds the alg property. */    
    protected String alg;

    /** Holds the key property. */    
    protected String key;

    /** No-arg constructor for serialization. */
    public Verifier() {
        // No-arg constructor for serialization.
    }

        

    
    /**
     * Accepts a new value for the alg property.
     *
     * @param alg The alg property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Verifier withAlg(String alg) {
        this.alg = alg;
        return this;
    }

    /**
     * Accepts a new value for the key property.
     *
     * @param key The key property.
     *
     * @return 'this' (so that fluents can be chained methods).
     */
    public Verifier withKey(String key) {
        this.key = key;
        return this;
    }
    /**
     * Provides the alg property.
     *
     * @return The alg property.
     */
    public String getAlg() {
        return alg;
    }

    /**
     * Provides the key property.
     *
     * @return The key property.
     */
    public String getKey() {
        return key;
    }
    /**
     * Accepts a new value for the alg property.
     *
     * @param alg The alg property.
     */
    public void setAlg(String alg) {
        this.alg = alg;
    }

    /**
     * Accepts a new value for the key property.
     *
     * @param key The key property.
     */
    public void setKey(String key) {
        this.key = key;
    }

    
}
