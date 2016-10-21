package com.thesett.auth.test.account;

import com.thesett.auth.test.AppTestSetupController;
import com.thesett.auth.top.Main;
import com.thesett.test.base.DatabaseCRUDTestBase;
import com.thesett.test.controllers.HibernateTransactionDAOFactory;
import com.thesett.util.dao.HibernateTransactionalProxy;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.model.Account;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class AccountDatabaseCRUDTest extends DatabaseCRUDTestBase<Account, Long>
{
    public AccountDatabaseCRUDTest()
    {
        super(new AccountTestData(), Account.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Account, Long> getDao()
    {
        return new AccountDAOImpl(sessionFactory, validatorFactory);
    }

    /** {@inheritDoc} */
    protected AccountDAO getTransactionalDAO()
    {
        AccountDAO accountDAO = new AccountDAOImpl(sessionFactory, validatorFactory);

        return HibernateTransactionalProxy.proxy(accountDAO, AccountDAO.class, sessionFactory);
    }

    @Before
    public void prequisites()
    {
        ((AccountTestData) testData).createPrerequisites(new HibernateTransactionDAOFactory(sessionFactory,
                validatorFactory));
    }

    @Test
    public void checkTestDataInitialAndUpdateAreDifferent() {
        Assert.assertFalse("Non-equal initial and update values should be specified in the test data set.",
                equality.checkEqualByValue(testData.getInitialValue(), testData.getUpdatedValue()));
    }
}
