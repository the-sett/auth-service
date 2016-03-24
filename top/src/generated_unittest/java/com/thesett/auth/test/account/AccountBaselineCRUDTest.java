package com.thesett.auth.test.account;

import com.thesett.test.base.BaselineCRUDTestBase;

import com.thesett.auth.model.Account;    

public class AccountBaselineCRUDTest extends BaselineCRUDTestBase<Account, Long>
{
    public AccountBaselineCRUDTest()
    {
        super(new AccountTestData());
    }
}
