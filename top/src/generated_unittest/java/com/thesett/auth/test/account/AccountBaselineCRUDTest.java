package com.thesett.auth.test.account;

import com.thesett.test.base.BaselineCRUDTestBase;

import com.thesett.auth.model.Account;
import org.junit.Assert;
import org.junit.Test;

public class AccountBaselineCRUDTest extends BaselineCRUDTestBase<Account, Long>
{
    public AccountBaselineCRUDTest()
    {
        super(new AccountTestData());
    }

    @Test
    public void checkTestDataInitialAndUpdateAreDifferent() {
        Assert.assertFalse("Non-equal initial and update values should be specified in the test data set.",
                equality.checkEqualByValue(testData.getInitialValue(), testData.getUpdatedValue()));
    }
}
