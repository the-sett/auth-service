package com.thesett.auth.top;

import java.io.InputStream;
import java.text.ParseException;

import javax.validation.Validation;
import javax.validation.ValidatorFactory;

import org.glassfish.jersey.media.multipart.MultiPartFeature;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;                
import com.fasterxml.jackson.databind.SerializationFeature;
import com.strategicgains.hyperexpress.HyperExpress;
import com.strategicgains.hyperexpress.domain.hal.HalResourceFactory;
import com.fasterxml.jackson.annotation.JsonInclude;

import io.dropwizard.Application;
import io.dropwizard.db.DataSourceFactory;
import io.dropwizard.migrations.MigrationsBundle;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import io.dropwizard.views.ViewBundle;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

import com.thesett.util.commands.refdata.RefDataLoadCommand;
import com.thesett.util.commands.dropviews.DropViewsCommand;
import com.thesett.util.config.hibernate.HibernateXmlBundle;
import com.thesett.util.config.hyperexpress.HalResourceModule;
import com.thesett.util.config.refdata.RefDataSetupBundle;
import com.thesett.util.config.validation.BeanValidationBundle;
import com.thesett.util.errors.StandardExceptionMapper;
import com.thesett.util.json.JodaTimeModule;
import com.thesett.util.services.rest.ReferenceDataResource;

import com.thesett.auth.config.AppConfiguration;    
import com.thesett.auth.services.ServiceFactory;
import com.thesett.auth.services.local.LocalServiceFactory;
import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.services.rest.AccountResource;    
import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.dao.RoleDAOImpl;
import com.thesett.auth.services.rest.RoleResource;    

public class Main extends Application<AppConfiguration> {
    /** Latch used to ensure hyper express is only initialized once. */
    private static boolean hyperExpressInitialized;

    /** Holds the command for setting up reference data in the database. */
    private static RefDataLoadCommand<AppConfiguration> refDataLoadCommand =
        new RefDataLoadCommand<AppConfiguration>() {
            /** {@inheritDoc} */
            public String getRefdataPackage(AppConfiguration configuration) {
                return configuration.getRefdata();
            }

            /** {@inheritDoc} */
            public DataSourceFactory getDataSourceFactory(AppConfiguration configuration) {
                return configuration.getDataSourceFactory();
            }
        };

    /** Holds the command for clearing all database views - to compensate for bug in Liquibase. */
    private static DropViewsCommand<AppConfiguration> dropViewsCommand =
            new DropViewsCommand<AppConfiguration>() {
                /** {@inheritDoc} */
                public DataSourceFactory getDataSourceFactory(AppConfiguration configuration) {
                    return configuration.getDataSourceFactory();
                }
            };

    /** The hibernate resource bundle. */
    private final HibernateXmlBundle<AppConfiguration> hibernateXmlBundle =
        new HibernateXmlBundle<AppConfiguration>("auth-model.hbm.xml") {
            /** {@inheritDoc} */
            public DataSourceFactory getDataSourceFactory(AppConfiguration configuration) {
                return configuration.getDataSourceFactory();
            }

            /** {@inheritDoc} */
            protected void configure(Configuration configuration) {
                configuration.addAnnotatedClass(AccountDAOImpl.class);
                configuration.addAnnotatedClass(RoleDAOImpl.class);
                extensionPoint.addHibernateClasses(configuration);
            }
        };

    /** The bean validation resource bundle. */
    private final BeanValidationBundle<AppConfiguration> beanValidationBundle =
        new BeanValidationBundle<AppConfiguration>() {
            /** {@inheritDoc} */
            public ValidatorFactory getValidatorFactory(AppConfiguration configuration) {
                String constraintsResource = configuration.getBeanValidationConstraints();
                InputStream resource = this.getClass().getClassLoader().getResourceAsStream(constraintsResource);

                return Validation.byDefaultProvider().configure().addMapping(resource).buildValidatorFactory();
            }
        };

