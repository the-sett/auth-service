/* Copyright Rupert Smith, 2005 to 2008, all rights reserved. */
package com.thesett.auth.services.config;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ClientSecretsConfiguration
{
    @JsonProperty String facebook;

    @JsonProperty String google;

    @JsonProperty String github;

    public String getFacebook()
    {
        return facebook;
    }

    public void setFacebook(String facebook)
    {
        this.facebook = facebook;
    }

    public String getGoogle()
    {
        return google;
    }

    public void setGoogle(String google)
    {
        this.google = google;
    }

    public String getGithub()
    {
        return github;
    }

    public void setGithub(String github)
    {
        this.github = github;
    }
}
