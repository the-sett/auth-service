package com.thesett.auth.client;

import java.util.List;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;

import com.fasterxml.jackson.jaxrs.json.JacksonJsonProvider;

import org.glassfish.jersey.client.ClientConfig;
import org.glassfish.jersey.client.proxy.WebResourceFactory;

import com.thesett.auth.services.ServiceFactory;

import com.thesett.util.client.WebExceptionCodeClientProxy;
import com.thesett.util.json.JodaTimeObjectMapperProvider;
import com.thesett.util.model.RefDataItem;    
import com.thesett.util.services.ReferenceDataService;
import com.thesett.aima.attribute.impl.EnumeratedStringAttribute;    
import com.thesett.auth.services.AccountClient;
import com.thesett.auth.services.AccountService;
import com.thesett.auth.services.RoleClient;
import com.thesett.auth.services.RoleService;

/**
 * RestJSONClientFactory implements a factory that can supply instances of the service interfaces, as web
 * clients over REST and JSON.
 */
public class ClientServiceFactory implements ServiceFactory {
    /** The base URL to access the services through. */
    private final String baseURL;

    /** A client configuration to use for all services. */
    private final ClientConfig clientConfig;

    /**
     * Creates an instance of the client factory.
     *
     * @param baseURL The base URL to access the api through. This should include the full path to the root of the api
     *                resources, for example, "http://localhost:8080/api".
     */
    public ClientServiceFactory(String baseURL) {
        this.baseURL = baseURL;

        // Set things up to use Jackson JSON.

        clientConfig = new ClientConfig();
        clientConfig.register(JacksonJsonProvider.class);
        clientConfig.register(JodaTimeObjectMapperProvider.class);

        initializeReferenceData();
    }

    /**
     * Creates a proxied client using the supplied interface.
     *
     * @param  resourceInterface The interface to proxy.
     * @param  <T>               The type of the service being proxied.
     *
     * @return A proxied client service.
     */
    public <T> T createClientProxy(Class<T> resourceInterface) {
        Client client = ClientBuilder.newClient(clientConfig);
        WebTarget target = client.target(baseURL);

        T clientProxy = WebResourceFactory.newResource(resourceInterface, target);

        return WebExceptionCodeClientProxy.proxy(clientProxy, resourceInterface);
    }

    public ReferenceDataService getReferenceDataService() {
        Class<ReferenceDataService> resourceInterface = ReferenceDataService.class;

        return createClientProxy(resourceInterface);
    }
    /** {@inheritDoc} */
    public AccountService getAccountService() {
        Class<AccountClient> resourceInterface = AccountClient.class;

        return createClientProxy(resourceInterface);
    }    

    /** {@inheritDoc} */
    public RoleService getRoleService() {
        Class<RoleClient> resourceInterface = RoleClient.class;

        return createClientProxy(resourceInterface);
    }    

    /** Queries the reference data service to get the ids of all reference data items, and caches them locally. */
    private void initializeReferenceData() {
        ReferenceDataService referenceDataService = getReferenceDataService();

        List<String> allTypes = referenceDataService.findAllTypes();

        for (String type : allTypes) {
            EnumeratedStringAttribute.EnumeratedStringAttributeFactory factoryForClass =
                EnumeratedStringAttribute.getFactoryForClass(type);

            List<RefDataItem> byName = referenceDataService.findByName(type);

            for (RefDataItem item : byName) {
                factoryForClass.createStringAttribute(item.getName()).setId(item.getId());
            }
        }
    }
}