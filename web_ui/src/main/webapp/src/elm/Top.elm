module Top exposing (main)

import Config exposing (config)
import Main
    exposing
        ( Model
        , Msg
        , delta2url
        , init
        , location2messages
        , subscriptions
        , update
        , view
        )



-- Entry point


main : Routing.RouteUrlProgram Never Model Msg
main =
    Routing.program
        { init = init config
        , subscriptions = subscriptions
        , update = update
        , view = view
        , delta2url = delta2url
        , location2messages = location2messages
        }
