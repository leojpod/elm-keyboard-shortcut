module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, kbd, p, span, text)
import Html.Attributes exposing (class)
import Html.Extra
import Maybe.Extra as Maybe
import Process
import Shortcut
import Task
import Time exposing (Posix)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { showModal : Bool
    , spaceFeedBack : Maybe Posix
    , shiftSpaceFeedback : Maybe Posix
    , now : Posix
    }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { showModal = False
      , spaceFeedBack = Nothing
      , shiftSpaceFeedback = Nothing
      , now = Time.millisToPosix 0
      }
    , Cmd.none
    )


type Msg
    = ToggleModal Bool
    | SpaceRegistered
    | ShiftSpaceRegistered
    | SpaceFeedback Posix
    | ShiftSpaceFeedback Posix
    | UpdateTime Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ spaceFeedBack, shiftSpaceFeedback } as model) =
    case msg of
        ToggleModal showModal ->
            ( { model | showModal = showModal }, Cmd.none )

        SpaceRegistered ->
            ( model
            , Time.now
                |> Task.perform SpaceFeedback
            )

        SpaceFeedback time ->
            ( { model
                | spaceFeedBack = Just time
                , now = time
              }
            , Process.sleep 1000
                |> Task.andThen (\_ -> Time.now)
                |> Task.perform UpdateTime
            )

        ShiftSpaceRegistered ->
            ( model
            , Time.now
                |> Task.perform ShiftSpaceFeedback
            )

        ShiftSpaceFeedback time ->
            ( { model
                | shiftSpaceFeedback = Just time
                , now = time
              }
            , Process.sleep 1000
                |> Task.andThen (\_ -> Time.now)
                |> Task.perform UpdateTime
            )

        UpdateTime time ->
            ( { model
                | now = time
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 3000 UpdateTime


view : Model -> Browser.Document Msg
view { showModal, spaceFeedBack, shiftSpaceFeedback, now } =
    { title = "Shortcut listener"
    , body =
        [ Shortcut.shortcutElement
            [ { msg = ToggleModal True
              , keyCombination =
                    { baseKey = Shortcut.Regular "O"
                    , shift = Just True
                    , alt = Just True
                    , meta = Nothing
                    , ctrl = Nothing
                    }
              }
            , Shortcut.esc <| ToggleModal True
            ]
            [ class "flex flex-col items-center justify-center min-h-screen text-xl" ]
            [ h1 [] [ text "Welcome" ]
            , p []
                [ text "To open the modal please press "
                , kbd [] [ text "⇧" ]
                , text "+"
                , kbd [] [ text "Alt" ]
                , text "+"
                , kbd [] [ text "o" ]
                ]
            , Shortcut.shortcutElement
                [ Shortcut.simpleShortcut Shortcut.Space SpaceRegistered
                ]
                [ class "flex items-center space-x-4" ]
                [ span []
                    [ text "registering "
                    , kbd [] [ text "Space" ]
                    ]
                , span
                    [ class "transition transition-all "
                    , spaceFeedBack
                        |> Maybe.unwrap (class "opacity-0")
                            (\time ->
                                if Time.posixToMillis time + 1000 < Time.posixToMillis now then
                                    class "animate-fade-out"

                                else
                                    class ""
                            )
                    ]
                    [ text "✓" ]
                ]
            , Shortcut.shortcutElement
                [ { msg = ShiftSpaceRegistered
                  , keyCombination =
                        { baseKey = Shortcut.Space
                        , shift = Just True
                        , alt = Nothing
                        , meta = Nothing
                        , ctrl = Nothing
                        }
                  }
                ]
                [ class "flex items-center space-x-4" ]
                [ span []
                    [ text "registering "
                    , kbd [] [ text "⇧" ]
                    , text "+"
                    , kbd [] [ text "Space" ]
                    ]
                , span
                    [ class "transition transition-all "
                    , shiftSpaceFeedback
                        |> Maybe.unwrap (class "opacity-0")
                            (\time ->
                                if Time.posixToMillis time + 1000 < Time.posixToMillis now then
                                    class "animate-fade-out"

                                else
                                    class ""
                            )
                    ]
                    [ text "✓" ]
                ]
            ]
        , Html.Extra.viewIf showModal <|
            shortcutModal
                [ h1 [] [ text "This is a modal" ]
                , p []
                    [ text "Press "
                    , kbd [] [ text "Escape" ]
                    , text " to close it"
                    ]
                ]
        ]
    }


shortcutModal : List (Html Msg) -> Html Msg
shortcutModal =
    Shortcut.shortcutElement
        [ Shortcut.esc <| ToggleModal False ]
        [ class "fixed top-0 bottom-0 left-0 right-0 flex flex-col items-center justify-center bg-gray-500 bg-opacity-75" ]
        << List.singleton
        << div [ class "w-3/4 max-w-4xl p-12 bg-white border-gray-800 rounded-lg shadow-xl" ]
