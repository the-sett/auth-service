package com.thesett.auth.test.permission;

import com.thesett.test.base.BaselineCRUDTestBase;

import com.thesett.auth.model.Permission;    

public class PermissionBaselineCRUDTest extends BaselineCRUDTestBase<Permission, Long>
{
    public PermissionBaselineCRUDTest()
    {
        super(new PermissionTestData());
    }
}
