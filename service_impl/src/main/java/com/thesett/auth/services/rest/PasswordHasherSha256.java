/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.io.IOException;

import com.thesett.common.util.Pair;

import org.apache.shiro.crypto.RandomNumberGenerator;
import org.apache.shiro.crypto.SecureRandomNumberGenerator;
import org.apache.shiro.crypto.hash.Sha256Hash;
import org.apache.shiro.util.ByteSource;

import sun.misc.BASE64Decoder;

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
     * @return The hashed password and its randomly chosen salt.
     */
    public Pair<String, String> hash(String password)
    {
        ByteSource salt = random.nextBytes();
        String result = new Sha256Hash(password, salt, hashIterations).toBase64();

        return new Pair<>(result, salt.toBase64());
    }

    /**
     * Checks a password against a hash and its salt.
     *
     * @param  password The password to check.
     * @param  hash     The password hash.
     * @param  salt     The salt to use when hashing the password.
     *
     * @return <tt>true</tt> iff the password matches the hash, when hashed with the supplied salt.
     */
    public boolean checkHash(String password, String hash, String salt)
    {
        BASE64Decoder decoder = new BASE64Decoder();
        byte[] saltBytes = new byte[0];

        try
        {
            saltBytes = decoder.decodeBuffer(salt);
        }
        catch (IOException e)
        {
            throw new IllegalStateException("The salt does not contain base64 data.", e);
        }

        String result = new Sha256Hash(password, saltBytes, hashIterations).toBase64();

        return hash.equals(result);
    }
}
