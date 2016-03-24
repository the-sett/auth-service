/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.dao;

import javax.persistence.MappedSuperclass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

import com.thesett.util.security.dao.UserSecurityDAO;
import com.thesett.util.security.model.AuthUser;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;

/**
 * Provides the queries needed to retrieve user accounts for authentication.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Find users by username. </td></tr>
 * <tr><td> Find users by database id. </td></tr>
 * </table></pre>
 *
 * @author Rupert Smith
 */
@MappedSuperclass
@NamedQueries(
    {
        @NamedQuery(
            name = "com.thesett.util.security.model.AuthUser.findByUsername",
            query = "SELECT u FROM Account u WHERE u.username = :username"
        ),
        @NamedQuery(
            name = "com.thesett.util.security.model.AuthUser.findById",
            query =
                "SELECT u FROM Account u " + "LEFT JOIN FETCH u.roles roles " + "LEFT JOIN FETCH roles.permissions " +
                "WHERE u.id = :id"
        )
    }
)
public class UserSecurityDAOImpl implements UserSecurityDAO
{
    private final SessionFactory sessionFactory;

    public UserSecurityDAOImpl(SessionFactory sessionFactory)
    {
        this.sessionFactory = sessionFactory;
    }

    /** {@inheritDoc} */
    public AuthUser findUserByUsername(String username)
    {
        return findOne(namedQuery("com.thesett.util.security.model.AuthUser.findByUsername").setString("username",
                username));
    }

    /** {@inheritDoc} */
    public AuthUser retrieve(Long id)
    {
        return findOne(namedQuery("com.thesett.util.security.model.AuthUser.findById").setLong("id", id));
    }

    protected Query namedQuery(String queryName)
    {
        return this.currentSession().getNamedQuery(queryName);
    }

    protected AuthUser findOne(Query query)
    {
        return (AuthUser) ((Query) this.checkNotNull(query)).uniqueResult();
    }

    protected Session currentSession()
    {
        return this.sessionFactory.getCurrentSession();
    }

    protected <O> O checkNotNull(O object)
    {
        if (object == null)
        {
            throw new IllegalArgumentException();
        }
        else
        {
            return object;
        }
    }
}
