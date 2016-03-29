/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.top;

import java.util.EnumSet;

import javax.servlet.DispatcherType;
import javax.validation.ValidatorFactory;

import com.bazaarvoice.dropwizard.assets.ConfiguredAssetsBundle;
import com.thesett.auth.config.AppConfiguration;
import com.thesett.auth.dao.UserSecurityDAOImpl;
import com.thesett.auth.services.ServiceFactory;
import com.thesett.jtrial.web.WebResource;
import com.thesett.util.config.shiro.ShiroBundle;
import com.thesett.util.config.shiro.ShiroConfiguration;
import com.thesett.util.dao.HibernateSessionAndDetachProxy;
import com.thesett.util.security.dao.UserSecurityDAO;
import com.thesett.util.security.web.ShiroDBRealmSetupListener;
import com.thesett.util.servlet.filter.CORSFilter;
import com.thesett.util.swagger.EnumTypeModelConverter;
import com.thesett.util.views.handlebars.HandlebarsBundle;
import com.thesett.util.views.handlebars.HandlebarsBundleConfig;

import io.dropwizard.assets.AssetsBundle;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import io.federecio.dropwizard.swagger.SwaggerBundle;
import io.federecio.dropwizard.swagger.SwaggerBundleConfiguration;
import io.swagger.converter.ModelConverters;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * Example is a DropWizard application extension point, allowing the environment to be configured,
 * additional services created, additional databse mappings to be created, and example data to be
 * inserted.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th>
 * <tr><td> Bootstrap the DropWizard environment. </td></tr>
 * <tr><td> Add additional services. </td></tr>
 * <tr><td> Add additional Hibernate ORM mappings. </td></tr>
 * <tr><td> Create some example data. </td></tr>
 * </table></pre>
 */
public class Example
{
    /** The Shiro configuration bundle. */
    private ShiroBundle<AppConfiguration> shiroBundle =
        new ShiroBundle<AppConfiguration>()
        {
            /** {@inheritDoc} */
            public ShiroConfiguration getShiroConfiguration(AppConfiguration configuration)
            {
                return configuration.getShiroConfiguration();
            }
        };

    /** The Swagger configuration bundle. */
    private SwaggerBundle<AppConfiguration> swaggerBundle =
        new SwaggerBundle<AppConfiguration>()
        {
            protected SwaggerBundleConfiguration getSwaggerBundleConfiguration(AppConfiguration configuration)
            {
                return configuration.swaggerBundleConfiguration;
            }
        };

    /** Configure the locations of the handlebars templates. */
    private final HandlebarsBundle handlebarsBundle =
        new HandlebarsBundle()
        {
            /** {@inheritDoc} */
            protected void configureHandlebars(HandlebarsBundleConfig configuration)
            {
                addTemplatePath("/META-INF/resources/webjars/thesett-laf/views/layouts");
                addTemplatePath("/META-INF/resources/webjars/thesett-laf/views/partials");
                addTemplatePath("/META-INF/resources/webjars/thesett-laf/views");

                addTemplatePath("/webapp/views/layouts");
                addTemplatePath("/webapp/views/partials");
                addTemplatePath("/webapp/views");
            }
        };

    /**
     * Sets up some additional DropWizard modules.
     *
     * @param bootstrap The DropWizard bootstrap configuration.
     */
    public void bootstrap(Bootstrap<AppConfiguration> bootstrap)
    {
        bootstrap.addBundle(shiroBundle);

        bootstrap.addBundle(swaggerBundle);
        ModelConverters.getInstance().addConverter(new EnumTypeModelConverter());

        bootstrap.addBundle(new AssetsBundle("/META-INF/resources/webjars/thesett-laf/", "/assets"));
        //bootstrap.addBundle(new ConfiguredAssetsBundle("/webapp/assets/", "/assets/"));
        bootstrap.addBundle(handlebarsBundle);
    }

    /**
     * Insert some example data.
     *
     * @param serviceFactory The service factory.
     */
    public void example(ServiceFactory serviceFactory)
    {
    }

    /**
     * Sets up some additional non-generated serviced.
     *
     * @param appConfiguration The application configuration.
     * @param environment      The DropWizard environment.
     * @param sessionFactory   The Hibernate session factory.
     * @param validatorFactory The Hibernate Validator factory.
     * @param serviceFactory   The service factory.
     */
    public void initAdditionalServices(AppConfiguration appConfiguration, Environment environment,
        SessionFactory sessionFactory, ValidatorFactory validatorFactory, ServiceFactory serviceFactory)
    {
        // Add the CORS fitler to allow cross-origin browsing to this API - needed to support
        // javascript clients that are running on a different origin to the one this API is
        // being served from. Disable this for secuirty, if a javascript client is not being used
        // or is being served from the same origin.
        environment.servlets().addFilter("cors", new CORSFilter()).addMappingForUrlPatterns(EnumSet.allOf(
                DispatcherType.class), false, "/*");

        // Attach a configurator for Shiro to the Servlet lifecycle.
        UserSecurityDAO userSecurityDAO =
            HibernateSessionAndDetachProxy.proxy(new UserSecurityDAOImpl(sessionFactory), UserSecurityDAO.class,
                sessionFactory);

        environment.servlets().addServletListeners(new ShiroDBRealmSetupListener(userSecurityDAO));

        WebResource webResource = new WebResource(serviceFactory);
        environment.jersey().register(webResource);
    }

    /**
     * Adds any classes with Hibernate queries to the Hibernate configuration.
     *
     * @param configuration The Hibernate configuration.
     */
    public void addHibernateClasses(Configuration configuration)
    {
        configuration.addAnnotatedClass(UserSecurityDAOImpl.class);
    }
}
