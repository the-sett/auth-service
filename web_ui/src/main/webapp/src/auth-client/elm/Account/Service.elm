module Account.Service exposing (..)

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
        |> Http.send FindAll
        |> Cmd.map msg

invokeFindByExample : (Msg -> msg) -> Model.Account -> Cmd msg
invokeFindByExample msg example =
    findByExampleTask example
        |> Http.send FindByExample
        |> Cmd.map msg


invokeCreate : (Msg -> msg) -> Model.Account -> Cmd msg
invokeCreate msg model =
    createTask model
        |> Http.send Create
        |> Cmd.map msg

invokeRetrieve : (Msg -> msg) -> String -> Cmd msg
invokeRetrieve msg id =
    retrieveTask id
        |> Http.send Retrieve
        |> Cmd.map msg

invokeUpdate : (Msg -> msg) -> String -> Model.Account -> Cmd msg
invokeUpdate msg id model =
    updateTask id model
        |> Http.send Update
        |> Cmd.map msg

invokeDelete : (Msg -> msg) -> String -> Cmd msg
invokeDelete msg id =
    let
       delete result = Delete <| Result.map (\() -> id) result
    in
     deleteTask id
        |> Http.send delete
        |> Cmd.map msg

type alias Callbacks model msg =
    { findAll : List (Model.Account) -> model -> ( model, Cmd msg )
    , findAllError : Http.Error -> model -> ( model, Cmd msg )
    , findByExample : List (Model.Account) -> model -> ( model, Cmd msg )
    , findByExampleError : Http.Error -> model -> ( model, Cmd msg )
    , create : Model.Account -> model -> ( model, Cmd msg )
    , createError : Http.Error -> model -> ( model, Cmd msg )
    , retrieve : Model.Account -> model -> ( model, Cmd msg )
    , retrieveError : Http.Error -> model -> ( model, Cmd msg )
    , update : Model.Account -> model -> ( model, Cmd msg )
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
    case (Debug.log "account.api" action) of
        FindAll result ->
            (case result of
                Ok account ->
                    callbacks.findAll account model

                Err httpError ->
                  let
                    (modelSpecific, cmdSpecific) = callbacks.findAllError httpError model
                    (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                  in
                    (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        FindByExample result ->
            (case result of
                Ok account ->
                    callbacks.findByExample account model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.findByExampleError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Create result ->
            (case result of
                Ok account ->
                    callbacks.create account model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.createError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Retrieve result ->
            (case result of
                Ok account ->
                    callbacks.retrieve account model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.retrieveError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Update result ->
            (case result of
                Ok account ->
                    callbacks.update account model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.updateError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
            )

        Delete result ->
            (case result of
                Ok id ->
                    callbacks.delete id model

                Err httpError ->
                    let
                      (modelSpecific, cmdSpecific) = callbacks.deleteError httpError model
                      (modelGeneral, cmdGeneral) = callbacks.error httpError modelSpecific
                    in
                      (modelGeneral, Cmd.batch [cmdSpecific, cmdGeneral])
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

findAllTask : Http.Request (List Account)
findAllTask =
    Http.request
    { method = "GET"
    , headers = []
    , url = routes.findAll
    , body = Http.emptyBody
    , expect = Http.expectJson (Decode.list accountDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

findByExampleTask : Account -> Http.Request (List Account)
findByExampleTask model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes.findByExample
    , body = Http.jsonBody <| accountEncoder model
    , expect = Http.expectJson (Decode.list accountDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

createTask : Account -> Http.Request Account
createTask model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes.create
    , body = Http.jsonBody <| accountEncoder model
    , expect = Http.expectJson accountDecoder
    , timeout = Nothing
    , withCredentials = False
    }


retrieveTask : String -> Http.Request Account
retrieveTask id =
    Http.request
    { method = "GET"
    , headers = []
    , url = routes.retrieve ++ id
    , body = Http.emptyBody
    , expect = Http.expectJson accountDecoder
    , timeout = Nothing
    , withCredentials = False
    }


updateTask : String -> Account -> Http.Request Account
updateTask id model =
    Http.request
    { method = "PUT"
    , headers = []
    , url = routes.update ++ id
    , body = Http.jsonBody <| accountEncoder model
    , expect = Http.expectJson accountDecoder
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
