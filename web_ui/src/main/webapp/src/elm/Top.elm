module Top exposing (main)

import Browser
import Config exposing (config)
import Main exposing (init, subscriptions, update, view)
import State exposing (Model, Msg(..))



-- Entry point


main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlRequest = \_ -> Noop
        , onUrlChange = \_ -> Noop
        }
