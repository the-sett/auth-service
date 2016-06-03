/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.rest;

import java.security.PublicKey;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.client.Client;

import com.thesett.auth.services.config.ClientSecretsConfiguration;
import com.thesett.util.security.jwt.JwtUtils;
import com.thesett.util.security.model.JWTAuthenticationToken;
import com.thesett.util.security.shiro.ShiroUtils;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;

/**
 * OAuthProviderResource provides a base class for implementing the interactions with OAuth providers.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Associate a user account with an OAuth provider with a local account.
 * </table></pre>
 *
 * @author Rupert Smith
 */
public abstract class OAuthProviderResource
{
    public static final String CLIENT_ID_KEY = "client_id";
    public static final String REDIRECT_URI_KEY = "redirect_uri";
    public static final String CLIENT_SECRET = "client_secret";
    public static final String CODE_KEY = "code";
    public static final String GRANT_TYPE_KEY = "grant_type";
    public static final String AUTH_CODE = "authorization_code";
    public static final String AUTH_HEADER_KEY = "Authorization";

    /** Provides client secrets for interacting with OAuth providers. */
    protected final ClientSecretsConfiguration secrets;

    /** Provides an HTTP client for interacting with OAuth providers. */
    protected final Client client;

    /**
     * Builds the base resource for interacting with an OAuth provider.
     *
     * @param secrets The client secrets for interacting with OAuth providers.
     * @param client  An HTTP client for interacting with OAuth providers.
     */
    public OAuthProviderResource(ClientSecretsConfiguration secrets, Client client)
    {
        this.secrets = secrets;
        this.client = client;
    }

    protected void processUser(Provider provider, String id, String displayName)
    {
        System.out.println("=========================");
        System.out.println("provider = " + provider);
        System.out.println("id = " + id);
        System.out.println("displayName = " + displayName);

        // If user is already signed in then link accounts.
        Subject subject = SecurityUtils.getSubject();
        boolean authenticated = subject.isAuthenticated();

        if (authenticated)
        {
            System.out.println("Authenticated, primary principal = " + subject.getPrincipal());

            System.out.println("Linking accounts...");
        }

        // Create a new user account or return an existing one.
        if (!authenticated) {
            System.out.println("Not already authenticated.");
        }
    }

    protected void setupShiroSubjectByJWTToken(HttpServletRequest request, PublicKey publicKey)
    {
        boolean tokenExtracted = JwtUtils.extractJWTtoRequestAttribute(request, "jwt", "jwt");

        if (tokenExtracted)
        {
            JWTAuthenticationToken jwt = JwtUtils.getAuthenticationToken(request, "jwt");

            jwt.setPublicKey(publicKey);

            boolean tokenIsValid = jwt.checkValid();

            if (tokenIsValid)
            {
                jwt.extractClaims();

                Subject subject = jwt.asLocalSubject();
                ShiroUtils.setSubject(subject);
            }
        }
    }
}
