module Main exposing (..)

import Array exposing (Array)
import String
import Navigation
import RouteUrl as Routing
import Material.Layout as Layout
import Material.Menu as Menu
import Menu.Types
import Main.Types exposing (..)
import Main.State exposing (..)
import Main.View exposing (..)
import AuthController
import Auth


log : a -> a
log =
    Debug.log "top"


main : Program Never (Routing.Model Model) (Routing.Msg Msg)
main =
    Routing.program
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init_
        , view = \model -> view model.auth.authState model
        , subscriptions =
            \init ->
                Sub.batch
                    [ Sub.map MenusMsg (Menu.subs Menu.Types.MDL init.menus.mdl)
                    , Layout.subs Mdl init.mdl
                    , Sub.map AuthMsg (AuthController.subscriptions init.auth)
                    ]
        , update = update
        }


init_ : ( Model, Cmd Msg )
init_ =
    ( init, Cmd.batch [ Layout.sub0 Mdl, Auth.refresh ] )



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
    [ String.dropLeft 1 location.hash |> SelectLocation ]
