package com.thesett.auth.test.role;

import com.thesett.util.security.shiro.LocalSubject;
import com.thesett.util.security.shiro.ShiroUtils;
import org.apache.shiro.subject.Subject;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import com.thesett.auth.test.AppTestSetupController;
import com.thesett.auth.top.Main;
import com.thesett.test.base.FullStackCRUDTestBase;
import com.thesett.util.dao.HibernateSessionAndDetachProxy;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.RoleDAOImpl;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.RoleService;
import com.thesett.auth.services.rest.RoleResource;

public class RoleFullStackCRUDTest extends FullStackCRUDTestBase<Role, Long>
{
    public RoleFullStackCRUDTest()
    {
        super(new RoleTestData(), Role.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Role, Long> getServiceLayer()
    {
        RoleDAOImpl roleDAO = new RoleDAOImpl(sessionFactory, validatorFactory);

        RoleResource roleResource = new RoleResource(roleDAO);

        return HibernateSessionAndDetachProxy.proxy(roleResource, RoleService.class, sessionFactory);
    }

    @Before
    public void setupSecurity()
    {
        Subject subject = new LocalSubject().withPermission("auth-admin");
        ShiroUtils.setSubject(subject);
    }

    @After
    public void teardownSecurity()
    {
        ShiroUtils.tearDownShiro();
    }

    @Test
    public void testFindAllNotEmpty() throws Exception {
        testFindAllNotEmpty("findAll");
    }

    @Test
    public void testFindByExampleNotEmpty() throws Exception {
        testFindByExampleNotEmpty("findByExample");
    }

    @Test
    public void testJsonSchema() throws Exception {
        testJsonSchema("schema");
    }
}
