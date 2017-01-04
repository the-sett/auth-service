type_instance(username, string_pattern, [regexp("^[a-zA-Z0-9]{4,30}$")]).
type_instance(roleName, string_pattern, [regexp("^[a-zA-Z0-9\\\\-]{4,30}$")]).
type_instance(permissionName, string_pattern, [regexp("^[a-zA-Z0-9\\\\-]{4,30}$")]).
type_instance(namedRef, view_type, [fields([property(name, string, "name", false)]), views([])]).
type_instance(account, entity_type, [fields([unique(key, fields([property(username, username, "username", false)])), property(password, string, "password", false), property(salt, string, "salt", false), property(root, boolean, "root", false), collection(set, roles, no_parent, fields([component_ref(role, role, false, _, _, false)]))]), views([])]).
type_instance(role, entity_type, [fields([unique(key, fields([property(name, roleName, "name", false)])), collection(set, permissions, no_parent, fields([component_ref(permission, permission, false, _, _, false)]))]), views([])]).
type_instance(permission, entity_type, [fields([unique(key, fields([property(name, permissionName, "name", false)]))]), views([])]).
type_instance(authRequest, component_type, [fields([property(username, string, "username", false), property(password, string, "password", false)]), views([])]).
type_instance(refreshRequest, component_type, [fields([property(refreshToken, string, "refreshToken", false)]), views([])]).
type_instance(authResponse, component_type, [fields([property(token, string, "token", false), property(refreshToken, string, "refreshToken", false)]), views([])]).
type_instance(verifier, component_type, [fields([property(alg, string, "alg", false), property(key, string, "key", false)]), views([])]).
