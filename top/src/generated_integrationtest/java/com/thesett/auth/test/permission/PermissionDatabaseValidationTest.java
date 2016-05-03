package com.thesett.auth.test.permission;

import java.util.Collection;

import com.thesett.auth.top.Main;
import org.junit.runners.Parameterized;
import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.base.DatabaseValidationTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.PermissionDAOImpl;
import com.thesett.auth.model.Permission;

public class PermissionDatabaseValidationTest extends DatabaseValidationTestBase<Permission, Long>
{
    public PermissionDatabaseValidationTest(Permission example, boolean valid)
    {
        super(new PermissionTestData(), Permission.class, example, valid, new AppTestSetupController(),
            Main.class, ResourceUtils.resourceFilePath("config.yml"));
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data()
    {
        return buildExamples(new PermissionTestData());
    }

    /** {@inheritDoc} */
    protected CRUD<Permission, Long> getDao()
    {
        return new PermissionDAOImpl(sessionFactory, validatorFactory);
    }
}
