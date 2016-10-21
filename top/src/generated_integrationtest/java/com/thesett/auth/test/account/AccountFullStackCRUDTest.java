package com.thesett.auth.test.account;

import com.thesett.auth.dao.RoleDAOImpl;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.RoleService;
import com.thesett.auth.services.rest.RoleResource;
import com.thesett.test.controllers.GenericDAOFactory;
import com.thesett.test.controllers.HibernateTransactionDAOFactory;
import com.thesett.util.entity.EntityAlreadyExistsException;
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
import com.thesett.util.entity.EntityException;

import com.thesett.auth.dao.AccountDAOImpl;
import com.thesett.auth.model.Account;
import com.thesett.auth.services.AccountService;
import com.thesett.auth.services.rest.AccountResource;

import java.util.HashSet;
import java.util.Set;

public class AccountFullStackCRUDTest extends FullStackCRUDTestBase<Account, Long>
{
    /** A role for using with tests. */
    private Set<Role> testRoles;

    public AccountFullStackCRUDTest()
    {
        super(new AccountTestData(), Account.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Account, Long> getServiceLayer()
    {
        AccountDAOImpl accountDAO = new AccountDAOImpl(sessionFactory, validatorFactory);
        RoleDAOImpl roleDAO = new RoleDAOImpl(sessionFactory, validatorFactory);

        AccountResource accountResource = new AccountResource(accountDAO, roleDAO);

        return HibernateSessionAndDetachProxy.proxy(accountResource, AccountService.class, sessionFactory);
    }

    protected RoleService getRoleService()
    {
        RoleDAOImpl roleDAO = new RoleDAOImpl(sessionFactory, validatorFactory);

        RoleResource roleResource = new RoleResource(roleDAO);

        return HibernateSessionAndDetachProxy.proxy(roleResource, RoleService.class, sessionFactory);
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

    @Before
    public void prerequisites()
    {
        ((AccountTestData) testData).createPrerequisites(
                testSetupController.getTransactionalReflectiveDAOFactory(sessionFactory, validatorFactory));
    }

    @Before
    public void createRole() throws Exception
    {
        if (fireOnceRule.shouldFireRule()) {
            RoleService roleService = getRoleService();

            testRoles = new HashSet<>();
            testRoles.add(roleService.create(new Role().withName("testRole")));
        }
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
    public void testUpdateUsernameCannotBeChanged() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account.setUsername("changed");
        account = accountService.update(account.getId(), account);

        Assert.assertEquals("The username should not be able to be changed.", "test", account.getUsername());
    }

    @Test
    public void testUpdateAcceptsPasswordChange() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account.setPassword("newpass");
        account = accountService.update(account.getId(), account);
    }

    @Test
    public void testUpdateAcceptsNoPasswordChange() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account.setPassword(null);
        account = accountService.update(account.getId(), account);
    }

    @Test
    public void testCreatedAccountDoesNotExposePassword() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        Assert.assertNull("Password should not be returned.", account.getPassword());
    }

    @Test
    public void testRetrievedAccountDoesNotExposePassword() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account = accountService.retrieve(account.getId());

        Assert.assertNull("Password should not be returned.", account.getPassword());
    }

    @Test
    public void testUpdatedAccountDoesNotExposePassword() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account = accountService.update(account.getId(), account);

        Assert.assertNull("Password should not be returned.", account.getPassword());
    }

    @Test(expected = EntityException.class)
    public void testCreateAtLeastOneRoleMustBeSet() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password");
    }

    @Test(expected = EntityException.class)
    public void testUpdateAtLeastOneRoleMustBeSet() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account.setRoles(null);
        account = accountService.update(account.getId(), account);
    }

    @Test(expected = EntityException.class)
    public void testCreateAllRolesSetMustExist() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Set<Role> badRoles = new HashSet<>();
        Role badRole = new Role().withName("unknown role");
        badRole.setId(9999999L);
        badRoles.add(badRole);

        Account account = new Account().withUsername("test").withPassword("password").withRoles(badRoles);
        account = accountService.create(account);
    }

    @Test(expected = EntityException.class)
    public void testUpdateAllRolesSetMustExist() throws Exception {
        AccountService accountService = (AccountService) getServiceLayer();

        Set<Role> badRoles = new HashSet<>();
        Role badRole = new Role().withName("unknown role");
        badRole.setId(9999999L);
        badRoles.add(badRole);

        Account account = new Account().withUsername("test").withPassword("password").withRoles(testRoles);
        account = accountService.create(account);

        account.setRoles(badRoles);
        account = accountService.update(account.getId(), account);
    }

    @Test
    public void testJsonSchema() throws Exception {
        testJsonSchema("schema");
    }
}
