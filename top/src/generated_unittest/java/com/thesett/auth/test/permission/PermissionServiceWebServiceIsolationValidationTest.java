package com.thesett.auth.test.permission;

import java.lang.reflect.Proxy;
import java.util.Collection;

import org.junit.runners.Parameterized;
import com.thesett.test.base.WebServiceIsolationValidationTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.PermissionDAO;
import com.thesett.auth.model.Permission;
import com.thesett.auth.services.rest.PermissionResource;

public class PermissionServiceWebServiceIsolationValidationTest
    extends WebServiceIsolationValidationTestBase<Permission, Long>
{
    public PermissionServiceWebServiceIsolationValidationTest(Permission example, boolean valid)
    {
        super(new PermissionTestData(), example, valid);
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data()
    {
        return buildExamples(new PermissionTestData());
    }

    protected CRUD<Permission, Long> getServiceLayer(CRUD<Permission, Long> dao)
    {
        PermissionDAO permissionDAO =
            (PermissionDAO) Proxy.newProxyInstance(dao.getClass().getClassLoader(), new Class[] { PermissionDAO.class },
                new DefaultProxy(dao));

        return new PermissionResource(permissionDAO);
    }
}
