package com.thesett.auth.test.account;

import java.util.Collection;

import com.thesett.auth.top.Main;
import org.junit.runners.Parameterized;
import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.base.DatabaseValidationTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.model.Account;

public class AccountDatabaseValidationTest extends DatabaseValidationTestBase<Account, Long>
{
    public AccountDatabaseValidationTest(Account example, boolean valid)
    {
        super(new AccountTestData(), Account.class, example, valid, new AppTestSetupController(),
            Main.class, ResourceUtils.resourceFilePath("config.yml"));
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data()
    {
        return buildExamples(new AccountTestData());
    }

    /** {@inheritDoc} */
    protected CRUD<Account, Long> getDao()
    {
        return new AccountDAOImpl(sessionFactory, validatorFactory);
    }
}
