module Scheduler where

import Prelude

import Affjax.RequestBody as AXRB
import Affjax.ResponseFormat as AXRF
import Affjax.Web as AXW
import Calendar as C
import Data.Argonaut (Json, fromObject)
import Data.Argonaut.Encode (encodeJson)
import Data.Array (foldl)
import Data.Date (Date, day, month, year)
import Data.DateTime (DateTime)
import Data.Either (Either(..))
import Data.Enum (fromEnum)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (joinWith)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign.Object as Obj
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

--new

type State =
  { currentlyPicked ∷ F.Option
  , availability ∷ Availability
  , datetime ∷ DateTime
  }

data Action = HandlePicked F.Output | HandleDate C.Output | Reset | Export | SendData

type Input = DateTime

type Slots =
  ( calendar ∷ ∀ q. H.Slot q C.Output Unit
  , form ∷ ∀ q. H.Slot q F.Output Unit
  )

initialState ∷ Input → State
initialState date = { currentlyPicked: Nothing, availability: Map.empty, datetime: date }

-- component :: forall q o. H.Component q Input o Aff
-- component = H.mkComponent
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
        , HH.button [ onClick (\_ → SendData), css "button__send" ] [ HH.text "Send" ]
        ]
    ]

-- handleAction ∷ ∀ cs o m. MonadEffect m ⇒ Action → H.HalogenM State Action cs o m Unit
-- handleAction = case _ of
handleAction :: forall o m. MonadAff m => Action -> H.HalogenM State Action Slots o m Unit
handleAction action = case action of
  HandlePicked option → do 
    H.modify_ _ { currentlyPicked = option }

  Reset → do
    H.modify_ _ { availability = Map.empty }

  Export → do
    av ← _.availability <$> H.get
    let csvContent = fromMaybe "" (encodeURI $ "data:text/csv," <> availabilityCSV av)
    _ ← liftEffect $ window >>= open csvContent "" ""
    pure unit

  SendData → do
    av ← _.availability <$> H.get
    let jsonData = encodeJson $ availabilityToJson av
    let requestBody = Just $ AXRB.json jsonData
    response ← H.liftAff $ AXW.post AXRF.json "https://httpbin.org/post" requestBody
    case response of
      Left _ → do
        liftEffect $ log $ "Error!"

      Right _ → do
        liftEffect $ log $ "Success: Data sent successfully."

    pure unit

  HandleDate date → do
    H.modify_ \s → case s.currentlyPicked of
      Just _ → s { availability = Map.alter toggleAvailability date s.availability }
      Nothing → s

  where
    toggleAvailability ∷ Maybe Boolean → Maybe Boolean
    toggleAvailability = Just <<< not <<< fromMaybe false

    availabilityToJson ∷ Availability → Json
    availabilityToJson av =
      let
        eventData = Map.toUnfoldableUnordered av
        addEntry :: Obj.Object Json -> Tuple Date Boolean -> Obj.Object Json
        addEntry acc (Tuple d available) = Obj.insert (showDate d) (encodeJson available) acc
      in
        fromObject $ foldl addEntry Obj.empty eventData


    availabilityCSV ∷ Availability → String
    availabilityCSV av =
      let
        header = "Date,Available"
        eventData = Map.toUnfoldableUnordered av
      in
        header <> "\n" <> joinWith "\n" (map mkRow eventData)

      where
      mkRow ∷ Tuple Date Boolean → String
      mkRow (Tuple d available) = showDate d <> "," <> (if available then "Yes" else "No")

showDate ∷ Date → String
showDate d = show (fromEnum $ year d) <> "/" <> show (fromEnum $ month d) <> "/" <> show (fromEnum $ day d)