package com.thesett.auth.services.local;

import com.thesett.auth.services.ServiceFactory;

import org.hibernate.SessionFactory;
import static com.thesett.util.dao.HibernateSessionAndDetachProxy.proxy;

import com.thesett.auth.services.AccountService;

import com.thesett.auth.services.RoleService;


public class LocalServiceFactory implements ServiceFactory {

    private final AccountService accountService;

    private final RoleService roleService;


    public LocalServiceFactory(SessionFactory sessionFactory, AccountService accountService, RoleService roleService) {
        this.accountService = proxy(accountService, AccountService.class, sessionFactory);

        this.roleService = proxy(roleService, RoleService.class, sessionFactory);

    }

    /** {@inheritDoc} */
    public AccountService getAccountService() {
        return accountService;
    }

    /** {@inheritDoc} */
    public RoleService getRoleService() {
        return roleService;
    }

}