-- Copyright (c) 2008, Maximilian Bolingbroke
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification, are permitted
-- provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this list of
--       conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this list of
--       conditions and the following disclaimer in the documentation and/or other materials
--       provided with the distribution.
--     * Neither the name of Maximilian Bolingbroke nor the names of other contributors may be used to
--       endorse or promote products derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
-- FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
-- IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ExistentialQuantification  #-}

module Control.Concurrent.MVar.WaitHandle (
    WaitHandle,
    newWaitHandle,
    waitOnWaitHandle,
    mayWaitOnWaitHandle
) where

import Control.Concurrent.MVar
import Unsafe.Coerce (unsafeCoerce)

-- | A 'WaitHandle' is basically just an 'MVar' that can only be put into once, and
-- then never gets anything removed from it

data WaitHandle a = forall b. WH (b -> a) (MVar b)

instance Eq (WaitHandle a) where
    WH _ mvar1 == WH _ mvar2 = mvar1 == unsafeCoerce mvar2

instance Show (WaitHandle a) where
    show (WH _ _) = "WaitHandle"

instance Functor WaitHandle where
    fmap f (WH g mvar) = WH (f . g) mvar

newWaitHandle :: IO (WaitHandle a, a -> IO ())
newWaitHandle = fmap (\mvar -> (WH id mvar, \x -> tryPutMVar mvar x >> return ())) newEmptyMVar

waitOnWaitHandle :: WaitHandle a -> IO a
waitOnWaitHandle (WH f mvar) = fmap f $ readMVar mvar

-- | Looks ahead to see if the caller is likely to have to wait on the wait handle.
-- If this function returns 'True' then they may or may not actually have to wait,
-- but if the function returns 'False' then they certainly won't have to wait.

mayWaitOnWaitHandle :: WaitHandle a -> IO Bool
mayWaitOnWaitHandle (WH _ mvar) = isEmptyMVar mvar
