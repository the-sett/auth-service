type_instance(namedRef, view_type, [fields([property(name, string, "name")]), views([])]).
type_instance(account, entity_type, [fields([unique(key, fields([property(username, string, "username")])), property(password, string, "password"), property(root, boolean, "root"), collection(set, roles, no_parent, fields([component_ref(role, role, false, _, _)]))]), views([])]).
type_instance(role, entity_type, [fields([unique(key, fields([property(name, string, "name")])), collection(set, permissions, no_parent, fields([component_ref(permission, permission, false, _, _)]))]), views([])]).
type_instance(permission, entity_type, [fields([unique(key, fields([property(name, string, "name")]))]), views([])]).
type_instance(authRequest, component_type, [fields([property(username, string, "username"), property(password, string, "password")]), views([])]).
type_instance(authResponse, component_type, [fields([property(token, string, "token")]), views([])]).
