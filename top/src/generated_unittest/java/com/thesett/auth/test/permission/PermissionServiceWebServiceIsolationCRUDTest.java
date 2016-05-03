package com.thesett.auth.test.permission;

import java.lang.reflect.Proxy;

import com.thesett.test.base.WebServiceIsolationCRUDTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.PermissionDAO;
import com.thesett.auth.model.Permission;
import com.thesett.auth.services.rest.PermissionResource;

public class PermissionServiceWebServiceIsolationCRUDTest extends WebServiceIsolationCRUDTestBase<Permission, Long>
{
    public PermissionServiceWebServiceIsolationCRUDTest()
    {
        super(new PermissionTestData());
    }

    protected CRUD<Permission, Long> getServiceLayer(CRUD<Permission, Long> dao)
    {
        PermissionDAO permissionDAO =
            (PermissionDAO) Proxy.newProxyInstance(dao.getClass().getClassLoader(), new Class[] { PermissionDAO.class },
                new DefaultProxy(dao));

        return new PermissionResource(permissionDAO);
    }
}
