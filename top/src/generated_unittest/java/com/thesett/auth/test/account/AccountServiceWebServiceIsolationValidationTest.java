package com.thesett.auth.test.account;

import java.lang.reflect.Proxy;
import java.util.Collection;

import org.junit.runners.Parameterized;
import com.thesett.test.base.WebServiceIsolationValidationTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.model.Account;
import com.thesett.auth.services.rest.AccountResource;

public class AccountServiceWebServiceIsolationValidationTest
    extends WebServiceIsolationValidationTestBase<Account, Long>
{
    public AccountServiceWebServiceIsolationValidationTest(Account example, boolean valid)
    {
        super(new AccountTestData(), example, valid);
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data()
    {
        return buildExamples(new AccountTestData());
    }

    protected CRUD<Account, Long> getServiceLayer(CRUD<Account, Long> dao)
    {
        AccountDAO accountDAO =
            (AccountDAO) Proxy.newProxyInstance(dao.getClass().getClassLoader(), new Class[] { AccountDAO.class },
                new DefaultProxy(dao));

        return new AccountResource(accountDAO);
    }
}
