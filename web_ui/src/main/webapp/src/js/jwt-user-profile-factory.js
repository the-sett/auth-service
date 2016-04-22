/*
 * JWTUserProfile maintains the current user profile, building it from a JWT token.
 */
authService.factory('JWTUserProfile', ['$window', '$http', '$q', function($window, $http, $q) {
    var user;
    
    var Profile = {

        OK: 200,
        UNAUTHORIZED: 401,
        FORBIDDEN: 403,    

        setUserFromToken : function(token) {
            // Keep the token in session storage.
            $window.sessionStorage.token = token;

            // Parse the token to extract the user profile.
            var base64Url = token.split('.')[1];
            var base64 = base64Url.replace('-', '+').replace('_', '/');
            user = JSON.parse($window.atob(base64));

            console.log(user);
        },
        
        getUser : function() {
            if (!user) {
                if (!$window.sessionStorage.token) {
                    return { anonymous: true };
                } else {
                    Profile.setUserFromToken($window.sessionStorage.token);
                    return user;
                }
            } else {
                return user;
            }
        },
        
        clearUser : function() {
            delete $window.sessionStorage.token;
            user = null;
        },
        
        hasRole : function(role) {
            //return userProfile.roles.indexOf(role) >= 0;
        },

        hasPermission : function(permission) {
            var user = Profile.getUser();

            if (!user.permissions)
                return false;

            var permissions = user.permissions.split(',');

            return permissions.indexOf(permission) >= 0;
        },

        hasAnyRole : function(roles) {
            /*return !!userProfile.roles.filter(function(role) {
              return roles.indexOf(role) >= 0;
              }).length;*/
        },

        isAnonymous : function() {
            var user = Profile.getUser();
            return user.anonymous;
        },

        isAuthenticated : function() {
            var user = Profile.getUser();
            return !user.anonymous;
        },

        login: function(credentials) {
            console.log("login");

            var deferred = $q.defer();
            
            $http
                .post('/auth/login', credentials)
                .success(function (data, status, headers, config) {
                    Profile.setUserFromToken(data);
                    deferred.resolve(Profile.OK);
                })
                .error(function (data, status, headers, config) {
                    Profile.clearUser();
                    deferred.reject(Profile.UNAUTHORIZED);
                });

            return deferred.promise;
        },
        
        logout: function() {
            console.log("logout");
            
            Profile.clearUser();

            var deferred = $q.defer();
            
            $http
                .post('/auth/logout', vm.user)
                .success(function (data, status, headers, config) {
                    deferred.resolve(Profile.OK);
                })
                .error(function (data, status, headers, config) {
                    Profile.clearUser();
                    deferred.reject(Profile.UNAUTHORIZED);
                });

            return deferred.promise;
            
        },

        refresh: function() {
            console.log("refresh");
            
            var deferred = $q.defer();
            
            $http
                .get('/auth/refresh')
                .success(function (data, status, headers, config) {
                    deferred.resolve(Profile.OK);
                })
                .error(function (data, status, headers, config) {
                    Profile.clearUser();
                    deferred.reject(Profile.UNAUTHORIZED);
                });

            return deferred.promise;
        }
    };

    return Profile;
}]);
