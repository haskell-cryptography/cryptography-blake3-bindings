{-# LANGUAGE CApiFFI #-}

-- | Module: Cryptography.BLAKE3
-- Description: BLAKE3 low-level primitives
-- Copyright: (C) Koz Ross 2022
-- License: BSD-3-Clause
-- Maintainer: koz.ross@retro-freedom.nz
-- Stability: Stable
-- Portability: GHC only
--
-- A collection of low-level primitives for BLAKE3. This includes C bindings,
-- and a few helper functions.
module Cryptography.BLAKE3
  ( -- * Constants
    blake3VersionString,
    blake3OutLen,

    -- * Data types
    Blake3Hasher,

    -- * Functions
    blake3HasherAlloc,
    blake3HasherInit,
    blake3HasherUpdate,
    blake3HasherFinalize,
    blake3HasherFree,
  )
where

import Data.Word (Word8)
import Foreign.C.Types (CChar, CSize (CSize), CUChar)
import Foreign.Marshal.Alloc (free, mallocBytes)
import Foreign.Ptr (Ptr)

-- | Version C-string for the current BLAKE3 C binding. Currently "1.6.0".
--
-- @since 1.0
foreign import capi "blake3.h value BLAKE3_VERSION_STRING"
  blake3VersionString :: Ptr CChar

-- | The default length of the hash output from BLAKE3. Currently 32.
--
-- @since 1.0
foreign import capi "blake3.h value BLAKE3_OUT_LEN"
  blake3OutLen :: CSize

-- | The 'running state' of a hashing process, containing the hash state.
--
-- The only meaningful way to interact with this is to allocate one with
-- 'blake3HasherAlloc', initialize it with 'blake3HasherInit', use it with the
-- other functions in this module, then deallocate with 'blake3HasherFree'.
--
-- @since 1.0
data Blake3Hasher

-- | Allocate enough space for a 'Blake3Hasher'. Ensure that you call
-- 'blake3HasherInit' afterwards before you use it.
--
-- @since 1.0
blake3HasherAlloc :: IO (Ptr Blake3Hasher)
blake3HasherAlloc = mallocBytes 3660

-- | Initialize the 'Blake3Hasher' passed in the first argument. Do this before
-- you call 'blake3HasherUpdate' with it.
--
-- @since 1.0
foreign import capi "blake3.h blake3_hasher_init"
  blake3HasherInit ::
    -- | The hasher to initialize
    Ptr Blake3Hasher ->
    -- | No meaningful result
    IO ()

-- | Given a 'Blake3Hasher' and some data, update the 'Blake3Hasher' to
-- incorporate the hash of the data provided.
--
-- @since 1.0
foreign import capi "blake3.h blake3_hasher_update"
  blake3HasherUpdate ::
    -- | Initialized hasher
    Ptr Blake3Hasher ->
    -- | Pointer to data (won't be modified)
    Ptr CUChar ->
    -- | The number of bytes to hash
    CSize ->
    -- | No meaningful result
    IO ()

-- | Emits the current hash to the provided location. This does not 'use up' the
-- 'Blake3Hasher' passed to it.
--
-- = Important note
--
-- Unless you have /very/ good reasons, the size argument should be
-- 'blake3OutLen'. In particular, smaller values than this defeat much of the
-- purpose of this hashing algorithm.
--
-- @since 1.0
foreign import capi "blake3.h blake3_hasher_finalize"
  blake3HasherFinalize ::
    -- | Initialized hasher (won't be modified)
    Ptr Blake3Hasher ->
    -- | Out-parameter to write the result to
    Ptr Word8 ->
    -- | How many bytes of hash to write
    CSize ->
    -- | No meaningful result
    IO ()

-- | Deallocates a 'Blake3Hasher'.
--
-- = Important note
--
-- Do not try to pass a pointer to a deallocated 'Blake3Hasher' to any functions
-- unless you enjoy your Haskell code segfaulting.
--
-- @since 1.0
blake3HasherFree :: Ptr Blake3Hasher -> IO ()
blake3HasherFree = free
