package com.thesett.auth.test.role;

import java.lang.reflect.Proxy;

import com.thesett.test.base.WebServiceIsolationCRUDTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.rest.RoleResource;
import com.thesett.util.security.shiro.LocalSubject;
import com.thesett.util.security.shiro.ShiroUtils;
import org.apache.shiro.subject.Subject;
import org.junit.After;
import org.junit.Before;

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
}
