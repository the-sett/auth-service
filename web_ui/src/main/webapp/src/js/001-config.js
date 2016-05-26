authService.constant('config', {
    "authService": {
        "endpoint": "/api/"
    }
});

authService.config(function($authProvider) {
    $authProvider.facebook({
      clientId: 'Facebook App ID',
      responseType: 'token'
    });

    $authProvider.google({
      clientId: 'Google Client ID'
    });

    $authProvider.github({
      clientId: 'GitHub Client ID'
    });
});
