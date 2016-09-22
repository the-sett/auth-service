module Model exposing(..)

import Set exposing (Set)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode exposing (..)

type NamedRef =
    NamedRef
    {
    name : String
    }


namedRefEncoder : NamedRef -> Encode.Value
namedRefEncoder (NamedRef model) =
        Encode.object
            [
            ( "name", Encode.string model.name )
            ]


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
        Encode.object
            [
            ( "username", Encode.string model.username )
            , ( "password", Encode.string model.password )
            ]


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
        Encode.object
            [
            ( "token", Encode.string model.token )
            ]


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
    , roles : List Role
    , id : String
    }


accountEncoder : Account -> Encode.Value
accountEncoder (Account model) =
        Encode.object
            [
            ( "username", Encode.string model.username )
            , ( "password", Encode.string model.password )
            , ("roles", model.roles |> List.map roleEncoder |> Encode.list)
            , ( "id", Encode.string model.id )
            ]


accountDecoder : Decoder Account
accountDecoder =
    (Decode.succeed
        (\username password roles id ->
            Account
                {
                username = username
                ,password = password
                ,roles = roles
                , id = id
                }
        )
    )
        |: ("username" := Decode.string)
        |: ("password" := Decode.string)
        |: ("roles" := Decode.list roleDecoder)
        |: ("id" := Decode.string)


type Role =
    Role
    {
    name : String
    , accounts : List Account
    , permissions : List Permission
    , id : String
    }


roleEncoder : Role -> Encode.Value
roleEncoder (Role model) =
        Encode.object
            [
            ( "name", Encode.string model.name )
            , ("accounts", model.accounts |> List.map accountEncoder |> Encode.list)
            , ("permissions", model.permissions |> List.map permissionEncoder |> Encode.list)
            , ( "id", Encode.string model.id )
            ]


roleDecoder : Decoder Role
roleDecoder =
    (Decode.succeed
        (\name accounts permissions id ->
            Role
                {
                name = name
                ,accounts = accounts
                ,permissions = permissions
                , id = id
                }
        )
    )
        |: ("name" := Decode.string)
        |: ("accounts" := Decode.list accountDecoder)
        |: ("permissions" := Decode.list permissionDecoder)
        |: ("id" := Decode.string)


type Permission =
    Permission
    {
    name : String
    , id : String
    }


permissionEncoder : Permission -> Encode.Value
permissionEncoder (Permission model) =
        Encode.object
            [
            ( "name", Encode.string model.name )
            , ( "id", Encode.string model.id )
            ]


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
        |: ("id" := Decode.string)


