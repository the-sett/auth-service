module Account.Api exposing (..)

import Platform.Cmd exposing (Cmd)
import Model
import Account.Service
import Task
import Result
import Http


type Msg
    = Done (Result.Result Http.Error Model.Account)


createCmd : Model.Account -> Cmd Msg
createCmd model =
    Account.Service.create model
        |> Task.perform (\error -> Done (Result.Err error)) (\result -> Done (Result.Ok result))


type alias Callbacks model msg =
    { create : Model.Account -> model -> Cmd msg
    }


update : Callbacks model msg -> Msg -> model -> Cmd msg
update callbacks action model =
    case action of
        Done result ->
            (case result of
                Ok account ->
                    callbacks.create account model

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
