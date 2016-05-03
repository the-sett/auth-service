package com.thesett.auth.services.local;

import com.thesett.auth.services.ServiceFactory;

import org.hibernate.SessionFactory;
import static com.thesett.util.dao.HibernateSessionAndDetachProxy.proxy;

import com.thesett.auth.services.AccountService;

import com.thesett.auth.services.RoleService;

import com.thesett.auth.services.PermissionService;


public class LocalServiceFactory implements ServiceFactory {

    private final AccountService accountService;

    private final RoleService roleService;

    private final PermissionService permissionService;


    public LocalServiceFactory(SessionFactory sessionFactory, AccountService accountService, RoleService roleService, PermissionService permissionService) {
        this.accountService = proxy(accountService, AccountService.class, sessionFactory);

        this.roleService = proxy(roleService, RoleService.class, sessionFactory);

        this.permissionService = proxy(permissionService, PermissionService.class, sessionFactory);

    }

    /** {@inheritDoc} */
    public AccountService getAccountService() {
        return accountService;
    }

    /** {@inheritDoc} */
    public RoleService getRoleService() {
        return roleService;
    }

    /** {@inheritDoc} */
    public PermissionService getPermissionService() {
        return permissionService;
    }

}