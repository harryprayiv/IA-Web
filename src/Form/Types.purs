module Types where


import Data.Date (Date)
import Data.Map as Map

type Availability = Map.Map Date Boolean
