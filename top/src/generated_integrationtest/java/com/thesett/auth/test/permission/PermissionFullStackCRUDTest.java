package com.thesett.auth.test.permission;

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

import com.thesett.auth.dao.PermissionDAOImpl;
import com.thesett.auth.model.Permission;
import com.thesett.auth.services.PermissionService;
import com.thesett.auth.services.rest.PermissionResource;

public class PermissionFullStackCRUDTest extends FullStackCRUDTestBase<Permission, Long>
{
    public PermissionFullStackCRUDTest()
    {
        super(new PermissionTestData(), Permission.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Permission, Long> getServiceLayer()
    {
        PermissionDAOImpl permissionDAO = new PermissionDAOImpl(sessionFactory, validatorFactory);

        PermissionResource permissionResource = new PermissionResource(permissionDAO);

        return HibernateSessionAndDetachProxy.proxy(permissionResource, PermissionService.class, sessionFactory);
    }

    @Before
    public void setupSecurity()
    {
        Subject subject = new LocalSubject().withPermission("admin");
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
