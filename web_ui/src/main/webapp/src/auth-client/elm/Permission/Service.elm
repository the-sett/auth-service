module Permission.Service exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (..)
import Model exposing (..)
import Platform.Cmd exposing (Cmd)
import Result
import Task exposing (Task)


invokeFindAll : String -> (Result.Result Http.Error (List Model.Permission) -> msg) -> Cmd msg
invokeFindAll root tagger =
    findAllTask root 
        |> Http.send tagger


invokeFindByExample : String -> (Result.Result Http.Error (List Model.Permission) -> msg) -> Model.Permission -> Cmd msg
invokeFindByExample root tagger example =
    findByExampleTask root example
        |> Http.send tagger


invokeCreate : String -> (Result.Result Http.Error Model.Permission -> msg) -> Model.Permission -> Cmd msg
invokeCreate root tagger model =
    createTask root model
        |> Http.send tagger        


invokeRetrieve : String -> (Result.Result Http.Error Model.Permission -> msg) -> String -> Cmd msg
invokeRetrieve root tagger id =
    retrieveTask root id
        |> Http.send tagger        


invokeUpdate : String -> (Result.Result Http.Error Model.Permission -> msg) -> String -> Model.Permission -> Cmd msg
invokeUpdate root tagger id model =
    updateTask root id model
        |> Http.send tagger        


invokeDelete : String ->  (Result.Result Http.Error () -> msg) -> String -> Cmd msg
invokeDelete root tagger id =
     deleteTask root id
        |> Http.send tagger


routes root =
    { findAll = root ++ "permission"
    , findByExample = root ++ "permission/example"
    , create = root ++ "permission"
    , retrieve = root ++ "permission/"
    , update = root ++ "permission/"
    , delete = root ++ "permission/"
    }


findAllTask : String -> Http.Request (List Permission)
findAllTask root =
    Http.request
    { method = "GET"
    , headers = []
    , url = routes root |> .findAll
    , body = Http.emptyBody
    , expect = Http.expectJson (Decode.list permissionDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

findByExampleTask : String -> Permission -> Http.Request (List Permission)
findByExampleTask root model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes root |> .findByExample
    , body = Http.jsonBody <| permissionEncoder model
    , expect = Http.expectJson (Decode.list permissionDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

createTask : String -> Permission -> Http.Request Permission
createTask root model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes root |> .create
    , body = Http.jsonBody <| permissionEncoder model
    , expect = Http.expectJson permissionDecoder
    , timeout = Nothing
    , withCredentials = False
    }


retrieveTask : String -> String -> Http.Request Permission
retrieveTask root id =
    Http.request
    { method = "GET"
    , headers = []
    , url = (routes root |> .retrieve) ++ id
    , body = Http.emptyBody
    , expect = Http.expectJson permissionDecoder
    , timeout = Nothing
    , withCredentials = False
    }


updateTask : String -> String -> Permission -> Http.Request Permission
updateTask root id model =
    Http.request
    { method = "PUT"
    , headers = []
    , url = (routes root |> .update) ++ id
    , body = Http.jsonBody <| permissionEncoder model
    , expect = Http.expectJson permissionDecoder
    , timeout = Nothing
    , withCredentials = False
    }


deleteTask : String -> String -> Http.Request ()
deleteTask root id =
    Http.request
   { method = "DELETE"
   , headers = []
   , url = (routes root |> .delete) ++ id
   , body = Http.emptyBody
   , expect = Http.expectStringResponse (\_ -> Ok ())
   , timeout = Nothing
   , withCredentials = False
   }
