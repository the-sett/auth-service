module Update exposing (evaluate, lift, message)

{-| Convenience function for lifting an update function for an inner model
and messages into a parent one.
-}

import Task


lift :
    (model -> submodel)
    -> (submodel -> model -> model)
    -> (subaction -> action)
    -> (subaction -> submodel -> ( submodel, Cmd subaction ))
    -> subaction
    -> model
    -> ( model, Cmd action )
lift get set tagger update action model =
    let
        ( updatedSubModel, msg ) =
            update action (get model)
    in
        ( set updatedSubModel model, Cmd.map tagger msg )


evaluate :
    (model -> ( model, Cmd msg ))
    -> ( model, Cmd msg )
    -> ( model, Cmd msg )
evaluate func ( model, cmds ) =
    let
        ( newModel, moreCmds ) =
            func model
    in
        ( newModel, Cmd.batch [ cmds, moreCmds ] )


{-| A command to generate a message without performing any action.
This is useful for implementing components that generate events in the manner
of HTML elements, but where the event fires from within Elm code, rather than
by an external trigger.
-}
message : msg -> Cmd msg
message x =
    Task.perform identity (Task.succeed x)
