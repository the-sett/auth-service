package com.thesett.auth.test.permission;

import com.thesett.test.base.JsonSerDesCRUDTestBase;

import com.thesett.auth.model.Permission;    

public class PermissionJsonSerDesCRUDTest extends JsonSerDesCRUDTestBase<Permission, Long>
{
    public PermissionJsonSerDesCRUDTest()
    {
        super(new PermissionTestData());
    }
}
