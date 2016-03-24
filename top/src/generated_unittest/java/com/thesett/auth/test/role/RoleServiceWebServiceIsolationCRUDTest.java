package com.thesett.auth.test.role;

import java.lang.reflect.Proxy;

import com.thesett.test.base.WebServiceIsolationCRUDTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.rest.RoleResource;

public class RoleServiceWebServiceIsolationCRUDTest extends WebServiceIsolationCRUDTestBase<Role, Long>
{
    public RoleServiceWebServiceIsolationCRUDTest()
    {
        super(new RoleTestData());
    }

    protected CRUD<Role, Long> getServiceLayer(CRUD<Role, Long> dao)
    {
        RoleDAO roleDAO =
            (RoleDAO) Proxy.newProxyInstance(dao.getClass().getClassLoader(), new Class[] { RoleDAO.class },
                new DefaultProxy(dao));

        return new RoleResource(roleDAO);
    }
}
