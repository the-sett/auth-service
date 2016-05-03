package com.thesett.auth.test.permission;

import com.thesett.auth.test.AppTestSetupController;
import com.thesett.auth.top.Main;
import com.thesett.test.base.DatabaseCRUDTestBase;
import com.thesett.util.dao.HibernateTransactionalProxy;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.PermissionDAO;
import com.thesett.auth.dao.PermissionDAOImpl;
import com.thesett.auth.model.Permission;

public class PermissionDatabaseCRUDTest extends DatabaseCRUDTestBase<Permission, Long>
{
    public PermissionDatabaseCRUDTest()
    {
        super(new PermissionTestData(), Permission.class, new AppTestSetupController(), Main.class,
            ResourceUtils.resourceFilePath("config.yml"));
    }

    /** {@inheritDoc} */
    protected CRUD<Permission, Long> getDao()
    {
        return new PermissionDAOImpl(sessionFactory, validatorFactory);
    }

    /** {@inheritDoc} */
    protected PermissionDAO getTransactionalDAO()
    {
        PermissionDAO permissionDAO = new PermissionDAOImpl(sessionFactory, validatorFactory);

        return HibernateTransactionalProxy.proxy(permissionDAO, PermissionDAO.class, sessionFactory);
    }
}
