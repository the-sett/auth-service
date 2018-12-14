module Routes exposing
    ( Route(..)
    , fromUrl
    , href
    , parser
    , replaceUrl
    , routeToString
    )

import Auth
import Browser
import Browser.Navigation as Navigation
import Html.Styled exposing (Attribute)
import Html.Styled.Attributes as Attributes
import Page.Accounts
import Page.Welcome
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)


type Route
    = WelcomeRoute
    | AccountsRoute


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map WelcomeRoute Parser.top
        , Parser.map AccountsRoute (s "accounts")
        ]


href : Route -> Attribute msg
href targetRoute =
    Attributes.href (routeToString targetRoute)


replaceUrl : Navigation.Key -> Route -> Cmd msg
replaceUrl key route =
    let
        _ =
            Debug.log "replaceUrl" route
    in
    --Cmd.none
    Navigation.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


routeToString : Route -> String
routeToString route =
    let
        path =
            case route of
                WelcomeRoute ->
                    []

                AccountsRoute ->
                    [ "accounts" ]
    in
    "/" ++ String.join "/" path
