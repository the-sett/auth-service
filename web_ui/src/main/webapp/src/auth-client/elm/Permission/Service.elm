module Permission.Service exposing (..)

import Http
import Json.Encode as Encode exposing (..)
import Model exposing (..)
import Platform.Cmd exposing (Cmd)
import Result
import Task exposing (Task)


invokeFindAll : String -> (Result.Result Http.Error (List Model.Permission) -> msg) -> Cmd msg
invokeFindAll root tagger =
    findAllTask root 
        |> Http.send FindAll
        |> Cmd.map msg

invokeFindByExample : String -> (Result.Result Http.Error (List Model.Permission) -> msg) -> Model.Permission -> Cmd msg
invokeFindByExample root tagger example =
    findByExampleTask root example
        |> Http.send FindByExample
        |> Cmd.map msg


invokeCreate : String -> (Result.Result Http.Error Model.Permission -> msg) -> Model.Permission -> Cmd msg
invokeCreate root msg model =
    createTask root model
        |> Http.send Create
        |> Cmd.map msg

invokeRetrieve : String -> (Result.Result Http.Error Model.Permission -> msg) -> String -> Cmd msg
invokeRetrieve root msg id =
    retrieveTask root id
        |> Http.send Retrieve
        |> Cmd.map msg

invokeUpdate : String -> (Result.Result Http.Error Model.Permission -> msg) -> String -> Model.Permission -> Cmd msg
invokeUpdate root msg id model =
    updateTask root id model
        |> Http.send Update
        |> Cmd.map msg

invokeDelete : String ->  (Result.Result Http.Error String -> msg) -> String -> Cmd msg
invokeDelete root msg id =
    let
       delete result = Delete <| Result.map (\() -> id) result
    in
     deleteTask root id
        |> Http.send delete
        |> Cmd.map msg

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
