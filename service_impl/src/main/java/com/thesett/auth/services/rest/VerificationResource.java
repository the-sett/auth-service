/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.PublicKey;
import java.util.Base64;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.thesett.auth.model.Verifier;
import com.thesett.auth.services.VerificationService;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;

/**
 * VerificationResource provides information about the verification key and algorithm that can be used to verify tokens
 * issues by the auth server.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Provide verification keys. </td></tr>
 * </table></pre>
 *
 * @author Rupert Smith
 */
@Path("/auth/verification-key")
@Api(value = "/auth/verification-key", description = "API for providing verification keys.")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
public class VerificationResource implements VerificationService
{
    /** The verification key. */
    private final PublicKey verificationKey;

    /** The verification information. */
    private Verifier verifier;

    /** @param verificationKey The verification key which can be used to verify tokens issued by this auth server. */
    public VerificationResource(PublicKey verificationKey)
    {
        this.verificationKey = verificationKey;
        this.verifier =
            new Verifier().withAlg("RSA512").withKey(Base64.getEncoder().encodeToString(verificationKey.getEncoded()));
    }

    /** {@inheritDoc} */
    @Override
    @GET
    @ApiOperation(value = "Provides a description of the verification key.")
    public Verifier restore()
    {
        return verifier;
    }
}
