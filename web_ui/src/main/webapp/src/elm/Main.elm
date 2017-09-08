module Main exposing (..)

import Array exposing (Array)
import String
import Navigation
import RouteUrl as Routing
import Material.Layout as Layout
import Material.Menu as Menu
import Main.State
import Menu.State
import AuthController
import Auth
import Config exposing (config)


log : a -> a
log =
    Debug.log "top"


main : Routing.RouteUrlProgram Never Main.State.Model Main.State.Msg
main =
    Routing.program
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init_
        , view = \model -> Main.State.view (AuthController.extractAuthState model.auth) model
        , subscriptions =
            \init ->
                Sub.batch
                    [ Sub.map Main.State.MenusMsg (Menu.subs Menu.State.Mdl init.menus.mdl)
                    , Layout.subs Main.State.Mdl init.mdl
                    ]
        , update = Main.State.update
        }


init_ : ( Main.State.Model, Cmd Main.State.Msg )
init_ =
    ( Main.State.init config
    , Cmd.batch
        [ Layout.sub0 Main.State.Mdl

        --, Auth.refresh
        ]
    )



-- ROUTING


urlOf : Main.State.Model -> String
urlOf model =
    "#" ++ (Array.get model.selectedTab Main.State.tabUrls |> Maybe.withDefault "")


delta2url : Main.State.Model -> Main.State.Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.selectedTab /= model2.selectedTab then
        { entry = Routing.NewEntry
        , url = urlOf model2
        }
            |> Just
    else
        Nothing


location2messages : Navigation.Location -> List Main.State.Msg
location2messages location =
    [ String.dropLeft 1 location.hash |> Main.State.SelectLocation ]
