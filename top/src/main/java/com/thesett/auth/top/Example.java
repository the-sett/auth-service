/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.top;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.util.Collection;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Callable;

import javax.servlet.DispatcherType;
import javax.validation.ValidatorFactory;

import com.bazaarvoice.dropwizard.assets.ConfiguredAssetsBundle;
import com.thesett.auth.config.AppConfiguration;
import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.dao.UserSecurityDAOImpl;
import com.thesett.auth.model.Account;
import com.thesett.auth.model.Permission;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.AccountService;
import com.thesett.auth.services.RoleService;
import com.thesett.auth.services.ServiceFactory;
import com.thesett.auth.services.rest.AuthResource;
import com.thesett.jtrial.web.WebResource;
import com.thesett.util.config.shiro.ShiroBundle;
import com.thesett.util.config.shiro.ShiroConfiguration;
import com.thesett.util.entity.EntityException;
import com.thesett.util.security.shiro.LocalSubject;
import com.thesett.util.security.shiro.ShiroUtils;
import com.thesett.util.security.web.ShiroJWTRealmSetupListener;
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

import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authz.AuthorizationException;
import org.apache.shiro.session.Session;
import org.apache.shiro.subject.ExecutionException;
import org.apache.shiro.subject.PrincipalCollection;
import org.apache.shiro.subject.Subject;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * Example is a DropWizard application extension point, allowing the environment to be configured, additional services
 * created, additional databse mappings to be created, and example data to be inserted.
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

                addTemplatePath("/webapp/app/views/layouts");
                addTemplatePath("/webapp/app/views/partials");
                addTemplatePath("/webapp/app/views");
            }
        };

    private Subject subject;

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

        bootstrap.addBundle(new AssetsBundle("/META-INF/resources/webjars/thesett-laf/", "/thesett-laf", null,
                "thesett-laf"));
        bootstrap.addBundle(new ConfiguredAssetsBundle("/webapp/app/", "/app"));
        bootstrap.addBundle(handlebarsBundle);
    }

    /**
     * Insert some example data.
     *
     * @param serviceFactory The service factory.
     */
    public void example(ServiceFactory serviceFactory)
    {
        subject = new LocalSubject().withPermission("admin");
        ShiroUtils.setSubject(subject);

        createRootAccount(serviceFactory);

        ShiroUtils.tearDownShiro();
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
        // Set up a key pair for creating and checking access tokens.
        KeyPairGenerator keyGenerator = null;

        try
        {
            keyGenerator = KeyPairGenerator.getInstance("RSA");
        }
        catch (NoSuchAlgorithmException e)
        {
            throw new IllegalStateException(e);
        }

        keyGenerator.initialize(1024);

        KeyPair keyPair = keyGenerator.genKeyPair();

        // Add the CORS fitler to allow cross-origin browsing to this API - needed to support
        // javascript clients that are running on a different origin to the one this API is
        // being served from. Disable this for security, if a javascript client is not being used
        // or is being served from the same origin.
        environment.servlets().addFilter("cors", new CORSFilter()).addMappingForUrlPatterns(EnumSet.allOf(
                DispatcherType.class), false, "/*");

        // Attach a configurator for Shiro to the Servlet lifecycle.
        /*UserSecurityDAO userSecurityDAO =
            HibernateSessionAndDetachProxy.proxy(new UserSecurityDAOImpl(sessionFactory), UserSecurityDAO.class,
                sessionFactory);*/

        environment.servlets().addServletListeners(new ShiroJWTRealmSetupListener(keyPair.getPublic()));

        WebResource webResource = new WebResource(serviceFactory);
        environment.jersey().register(webResource);

        AccountDAO accountDAO = new AccountDAOImpl(sessionFactory, validatorFactory);
        AuthResource authResource = new AuthResource(accountDAO, keyPair);
        environment.jersey().register(authResource);
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

    /**
     * If no accounts exist, creates the root account 'admin/admin'.
     *
     * @param serviceFactory The service factory.
     */
    private void createRootAccount(ServiceFactory serviceFactory)
    {
        AccountService accountService = serviceFactory.getAccountService();
        RoleService roleService = serviceFactory.getRoleService();

        if (accountService.findAll().isEmpty())
        {
            try
            {
                Set<Permission> permissions = new HashSet<>();
                permissions.add(new Permission().withName("admin"));

                Role adminRole = new Role().withName("admin").withPermissions(permissions);
                roleService.create(adminRole);

                Set<Role> roles = new HashSet<>();
                roles.add(adminRole);

                accountService.create(new Account().withUsername("admin").withPassword("admin").withRoles(roles));
            }
            catch (EntityException e)
            {
                throw new IllegalStateException(e);
            }
        }
    }
}
