/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
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
import com.thesett.util.string.StringUtils;

import io.dropwizard.hibernate.UnitOfWork;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.SignatureException;
import io.jsonwebtoken.UnsupportedJwtException;
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
@Path("/api/auth/")
@Api(value = "/api/auth/", description = "API for handling authentication requests.")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class AuthResource
{
    /** The public key for signature verification. */
    private static final PublicKey PUB_KEY;

    /** The secret key for signing access tokens. */
    private static final PrivateKey SECRET_KEY;

    // Initialize the key pair.
    static
    {
        KeyPairGenerator keyGenerator = null;

        try
        {
            keyGenerator = KeyPairGenerator.getInstance("RSA");
        }
        catch (NoSuchAlgorithmException e)
        {
            throw new IllegalStateException(e);
        }

        keyGenerator.initialize(1024);

        KeyPair kp = keyGenerator.genKeyPair();
        PUB_KEY = kp.getPublic();
        SECRET_KEY = kp.getPrivate();
    }

    /** Status code to respond to failed logins with. */
    public static final Response UNAUTHORIZED = Response.status(401).build();

    /** The account DAO for verifying logins against. */
    private final AccountDAO accountDAO;

    /**
     * Creates a set of authentication end-points, against the accounts accessible through the specified accounts DAO.
     *
     * @param accountDAO The accounts DAO, to verify user accounts against.
     */
    public AuthResource(AccountDAO accountDAO)
    {
        this.accountDAO = accountDAO;

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
        String token = createToken(account, permissions);
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

        return !StringUtils.nullOrEmpty(token) && checkToken(token);
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

    /**
     * Builds a JWT token with claims matching the users account and permissions.
     *
     * @param  account     The user account to extract the subject from.
     * @param  permissions The users permissions.
     *
     * @return A signed JWT token.
     */
    private String createToken(Account account, Set<String> permissions)
    {
        JwtBuilder builder = Jwts.builder();
        builder.setSubject(account.getUsername());

        for (String permission : permissions)
        {
            builder.claim(permission, true);
        }

        builder.signWith(SignatureAlgorithm.RS512, SECRET_KEY);

        return builder.compact();
    }

    /**
     * Parses a JWT token in order to confirm that it is valid.
     *
     * @param  token The JWT token to parse.
     *
     * @return <tt>true</tt> iff the token is valid.
     */
    private boolean checkToken(String token)
    {
        try
        {
            Jwts.parser().setSigningKey(PUB_KEY).parseClaimsJws(token);

            return true;
        }
        catch (SignatureException | UnsupportedJwtException | ExpiredJwtException | MalformedJwtException e)
        {
            return false;
        }
    }
}
