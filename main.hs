import           BasicPrelude
import           Control.Concurrent
import           Control.Concurrent.Async
import           Control.Concurrent.STM
import           Control.Monad.Trans.Resource
import           Data.Conduit
import           Data.Conduit.Binary
import           Data.Conduit.Serialization.Binary
import qualified Data.Conduit.List as CL
import           Data.Conduit.TMChan
import           SwiftNav.SBP
import           System.IO hiding (putStrLn)
import           Safe

touch :: SBPMsg -> SBPMsg
touch = id

main0 :: IO ()
main0 =
  runResourceT $
    sourceHandle stdin =$=
    conduitDecode      =$=
    CL.map touch       $$
    CL.sinkNull

main1 :: IO ()
main1 = do
  chan <- atomically $ newBroadcastTMChan
  runResourceT $
    sourceHandle stdin =$=
    conduitDecode      =$=
    CL.map touch       $$
    sinkTMChan chan True

main2 :: IO ()
main2 = do
  chan <- atomically $ newBroadcastTMChan
  runResourceT $
    sourceHandle stdin =$=
    conduitDecode      =$=
    CL.map touch       =$=
    conduitEncode      $$
    sinkTMChan chan True

main3 :: IO ()
main3 = do
  chan    <- atomically $ newBroadcastTMChan
  chanDup <- atomically $ dupTMChan chan
  void $ concurrently
    ( runResourceT $
        sourceHandle stdin =$=
        conduitDecode      =$=
        CL.map touch       $$
        sinkTMChan chan True )
    ( runResourceT $
        sourceTMChan chanDup $$
          CL.sinkNull )

main4 :: IO ()
main4 = do
  chan    <- atomically $ newBroadcastTMChan
  chanDup <- atomically $ dupTMChan chan
  void $ concurrently
    ( runResourceT $
        sourceHandle stdin =$=
        conduitDecode      =$=
        CL.map touch       =$=
        conduitEncode      $$
        sinkTMChan chan True )
    ( runResourceT $
        sourceTMChan chanDup $$
          CL.sinkNull )

main5 :: IO ()
main5 = do
  chan    <- atomically $ newBroadcastTMChan
  chanDup <- atomically $ dupTMChan chan
  void $ concurrently
    ( runResourceT $
        sourceHandle stdin =$=
        conduitDecode      =$=
        CL.map touch       $$
        sinkTMChan chan True )
    ( runResourceT $
        sourceTMChan chanDup =$=
          conduitEncode      $$
          CL.sinkNull )

main6 :: IO ()
main6 = do
  chan    <- atomically $ newBroadcastTMChan
  chanDup <- atomically $ dupTMChan chan
  void $ concurrently
    ( runResourceT $
        sourceHandle stdin $$
        sinkTMChan chan True )
    ( runResourceT $
        sourceTMChan chanDup $$
          CL.sinkNull )

sleeper :: SBPMsg -> ResourceT IO SBPMsg
sleeper m = do
  liftIO $ threadDelay 1
  return m

main7 :: IO ()
main7 = do
  chan    <- atomically $ newBroadcastTMChan
  chanDup <- atomically $ dupTMChan chan
  void $ concurrently
    ( runResourceT $
        sourceHandle stdin =$=
        conduitDecode      =$=
        CL.map touch       =$=
        CL.mapM sleeper    $$
        sinkTMChan chan True )
    ( runResourceT $
        sourceTMChan chanDup $$
          CL.sinkNull )

main :: IO ()
main = do
  args <- getArgs
  case headDef "0" args of
    "1" -> main1
    "2" -> main2
    "3" -> main3
    "4" -> main4
    "5" -> main5
    "6" -> main6
    "7" -> main7
    _   -> main0
