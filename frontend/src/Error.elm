module Error exposing (buildErrorMessage, viewError)

import Html exposing (Html, div, h3, text)
import Http

{-| Helper function for reporting HTTP errors.
-}
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


{-| Function for reporting errors.
-}
viewError : String -> String -> Html msg
viewError errorHeading errorMessage =
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]