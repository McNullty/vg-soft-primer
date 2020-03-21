module Pages.Login.Login exposing (..)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, for)
import Http
import OAuth.Password as Oauth2
import Url exposing (Url)


type alias Model =
    { navKey : Nav.Key
    , url : Url
    , loginData : LoginData
    }


type alias LoginData =
    { email : String
    , password : String
    }


type alias OauthToken =
    { accessToken : String
    , tokenType : String
    , refreshToken : String
    , expiresIn : Int
    , scope : String
    , jti : String
    }


type Msg
    = StoreEmail String
    | StorePassword String
    | SendCredentials
    | ResponseReceived (Result Http.Error Oauth2.AuthenticationSuccess)


init : Nav.Key -> Url -> ( Model, Cmd Msg )
init navKey url =
    ( initialModel navKey url, Cmd.none )


initialModel : Nav.Key -> Url -> Model
initialModel navKey url =
    { navKey = navKey
    , url = url
    , loginData = emptyLoginData
    }


emptyLoginData : LoginData
emptyLoginData =
    { email = ""
    , password = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreEmail email ->
            let
                loginData =
                    model.loginData

                updateEmail =
                    { loginData | email = email }
            in
            ( { model | loginData = updateEmail }, Cmd.none )

        StorePassword password ->
            let
                loginData =
                    model.loginData

                updatePassword =
                    { loginData | password = password }
            in
            ( { model | loginData = updatePassword }, Cmd.none )

        SendCredentials ->
            ( model, sendCredentials model )

        _ ->
            ( model, Cmd.none )


resultToMsg : Result Http.Error Oauth2.AuthenticationSuccess -> Msg
resultToMsg result =
    ResponseReceived result


createAuthentication : Model -> Oauth2.Authentication
createAuthentication model =
    { credentials = Just createCredentials
    , url = createUrl model.url
    , scope = [ "write" ]
    , username = model.loginData.email
    , password = model.loginData.password
    }


createCredentials : Oauth2.Credentials
createCredentials =
    { clientId = "application-client"
    , secret = "o5EWyOd!B44d9Mg3fOjT#!gE"
    }


createUrl : Url -> Url
createUrl oldUrl =
    { oldUrl | path = "/oauth/token" }


sendCredentials : Model -> Cmd Msg
sendCredentials model =
    Oauth2.makeTokenRequest resultToMsg (createAuthentication model)
        |> Http.request



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
        , loginForm
        ]


loginForm : Html Msg
loginForm =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ Form.form []
                    [ Form.group []
                        [ Form.label [ for "email" ] [ text "Email" ]
                        , Input.text
                            [ Input.id "email"
                            , Input.onInput StoreEmail
                            ]
                        ]
                    , Form.group []
                        [ Form.label [ for "password" ] [ text "Password" ]
                        , Input.password
                            [ Input.id "password"
                            , Input.onInput StorePassword
                            ]
                        ]
                    ]
                , div []
                    [ button [ onClick SendCredentials, Button.large, Button.primary ]
                        [ text "Sign in" ]
                    ]
                ]
            ]
        ]
