module Pages.Login.Login exposing (..)

import Browser.Navigation as Nav
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


type alias Model =
    { navKey : Nav.Key
    }


type Msg
    = StoreUsername


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( initialModel navKey, Cmd.none )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    }



--    __      _______ ________          __
--    \ \    / /_   _|  ____\ \        / /
--     \ \  / /  | | | |__   \ \  /\  / /
--      \ \/ /   | | |  __|   \ \/  \/ /
--       \  /   _| |_| |____   \  /\  /
--        \/   |_____|______|   \/  \/
--


view : Model -> Html Msg
view model =
    div []
        [ h1 [ class "text-center" ] [ text "Sign in" ]
        ]
