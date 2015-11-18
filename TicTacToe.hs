{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}

module TicTacToe where


-- | represents the choice of a player
data Marker = Circle | Cross 
  deriving (Eq, Show)

-- | fields make up the board
data Field = Empty | FieldCons Marker 
  deriving (Eq)

-- | a row consists of three fields
data Row = RowCons Field Field Field

-- | a board consists of three rows
data Board = BoardCons Row Row Row

-- | convenience type definitions
type BoardOrMsg = Either Board String
type Choice = (Int, Int, Marker)

instance Show Field where
  show (FieldCons m)
    | m == Circle = "O"
    | otherwise   = "X"
  show Empty = " "

instance Show Row where
  show (RowCons f0 f1 f2) = show f0 ++ " " ++ show f1 ++ " " ++ show f2

instance Show Board where
  show (BoardCons r0 r1 r2) =  show r0 ++ "\n" ++ show r1 ++ "\n" ++ show r2 

instance Show BoardOrMsg where
  show bmsg = case bmsg of 
    (Left b) -> show b
    (Right msg) -> msg



-- | creates the initial empty board with only empty fields
initialBoard :: BoardOrMsg
initialBoard = let initialRows = replicate 3 (RowCons Empty Empty Empty)
                 in boardFromRows initialRows

boardFromRows :: [Row] -> BoardOrMsg
boardFromRows rows
  | length rows /= 3 = Right ("Not the right number of rows: " ++ show (length rows))
  | otherwise = Left (BoardCons (rows !! 0) (rows !! 1) (rows !! 2))


makeChoice :: Choice -> BoardOrMsg -> BoardOrMsg
makeChoice c@(col, row, _) (Left b)   
  | isFree (col, row) b   = Left (makeChoicePure c b)
  | otherwise             = Right ("The field (" ++ show col ++ "," ++ show row ++ ") is already used.")
makeChoice c (Right msg)  = Right ("Can't make choice " ++ show c ++ "; " ++ msg)


-- | a player makes a choice by passing (x, y)-coordinates and a marker
makeChoicePure :: (Int, Int, Marker) -> Board -> Board
makeChoicePure (col, row, m) (BoardCons r0 r1 r2) 
  | row == 0 = BoardCons (newRow (col, m) r0) r1 r2
  | row == 1 = BoardCons r0 (newRow (col, m) r1) r2
  | row == 2 = BoardCons r0 r1 (newRow (col, m) r2)


isFree :: (Int, Int) -> Board -> Bool
isFree (col, row) (BoardCons (RowCons f0 f1 f2) (RowCons f3 f4 f5) (RowCons f6 f7 f8)) = 
    let fields = [f0, f1, f2, f3, f4, f5, f6, f7, f8]
        index  = row*3 + col
        in fields !! index == Empty

-- | helper function to create a new row
newRow :: (Int, Marker) -> Row -> Row
newRow (col, m) (RowCons f0 f1 f2) 
  | col == 0 = RowCons (FieldCons m) f1 f2
  | col == 1 = RowCons f0 (FieldCons m) f2
  | col == 2 = RowCons f0 f1 (FieldCons m)


checkWinner :: BoardOrMsg -> Maybe Marker
checkWinner (Left b)    = checkWinnerPure b
checkWinner (Right msg) = Nothing

checkWinnerPure :: Board -> Maybe Marker
checkWinnerPure b = let res0 = checkRows b in
                case res0 of
                  Just _ -> res0
                  Nothing -> let res1 = checkCols b in
                    case res1 of
                      Just _ -> res1
                      Nothing -> let res2 = checkDiagonals b in
                        case res2 of
                          Just _ -> res2
                          Nothing -> Nothing


checkRows :: Board -> Maybe Marker
checkRows (BoardCons r0 r1 r2) = let res0 = checkRow r0 in
                case res0 of
                  Just _ -> res0
                  Nothing -> let res1 = checkRow r1 in
                    case res1 of
                      Just _ -> res1
                      Nothing -> let res2 = checkRow r2 in
                        case res2 of
                          Just _ -> res2
                          Nothing -> Nothing


checkRow :: Row -> Maybe Marker
checkRow (RowCons f0 f1 f2) 
  | f0 == f1 && f1 == f2  = case f0 of
    Empty              -> Nothing
    (FieldCons Cross)  -> Just Cross
    (FieldCons Circle) -> Just Circle
  | otherwise             = Nothing


checkCols :: Board -> Maybe Marker
checkCols b = let res0 = checkFirstCol b in
                case res0 of
                  Just _ -> res0
                  Nothing -> let res1 = checkSecondCol b in
                    case res1 of
                      Just _ -> res1
                      Nothing -> let res2 = checkThirdCol b in
                        case res2 of
                          Just _ -> res2
                          Nothing -> Nothing

checkFirstCol :: Board -> Maybe Marker
checkFirstCol (BoardCons (RowCons f0 _ _) (RowCons f1 _ _) (RowCons f2 _ _)) 
  | f0 == f1 && f1 == f2 = case f0 of
    Empty              -> Nothing
    (FieldCons Cross)  -> Just Cross
    (FieldCons Circle) -> Just Circle
  | otherwise = Nothing
  
checkSecondCol :: Board -> Maybe Marker
checkSecondCol (BoardCons (RowCons _ f0 _) (RowCons _ f1 _) (RowCons _ f2 _)) 
  | f0 == f1 && f1 == f2 = case f0 of
    Empty              -> Nothing
    (FieldCons Cross)  -> Just Cross
    (FieldCons Circle) -> Just Circle
  | otherwise = Nothing
  
checkThirdCol :: Board -> Maybe Marker
checkThirdCol (BoardCons (RowCons _ _ f0) (RowCons _ _ f1) (RowCons _ _ f2)) 
  | f0 == f1 && f1 == f2 = case f0 of
    Empty              -> Nothing
    (FieldCons Cross)  -> Just Cross
    (FieldCons Circle) -> Just Circle
  | otherwise = Nothing

checkDiagonals :: Board -> Maybe Marker
checkDiagonals (BoardCons (RowCons f00 _ f10) (RowCons _ f1 _) (RowCons f12 _ f02)) 
  | f00 == f1 && f1 == f02 = case f00 of
    Empty              -> Nothing
    (FieldCons Cross)  -> Just Cross
    (FieldCons Circle) -> Just Circle
  | f10 == f1 && f1 == f12 = case f10 of
    Empty              -> Nothing
    (FieldCons Cross)  -> Just Cross
    (FieldCons Circle) -> Just Circle
  | otherwise = Nothing
  



