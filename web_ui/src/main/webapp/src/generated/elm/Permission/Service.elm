module Permission.Service exposing (..)

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
    = FindAll (Result.Result Http.Error (List Model.Permission))
    | FindByExample (Result.Result Http.Error (List Model.Permission))
    | Create (Result.Result Http.Error Model.Permission)
    | Retrieve (Result.Result Http.Error Model.Permission)
    | Update (Result.Result Http.Error Model.Permission)
    | Delete (Result.Result Http.Error String)


invokeFindAll : (Msg -> msg) -> Cmd msg
invokeFindAll msg =
    findAllTask
        |> Task.perform (\error -> FindAll (Result.Err error)) (\result -> FindAll (Result.Ok result))
        |> Cmd.map msg

invokeFindByExample : (Msg -> msg) -> Model.Permission -> Cmd msg
invokeFindByExample msg example =
    findByExampleTask example
        |> Task.perform (\error -> FindByExample (Result.Err error)) (\result -> FindByExample (Result.Ok result))
        |> Cmd.map msg


invokeCreate : (Msg -> msg) -> Model.Permission -> Cmd msg
invokeCreate msg model =
    createTask model
        |> Task.perform (\error -> Create (Result.Err error)) (\result -> Create (Result.Ok result))
        |> Cmd.map msg

invokeRetrieve : (Msg -> msg) -> String -> Cmd msg
invokeRetrieve msg id =
    retrieveTask id
        |> Task.perform (\error -> Retrieve (Result.Err error)) (\result -> Retrieve (Result.Ok result))
        |> Cmd.map msg

invokeUpdate : (Msg -> msg) -> String -> Model.Permission -> Cmd msg
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
    { findAll : List (Model.Permission) -> model -> ( model, Cmd msg )
    , findAllError : Http.Error -> model -> ( model, Cmd msg )
    , findByExample : List (Model.Permission) -> model -> ( model, Cmd msg )
    , findByExampleError : Http.Error -> model -> ( model, Cmd msg )
    , create : Model.Permission -> model -> ( model, Cmd msg )
    , createError : Http.Error -> model -> ( model, Cmd msg )
    , retrieve : Model.Permission -> model -> ( model, Cmd msg )
    , retrieveError : Http.Error -> model -> ( model, Cmd msg )
    , update : Model.Permission -> model -> ( model, Cmd msg )
    , updateError : Http.Error -> model -> ( model, Cmd msg )
    , delete : String -> model -> ( model, Cmd msg )
    , deleteError : Http.Error -> model -> ( model, Cmd msg )
    , error : Http.Error -> model -> ( model, Cmd msg )
    }

callbacks : Callbacks model msg
callbacks =
    { findAll = \_ -> \model -> ( model, Cmd.none )
    , findAllError = \_ -> \model -> ( model, Cmd.none )
    , findByExample = \_ -> \model -> ( model, Cmd.none )
    , findByExampleError = \_ -> \model -> ( model, Cmd.none )
    , create = \_ -> \model -> ( model, Cmd.none )
    , createError = \_ -> \model -> ( model, Cmd.none )
    , retrieve = \_ -> \model -> ( model, Cmd.none )
    , retrieveError = \_ -> \model -> ( model, Cmd.none )
    , update = \_ -> \model -> ( model, Cmd.none )
    , updateError = \_ -> \model -> ( model, Cmd.none )
    , delete = \_ -> \model -> ( model, Cmd.none )
    , deleteError = \_ -> \model -> ( model, Cmd.none )
    , error = \_ -> \model -> ( model, Cmd.none )
    }


update : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update callbacks action model =
    update' callbacks (Log.debug "permission.api" action) model


update' : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update' callbacks action model =
    case action of
        FindAll result ->
            (case result of
                Ok permission ->
                    callbacks.findAll permission model

                Err httpError ->
                  let
                    (modelSpecific, cmdSpecific) = callbacks.findAllError httpError model
                    (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                  in
                    (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        FindByExample result ->
            (case result of
                Ok permission ->
                    callbacks.findByExample permission model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.findByExampleError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Create result ->
            (case result of
                Ok permission ->
                    callbacks.create permission model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.createError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Retrieve result ->
            (case result of
                Ok permission ->
                    callbacks.retrieve permission model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.retrieveError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Update result ->
            (case result of
                Ok permission ->
                    callbacks.update permission model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.updateError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Delete result ->
            (case result of
                Ok response ->
                    callbacks.delete response model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.deleteError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

api =  "/api/"

routes =
    { findAll = api ++ "permission"
    , findByExample = api ++ "permission/example"
    , create = api ++ "permission"
    , retrieve = api ++ "permission/"
    , update = api ++ "permission/"
    , delete = api ++ "permission/"
    }

findAllTask : Task Http.Error (List Permission)
findAllTask =
    { verb = "GET"
    , headers = []
    , url = routes.findAll
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson (Decode.list permissionDecoder)

findByExampleTask : Permission -> Task Http.Error (List Permission)
findByExampleTask model =
    { verb = "POST"
    , headers = []
    , url = routes.findByExample
    , body = Http.string <| Encode.encode 0 <| permissionEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson (Decode.list permissionDecoder)

createTask : Permission -> Task Http.Error Permission
createTask model =
    { verb = "POST"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.create
    , body = Http.string <| Encode.encode 0 <| permissionEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson permissionDecoder


retrieveTask : String -> Task Http.Error Permission
retrieveTask id =
    { verb = "GET"
    , headers = []
    , url = routes.retrieve ++ id
    , body = Http.empty
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson permissionDecoder


updateTask : String -> Permission -> Task Http.Error Permission
updateTask id model =
    { verb = "PUT"
    , headers = [ ( "Content-Type", "application/json" ) ]
    , url = routes.update ++ id
    , body = Http.string <| Encode.encode 0 <| permissionEncoder model
    }
        |> Http.send Http.defaultSettings
        |> Http.fromJson permissionDecoder



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
