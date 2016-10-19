package com.thesett.auth.test.account;

import com.thesett.util.security.shiro.LocalSubject;
import com.thesett.util.security.shiro.ShiroUtils;
import org.apache.shiro.subject.Subject;
import org.junit.*;
import com.thesett.auth.test.AppTestSetupController;
import com.thesett.auth.top.Main;
import com.thesett.test.base.FullStackCRUDTestBase;
import com.thesett.util.dao.HibernateSessionAndDetachProxy;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.model.Account;
import com.thesett.auth.services.AccountService;
import com.thesett.auth.services.rest.AccountResource;

public class AccountFullStackCRUDTest extends FullStackCRUDTestBase<Account, Long>
{
    public AccountFullStackCRUDTest()
    {
        super(new AccountTestData(), Account.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Account, Long> getServiceLayer()
    {
        AccountDAOImpl accountDAO = new AccountDAOImpl(sessionFactory, validatorFactory);

        AccountResource accountResource = new AccountResource(accountDAO);

        return HibernateSessionAndDetachProxy.proxy(accountResource, AccountService.class, sessionFactory);
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

    @Test
    public void testFindAllNotEmpty() throws Exception {
        testFindAllNotEmpty("findAll");
    }

    @Test
    public void testFindByExampleNotEmpty() throws Exception {
        testFindByExampleNotEmpty("findByExample");
    }

    @Test
    public void testJsonSchema() throws Exception {
        testJsonSchema("schema");
    }
}
