module Main exposing (main)

import RouteUrl as Routing
import Config
import Top


-- Entry point


main : Routing.RouteUrlProgram Never Top.Model Top.Msg
main =
    Routing.program
        { delta2url = Top.delta2url
        , location2messages = Top.location2messages
        , init = Top.init Config.config
        , view = Top.view
        , subscriptions = Top.subscriptions
        , update = Top.update
        }
