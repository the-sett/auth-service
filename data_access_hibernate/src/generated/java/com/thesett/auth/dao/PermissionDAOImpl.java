package com.thesett.auth.dao;

import javax.persistence.MappedSuperclass;
import javax.persistence.NamedQueries;
import javax.validation.ValidatorFactory;

import org.hibernate.SessionFactory;

import com.thesett.util.dao.HibernateBaseDAO;
import com.thesett.auth.model.Permission;

/**
 * PermissionDAOImpl provides an implementation of the DAO for Permission using
 * Hibernate.
 *
 * @author Generated Code
 */
@MappedSuperclass
@NamedQueries({})
public class PermissionDAOImpl extends HibernateBaseDAO<Permission, Long> implements PermissionDAO {
    /**
     * Creates the DAO on the provided Hibernate session factory.
     *
     * @param sessionFactory   The hibernate session factory to use.
     * @param validatorFactory The bean validator factory to use to validate all data prior to insertion.
     */
    public PermissionDAOImpl(SessionFactory sessionFactory, ValidatorFactory validatorFactory) {
        super(sessionFactory, validatorFactory);
    }
}
