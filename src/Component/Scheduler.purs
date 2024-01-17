module Scheduler where

import Prelude

import Calendar as C
import Data.Date (Date, day, month, year)
import Data.DateTime (DateTime)
import Data.Enum (fromEnum)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (joinWith)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Effect.Class (class MonadEffect, liftEffect)
import Form as F
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events (onClick)
import JSURI (encodeURI)
import Type.Prelude (Proxy(..))
import Types (Availability)
import Utils (css)
import Web.HTML (window)
import Web.HTML.Window (open)

type State =
  { currentlyPicked ∷ F.Option
  , availability ∷ Availability
  , datetime ∷ DateTime
  }

data Action = HandlePicked F.Output | HandleDate C.Output | Reset | Export

type Input = DateTime

type Slots =
  ( calendar ∷ ∀ q. H.Slot q C.Output Unit
  , form ∷ ∀ q. H.Slot q F.Output Unit
  )

initialState ∷ Input → State
initialState date = { currentlyPicked: Nothing, availability: Map.empty, datetime: date }

component ∷ ∀ q o. H.Component q Input o Aff
component =
  H.mkComponent
    { initialState: initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }

render ∷ State → H.ComponentHTML Action Slots Aff
render state =
  HH.div [ css "app" ]
    [ HH.div [ css "calendar-container" ]
        [ HH.slot (Proxy ∷ Proxy "calendar") unit C.calendar { now: state.datetime, availability: state.availability } HandleDate
        , HH.slot (Proxy ∷ Proxy "form") unit F.form unit HandlePicked
        ]
    , HH.div [ css "buttons" ]
        [ HH.button [ onClick (\_ → Reset), css "button__reset" ] [ HH.text "Reset" ]
        , HH.button [ onClick (\_ → Export), css "button__export" ] [ HH.text "Export" ]
        ]
    ]

handleAction ∷ ∀ cs o m. MonadEffect m ⇒ Action → H.HalogenM State Action cs o m Unit
handleAction = case _ of
  HandlePicked option → do 
    H.modify_ _ { currentlyPicked = option }

  Reset → do
    H.modify_ _ { availability = Map.empty }

  Export → do
    av ← _.availability <$> H.get
    let csvContent = fromMaybe "" (encodeURI $ "data:text/csv," <> availabilityCSV av)
    _ ← liftEffect $ window >>= open csvContent "" ""
    pure unit

  HandleDate date → do
    H.modify_ \s → case s.currentlyPicked of
      Just _ → s { availability = Map.alter toggleAvailability date s.availability }
      Nothing → s

  where
    toggleAvailability ∷ Maybe Boolean → Maybe Boolean
    toggleAvailability = Just <<< not <<< fromMaybe false

    availabilityCSV ∷ Availability → String
    availabilityCSV av =
      let
        header = "Date,Available"
        eventData = Map.toUnfoldableUnordered av
      in
        header <> "\n" <> joinWith "\n" (map mkRow eventData)

      where
      showDate ∷ Date → String
      showDate d = show (fromEnum $ year d) <> "/" <> show (fromEnum $ month d) <> "/" <> show (fromEnum $ day d)

      mkRow ∷ Tuple Date Boolean → String
      mkRow (Tuple d available) = showDate d <> "," <> (if available then "Yes" else "No")