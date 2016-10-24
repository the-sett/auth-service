package com.thesett.auth.test.account;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.model.Role;
import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.controllers.ReflectiveDAOFactory;
import com.thesett.test.stack.ModelEqualityByValue;
import com.thesett.test.stack.TestDataSupplierLongKey;

import com.thesett.auth.model.Account;
import com.thesett.util.entity.CRUD;
import com.thesett.util.entity.EntityException;

public class AccountTestData extends TestDataSupplierLongKey<Account>
{
    private Role role = new Role().withName("testRole");
    private Role refRole = new Role();

    public void createPrerequisites(ReflectiveDAOFactory daoFactory)
    {
        CRUD<Role, Long> roleDAO = daoFactory.getDAO(RoleDAO.class);

        try
        {
            roleDAO.create(role);
            refRole.setId(role.getId());
        }
        catch (EntityException e)
        {
            throw new IllegalStateException(e);
        }
    }


    public AccountTestData()
    {
        Set<Role> roleSet = new HashSet<>();
        roleSet.add(role);

        initialValue = new Account().withUsername("user1").withPassword("password").withRoot(true).withRoles(roleSet);
        updatedValue = new Account().withUsername("user1").withRoot(false).withRoles(roleSet);
    }

    /** {@inheritDoc} */
    public Account getDefaultValue()
    {
        return new Account();
    }

    /** {@inheritDoc} */
    public List<Account> examples()
    {
        return new LinkedList<Account>()
            {
                {
                }
            };
    }

    /** {@inheritDoc} */
    public List<Account> counterExamples()
    {
        return new LinkedList<Account>()
            {
                {
                }
            };
    }

    /** {@inheritDoc} */
    public ModelEqualityByValue getEqualityChecker()
    {
        return AppTestSetupController.MODEL_EQUALITY_BY_VALUE;
    }
}
