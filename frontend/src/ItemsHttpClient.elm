module ItemsHttpClient exposing (..)

import CommonTypes exposing (PagingData)
import Dict exposing (Dict)
import Http exposing (Metadata, Response(..), expectStringResponse)
import Json.Decode as Decode exposing (Error(..))
import Json.Decode.Pipeline as Pipeline
import Pages.Items.Item exposing (Item, ItemId(..), itemDecoder)
import RemoteData exposing (WebData)

type alias ItemsResponseBody =
    { items : (List Item)
    , page : PagingData
    }


type alias ItemsResponse =
    { body : ItemsResponseBody
    , etag : Maybe String
    }


type Msg
    = FetchError String
    | ItemsReceived (WebData ItemsResponse)
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
            |> Pipeline.optionalAt ["_embedded", "items"] (Decode.list itemDecoder) []
            |> Pipeline.requiredAt ["page"] pageDecoder


getEtagFromHeader : Dict String String -> Maybe String
getEtagFromHeader headers =
    Dict.get "etag" headers

{-|
    This function uses header metadata and body from response to create ItemsResponse type
-}
processMetadataAndBody : Metadata -> String -> Result Decode.Error ItemsResponse
processMetadataAndBody metadata body =
    let
        etagResult = getEtagFromHeader metadata.headers

        bodyResult = Decode.decodeString itemsResponseDecoder body
        response  =
            case bodyResult of
                Result.Ok value ->  Result.Ok { body = value
                                              , etag = etagResult
                                              }
                Result.Err err -> Result.Err err

    in
    response


{-| This function takes parsed result that was already put in type and creates appropriate application message

    This function will take results form parser and create application message depending on result
-}
customMessageFromResult : (Result Decode.Error ItemsApiResponses -> Msg)
customMessageFromResult result =
    case result of
        Result.Ok value ->
            case value of
                Success itemResponse -> ItemsReceived (RemoteData.Success itemResponse)
                NotModified -> ItemsNotModified
                CustomError errorMessage-> FetchError errorMessage
        Result.Err errorMessage ->
            FetchError ("Custom error message" ++ Decode.errorToString errorMessage)


type ItemsApiResponses
    = Success ItemsResponse
    | NotModified
    | CustomError String


{-|
    This function gets response from HTTP client and translates it to type or error.

    Output fom this function will be passed to  customFromResult
-}
customResponseToResult : Response String -> Result Decode.Error ItemsApiResponses
customResponseToResult response =
     case response of
         BadUrl_ url ->
             Result.Ok (CustomError ("Bad url: " ++ url))
         Timeout_ ->
             Result.Ok (CustomError "Timeout")
         NetworkError_ ->
             Result.Ok (CustomError "Network error")
         BadStatus_ _ body ->
             Result.Ok (CustomError body)
         GoodStatus_ metadata body ->
             case metadata.statusCode of
                 200 -> let
                            response = processMetadataAndBody metadata body

                            apiResponse =
                                case response of
                                    Result.Ok value -> Result.Ok (Success value)
                                    Result.Err error ->
                                        Result.Ok (CustomError ("Error while parsing: " ++ Decode.errorToString error))

                        in
                        apiResponse
                 305 -> Result.Ok NotModified

customExpectJson : Http.Expect Msg
customExpectJson  =
    expectStringResponse customMessageFromResult customResponseToResult