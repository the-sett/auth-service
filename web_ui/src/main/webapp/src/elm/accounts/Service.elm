module Accounts.Service exposing (..)

import Http
import Http.Decorators
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Task exposing (Task)


api =
    "/api/"


routes =
    { create = api ++ "account"
    , retrieve = api ++ "account"
    , update = api ++ "account"
    , delete = api ++ "account"
    }


type alias Account =
    { username : String
    , password : String
    }


accountEncoder : Account -> Encode.Value
accountEncoder model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


accountDecoder : Decoder Account
accountDecoder =
    Decode.object2 Account
        ("username" := Decode.string)
        ("password" := Decode.string)


createRequest : Account -> Task Http.Error Account
createRequest model =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.create
    , body = Http.string <| Encode.encode 0 <| accountEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson accountDecoder
