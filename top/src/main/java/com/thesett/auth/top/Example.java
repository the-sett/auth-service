/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.top;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.util.EnumSet;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.DispatcherType;
import javax.validation.ValidatorFactory;
import javax.ws.rs.client.Client;

import com.bazaarvoice.dropwizard.assets.ConfiguredAssetsBundle;
import com.google.common.cache.CacheBuilderSpec;
import com.thesett.auth.config.AppConfiguration;
import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.dao.UserSecurityDAOImpl;
import com.thesett.auth.model.Account;
import com.thesett.auth.model.Permission;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.*;
import com.thesett.auth.services.config.ClientSecretsConfiguration;
import com.thesett.auth.services.rest.AuthResource;
import com.thesett.auth.services.rest.FacebookAuthResource;
import com.thesett.auth.services.rest.GithubAuthResource;
import com.thesett.auth.services.rest.GoogleAuthResource;
import com.thesett.auth.services.rest.VerificationResource;
import com.thesett.util.caching.InfinispanBundle;
import com.thesett.util.caching.InfinispanConfiguration;
import com.thesett.util.collections.CollectionUtil;
import com.thesett.util.config.shiro.ShiroBundle;
import com.thesett.util.config.shiro.ShiroConfiguration;
import com.thesett.util.entity.EntityException;
import com.thesett.util.security.shiro.LocalSubject;
import com.thesett.util.security.shiro.ShiroUtils;
import com.thesett.util.security.web.ShiroJWTRealmSetupListener;
import com.thesett.util.servlet.filter.CORSFilter;
import com.thesett.util.swagger.EnumTypeModelConverter;

import io.dropwizard.client.JerseyClientBuilder;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import io.federecio.dropwizard.swagger.SwaggerBundle;
import io.federecio.dropwizard.swagger.SwaggerBundleConfiguration;
import io.swagger.converter.ModelConverters;

import org.apache.shiro.subject.Subject;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.infinispan.Cache;
import org.infinispan.manager.EmbeddedCacheManager;

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

    private InfinispanBundle<AppConfiguration> infinispanBundle =
        new InfinispanBundle<AppConfiguration>()
        {
            protected InfinispanConfiguration getInfinispanConfiguration(AppConfiguration configuration)
            {
                return configuration.infinispanConfiguration;
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
        bootstrap.addBundle(infinispanBundle);

        bootstrap.addBundle(new ConfiguredAssetsBundle("/webapp/app/", CacheBuilderSpec.disableCaching(),
                "/admin", "index.html"));

        ModelConverters.getInstance().addConverter(new EnumTypeModelConverter());
    }

    /**
     * Insert some example data.
     *
     * @param serviceFactory The service factory.
     */
    public void example(ServiceFactory serviceFactory)
    {
        Subject subject = new LocalSubject().withPermission("auth-admin");
        ShiroUtils.setSubject(subject);

        createDefaultRolesAccount(serviceFactory);
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

        // Add the CORS filter to allow cross-origin browsing to this API - needed to support
        // javascript clients that are running on a different origin to the one this API is
        // being served from. Disable this for security, if a javascript client is not being used
        // or is being served from the same origin.
        environment.servlets()
            .addFilter("cors", new CORSFilter())
            .addMappingForUrlPatterns(EnumSet.allOf(DispatcherType.class), false, "/*");

        // Attach a configurator for Shiro to the Servlet lifecycle.
        environment.servlets().addServletListeners(new ShiroJWTRealmSetupListener(keyPair.getPublic()));

        // Set up the auth endpoints.
        EmbeddedCacheManager cacheManager = infinispanBundle.getCacheManager();
        Cache<String, Account> refreshCache = cacheManager.getCache();

        AccountDAO accountDAO = new AccountDAOImpl(sessionFactory, validatorFactory);
        AuthService authResource = new AuthResource(accountDAO, keyPair, 5 * 60 * 1000L, 30 * 60 * 1000L, refreshCache);
        environment.jersey().register(authResource);

        VerificationService verificationService = new VerificationResource(keyPair.getPublic());
        environment.jersey().register(verificationService);

        // Attach resources for handling OAuth providers.
        Client client = new JerseyClientBuilder(environment).using(appConfiguration.getHttpClient()).build("client");
        ClientSecretsConfiguration clientSecrets = appConfiguration.getClientSecretsConfiguration();

        GithubAuthResource githubAuthResource = new GithubAuthResource(clientSecrets, client);
        environment.jersey().register(githubAuthResource);

        FacebookAuthResource facebookAuthResource = new FacebookAuthResource(clientSecrets, client);
        environment.jersey().register(facebookAuthResource);

        GoogleAuthResource googleAuthResource = new GoogleAuthResource(clientSecrets, client);
        environment.jersey().register(googleAuthResource);
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
     * Creates the default role set, if no roles exist.
     *
     * @param serviceFactory The service factory.
     */
    private void createDefaultRolesAccount(ServiceFactory serviceFactory)
    {
        RoleService roleService = serviceFactory.getRoleService();

        try
        {
            Set<Permission> permissions;
            Role role;

            // Create the admin role.
            permissions = new HashSet<>();
            permissions.add(new Permission().withName("auth-admin"));

            role = new Role().withName("auth-root").withPermissions(permissions);
            createRoleIfNotExists(roleService, role);

            // Create the user role.
            permissions = new HashSet<>();
            permissions.add(new Permission().withName("user"));

            role = new Role().withName("user").withPermissions(permissions);
            createRoleIfNotExists(roleService, role);
        }
        catch (EntityException e)
        {
            throw new IllegalStateException(e);
        }
    }

    private Role createRoleIfNotExists(RoleService roleService, Role role) throws EntityException
    {
        Role check = CollectionUtil.first(roleService.findByExample(new Role().withName(role.getName())));

        if (check == null)
        {
            return roleService.create(role);
        }

        return check;
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
                Role adminRole = CollectionUtil.first(roleService.findByExample(new Role().withName("auth-root")));

                Set<Role> roles = new HashSet<>();
                roles.add(adminRole);

                accountService.create(new Account().withUsername("admin").withPassword("admin").withRoles(roles)
                    .withRoot(true));
            }
            catch (EntityException e)
            {
                throw new IllegalStateException(e);
            }
        }
    }
}
