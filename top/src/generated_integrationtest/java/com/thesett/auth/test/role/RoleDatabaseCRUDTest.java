package com.thesett.auth.test.role;

import com.thesett.auth.test.AppTestSetupController;
import com.thesett.auth.top.Main;
import com.thesett.test.base.DatabaseCRUDTestBase;
import com.thesett.util.dao.HibernateTransactionalProxy;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.RoleDAO;
import com.thesett.auth.dao.RoleDAOImpl;
import com.thesett.auth.model.Role;

public class RoleDatabaseCRUDTest extends DatabaseCRUDTestBase<Role, Long>
{
    public RoleDatabaseCRUDTest()
    {
        super(new RoleTestData(), Role.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Role, Long> getDao()
    {
        return new RoleDAOImpl(sessionFactory, validatorFactory);
    }

    /** {@inheritDoc} */
    protected RoleDAO getTransactionalDAO()
    {
        RoleDAO roleDAO = new RoleDAOImpl(sessionFactory, validatorFactory);

        return HibernateTransactionalProxy.proxy(roleDAO, RoleDAO.class, sessionFactory);
    }
}
