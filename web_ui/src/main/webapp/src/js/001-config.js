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
        clientId: '964932371492-5jlqis26ofd8osgupk5sk35vmu1958nm.apps.googleusercontent.com',
        redirectUri: window.location.origin + '/auth-service'
    });

    $authProvider.github({
        clientId: 'd15f8aa4afc840428214',
        redirectUri: window.location.origin + '/auth-service'
    });
});
