/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.Cookie;
import javax.ws.rs.core.Response;

import com.thesett.auth.model.AuthRequest;
import com.thesett.auth.model.RefreshRequest;

/**
 * AuthService provides endpoints to authenticate against, to refresh authentication tokens, and to logout.
 *
 * <p/>TODO: This should expose the non-cookie based auth endpoints only.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities
 * <tr><td> Authenticate Users </td></tr>
 * <tr><td> Refresh Logins </td></tr>
 * <tr><td> Logout Users </td></tr>
 * </table></pre>
 *
 * @author Rupert Smith
 */
public interface AuthService
{
    /**
     * Authenticates a user by username and password. If the request is successful a JWT token is returned as an
     * 'httpOnly' cookie. The JWT token will contain the username as subject, and the users roles as valid claims. The
     * token is also returned in the body, as it can be useful for a front-end to customize itself based on what rights
     * a user has.
     *
     * @param  authRequest The username/password authentication request.
     *
     * @return A response with the JWT as an httpOnly cookie, and in the body paired with the refresh token, or the HTTP
     *         401 return code when the login is not accepted.
     */
    Response login(HttpServletRequest request, AuthRequest authRequest);

    /**
     * Refreshes the callers access tokens, provided they have a valid refresh token.
     *
     * @param  refreshRequest The refresh request with the refresh token in it.
     *
     * @return A response with the JWT as an httpOnly cookie, and in the body paired with the refresh token, or the HTTP
     *         401 return code when the login is not accepted.
     */
    Response refresh(HttpServletRequest request, RefreshRequest refreshRequest);

    /**
     * Refreshes the auth token from a refresh token held in a cookie.
     *
     * @return A response with the JWT as an httpOnly cookie, and in the body paired with the refresh token, or the HTTP
     *         401 return code when the login is not accepted.
     */
    Response restore(HttpServletRequest request, Cookie cookie);

    /**
     * Removes the callers JWT token cookie.
     *
     * @return An OK response, with a JWT cookie set to expire in the past.
     */
    Response logout();
}
