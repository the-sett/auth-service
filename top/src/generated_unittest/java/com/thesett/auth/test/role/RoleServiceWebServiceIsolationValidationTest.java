package com.thesett.auth.test.role;

import java.lang.reflect.Proxy;
import java.util.Collection;

import org.junit.runners.Parameterized;
import com.thesett.test.base.WebServiceIsolationValidationTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.rest.RoleResource;

public class RoleServiceWebServiceIsolationValidationTest
    extends WebServiceIsolationValidationTestBase<Role, Long>
{
    public RoleServiceWebServiceIsolationValidationTest(Role example, boolean valid)
    {
        super(new RoleTestData(), example, valid);
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data()
    {
        return buildExamples(new RoleTestData());
    }

    protected CRUD<Role, Long> getServiceLayer(CRUD<Role, Long> dao)
    {
        RoleDAO roleDAO =
            (RoleDAO) Proxy.newProxyInstance(dao.getClass().getClassLoader(), new Class[] { RoleDAO.class },
                new DefaultProxy(dao));

        return new RoleResource(roleDAO);
    }
}
