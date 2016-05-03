package com.thesett.auth.test.role;

import java.util.LinkedList;
import java.util.List;

import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.stack.ModelEqualityByValue;
import com.thesett.test.stack.TestDataSupplierLongKey;

import com.thesett.auth.model.Role;    

public class RoleTestData extends TestDataSupplierLongKey<Role>
{
    public RoleTestData()
    {
        initialValue = new Role().withName("role1");
        updatedValue = new Role().withName("role2");
    }

    /** {@inheritDoc} */
    public Role getDefaultValue()
    {
        return new Role();
    }

    /** {@inheritDoc} */
    public List<Role> examples()
    {
        return new LinkedList<Role>()
            {
                {
                }
            };
    }

    /** {@inheritDoc} */
    public List<Role> counterExamples()
    {
        return new LinkedList<Role>()
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
