module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Extra
import Shortcut


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    Bool


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( False, Cmd.none )


type Msg
    = CloseModal
    | OpenModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        CloseModal ->
            ( False, Cmd.none )

        OpenModal ->
            ( True, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view showModal =
    { title = "Shortcut listener"
    , body =
        [ Shortcut.shortcutElement
            [ { msg = OpenModal
              , keyCombination =
                    { baseKey = Shortcut.Regular "O"
                    , shift = Just True
                    , alt = Just True
                    , meta = Nothing
                    , ctrl = Nothing
                    }
              }
            , Shortcut.esc OpenModal
            ]
            [ class "flex flex-col items-center justify-center min-h-screen text-xl" ]
            [ Html.h1 [] [ text "Welcome" ]
            , Html.p []
                [ text "To open the modal please press "
                , Html.kbd [] [ text "Shift" ]
                , text "+"
                , Html.kbd [] [ text "Alt" ]
                , text "+"
                , Html.kbd [] [ text "o" ]
                ]
            ]
        , Html.Extra.viewIf showModal <|
            shortcutModal
                [ Html.h1 [] [ text "This is a modal" ]
                , Html.p []
                    [ text "Press "
                    , Html.kbd [] [ text "Escape" ]
                    , text " to close it"
                    ]
                ]
        ]
    }


shortcutModal : List (Html Msg) -> Html Msg
shortcutModal =
    Shortcut.shortcutElement
        [ Shortcut.esc CloseModal ]
        [ class "fixed top-0 bottom-0 left-0 right-0 flex flex-col items-center justify-center bg-gray-500 bg-opacity-75" ]
        << List.singleton
        << div [ class "w-3/4 max-w-4xl p-12 bg-white border-gray-800 rounded-lg shadow-xl" ]
