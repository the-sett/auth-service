package com.thesett.auth.test.account;

import com.thesett.test.base.JsonSerDesCRUDTestBase;

import com.thesett.auth.model.Account;    

public class AccountJsonSerDesCRUDTest extends JsonSerDesCRUDTestBase<Account, Long>
{
    public AccountJsonSerDesCRUDTest()
    {
        super(new AccountTestData());
    }
}
