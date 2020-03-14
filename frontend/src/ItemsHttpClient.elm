module ItemsHttpClient exposing (..)

import CommonTypes exposing (PagingData)
import Dict exposing (Dict)
import Http exposing (Metadata, Response(..), expectStringResponse)
import Json.Decode as Decode exposing (Error(..))
import Json.Decode.Pipeline as Pipeline
import Pages.Items.Item exposing (Item, ItemId(..), itemDecoder)
import RemoteData exposing (WebData)


type alias ItemsResponseBody =
    { items : List Item
    , page : PagingData
    }


type alias ItemsResponse =
    { body : ItemsResponseBody
    , etag : Maybe String
    }


type ItemsApiResponses
    = Success ItemsResponse
    | NotModified
    | CustomError String


type FetchingResults fetchingType
    = FetchError String
    | ItemsReceived (WebData fetchingType)
    | ItemsNotModified


pageDecoder : Decode.Decoder PagingData
pageDecoder =
    Decode.succeed PagingData
        |> Pipeline.required "size" Decode.int
        |> Pipeline.required "totalElements" Decode.int
        |> Pipeline.required "totalPages" Decode.int
        |> Pipeline.required "number" Decode.int


itemsResponseDecoder : Decode.Decoder ItemsResponseBody
itemsResponseDecoder =
    Decode.succeed ItemsResponseBody
        |> Pipeline.optionalAt [ "_embedded", "items" ] (Decode.list itemDecoder) []
        |> Pipeline.requiredAt [ "page" ] pageDecoder


getEtagFromHeader : Dict String String -> Maybe String
getEtagFromHeader headers =
    Dict.get "etag" headers


{-|

    This function uses header metadata and body from response to create ItemsResponse type

-}
processMetadataAndBody : Metadata -> String -> Result Decode.Error ItemsResponse
processMetadataAndBody metadata body =
    let
        etagResult =
            getEtagFromHeader metadata.headers

        bodyResult =
            Decode.decodeString itemsResponseDecoder body

        response =
            case bodyResult of
                Result.Ok value ->
                    Result.Ok
                        { body = value
                        , etag = etagResult
                        }

                Result.Err err ->
                    Result.Err err
    in
    response


{-| This function takes parsed result that was already put in type and creates appropriate application message

    This function will take results form parser and create application message depending on result

-}
customResultToMessage : (FetchingResults -> a) -> (Result Decode.Error ItemsApiResponses -> a)
customResultToMessage converter result =
    let
        fetchingResults =
            case result of
                Result.Ok value ->
                    case value of
                        Success itemResponse ->
                            ItemsReceived (RemoteData.Success itemResponse)

                        NotModified ->
                            ItemsNotModified

                        CustomError errorMessage ->
                            FetchError errorMessage

                Result.Err errorMessage ->
                    FetchError ("Custom error message" ++ Decode.errorToString errorMessage)
    in
    converter fetchingResults


{-|

    This function gets response from HTTP client and translates it to type or error.

    Output fom this function will be passed to  customFromResult

-}
customResponseToResult :
    Response String
    -> (Metadata -> String -> Result Decode.Error ItemsResponse)
    -> Result Decode.Error ItemsApiResponses
customResponseToResult response metadataAndBodyProcessor =
    let
        _ =
            Debug.log "Response" response
    in
    case response of
        BadUrl_ url ->
            Result.Ok (CustomError ("Bad url: " ++ url))

        Timeout_ ->
            Result.Ok (CustomError "Timeout")

        NetworkError_ ->
            Result.Ok (CustomError "Network error")

        BadStatus_ metadata body ->
            let
                _ =
                    Debug.log "Metadata status" metadata.statusCode

                _ =
                    Debug.log "Bad status body" body
            in
            case metadata.statusCode of
                304 ->
                    Result.Ok NotModified

                _ ->
                    Result.Ok (CustomError ("Mad status" ++ String.fromInt metadata.statusCode ++ body))

        GoodStatus_ metadata body ->
            case metadata.statusCode of
                200 ->
                    let
                        processingResponse =
                            metadataAndBodyProcessor metadata body

                        apiResponse =
                            case processingResponse of
                                Result.Ok value ->
                                    Result.Ok (Success value)

                                Result.Err error ->
                                    Result.Ok (CustomError ("Error while parsing: " ++ Decode.errorToString error))
                    in
                    apiResponse

                _ ->
                    Result.Ok
                        (CustomError
                            ("Good status but with unknown value: " ++ String.fromInt metadata.statusCode)
                        )


customExpectFunction :
    (FetchingResults -> a)
    -> (Response String -> Result Decode.Error ItemsApiResponses)
    -> Http.Expect a
customExpectFunction converter responseToResult =
    expectStringResponse (customResultToMessage converter) responseToResult


responseToItemsApiResponse : Response String -> Result Decode.Error ItemsApiResponses
responseToItemsApiResponse response =
    customResponseToResult response processMetadataAndBody


fetchItems : Int -> Maybe String -> (FetchingResults -> a) -> Cmd a
fetchItems pageNumber etag convertToMsg =
    Http.request
        { method = "GET"
        , headers =
            case etag of
                Just tag ->
                    [ Http.header "If-None-Match" tag ]

                Nothing ->
                    []
        , url = "/api/items?page=" ++ String.fromInt pageNumber
        , body = Http.emptyBody
        , expect = customExpectFunction convertToMsg responseToItemsApiResponse
        , timeout = Nothing
        , tracker = Nothing
        }
