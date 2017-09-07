package com.thesett.auth.config;

/**
 * Holds the API roots of dependant services.
 *
 * <pre><p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities <th> Collaborations
 * <tr><td> Captures the API roots of dependant services.
 * </table></pre>
 *
 * @author Rupert Smith
 */
public class ApiConfiguration {
    private String root;
    private String avatarRoot;

    public String getRoot() {
        return root;
    }

    public void setRoot(String root) {
        this.root = root;
    }
}