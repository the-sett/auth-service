module Main exposing (main)

import RouteUrl as Routing
import TimeTravel.Navigation as TimeTravel
import Config exposing (config)
import Top
    exposing
        ( delta2url
        , location2messages
        , init
        , update
        , subscriptions
        , view
        , Model
        , Msg
        )


-- Entry point


main =
    routeMain


debugMain =
    let
        navApp =
            Routing.navigationApp
                { init = init config
                , subscriptions = subscriptions
                , update = update
                , view = view
                , delta2url = delta2url
                , location2messages = location2messages
                }
    in
        TimeTravel.program navApp.locationToMessage
            { init = navApp.init
            , subscriptions = navApp.subscriptions
            , update = navApp.update
            , view = navApp.view
            }


routeMain : Routing.RouteUrlProgram Never Model Msg
routeMain =
    Routing.program
        { init = init config
        , subscriptions = subscriptions
        , update = update
        , view = view
        , delta2url = delta2url
        , location2messages = location2messages
        }
