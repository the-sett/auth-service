package com.thesett.auth.test.account;

import java.util.LinkedList;
import java.util.List;

import com.thesett.auth.test.AppTestSetupController;
import com.thesett.test.stack.ModelEqualityByValue;
import com.thesett.test.stack.TestDataSupplierLongKey;

import com.thesett.auth.model.Account;    

public class AccountTestData extends TestDataSupplierLongKey<Account>
{
    public AccountTestData()
    {
        initialValue = new Account().withUsername("user1");
        updatedValue = new Account().withUsername("user2");
    }

    /** {@inheritDoc} */
    public Account getDefaultValue()
    {
        return new Account();
    }

    /** {@inheritDoc} */
    public List<Account> examples()
    {
        return new LinkedList<Account>()
            {
                {
                }
            };
    }

    /** {@inheritDoc} */
    public List<Account> counterExamples()
    {
        return new LinkedList<Account>()
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
