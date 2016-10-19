module Account.Service exposing (..)

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
    = FindAll (Result.Result Http.Error (List Model.Account))
    | FindByExample (Result.Result Http.Error (List Model.Account))
    | Create (Result.Result Http.Error Model.Account)
    | Retrieve (Result.Result Http.Error Model.Account)
    | Update (Result.Result Http.Error Model.Account)
    | Delete (Result.Result Http.Error String)


invokeFindAll : (Msg -> msg) -> Cmd msg
invokeFindAll msg =
    findAllTask
        |> Task.perform (\error -> FindAll (Result.Err error)) (\result -> FindAll (Result.Ok result))
        |> Cmd.map msg

invokeFindByExample : (Msg -> msg) -> Model.Account -> Cmd msg
invokeFindByExample msg example =
    findByExampleTask example
        |> Task.perform (\error -> FindByExample (Result.Err error)) (\result -> FindByExample (Result.Ok result))
        |> Cmd.map msg


invokeCreate : (Msg -> msg) -> Model.Account -> Cmd msg
invokeCreate msg model =
    createTask model
        |> Task.perform (\error -> Create (Result.Err error)) (\result -> Create (Result.Ok result))
        |> Cmd.map msg

invokeRetrieve : (Msg -> msg) -> String -> Cmd msg
invokeRetrieve msg id =
    retrieveTask id
        |> Task.perform (\error -> Retrieve (Result.Err error)) (\result -> Retrieve (Result.Ok result))
        |> Cmd.map msg

invokeUpdate : (Msg -> msg) -> String -> Model.Account -> Cmd msg
invokeUpdate msg id model =
    updateTask id model
        |> Task.perform (\error -> Update (Result.Err error)) (\result -> Update (Result.Ok result))
        |> Cmd.map msg

invokeDelete : (Msg -> msg) -> String -> Cmd msg
invokeDelete msg id =
    deleteTask id
        |> Task.perform (\error -> Delete (Result.Err error)) (\result -> Delete (Result.Ok id))
        |> Cmd.map msg

type alias Callbacks model msg =
    { findAll : List (Model.Account) -> model -> ( model, Cmd msg )
    , findByExample : List (Model.Account) -> model -> ( model, Cmd msg )
    , create : Model.Account -> model -> ( model, Cmd msg )
    , retrieve : Model.Account -> model -> ( model, Cmd msg )
    , update : Model.Account -> model -> ( model, Cmd msg )
    , delete : String -> model -> ( model, Cmd msg )
    , error : Http.Error -> model -> ( model, Cmd msg )
    }

callbacks : Callbacks model msg
callbacks =
    { findAll = \_ -> \model -> ( model, Cmd.none )
    , findByExample = \_ -> \model -> ( model, Cmd.none )
    , create = \_ -> \model -> ( model, Cmd.none )
    , retrieve = \_ -> \model -> ( model, Cmd.none )
    , update = \_ -> \model -> ( model, Cmd.none )
    , delete = \_ -> \model -> ( model, Cmd.none )
    , error = \_ -> \model -> ( model, Cmd.none )
    }


update : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update callbacks action model =
    update' callbacks (Log.debug "account.api" action) model


update' : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update' callbacks action model =
    case action of
        FindAll result ->
            (case result of
                Ok account ->
                    callbacks.findAll account model

                Err httpError ->
                    callbacks.error httpError model
            )

        FindByExample result ->
            (case result of
                Ok account ->
                    callbacks.findByExample account model

                Err httpError ->
                    callbacks.error httpError model
            )

        Create result ->
            (case result of
                Ok account ->
                    callbacks.create account model

                Err httpError ->
                    callbacks.error httpError model
            )

        Retrieve result ->
            (case result of
                Ok account ->
                    callbacks.retrieve account model

                Err httpError ->
                    callbacks.error httpError model
            )

        Update result ->
            (case result of
                Ok account ->
                    callbacks.update account model

                Err httpError ->
                    callbacks.error httpError model
            )

        Delete result ->
            (case result of
                Ok response ->
                    callbacks.delete response model

                Err httpError ->
                    callbacks.error httpError model
            )

api =  "/api/"

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



deleteTask : String -> Task Http.Error Http.Response
deleteTask id =
   { verb = "DELETE"
   , headers = []
   , url = routes.delete ++ id
   , body = Http.empty
   }
       |> Http.send Http.defaultSettings
       |> Task.mapError promoteError


promoteError : Http.RawError -> Http.Error
promoteError rawError =
   case rawError of
       Http.RawTimeout -> Http.Timeout
       Http.RawNetworkError -> Http.NetworkError
