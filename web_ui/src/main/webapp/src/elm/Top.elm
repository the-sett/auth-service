module Top exposing (main)

import Browser
import Config exposing (config)
import Main exposing (Model, Msg(..), init, subscriptions, update, view)



-- Entry point


main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
