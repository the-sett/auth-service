package com.thesett.auth.test.permission;

import java.util.LinkedList;
import java.util.List;

import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.stack.ModelEqualityByValue;
import com.thesett.test.stack.TestDataSupplierLongKey;

import com.thesett.auth.model.Permission;    

public class PermissionTestData extends TestDataSupplierLongKey<Permission>
{
    public PermissionTestData()
    {
        initialValue = new Permission().withName("permission1");
        updatedValue = new Permission().withName("permission2");
    }

    /** {@inheritDoc} */
    public Permission getDefaultValue()
    {
        return new Permission();
    }

    /** {@inheritDoc} */
    public List<Permission> examples()
    {
        return new LinkedList<Permission>()
            {
                {
                }
            };
    }

    /** {@inheritDoc} */
    public List<Permission> counterExamples()
    {
        return new LinkedList<Permission>()
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
