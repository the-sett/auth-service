module Role.Service exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (..)
import Model exposing (..)
import Platform.Cmd exposing (Cmd)
import Result
import Task exposing (Task)


invokeFindAll : String -> (Result.Result Http.Error (List Model.Role) -> msg) -> Cmd msg
invokeFindAll root tagger =
    findAllTask root 
        |> Http.send tagger


invokeFindByExample : String -> (Result.Result Http.Error (List Model.Role) -> msg) -> Model.Role -> Cmd msg
invokeFindByExample root tagger example =
    findByExampleTask root example
        |> Http.send tagger


invokeCreate : String -> (Result.Result Http.Error Model.Role -> msg) -> Model.Role -> Cmd msg
invokeCreate root tagger model =
    createTask root model
        |> Http.send tagger        


invokeRetrieve : String -> (Result.Result Http.Error Model.Role -> msg) -> String -> Cmd msg
invokeRetrieve root tagger id =
    retrieveTask root id
        |> Http.send tagger        


invokeUpdate : String -> (Result.Result Http.Error Model.Role -> msg) -> String -> Model.Role -> Cmd msg
invokeUpdate root tagger id model =
    updateTask root id model
        |> Http.send tagger        


invokeDelete : String ->  (Result.Result Http.Error () -> msg) -> String -> Cmd msg
invokeDelete root tagger id =
     deleteTask root id
        |> Http.send tagger


routes root =
    { findAll = root ++ "role"
    , findByExample = root ++ "role/example"
    , create = root ++ "role"
    , retrieve = root ++ "role/"
    , update = root ++ "role/"
    , delete = root ++ "role/"
    }


findAllTask : String -> Http.Request (List Role)
findAllTask root =
    Http.request
    { method = "GET"
    , headers = []
    , url = routes root |> .findAll
    , body = Http.emptyBody
    , expect = Http.expectJson (Decode.list roleDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

findByExampleTask : String -> Role -> Http.Request (List Role)
findByExampleTask root model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes root |> .findByExample
    , body = Http.jsonBody <| roleEncoder model
    , expect = Http.expectJson (Decode.list roleDecoder)
    , timeout = Nothing
    , withCredentials = False
    }

createTask : String -> Role -> Http.Request Role
createTask root model =
    Http.request
    { method = "POST"
    , headers = []
    , url = routes root |> .create
    , body = Http.jsonBody <| roleEncoder model
    , expect = Http.expectJson roleDecoder
    , timeout = Nothing
    , withCredentials = False
    }


retrieveTask : String -> String -> Http.Request Role
retrieveTask root id =
    Http.request
    { method = "GET"
    , headers = []
    , url = (routes root |> .retrieve) ++ id
    , body = Http.emptyBody
    , expect = Http.expectJson roleDecoder
    , timeout = Nothing
    , withCredentials = False
    }


updateTask : String -> String -> Role -> Http.Request Role
updateTask root id model =
    Http.request
    { method = "PUT"
    , headers = []
    , url = (routes root |> .update) ++ id
    , body = Http.jsonBody <| roleEncoder model
    , expect = Http.expectJson roleDecoder
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
