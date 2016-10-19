package com.thesett.auth.test.account;

import java.lang.reflect.Proxy;

import com.thesett.test.base.WebServiceIsolationCRUDTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.model.Account;
import com.thesett.auth.services.rest.AccountResource;
import com.thesett.util.security.shiro.LocalSubject;
import com.thesett.util.security.shiro.ShiroUtils;
import org.apache.shiro.subject.Subject;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class AccountServiceWebServiceIsolationCRUDTest extends WebServiceIsolationCRUDTestBase<Account, Long>
{
    public AccountServiceWebServiceIsolationCRUDTest()
    {
        super(new AccountTestData());
    }

    protected CRUD<Account, Long> getServiceLayer(CRUD<Account, Long> dao)
    {
        AccountDAO accountDAO =
            (AccountDAO) Proxy.newProxyInstance(dao.getClass().getClassLoader(), new Class[] { AccountDAO.class },
                new DefaultProxy(dao));

        return new AccountResource(accountDAO);
    }

    @Test
    public void checkTestDataInitialAndUpdateAreDifferent() {
        Assert.assertFalse("Non-equal initial and update values should be specified in the test data set.",
                equality.checkEqualByValue(testData.getInitialValue(), testData.getUpdatedValue()));
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
