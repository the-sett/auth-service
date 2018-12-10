module Model exposing
    ( AuthRequest(..), authRequestEncoder, authRequestDecoder
    , RefreshRequest(..), refreshRequestEncoder, refreshRequestDecoder
    , AuthResponse(..), authResponseEncoder, authResponseDecoder
    , Verifier(..), verifierEncoder, verifierDecoder
    , Account(..), accountEncoder, accountDecoder
    , Role(..), roleEncoder, roleDecoder
    , Permission(..), permissionEncoder, permissionDecoder
    )

{-|

@docs AuthRequest, authRequestEncoder, authRequestDecoder
@docs RefreshRequest, refreshRequestEncoder, refreshRequestDecoder
@docs AuthResponse, authResponseEncoder, authResponseDecoder
@docs Verifier, verifierEncoder, verifierDecoder
@docs Account, accountEncoder, accountDecoder
@docs Role, roleEncoder, roleDecoder
@docs Permission, permissionEncoder, permissionDecoder

-}

import Dict exposing (Dict)
import Exts.Maybe exposing (catMaybes)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (andMap, withDefault)
import Json.Encode as Encode exposing (..)
import Set exposing (Set)


{-| Describes the AuthRequest component type.
-}
type AuthRequest
    = AuthRequest
        { username : Maybe String
        , password : Maybe String
        }


{-| A JSON encoder for the AuthRequest type.
-}
authRequestEncoder : AuthRequest -> Encode.Value
authRequestEncoder (AuthRequest model) =
    [ Maybe.map (\username -> ( "username", Encode.string username )) model.username
    , Maybe.map (\password -> ( "password", Encode.string password )) model.password
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the AuthRequest type.
-}
authRequestDecoder : Decoder AuthRequest
authRequestDecoder =
    Decode.succeed
        (\username password ->
            AuthRequest
                { username = username
                , password = password
                }
        )
        |> andMap (Decode.maybe (field "username" Decode.string))
        |> andMap (Decode.maybe (field "password" Decode.string))


{-| Describes the RefreshRequest component type.
-}
type RefreshRequest
    = RefreshRequest
        { refreshToken : Maybe String
        }


{-| A JSON encoder for the RefreshRequest type.
-}
refreshRequestEncoder : RefreshRequest -> Encode.Value
refreshRequestEncoder (RefreshRequest model) =
    [ Maybe.map (\refreshToken -> ( "refreshToken", Encode.string refreshToken )) model.refreshToken
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the RefreshRequest type.
-}
refreshRequestDecoder : Decoder RefreshRequest
refreshRequestDecoder =
    Decode.succeed
        (\refreshToken ->
            RefreshRequest
                { refreshToken = refreshToken
                }
        )
        |> andMap (Decode.maybe (field "refreshToken" Decode.string))


{-| Describes the AuthResponse component type.
-}
type AuthResponse
    = AuthResponse
        { token : Maybe String
        , refreshToken : Maybe String
        }


{-| A JSON encoder for the AuthResponse type.
-}
authResponseEncoder : AuthResponse -> Encode.Value
authResponseEncoder (AuthResponse model) =
    [ Maybe.map (\token -> ( "token", Encode.string token )) model.token
    , Maybe.map (\refreshToken -> ( "refreshToken", Encode.string refreshToken )) model.refreshToken
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the AuthResponse type.
-}
authResponseDecoder : Decoder AuthResponse
authResponseDecoder =
    Decode.succeed
        (\token refreshToken ->
            AuthResponse
                { token = token
                , refreshToken = refreshToken
                }
        )
        |> andMap (Decode.maybe (field "token" Decode.string))
        |> andMap (Decode.maybe (field "refreshToken" Decode.string))


{-| Describes the Verifier component type.
-}
type Verifier
    = Verifier
        { alg : Maybe String
        , key : Maybe String
        }


