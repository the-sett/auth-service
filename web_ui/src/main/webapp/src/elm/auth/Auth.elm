port module Auth exposing (..)

import Auth.Types exposing (..)


login : AuthRequest -> Cmd msg
login authRequest =
    sendLogin authRequest


logout : Cmd msg
logout =
    sendLogout ()


unauthed : Cmd msg
unauthed =
    sendUnauthed ()


port sendLogin : AuthRequest -> Cmd msg


port sendLogout : () -> Cmd msg


port sendUnauthed : () -> Cmd msg
