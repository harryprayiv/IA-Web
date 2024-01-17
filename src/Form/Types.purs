module Types where

import Prelude

import Data.Date (Date)
import Data.Map as Map
import Data.String (length)
import Data.Time (Time)

type Availability = Map.Map Date Boolean
