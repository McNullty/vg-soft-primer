module Pages.Greeting.Greeting exposing (..)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Spinner as Spinner
import Bootstrap.Table as Table
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, h1, h3, text, span)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)
import Http
import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)


type alias Model =
    { greeting : WebData Greeting
    }

type alias Greeting =
    { id : GreetingId
    , content : String
    }

type GreetingId
    = GreetingId Int

type Msg
    = FetchGreeting
    | GreetingReceived (WebData Greeting)

init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchGreeting )

initialModel : Model
initialModel =
    { greeting = RemoteData.Loading
    }

fetchGreeting : Cmd Msg
fetchGreeting =
    Http.get
        { url = "/api/greeting"
        , expect =
            greetingDecoder
                |> Http.expectJson (RemoteData.fromResult >> GreetingReceived)
        }

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

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGreeting ->
            ( { model | greeting = RemoteData.Loading }, fetchGreeting )

        GreetingReceived response ->
            ( { model | greeting = response }, Cmd.none )

-- VIEWS

view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ h1 [ class "text-center" ] [ text "Greeting view" ]]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ button [ onClick FetchGreeting, Button.large, Button.primary, Button.attrs [ Spacing.m1 ]]
                    [ text "Refresh posts" ]]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ viewGreetingOrError model ]
            ]
        ]


viewGreetingOrError : Model -> Html Msg
viewGreetingOrError model =
    case model.greeting of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div []
                [ Spinner.spinner [ Spinner.large ] [ span [ class "sr-only"]  [ text "Loading..."] ] ]

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
