module Permission.Service exposing (..)

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
    | Delete (Result.Result Http.Error ())


invokeFindAll : (Msg -> msg) -> Cmd msg
invokeFindAll msg =
    findAllTask
        |> Http.send FindAll
        |> Cmd.map msg

invokeFindByExample : (Msg -> msg) -> Model.Permission -> Cmd msg
invokeFindByExample msg example =
    findByExampleTask example
        |> Http.send FindByExample
        |> Cmd.map msg


invokeCreate : (Msg -> msg) -> Model.Permission -> Cmd msg
invokeCreate msg model =
    createTask model
        |> Http.send Create
        |> Cmd.map msg

invokeRetrieve : (Msg -> msg) -> String -> Cmd msg
invokeRetrieve msg id =
    retrieveTask id
        |> Http.send Retrieve
        |> Cmd.map msg

invokeUpdate : (Msg -> msg) -> String -> Model.Permission -> Cmd msg
invokeUpdate msg id model =
    updateTask id model
        |> Http.send Update
        |> Cmd.map msg

invokeDelete : (Msg -> msg) -> String -> Cmd msg
invokeDelete msg id =
    deleteTask id
        |> Http.send Delete
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
    , delete : model -> ( model, Cmd msg )
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
    , delete = \model -> ( model, Cmd.none )
    , deleteError = \_ -> \model -> ( model, Cmd.none )
    , error = \_ -> \model -> ( model, Cmd.none )
    }


update : Callbacks model msg -> Msg -> model -> ( model, Cmd msg )
update callbacks action model =
    case (Debug.log "permission.api" action) of
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
                Ok _ ->
                    callbacks.delete model

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

findAllTask : Http.Request (List Permission)
findAllTask =
    Http.request
    { method = "GET"
    , headers = []
    , url = routes.findAll
    , body = Http.emptyBody
    , expect = Http.expectJson (Decode.list permissionDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

findByExampleTask : Permission -> Http.Request (List Permission)
findByExampleTask model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes.findByExample
    , body = Http.jsonBody <| permissionEncoder model
    , expect = Http.expectJson (Decode.list permissionDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

createTask : Permission -> Http.Request Permission
createTask model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes.create
    , body = Http.jsonBody <| permissionEncoder model
    , expect = Http.expectJson permissionDecoder
    , timeout = Nothing
    , withCredentials = False
    }


retrieveTask : String -> Http.Request Permission
retrieveTask id =
    Http.request
    { method = "GET"
    , headers = []
    , url = routes.retrieve ++ id
    , body = Http.emptyBody
    , expect = Http.expectJson permissionDecoder
    , timeout = Nothing
    , withCredentials = False
    }


updateTask : String -> Permission -> Http.Request Permission
updateTask id model =
    Http.request
    { method = "PUT"
    , headers = []
    , url = routes.update ++ id
    , body = Http.jsonBody <| permissionEncoder model
    , expect = Http.expectJson permissionDecoder
    , timeout = Nothing
    , withCredentials = False
    }


deleteTask : String -> Http.Request ()
deleteTask id =
    Http.request
   { method = "DELETE"
   , headers = []
   , url = routes.delete ++ id
   , body = Http.emptyBody
   , expect = Http.expectStringResponse (\_ -> Ok ())
   , timeout = Nothing
   , withCredentials = False
   }
