package com.thesett.auth.test.role;

import com.thesett.test.base.BaselineCRUDTestBase;

import com.thesett.auth.model.Role;    

public class RoleBaselineCRUDTest extends BaselineCRUDTestBase<Role, Long>
{
    public RoleBaselineCRUDTest()
    {
        super(new RoleTestData());
    }
}
