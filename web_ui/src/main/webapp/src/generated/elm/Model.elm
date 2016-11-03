module Model exposing (..)

import Set exposing (Set)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:), withDefault, maybeNull)
import Json.Encode as Encode exposing (..)
import Exts.Maybe exposing (catMaybes)


type NamedRef
    = NamedRef
        { name : Maybe String
        }


namedRefEncoder : NamedRef -> Encode.Value
namedRefEncoder (NamedRef model) =
    [ Maybe.map (\name -> ( "name", Encode.string name )) model.name
    ]
        |> catMaybes
        |> Encode.object


namedRefDecoder : Decoder NamedRef
namedRefDecoder =
    (Decode.succeed
        (\name ->
            NamedRef
                { name = name
                }
        )
    )
        |: Decode.maybe ("name" := Decode.string)


type AuthRequest
    = AuthRequest
        { username : Maybe String
        , password : Maybe String
        }


authRequestEncoder : AuthRequest -> Encode.Value
authRequestEncoder (AuthRequest model) =
    [ Maybe.map (\username -> ( "username", Encode.string username )) model.username
    , Maybe.map (\password -> ( "password", Encode.string password )) model.password
    ]
        |> catMaybes
        |> Encode.object


authRequestDecoder : Decoder AuthRequest
authRequestDecoder =
    (Decode.succeed
        (\username password ->
            AuthRequest
                { username = username
                , password = password
                }
        )
    )
        |: Decode.maybe ("username" := Decode.string)
        |: Decode.maybe ("password" := Decode.string)


type AuthResponse
    = AuthResponse
        { token : Maybe String
        }


authResponseEncoder : AuthResponse -> Encode.Value
authResponseEncoder (AuthResponse model) =
    [ Maybe.map (\token -> ( "token", Encode.string token )) model.token
    ]
        |> catMaybes
        |> Encode.object


authResponseDecoder : Decoder AuthResponse
authResponseDecoder =
    (Decode.succeed
        (\token ->
            AuthResponse
                { token = token
                }
        )
    )
        |: Decode.maybe ("token" := Decode.string)


type Account
    = Account
        { username : Maybe String
        , password : Maybe String
        , root : Maybe Bool
        , roles : Maybe (List Role)
        , id : Maybe String
        }


accountEncoder : Account -> Encode.Value
accountEncoder (Account model) =
    [ Maybe.map (\username -> ( "username", Encode.string username )) model.username
    , Maybe.map (\password -> ( "password", Encode.string password )) model.password
    , Maybe.map (\root -> ( "root", Encode.bool root )) model.root
    , Maybe.map (\roles -> ( "roles", roles |> List.map roleEncoder |> Encode.list )) model.roles
    , Maybe.map (\id -> ( "id", Encode.string id )) model.id
    ]
        |> catMaybes
        |> Encode.object


accountDecoder : Decoder Account
accountDecoder =
    (Decode.succeed
        (\username password root roles id ->
            Account
                { username = username
                , password = password
                , root = root
                , roles = roles
                , id = id
                }
        )
    )
        |: Decode.maybe ("username" := Decode.string)
        |: Decode.maybe ("password" := Decode.string)
        |: Decode.maybe ("root" := Decode.bool)
        |: (("roles" := maybeNull (Decode.list roleDecoder)) |> withDefault Nothing)
        |: Decode.maybe ("id" := Decode.int |> Decode.map toString)


type Role
    = Role
        { name : Maybe String
        , permissions : Maybe (List Permission)
        , id : Maybe String
        }


roleEncoder : Role -> Encode.Value
roleEncoder (Role model) =
    [ Maybe.map (\name -> ( "name", Encode.string name )) model.name
    , Maybe.map (\permissions -> ( "permissions", permissions |> List.map permissionEncoder |> Encode.list )) model.permissions
    , Maybe.map (\id -> ( "id", Encode.string id )) model.id
    ]
        |> catMaybes
        |> Encode.object


roleDecoder : Decoder Role
roleDecoder =
    (Decode.succeed
        (\name permissions id ->
            Role
                { name = name
                , permissions = permissions
                , id = id
                }
        )
    )
        |: Decode.maybe ("name" := Decode.string)
        |: (("permissions" := maybeNull (Decode.list permissionDecoder)) |> withDefault Nothing)
        |: Decode.maybe ("id" := Decode.int |> Decode.map toString)


type Permission
    = Permission
        { name : Maybe String
        , id : Maybe String
        }


permissionEncoder : Permission -> Encode.Value
permissionEncoder (Permission model) =
    [ Maybe.map (\name -> ( "name", Encode.string name )) model.name
    , Maybe.map (\id -> ( "id", Encode.string id )) model.id
    ]
        |> catMaybes
        |> Encode.object


permissionDecoder : Decoder Permission
permissionDecoder =
    (Decode.succeed
        (\name id ->
            Permission
                { name = name
                , id = id
                }
        )
    )
        |: Decode.maybe ("name" := Decode.string)
        |: Decode.maybe ("id" := Decode.int |> Decode.map toString)
