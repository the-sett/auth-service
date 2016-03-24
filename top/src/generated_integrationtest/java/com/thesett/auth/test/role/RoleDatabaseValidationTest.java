package com.thesett.auth.test.role;

import java.util.Collection;

import com.thesett.auth.top.Main;
import org.junit.runners.Parameterized;
import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.base.DatabaseValidationTestBase;
import com.thesett.util.entity.CRUD;
import com.thesett.util.resource.ResourceUtils;

import com.thesett.auth.dao.RoleDAOImpl;
import com.thesett.auth.model.Role;

public class RoleDatabaseValidationTest extends DatabaseValidationTestBase<Role, Long>
{
    public RoleDatabaseValidationTest(Role example, boolean valid)
    {
        super(new RoleTestData(), Role.class, example, valid, new AppTestSetupController(),
            Main.class, ResourceUtils.resourceFilePath("config.yml"));
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data()
    {
        return buildExamples(new RoleTestData());
    }

    /** {@inheritDoc} */
    protected CRUD<Role, Long> getDao()
    {
        return new RoleDAOImpl(sessionFactory, validatorFactory);
    }
}
