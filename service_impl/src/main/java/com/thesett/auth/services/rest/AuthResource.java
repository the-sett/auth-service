/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.KeyPair;
import java.util.LinkedHashSet;
import java.util.Set;

import javax.ws.rs.Consumes;
import javax.ws.rs.CookieParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Cookie;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.NewCookie;
import javax.ws.rs.core.Response;

import com.thesett.auth.dao.AccountDAO;
import com.thesett.auth.model.Account;
import com.thesett.auth.model.AuthRequest;
import com.thesett.auth.model.Role;
import com.thesett.util.collections.CollectionUtil;
import com.thesett.util.jersey.UnitOfWorkWithDetach;
import com.thesett.util.security.jwt.JwtUtils;
import com.thesett.util.string.StringUtils;

import io.dropwizard.hibernate.UnitOfWork;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;

/**
 * AuthResource provides authentication end-points, and supplies JWT tokens in response to valid requests.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Authenticate Users </td></tr>
 * <tr><td> Refresh Logins </td></tr>
 * <tr><td> Logout Users </td></tr>
 * </table></pre>
 *
 * @author Rupert Smith
 */
@Path("/auth/")
@Api(value = "/auth/", description = "API for handling authentication requests.")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class AuthResource
{
    /** Status code to respond to failed logins with. */
    public static final Response UNAUTHORIZED = Response.status(401).build();

    /** An asymmetric crypto kay pair for creating and checking tokens. */
    private final KeyPair keyPair;

    /** The account DAO for verifying logins against. */
    private final AccountDAO accountDAO;

    /**
     * Creates a set of authentication end-points, against the accounts accessible through the specified accounts DAO.
     *
     * @param accountDAO The accounts DAO, to verify user accounts against.
     * @param keyPair    An asymmetric crypto kay pair for creating and checking tokens.
     */
    public AuthResource(AccountDAO accountDAO, KeyPair keyPair)
    {
        this.accountDAO = accountDAO;

        this.keyPair = keyPair;
    }

    /**
     * Authenticates a user by username and password. If the request is successful a JWT token is returned as an
     * 'httpOnly' cookie. The JWT token will contain the username as subject, and the users roles as valid claims. The
     * token is also returned in the body, as it can be useful for a front-end to customize itself based on what rights
     * a user has.
     *
     * @param  authRequest The username/password authentication request.
     *
     * @return A response with the JWT as an httpOnly cookie, and in the body, or the {@link #UNAUTHORIZED} return code
     *         when the login is not accepted.
     */
    @POST
    @Path("/login")
    @UnitOfWork
    @ApiOperation(value = "Authenticates a user by username and password.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = String.class),
                @ApiResponse(code = 401, message = "User not authenticated.")
            }
    )
    public Response login(AuthRequest authRequest)
    {
        // Check the request against the accounts.
        Account account =
            CollectionUtil.first(accountDAO.findByExample(new Account().withUsername(authRequest.getUsername())));

        if (account == null)
        {
            return UNAUTHORIZED;
        }

        if (!account.getPassword().equals(authRequest.getPassword()))
        {
            return UNAUTHORIZED;
        }

        // Extract the users permissions into a description of their access claims.
        Set<String> permissions = new LinkedHashSet<>();

        if (account.getRoles() != null)
        {
            for (Role role : account.getRoles())
            {
                if (role.getPermissions() != null)
                {
                    for (String permission : role.getPermissions())
                    {
                        permissions.add(permission);
                    }
                }
            }
        }

        // Create the JWT token with claims matching the account, as a cookie.
        String token = JwtUtils.createToken(account.getUsername(), permissions, keyPair.getPrivate());
        NewCookie cookie = new NewCookie("jwt", token, "/", "localhost", "jwt", 600, false, true);

        Response response = Response.ok().cookie(cookie).entity("\"" + token + "\"").build();

        return response;
    }

    /**
     * Refreshes the callers JWT token, provided they are currently logged in with a valid token.
     *
     * @param  cookie The callers JWT token cookie.
     *
     * @return <tt>true</tt> iff the caller has a currently valid token.
     */
    @GET
    @Path("/refresh")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Checks if a user token is authenticated.")
    public boolean isAuthenticated(@CookieParam(value = "jwt") Cookie cookie)
    {
        System.out.println("cookie = " + cookie);

        if (cookie == null)
        {
            return false;
        }

        String token = cookie.getValue();
        System.out.println("token = " + token);

        return !StringUtils.nullOrEmpty(token) && JwtUtils.checkToken(token, keyPair.getPublic());
    }

    /**
     * Removes the callers JWT token cookie.
     *
     * @return An OK response, with a JWT cookie set to expire in the past.
     */
    @POST
    @Path("/logout")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Removes the authentication cookie.")
    public Response logout()
    {
        return Response.ok().header("Set-Cookie",
            "jwt=deleted;Domain=localhost;Path=/;Expires=Thu, 01-Jan-1970 00:00:01 GMT").build();
    }
}
