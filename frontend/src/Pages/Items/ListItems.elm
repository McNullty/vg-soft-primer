module Pages.Items.ListItems exposing (Model, Msg(..), init, update, view, pagingData, convertToMsg)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Pagination as Pagination
import Bootstrap.Spinner as Spinner
import Bootstrap.Table as Table exposing (Row)
import Bootstrap.Utilities.Spacing as Spacing
import Error exposing (buildErrorMessage, viewError)
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (class, href)
import Http exposing (Error(..), Expect, Metadata)
import ItemsHttpClient exposing (FetchingResults(..), ItemsResponse, fetchItems)
import List exposing (length, range)
import Pages.Items.Item as Item exposing (Item, ItemId, idToString)
import RemoteData exposing (RemoteData(..), WebData)
import Result as Http


type alias Model =
    { itemsResponse : WebData ItemsResponse
    , errorMessage : Maybe String
    , activePage : Int
    , etag : Maybe String
    , cachedItemsResponse : Maybe (WebData ItemsResponse)
    }


type Msg
    = FetchItems
    | ResponseReceived FetchingResults
    | DeleteItem ItemId
    | ItemDeleted (Result Http.Error String)
    | Pagination Int


init : Int -> ( Model, Cmd Msg )
init pageNumber =
    ( initialModel pageNumber, fetchItems pageNumber Nothing convertToMsg)


initialModel : Int -> Model
initialModel pageNumber =
    { itemsResponse = RemoteData.Loading
    , errorMessage = Nothing
    , activePage = pageNumber
    , etag = Nothing
    , cachedItemsResponse = Nothing
    }


convertToMsg : FetchingResults -> Msg
convertToMsg result =
    ResponseReceived result


deleteItem : ItemId -> Cmd Msg
deleteItem itemId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "/api/items/" ++ (idToString itemId)
        , body = Http.emptyBody
        , expect = Http.expectString ItemDeleted
        , timeout = Nothing
        , tracker = Nothing
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ = Debug.log "ListItems Msg" msg
    in
    case msg of
        FetchItems ->
            ( { model | itemsResponse = RemoteData.Loading }, fetchItems model.activePage model.etag convertToMsg )

        ResponseReceived results ->
            case results of
                FetchError error ->
                    ( { model | errorMessage = Just  error }
                    , Cmd.none
                    )


                ItemsReceived webData ->
                    let
                        numberOfItems =
                            case webData of
                                Success res -> length res.body.items
                                _ -> 0

                        etag =
                            case webData of
                                Success res -> res.etag
                                _ -> Nothing

                        _ = Debug.log "Got items" numberOfItems
                    in
                    case numberOfItems of
                        0 -> ( { model | itemsResponse = RemoteData.Loading }, fetchItems (model.activePage - 1) model.etag convertToMsg )
                        _ -> ( { model | itemsResponse = webData, etag = etag, cachedItemsResponse = Just webData }, Cmd.none )


                ItemsNotModified ->
                    let
                        cachedItemsResponse =
                            case model.cachedItemsResponse of
                                Just itemResponse -> itemResponse
                                Nothing -> RemoteData.Loading

                        error =
                            case model.cachedItemsResponse of
                                Just _ -> Nothing
                                Nothing -> Just "Not found anything in cache"
                    in
                    (  { model | itemsResponse = cachedItemsResponse, errorMessage = error}, Cmd.none)


        DeleteItem itemId ->
            ( model, deleteItem itemId )

        ItemDeleted (Ok _) ->
            ( model, fetchItems model.activePage model.etag convertToMsg )

        ItemDeleted (Err error) ->
            ( { model | errorMessage = Just (buildErrorMessage error) }
            , Cmd.none
            )

        Pagination page ->
            ( {model | activePage = page }, Cmd.none)


--    __      _______ ________          __
--    \ \    / /_   _|  ____\ \        / /
--     \ \  / /  | | | |__   \ \  /\  / /
--      \ \/ /   | | |  __|   \ \/  \/ /
--       \  /   _| |_| |____   \  /\  /
--        \/   |_____|______|   \/  \/
--


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
                    [ text "Refresh items" ]
                , Alert.link [href "/items-new"] [text "Create new Item"]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ viewItemsOrError model ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ simplePaginationList model ]
            ]
        ]


viewItemsOrError : Model -> Html Msg
viewItemsOrError model =
    case model.itemsResponse of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div []
                [ Spinner.spinner [ Spinner.large ] [ span [ class "sr-only"]  [ text "Loading..."] ] ]

        RemoteData.Success itemsResponse ->
            viewItems itemsResponse

        RemoteData.Failure httpError ->
            viewError "Couldn't fetch data at this time." (buildErrorMessage httpError)


viewItems : ItemsResponse -> Html Msg
viewItems itemsResponse =
    div []
        [ Table.simpleTable
            ( Table.simpleThead
                [ Table.th [] [ text "Name" ]
                , Table.th [] [ text "Description" ]
                ]
                , Table.tbody []
                    (List.map viewItem itemsResponse.body.items)
            )
        ]

viewItem : Item -> Row Msg
viewItem item =
    Table.tr []
        [ Table.td []
            [ text item.name ]
        , Table.td []
            [ text item.description ]
        , Table.td []
            [ Alert.link [href ("/items/" ++ (Item.idToString item.id))] [text "Edit"]]
        , Table.td []
            [ button [onClick (DeleteItem item.id), Button.large, Button.primary ] [text "Delete"]]
        ]



simplePaginationList : Model -> Html Msg
simplePaginationList model =
    Pagination.defaultConfig
        |> Pagination.ariaLabel "Pagination"
        |> Pagination.align HAlign.centerXs
        |> Pagination.large
        |> Pagination.itemsList
            { selectedMsg = Pagination
            , prevItem = Just <| Pagination.ListItem [] [ text "Previous" ]
            , nextItem = Just <| Pagination.ListItem [] [ text "Next" ]
            , activeIdx = model.activePage
            , data = pagingDataFromModel model
            , itemFn = \idx _ -> Pagination.ListItem [] [ text <| String.fromInt (idx + 1) ]
            , urlFn = \idx _ -> "/items?page=" ++ String.fromInt idx
            }
        |> Pagination.view

pagingDataFromModel : Model -> List Int
pagingDataFromModel model =
    case model.itemsResponse of
        RemoteData.Success itemsResponse ->
            pagingData itemsResponse.body.page.totalPages

        _ ->
            []

pagingData : Int -> List Int
pagingData numberOfPages =
    range 1 numberOfPages

