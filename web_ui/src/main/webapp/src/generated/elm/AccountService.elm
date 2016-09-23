module Account.Service exposing (..)

import Http
import Http.Decorators
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Task exposing (Task)
import Model exposing (..)

api =  "/api/"

routes =
    { findAll = api ++ "account"
    , findByExample = api ++ "account/example"
    , create = api ++ "account"
    , retrieve = api ++ "account/"
    , update = api ++ "account/"
    , delete = api ++ "account/"
    }

findAll : Task Http.Error (List Account)
findAll =
    { verb = "GET"
    , headers = []
    , url = routes.findAll
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson (Decode.list accountDecoder)

findByExample : Account -> Task Http.Error (List Account)
findByExample model =
    { verb = "POST"
    , headers = []
    , url = routes.findByExample
    , body = Http.string <| Encode.encode 0 <| accountEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson (Decode.list accountDecoder)

create : Account -> Task Http.Error Account
create model =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.create
    , body = Http.string <| Encode.encode 0 <| accountEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson accountDecoder


retrieve : String -> Task Http.Error Account
retrieve id =
    { verb = "GET"
    , headers = []
    , url = routes.retrieve ++ id
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson accountDecoder


update : String -> Account -> Task Http.Error Account
update id model =
    { verb = "PUT"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.update ++ id
    , body = Http.string <| Encode.encode 0 <| accountEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson accountDecoder


promoteError : Http.RawError -> Http.Error
promoteError rawError =
    case rawError of
        Http.RawTimeout -> Http.Timeout
        Http.RawNetworkError -> Http.NetworkError

delete : String -> Task Http.Error Http.Response
delete id =
   { verb = "DELETE"
   , headers = []
   , url = routes.delete ++ id
   , body = Http.empty
   }
       |> Http.send Http.defaultSettings
       |> Task.mapError promoteError
-- Needs more work as also to pick up HTTP error codes as BadResponse?
