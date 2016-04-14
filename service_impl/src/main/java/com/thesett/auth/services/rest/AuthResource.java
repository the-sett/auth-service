/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.Key;
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

import com.thesett.auth.model.Account;
import com.thesett.auth.model.AuthRequest;
import com.thesett.auth.model.Role;
import com.thesett.auth.services.AccountService;
import com.thesett.util.collections.CollectionUtil;
import com.thesett.util.jersey.UnitOfWorkWithDetach;
import com.thesett.util.string.StringUtils;

import io.dropwizard.hibernate.UnitOfWork;
import io.jsonwebtoken.*;
import io.jsonwebtoken.impl.crypto.MacProvider;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;

/**
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td>
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
    public static final Key TEMP_KEY = MacProvider.generateKey();
    public static final Response UNAUTHORIZED = Response.status(401).build();

    private final AccountService accountResource;

    public AuthResource(AccountService accountResource)
    {
        this.accountResource = accountResource;
    }

    /**
     * Authenticates a user by username and password. If the request is successful a JWT token is returned
     * as an 'httpOnly' cookie. The JWT token will contain the username as subject, and the users roles
     * as valid claims. The token is also returned in the body, as it can be useful for a front-end to customize
     * itself based on what rights a user has.
     *
     * @param authRequest The username/password authentication request.
     *
     * @return
     */
    @POST
    @Path("/authenticate")
    @UnitOfWork
    @ApiOperation(value = "Authenticates a user by username and password.")
    @ApiResponses(
        value =
            {
                @ApiResponse(code = 200, message = "Success.", response = String.class),
                @ApiResponse(code = 401, message = "User not authenticated.")
            }
    )
    public Response authenticate(AuthRequest authRequest)
    {
        // Check the request against the accounts.
        Account account =
            CollectionUtil.first(accountResource.findByExample(new Account().withUsername(authRequest.getUsername())));

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

    @GET
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

    @POST
    @Path("/logout")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Removes the authentication cookie.")
    public Response logout()
    {
        return Response.ok().header("Set-Cookie",
            "jwt=deleted;Domain=localhost;Path=/;Expires=Thu, 01-Jan-1970 00:00:01 GMT").build();
    }

    private String createToken(Account account, Set<String> permissions)
    {
        JwtBuilder builder = Jwts.builder();
        builder.setSubject(account.getUsername());

        for (String permission : permissions)
        {
            builder.claim(permission, true);
        }

        builder.signWith(SignatureAlgorithm.HS512, TEMP_KEY);

        return builder.compact();
    }

    private boolean checkToken(String token)
    {
        try
        {
            Jwts.parser().setSigningKey(TEMP_KEY).parseClaimsJws(token);

            return true;
        }
        catch (SignatureException | UnsupportedJwtException | ExpiredJwtException | MalformedJwtException e)
        {
            return false;
        }
    }
}
