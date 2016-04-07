/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.Key;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

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
    public JWT authenticate()
    {
        return new JWT(createToken("test"));
    }

    private String createToken(String subject)
    {
        String token = Jwts.builder().setSubject(subject).signWith(SignatureAlgorithm.HS512, TEMP_KEY).compact();

        return token;
    }

    private void checkToken(String token)
    {
        assert Jwts.parser().setSigningKey(TEMP_KEY).parseClaimsJws(token).getBody().getSubject().equals("Joe");
    }

    private class JWT
    {
        private String token;

        public JWT(String token)
        {
            this.token = token;
        }

        public String getToken()
        {
            return token;
        }

        public void setToken(String token)
        {
            this.token = token;
        }
    }
}
