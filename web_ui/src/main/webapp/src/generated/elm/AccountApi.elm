module Account.Api exposing (..)

import Platform.Cmd exposing (Cmd)
import Log
import Model
import Account.Service
import Task
import Result
import Http


type Msg
    = Create (Result.Result Http.Error Model.Account)
    | FindAll (Result.Result Http.Error (List Model.Account))



--Cmd.map AccountApi Account.Api.findAll


findAll : Cmd Msg
findAll =
    Account.Service.findAll
        |> Task.perform (\error -> FindAll (Result.Err error)) (\result -> FindAll (Result.Ok result))


create : Model.Account -> Cmd Msg
create model =
    Account.Service.create model
        |> Task.perform (\error -> Create (Result.Err error)) (\result -> Create (Result.Ok result))


type alias Callbacks model msg =
    { findAll : List (Model.Account) -> model -> Cmd msg
    , create : Model.Account -> model -> Cmd msg
    }


update : Callbacks model msg -> Msg -> model -> Cmd msg
update callbacks action model =
    update' callbacks (Log.debug "account.api" action) model


update' : Callbacks model msg -> Msg -> model -> Cmd msg
update' callbacks action model =
    case action of
        Create result ->
            (case result of
                Ok account ->
                    callbacks.create account model

                Err _ ->
                    Cmd.none
            )

        FindAll result ->
            (case result of
                Ok account ->
                    callbacks.findAll account model

                Err _ ->
                    Cmd.none
            )



-- I want a convenience function that helps with lifting this update function into
-- whatever module needs to use it.
-- The convenience method will take a set of call back functions are arguments
-- which will be invoked with whatever model the user gives for updating.
-- So to the end user, set up the lifted update using the convenience function.
-- Invoke the HTTP wrapper cmds, (they in turn invoke the update), and receive
-- back results with the correct model through the callback functions.
-- This waym the user does not need to be directly aware of the update function
-- or the commands that it uses to talk REST.
