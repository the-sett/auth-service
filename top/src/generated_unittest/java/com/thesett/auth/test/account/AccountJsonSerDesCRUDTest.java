package com.thesett.auth.test.account;

import com.thesett.test.base.JsonSerDesCRUDTestBase;

import com.thesett.auth.model.Account;
import org.junit.Assert;
import org.junit.Test;

public class AccountJsonSerDesCRUDTest extends JsonSerDesCRUDTestBase<Account, Long>
{
    public AccountJsonSerDesCRUDTest()
    {
        super(new AccountTestData());
    }

    @Test
    public void checkTestDataInitialAndUpdateAreDifferent() {
        Assert.assertFalse("Non-equal initial and update values should be specified in the test data set.",
                equality.checkEqualByValue(testData.getInitialValue(), testData.getUpdatedValue()));
    }
}
