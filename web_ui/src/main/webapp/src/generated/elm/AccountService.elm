module Account.Service exposing (Msg, update, Callbacks, findAll, create)

import Log
import Platform.Cmd exposing (Cmd)
import Result
import Http
import Http
import Http.Decorators
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Task exposing (Task)
import Model exposing (..)


type Msg
    = Create (Result.Result Http.Error Model.Account)
    | FindAll (Result.Result Http.Error (List Model.Account))


findAll : Cmd Msg
findAll =
    findAllTask
        |> Task.perform (\error -> FindAll (Result.Err error)) (\result -> FindAll (Result.Ok result))


create : Model.Account -> Cmd Msg
create model =
    createTask model
        |> Task.perform (\error -> Create (Result.Err error)) (\result -> Create (Result.Ok result))


type alias Callbacks model msg =
    { findAll : List (Model.Account) -> model -> ( model, Cmd msg )
    , create : Model.Account -> model -> ( model, Cmd msg )
    , error : Http.Error -> model -> ( model, Cmd msg )
    }


update : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update callbacks action model =
    update' callbacks (Log.debug "account.api" action) model


update' : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update' callbacks action model =
    case action of
        Create result ->
            (case result of
                Ok account ->
                    callbacks.create account model

                Err httpError ->
                    callbacks.error httpError model
            )

        FindAll result ->
            (case result of
                Ok account ->
                    callbacks.findAll account model

                Err httpError ->
                    callbacks.error httpError model
            )


api =
    "/api/"


routes =
    { findAll = api ++ "account"
    , findByExample = api ++ "account/example"
    , create = api ++ "account"
    , retrieve = api ++ "account/"
    , update = api ++ "account/"
    , delete = api ++ "account/"
    }


findAllTask : Task Http.Error (List Account)
findAllTask =
    { verb = "GET"
    , headers = []
    , url = routes.findAll
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson (Decode.list accountDecoder)


findByExampleTask : Account -> Task Http.Error (List Account)
findByExampleTask model =
    { verb = "POST"
    , headers = []
    , url = routes.findByExample
    , body = Http.string <| Encode.encode 0 <| accountEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson (Decode.list accountDecoder)


createTask : Account -> Task Http.Error Account
createTask model =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.create
    , body = Http.string <| Encode.encode 0 <| accountEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson accountDecoder


retrieveTask : String -> Task Http.Error Account
retrieveTask id =
    { verb = "GET"
    , headers = []
    , url = routes.retrieve ++ id
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson accountDecoder


updateTask : String -> Account -> Task Http.Error Account
updateTask id model =
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
        Http.RawTimeout ->
            Http.Timeout

        Http.RawNetworkError ->
            Http.NetworkError


deleteTask : String -> Task Http.Error Http.Response
deleteTask id =
    { verb = "DELETE"
    , headers = []
    , url = routes.delete ++ id
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Task.mapError promoteError



-- Needs more work as also to pick up HTTP error codes as BadResponse?
