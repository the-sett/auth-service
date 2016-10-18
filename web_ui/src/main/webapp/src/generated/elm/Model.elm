module Model exposing(..)

import Set exposing (Set)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:), withDefault, maybeNull)
import Json.Encode as Encode exposing (..)
import Exts.Maybe exposing (catMaybes)
type NamedRef =
    NamedRef
    {
    name : String
    }


namedRefEncoder : NamedRef -> Encode.Value
namedRefEncoder (NamedRef model) =
        [
        Just ( "name", Encode.string model.name )
        ]
          |> catMaybes
          |> Encode.object


namedRefDecoder : Decoder NamedRef
namedRefDecoder =
    (Decode.succeed
        (\name ->
            NamedRef
                {
                name = name
                }
        )
    )
        |: ("name" := Decode.string)


type AuthRequest =
    AuthRequest
    {
    username : String
    , password : String
    }


authRequestEncoder : AuthRequest -> Encode.Value
authRequestEncoder (AuthRequest model) =
        [
        Just ( "username", Encode.string model.username )
        , Just ( "password", Encode.string model.password )
        ]
          |> catMaybes
          |> Encode.object


authRequestDecoder : Decoder AuthRequest
authRequestDecoder =
    (Decode.succeed
        (\username password ->
            AuthRequest
                {
                username = username
                ,password = password
                }
        )
    )
        |: ("username" := Decode.string)
        |: ("password" := Decode.string)


type AuthResponse =
    AuthResponse
    {
    token : String
    }


authResponseEncoder : AuthResponse -> Encode.Value
authResponseEncoder (AuthResponse model) =
        [
        Just ( "token", Encode.string model.token )
        ]
          |> catMaybes
          |> Encode.object


authResponseDecoder : Decoder AuthResponse
authResponseDecoder =
    (Decode.succeed
        (\token ->
            AuthResponse
                {
                token = token
                }
        )
    )
        |: ("token" := Decode.string)


type Account =
    Account
    {
    username : String
    , password : String
    , root : Bool
    , roles : Maybe (List Role)
    , id : String
    }


accountEncoder : Account -> Encode.Value
accountEncoder (Account model) =
        [
        Just ( "username", Encode.string model.username )
        , Just ( "password", Encode.string model.password )
        , Just ( "root", Encode.bool model.root )
        , case model.roles of
            Just roles -> Just ( "roles", roles |> List.map roleEncoder |> Encode.list )

            Nothing -> Nothing
        , Just ( "id", Encode.string model.id )
        ]
          |> catMaybes
          |> Encode.object


accountDecoder : Decoder Account
accountDecoder =
    (Decode.succeed
        (\username password root roles id ->
            Account
                {
                username = username
                ,password = password
                ,root = root
                ,roles = roles
                , id = id
                }
        )
    )
        |: ("username" := Decode.string)
        |: ("password" := Decode.string)
        |: ("root" := Decode.bool)
        |: (("roles" := maybeNull (Decode.list roleDecoder)) |> withDefault Nothing)
        |: ("id" := Decode.int |> Decode.map toString)


type Role =
    Role
    {
    name : String
    , permissions : Maybe (List Permission)
    , id : String
    }


roleEncoder : Role -> Encode.Value
roleEncoder (Role model) =
        [
        Just ( "name", Encode.string model.name )
        , case model.permissions of
            Just permissions -> Just ( "permissions", permissions |> List.map permissionEncoder |> Encode.list )

            Nothing -> Nothing
        , Just ( "id", Encode.string model.id )
        ]
          |> catMaybes
          |> Encode.object


roleDecoder : Decoder Role
roleDecoder =
    (Decode.succeed
        (\name permissions id ->
            Role
                {
                name = name
                ,permissions = permissions
                , id = id
                }
        )
    )
        |: ("name" := Decode.string)
        |: (("permissions" := maybeNull (Decode.list permissionDecoder)) |> withDefault Nothing)
        |: ("id" := Decode.int |> Decode.map toString)


type Permission =
    Permission
    {
    name : String
    , id : String
    }


permissionEncoder : Permission -> Encode.Value
permissionEncoder (Permission model) =
        [
        Just ( "name", Encode.string model.name )
        , Just ( "id", Encode.string model.id )
        ]
          |> catMaybes
          |> Encode.object


permissionDecoder : Decoder Permission
permissionDecoder =
    (Decode.succeed
        (\name id ->
            Permission
                {
                name = name
                , id = id
                }
        )
    )
        |: ("name" := Decode.string)
        |: ("id" := Decode.int |> Decode.map toString)


