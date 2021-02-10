import drng

# Checks if the rdseed instruction is supported by the hardware
if rdSeedIsSupported:
  # Obtaining 16 random bits
  var u16: uint16

  if rdSeed16(u16) == DrngSuccess:
    echo "16 random bits: ", u16
  
  # Obtaining 32 random bits
  var u32: uint32

  if rdSeed32(u32) == DrngSuccess:
    echo "32 random bits: ", u32
  
  # Obtaining 64 random bits
  var u64: uint64

  if rdSeed64(u64) == DrngSuccess:
    echo "64 random bits: ", u64
  
  # Obtaining N random bytes
  var nRandBytes = newSeq[uint8](u16 mod 38)

  if rdSeedGetBytes(nRandBytes) == DrngSuccess:
    echo len(nRandBytes), " random bytes: ", nRandBytes
  
  # Obtaining N random `uint16`
  var nRandu16 = newSeq[uint16](u16 mod 28)

  if rdSeedGetN16(nRandu16) == DrngSuccess:
    echo len(nRandu16), " random `uint16`: ", nRandu16
  
  # Obtaining N random `uint32`
  var nRandu32 = newSeq[uint32](u32 mod 18)

  if rdSeedGetN32(nRandu32) == DrngSuccess:
    echo len(nRandu32), " random `uint32`: ", nRandu32
  
  # Obtaining N random `uint64`
  var nRandu64 = newSeq[uint64](u64 mod 8)

  if rdSeedGetN64(nRandu64) == DrngSuccess:
    echo len(nRandu64), " random `uint64`: ", nRandu64
else:
  echo "RdSeed not supported"