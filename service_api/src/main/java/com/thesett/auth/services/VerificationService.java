/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services;

import com.thesett.auth.model.Verifier;

/**
 * VerificationService provides information about the verification key and algorithm that can be used to verify tokens
 * issues by the auth server.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Provide verification keys. </td></tr>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public interface VerificationService
{
    /**
     * Provides information about the verification algorithm and key that should be used to verify all tokens issues by
     * the auth service.
     *
     * @return Information about the verification algorithm and key.
     */
    Verifier retrieve();
}
