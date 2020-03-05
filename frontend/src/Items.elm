module Items exposing (..)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Spinner as Spinner
import Bootstrap.Table as Table exposing (Row)
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, h1, h3, span, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required, requiredAt)
import RemoteData exposing (WebData)

type ItemId
    = ItemId String

type alias Item =
    { id : ItemId
    , name : String
    , description : String
    }

type alias Page =
    { size : Int
    , totalElements : Int
    , totalPages : Int
    , number : Int
    }

type alias ItemsResponse =
    { items : (List Item)
    , page : Page
    }

type alias Model =
    { items : WebData ItemsResponse
    }

type Msg
    = FetchItems
    | ItemsReceived (WebData ItemsResponse)

init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchPosts )

initialModel : Model
initialModel =
    { items = RemoteData.Loading
    }

fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "/api/items"
        , expect =
            itemsResponseDecoder
                |> Http.expectJson (RemoteData.fromResult >> ItemsReceived)
        }


itemsResponseDecoder : Decoder ItemsResponse
itemsResponseDecoder =
    Decode.succeed ItemsResponse
        |> requiredAt ["_embedded", "items"] (list itemDecoder)
        |> requiredAt ["page"] pageDecoder


itemDecoder : Decoder Item
itemDecoder =
   Decode.succeed Item
        |> required "id" idDecoder
        |> required "name" string
        |> required "description" string

pageDecoder : Decoder Page
pageDecoder =
    Decode.succeed Page
        |> required "size" int
        |> required "totalElements" int
        |> required "totalPages" int
        |> required "number" int

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchItems ->
            ( { model | items = RemoteData.Loading }, fetchPosts )

        ItemsReceived response ->
            ( { model | items = response }, Cmd.none )

idDecoder : Decoder ItemId
idDecoder =
    Decode.map ItemId string


idToString : ItemId -> String
idToString (ItemId id) =
    id

-- VIEWS

view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ h1 [ class "text-center" ] [ text "Items view" ]]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ button [ onClick FetchItems, Button.large, Button.primary, Button.attrs [ Spacing.m1 ]]
                    [ text "Refresh items" ]]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ viewItemsOrError model ]
            ]
        ]


viewItemsOrError : Model -> Html Msg
viewItemsOrError model =
    case model.items of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div []
                [ Spinner.spinner [ Spinner.large ] [ span [ class "sr-only"]  [ text "Loading..."] ] ]

        RemoteData.Success itemsResponse ->
            viewItems itemsResponse

        RemoteData.Failure httpError ->
            viewError (buildErrorMessage httpError)


viewItems : ItemsResponse -> Html Msg
viewItems itemsResponse =
    div []
        [ Table.simpleTable
            ( Table.simpleThead
                [ Table.th [] [ text "Name" ]
                , Table.th [] [ text "Description" ]
                ]
                , Table.tbody []
                    (List.map viewItem itemsResponse.items)
            )
        ]

viewItem : Item -> Row Msg
viewItem item =
    Table.tr []
        [ Table.td []
             [ text item.name ]
        , Table.td []
             [ text item.description ]
        ]

-- TODO: Refactor - this functions should go to errors module
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