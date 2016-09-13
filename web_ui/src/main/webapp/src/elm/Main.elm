module Main exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import String
import Navigation
import RouteUrl as Routing
import Material.Layout as Layout
import Material.Menu as Menu
import Menu.Types
import Main.Types exposing (..)
import Main.State exposing (..)
import Main.View exposing (..)
import Accounts.State
import Roles.State
import Permissions.State
import Auth.Types


log =
    Debug.log "top"



-- main : Program Never


main : Program (Maybe Auth.Types.Model)
main =
    Routing.programWithFlags
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init'
        , view = view
        , subscriptions =
            \init ->
                Sub.batch
                    [ Sub.map MenusMsg (Menu.subs Menu.Types.MDL init.menus.mdl)
                    , Layout.subs Mdl init.mdl
                    ]
        , update = update
        }


init' : Maybe Auth.Types.Model -> ( Model, Cmd Msg )
init' authModel =
    case authModel of
        Just authModel ->
            let
                d =
                    log "authModel present"
            in
                ( { init
                    | auth = authModel
                  }
                , Layout.sub0 Mdl
                )

        Nothing ->
            let
                d =
                    log "authModel not present"
            in
                ( init, Layout.sub0 Mdl )



-- ROUTING


urlOf : Model -> String
urlOf model =
    "#" ++ (Array.get model.selectedTab tabUrls |> Maybe.withDefault "")


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.selectedTab /= model2.selectedTab then
        { entry = Routing.NewEntry
        , url = urlOf model2
        }
            |> Just
    else
        Nothing


location2messages : Navigation.Location -> List Msg
location2messages location =
    [ case String.dropLeft 1 location.hash of
        "" ->
            SelectTab 0

        x ->
            Dict.get x urlTabs
                |> Maybe.withDefault -1
                |> SelectTab
    ]