{-| A JSON encoder for the Verifier type.
-}
verifierEncoder : Verifier -> Encode.Value
verifierEncoder (Verifier model) =
    [ Maybe.map (\alg -> ( "alg", Encode.string alg )) model.alg
    , Maybe.map (\key -> ( "key", Encode.string key )) model.key
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the Verifier type.
-}
verifierDecoder : Decoder Verifier
verifierDecoder =
    Decode.succeed
        (\alg key ->
            Verifier
                { alg = alg
                , key = key
                }
        )
        |> andMap (Decode.maybe (field "alg" Decode.string))
        |> andMap (Decode.maybe (field "key" Decode.string))


{-| Describes the Account component type.
-}
type Account
    = Account
        { uuid : String
        , username : Maybe String
        , password : Maybe String
        , salt : Maybe String
        , root : Maybe Bool
        , roles : Maybe (List Role)
        , id : Maybe String
        }


{-| A JSON encoder for the Account type.
-}
accountEncoder : Account -> Encode.Value
accountEncoder (Account model) =
    [ Just ( "uuid", Encode.string model.uuid )
    , Maybe.map (\username -> ( "username", Encode.string username )) model.username
    , Maybe.map (\password -> ( "password", Encode.string password )) model.password
    , Maybe.map (\salt -> ( "salt", Encode.string salt )) model.salt
    , Maybe.map (\root -> ( "root", Encode.bool root )) model.root
    , Maybe.map (\roles -> ( "roles", Encode.list roleEncoder roles )) model.roles
    , Maybe.map (\id -> ( "id", Encode.string id )) model.id
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the Account type.
-}
accountDecoder : Decoder Account
accountDecoder =
    Decode.succeed
        (\uuid username password salt root roles id ->
            Account
                { uuid = uuid
                , username = username
                , password = password
                , salt = salt
                , root = root
                , roles = roles
                , id = id
                }
        )
        |> andMap (field "uuid" Decode.string)
        |> andMap (Decode.maybe (field "username" Decode.string))
        |> andMap (Decode.maybe (field "password" Decode.string))
        |> andMap (Decode.maybe (field "salt" Decode.string))
        |> andMap (Decode.maybe (field "root" Decode.bool))
        |> andMap (field "roles" (Decode.maybe (Decode.list (Decode.lazy (\_ -> roleDecoder)))) |> withDefault Nothing)
        |> andMap (Decode.maybe (field "id" Decode.int |> Decode.map String.fromInt))


{-| Describes the Role component type.
-}
type Role
    = Role
        { name : Maybe String
        , permissions : Maybe (List Permission)
        , id : Maybe String
        }


{-| A JSON encoder for the Role type.
-}
roleEncoder : Role -> Encode.Value
roleEncoder (Role model) =
    [ Maybe.map (\name -> ( "name", Encode.string name )) model.name
    , Maybe.map (\permissions -> ( "permissions", Encode.list permissionEncoder permissions )) model.permissions
    , Maybe.map (\id -> ( "id", Encode.string id )) model.id
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the Role type.
-}
roleDecoder : Decoder Role
roleDecoder =
    Decode.succeed
        (\name permissions id ->
            Role
                { name = name
                , permissions = permissions
                , id = id
                }
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (field "permissions" (Decode.maybe (Decode.list (Decode.lazy (\_ -> permissionDecoder)))) |> withDefault Nothing)
        |> andMap (Decode.maybe (field "id" Decode.int |> Decode.map String.fromInt))


{-| Describes the Permission component type.
-}
type Permission
    = Permission
        { name : Maybe String
        , id : Maybe String
        }


{-| A JSON encoder for the Permission type.
-}
permissionEncoder : Permission -> Encode.Value
permissionEncoder (Permission model) =
    [ Maybe.map (\name -> ( "name", Encode.string name )) model.name
    , Maybe.map (\id -> ( "id", Encode.string id )) model.id
    ]
        |> catMaybes
        |> Encode.object


{-| A JSON decoder for the Permission type.
-}
permissionDecoder : Decoder Permission
permissionDecoder =
    Decode.succeed
        (\name id ->
            Permission
                { name = name
                , id = id
                }
        )
        |> andMap (Decode.maybe (field "name" Decode.string))
        |> andMap (Decode.maybe (field "id" Decode.int |> Decode.map String.fromInt))
