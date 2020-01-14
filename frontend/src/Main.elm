module Main exposing (..)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Spinner as Spinner
import Bootstrap.Table as Table
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import RemoteData exposing (RemoteData, WebData)

type alias Greeting =
    { id : GreetingId
    , content : String
    }

type GreetingId
    = GreetingId Int

type alias Model =
    { greeting : WebData Greeting
    }

type Msg
    = FetchGreeting
    | GreetingReceived (WebData Greeting)

greetingDecoder : Decoder Greeting
greetingDecoder =
    Decode.succeed Greeting
        |> required "id" idDecoder
        |> required "content" string


idDecoder : Decoder GreetingId
idDecoder =
    Decode.map GreetingId int


idToString : GreetingId -> String
idToString (GreetingId id) =
    String.fromInt id

view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ h1 [ class "text-center" ] [ text "Greeting view" ]]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ div []
                    [ Spinner.spinner [ Spinner.large] [ text "Loading..." ] ]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ button [ onClick FetchGreeting, Button.large, Button.primary, Button.attrs [ Spacing.m1 ]]
                    [ text "Refresh posts" ]]
            ]
        , viewGreetingOrError model
        ]


viewGreetingOrError : Model -> Html Msg
viewGreetingOrError model =
    case model.greeting of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div []
                [ Spinner.spinner [ Spinner.large ] [ text "Loading..." ] ]

        RemoteData.Success greeting ->
            viewGreeting greeting

        RemoteData.Failure httpError ->
            viewError (buildErrorMessage httpError)

viewGreeting : Greeting -> Html Msg
viewGreeting greeting =
    div []
        [ Table.simpleTable
            ( Table.simpleThead
                [ Table.th [] [ text "ID" ]
                , Table.th [] [ text "Greeting" ]
                ]
                , Table.tbody []
                    [ Table.tr []
                        [ Table.td []
                             [ text (idToString greeting.id) ]
                        , Table.td []
                             [ text (greeting.content) ]
                        ]
                    ]
            )
        ]

viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message

fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "/api/greeting"
        , expect =
            greetingDecoder
                |> Http.expectJson (RemoteData.fromResult >> GreetingReceived)
        }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGreeting ->
            ( { model | greeting = RemoteData.Loading }, fetchPosts )

        GreetingReceived response ->
            ( { model | greeting = response }, Cmd.none )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { greeting = RemoteData.Loading }, fetchPosts )

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }