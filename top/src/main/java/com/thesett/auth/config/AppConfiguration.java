/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.config;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;

import com.bazaarvoice.dropwizard.assets.AssetsBundleConfiguration;
import com.bazaarvoice.dropwizard.assets.AssetsConfiguration;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.thesett.util.config.shiro.ShiroConfiguration;

import io.dropwizard.Configuration;
import io.dropwizard.db.DataSourceFactory;
import io.federecio.dropwizard.swagger.SwaggerBundleConfiguration;

/**
 * AppConfiguration holds configuration items for Accounts.
 */
public class AppConfiguration extends Configuration implements AssetsBundleConfiguration
{
    @JsonProperty("swagger")
    public SwaggerBundleConfiguration swaggerBundleConfiguration;

    /** Holds the web assets configuration. */
    @Valid
    @NotNull
    @JsonProperty
    private final AssetsConfiguration assets = new AssetsConfiguration();

    /** Holds the configured data source factory. */
    @Valid
    @NotNull
    private DataSourceFactory database = new DataSourceFactory();

    /** Holds the name of the package to load the reference data .csv files from. */
    private String refdata;

    /** Holds the name of the resource to load the catalogue knowledge level model from. */
    private String modelResource;

    /** Holds the name of the resource to load bean validation constraints from. */
    private String beanValidationConstraints;

    /** Holds the configuration settings for Shiro. */
    private ShiroConfiguration shiroConfiguration;

    /**
     * Provides the data source factory.
     *
     * @return The data source factory.
     */
    @JsonProperty("database")
    public DataSourceFactory getDataSourceFactory()
    {
        return database;
    }

    /**
     * Establishes the data source factory.
     *
     * @param dataSourceFactory The data source factory.
     */
    @JsonProperty("database")
    public void setDataSourceFactory(DataSourceFactory dataSourceFactory)
    {
        this.database = dataSourceFactory;
    }

    /**
     * Provides the web assets configuration.
     *
     * @return The web assets configuration.
     */
    public AssetsConfiguration getAssetsConfiguration()
    {
        return assets;
    }

    /**
     * Provides the name of the package to load the reference data .csv files from.
     *
     * @return The name of the package to load the reference data .csv files from.
     */
    @JsonProperty
    public String getRefdata()
    {
        return refdata;
    }

    /**
     * Establishes the name of the package to load the reference data .csv files from.
     *
     * @param name The name of the package to load the reference data .csv files from.
     */
    @JsonProperty
    public void setRefdata(String name)
    {
        this.refdata = name;
    }

    /**
     * Provides the name of the resource to load the catalogue knowledge level model from.
     *
     * @return The name of the resource to load the catalogue knowledge level model from.
     */
    @JsonProperty
    public String getModelResource()
    {
        return modelResource;
    }

    /**
     * Establishes the name of the resource to load the catalogue knowledge level model from.
     *
     * @param modelResource The name of the resource to load the catalogue knowledge level model from.
     */
    @JsonProperty
    public void setModelResource(String modelResource)
    {
        this.modelResource = modelResource;
    }

    /**
     * Provides the name of the resource to load bean validation constraints from.
     *
     * @return The name of the resource to load bean validation constraints from.
     */
    @JsonProperty
    public String getBeanValidationConstraints()
    {
        return beanValidationConstraints;
    }

    /**
     * Establishes the name of the resource to load bean validation constraints from.
     *
     * @param beanValidationConstraints The name of the resource to load bean validation constraints from.
     */
    @JsonProperty
    public void setBeanValidationConstraints(String beanValidationConstraints)
    {
        this.beanValidationConstraints = beanValidationConstraints;
    }

    @JsonProperty("shiro")
    public ShiroConfiguration getShiroConfiguration()
    {
        return shiroConfiguration;
    }

    @JsonProperty("shiro")
    public void setShiroConfiguration(ShiroConfiguration shiroConfiguration)
    {
        this.shiroConfiguration = shiroConfiguration;
    }
}