    /** The reference data initialization bundle. */
    RefDataSetupBundle<AppConfiguration> refDataSetupBundle =
        new RefDataSetupBundle<AppConfiguration>() {
            /** {@inheritDoc} */
            public String getRefdataPackage(AppConfiguration configuration) {
                return configuration.getRefdata();
            }

            /** {@inheritDoc} */
            public DataSourceFactory getDataSourceFactory(AppConfiguration configuration) {
                return configuration.getDataSourceFactory();
            }
        };

    /** The database migration resource bundle. */
    private final MigrationsBundle<AppConfiguration> migrationsBundle =
        new MigrationsBundle<AppConfiguration>() {
            /** {@inheritDoc} */
            public DataSourceFactory getDataSourceFactory(AppConfiguration configuration) {
                return configuration.getDataSourceFactory();
            }
        };

    /** Create the extension point. */
    private Example extensionPoint = new Example();

    /**
     * Starts the Accounts application running.
     *
     * @param args The command line arguments.
     */
    public static void main(String[] args) {
        try {
            new Main().run(args);
        } catch (Exception e) {
            throw new IllegalStateException("Application failed with an exception.", e);
        }
    }

    /** {@inheritDoc} */
    public void initialize(Bootstrap<AppConfiguration> bootstrap) {
        bootstrap.addBundle(migrationsBundle);
        bootstrap.addBundle(hibernateXmlBundle);
        bootstrap.addBundle(refDataSetupBundle);
        bootstrap.addBundle(beanValidationBundle);
        bootstrap.addBundle(new ViewBundle());

        bootstrap.addCommand(refDataLoadCommand);
        bootstrap.addCommand(dropViewsCommand);

        bootstrap.getObjectMapper().registerModule(new JodaTimeModule());
        bootstrap.getObjectMapper().configure(SerializationFeature.WRITE_EMPTY_JSON_ARRAYS, false);
        bootstrap.getObjectMapper().setSerializationInclusion(JsonInclude.Include.NON_NULL);
        bootstrap.getObjectMapper().configure(JsonGenerator.Feature.QUOTE_FIELD_NAMES, true);
        bootstrap.getObjectMapper().configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true);

        bootstrap.getObjectMapper().registerModule(new HalResourceModule());

        extensionPoint.bootstrap(bootstrap);
    }

    /** {@inheritDoc} */
    public void run(AppConfiguration ppConfiguration, Environment environment) throws ParseException {
        if (!hyperExpressInitialized) {
            HalResourceFactory halFactory = new HalResourceFactory();
            HyperExpress.registerResourceFactoryStrategy(halFactory, "application/hal+json");

            hyperExpressInitialized = true;
        }

        SessionFactory sessionFactory = hibernateXmlBundle.getSessionFactory();

        environment.jersey().register(new StandardExceptionMapper());
        environment.jersey().register(MultiPartFeature.class);

        // Obtain a reference to the validator.
        ValidatorFactory validatorFactory = beanValidationBundle.getValidatorFactory(ppConfiguration);

        // Set up the DAOs on top of Hibernate and the validator.
        AccountDAO accountDAO = new AccountDAOImpl(sessionFactory, validatorFactory);
        RoleDAO roleDAO = new RoleDAOImpl(sessionFactory, validatorFactory);

        // Build all of the services on top of the DAOs.
        ReferenceDataResource referenceDataResource = new ReferenceDataResource(refDataSetupBundle.getRefdataTypes());

        AccountResource accountResource = new AccountResource(accountDAO);
        RoleResource roleResource = new RoleResource(roleDAO);

        ServiceFactory serviceFactory =
            new LocalServiceFactory(sessionFactory,
            accountResource, 
            roleResource
        );

        // Register the REST APIs.
        environment.jersey().register(referenceDataResource);
        environment.jersey().register(accountResource);
        environment.jersey().register(roleResource);

        environment.jersey().setUrlPattern("/*");

        // Run the example to create some example data.
        extensionPoint.initAdditionalServices(ppConfiguration, environment, sessionFactory,
            validatorFactory, serviceFactory);
        extensionPoint.example(serviceFactory);
    }
}