package com.thesett.auth.test.role;

import com.thesett.test.base.JsonSerDesCRUDTestBase;

import com.thesett.auth.model.Role;    

public class RoleJsonSerDesCRUDTest extends JsonSerDesCRUDTestBase<Role, Long>
{
    public RoleJsonSerDesCRUDTest()
    {
        super(new RoleTestData());
    }
}
