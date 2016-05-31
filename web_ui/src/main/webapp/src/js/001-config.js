authService.constant('config', {
    "authService": {
        "endpoint": "/api/"
    }
});

authService.config(function($authProvider) {
    $authProvider.facebook({
        clientId: '138414813234505',
        redirectUri: window.location.origin + '/auth-service'        
    });

    $authProvider.google({
      clientId: 'Google Client ID'
    });

    $authProvider.github({
        clientId: 'd15f8aa4afc840428214',
        redirectUri: window.location.origin + '/auth-service'
    });
});
