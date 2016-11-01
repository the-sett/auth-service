/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import org.apache.shiro.crypto.RandomNumberGenerator;
import org.apache.shiro.crypto.SecureRandomNumberGenerator;
import org.apache.shiro.crypto.hash.Sha256Hash;

/**
 * PasswordHasherSha256 salts and hashes a password using SHA-256 for a defined number of iterations.
 *
 * <p/>The hashed password can be check with Shiro's Sha256CredentialsMatcher.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Hash passwords with salt and key stretching. </td></tr>
 * </table></pre>
 */
public class PasswordHasherSha256
{
    /** The number of key stretching iterations to perform. */
    private final int hashIterations;

    /** A secure random number generator for the salt. */
    private RandomNumberGenerator random;

    /**
     * Creates a password hasher.
     *
     * @param iterations The number of key stretching iterations to use.
     */
    public PasswordHasherSha256(int iterations)
    {
        this.hashIterations = iterations;
        random = new SecureRandomNumberGenerator();
    }

    /**
     * Hashes a password with salt and key-stretching.
     *
     * @param  password The password to hash.
     *
     * @return The hashed password.
     */
    public String hash(String password)
    {
        Object salt = random.nextBytes();
        String result = new Sha256Hash(password, salt, hashIterations).toBase64();

        return result;
    }
}
