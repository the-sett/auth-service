port module Auth exposing (..)


type alias Credentials =
    { username : String
    , password : String
    }


login : Credentials -> Cmd msg
login authRequest =
    sendLogin authRequest


logout : Cmd msg
logout =
    sendLogout ()


unauthed : Cmd msg
unauthed =
    sendUnauthed ()


port sendLogin : Credentials -> Cmd msg


port sendLogout : () -> Cmd msg


port sendUnauthed : () -> Cmd msg
