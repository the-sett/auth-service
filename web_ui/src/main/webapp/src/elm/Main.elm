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
import Auth.Types
import Auth.State


log : a -> a
log =
    Debug.log "top"


main : Program (Maybe Auth.Types.SavedModel)
main =
    Routing.programWithFlags
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init'
        , view = \model -> view model.auth.authState model
        , subscriptions =
            \init ->
                Sub.batch
                    [ Sub.map MenusMsg (Menu.subs Menu.Types.MDL init.menus.mdl)
                    , Layout.subs Mdl init.mdl
                    , Sub.map AuthMsg (Auth.State.subscriptions init.auth)
                    ]
        , update = update
        }



-- The program may be started with an existing auth model (containing an
-- authentication token). If this is the case, the token is kept.
-- Generally, this will not be done as keeping the auth state in web storage
-- is a security weakness. A better alternative is to attempt to regain the
-- auth status from the server - if the browser still holds a valid auth token
-- in a cookie this will be possible.


init' : Maybe Auth.Types.SavedModel -> ( Model, Cmd Msg )
init' authModel =
    case authModel of
        Just authModel ->
            let
                d =
                    log "authModel present"
            in
                ( { init
                    | auth = Auth.State.fromSavedModel authModel Auth.State.init
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
    [ String.dropLeft 1 location.hash |> SelectLocation ]
