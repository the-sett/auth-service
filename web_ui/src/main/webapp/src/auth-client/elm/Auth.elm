port module Auth
    exposing
        ( login
        , refresh
        , logout
        , unauthed
        , Credentials
        )

import Emitter
import Json.Encode as Encode


type alias Credentials =
    { username : String
    , password : String
    }


credentialsEncoder : Credentials -> Encode.Value
credentialsEncoder model =
    [ ( "username", Encode.string model.username )
    , ( "password", Encode.string model.password )
    ]
        |> Encode.object


login : Credentials -> Cmd msg
login authRequest =
    Emitter.send "auth.login" <| credentialsEncoder authRequest


refresh : Cmd msg
refresh =
    Emitter.sendNaked "auth.refresh"


logout : Cmd msg
logout =
    Emitter.sendNaked "auth.logout"


unauthed : Cmd msg
unauthed =
    Emitter.sendNaked "auth.unauthed"
