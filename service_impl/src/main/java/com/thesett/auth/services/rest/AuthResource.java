/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.Key;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.NewCookie;
import javax.ws.rs.core.Response;

import com.thesett.util.jersey.UnitOfWorkWithDetach;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.impl.crypto.MacProvider;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;

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

    @POST
    @Path("/authenticate")
    @UnitOfWorkWithDetach
    @ApiOperation(value = "Authenticate a user by username and password.")
    public Response authenticate()
    {
        String token = createToken("test");
        NewCookie cookie = new NewCookie("jwt", token, null, null, null, 0, true, true);
        JWT jwt = new JWT(token);
        Response response = Response.ok().cookie(cookie).entity(jwt).build();

        return response;
    }

    private String createToken(String subject)
    {
        return Jwts.builder().setSubject(subject).signWith(SignatureAlgorithm.HS512, TEMP_KEY).compact();
    }

    private void checkToken(String token)
    {
        assert Jwts.parser().setSigningKey(TEMP_KEY).parseClaimsJws(token).getBody().getSubject().equals("Joe");
    }

    private class JWT
    {
        private String jwt;

        public JWT(String jwt)
        {
            this.jwt = jwt;
        }

        public String getJwt()
        {
            return jwt;
        }

        public void setJwt(String jwt)
        {
            this.jwt = jwt;
        }
    }
}
