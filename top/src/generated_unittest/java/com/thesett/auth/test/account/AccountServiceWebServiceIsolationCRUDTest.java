package com.thesett.auth.test.account;

import java.lang.reflect.Proxy;

import com.thesett.test.base.WebServiceIsolationCRUDTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.proxies.DefaultProxy;

import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.model.Account;
import com.thesett.auth.services.rest.AccountResource;

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
}
