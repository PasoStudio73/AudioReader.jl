# ---------------------------------------------------------------------------- #
#                                lossy types                                   #
# ---------------------------------------------------------------------------- #
# mpg123 encodings
const MPG123_ENC_8           = 0x00f                                            # 0000 0000 0000 1111 Some 8 bit  integer encoding.
const MPG123_ENC_16          = 0x040                                            # 0000 0000 0100 0000 Some 16 bit integer encoding.
const MPG123_ENC_24          = 0x4000                                           # 0100 0000 0000 0000 Some 24 bit integer encoding.
const MPG123_ENC_32          = 0x100                                            # 0000 0001 0000 0000 Some 32 bit integer encoding.
const MPG123_ENC_SIGNED      = 0x080                                            # 0000 0000 1000 0000 Some signed integer encoding.
const MPG123_ENC_FLOAT       = 0xe00                                            # 0000 1110 0000 0000 Some float encoding.
const MPG123_ENC_SIGNED_16   = MPG123_ENC_16 | MPG123_ENC_SIGNED | 0x10         # 0000 0000 1101 0000 signed 16 bit
const MPG123_ENC_UNSIGNED_16 = MPG123_ENC_16 | 0x20                             # 0000 0000 0110 0000 unsigned 16 bit
const MPG123_ENC_UNSIGNED_8  = 0x01                                             # 0000 0000 0000 0001 unsigned 8 bit
const MPG123_ENC_SIGNED_8    = MPG123_ENC_SIGNED | 0x02                         # 0000 0000 1000 0010 signed 8 bit
const MPG123_ENC_ULAW_8      = 0x04                                             # 0000 0000 0000 0100 ulaw 8 bit
const MPG123_ENC_ALAW_8      = 0x08                                             # 0000 0000 0000 0100 alaw 8 bit
const MPG123_ENC_SIGNED_32   = MPG123_ENC_32 | MPG123_ENC_SIGNED | 0x1000       # 0001 0001 1000 0000 signed 32 bit
const MPG123_ENC_UNSIGNED_32 = MPG123_ENC_32 | 0x2000                           # 0010 0001 0000 0000 unsigned 32 bit
const MPG123_ENC_SIGNED_24   = MPG123_ENC_24 | MPG123_ENC_SIGNED | 0x1000       # 0101 0000 1000 0000 signed 24 bit
const MPG123_ENC_UNSIGNED_24 = MPG123_ENC_24 | 0x2000                           # 0110 0000 0000 0000 unsigned 24 bit
const MPG123_ENC_FLOAT_32    = 0x200                                            # 0000 0010 0000 0000 32bit float
const MPG123_ENC_FLOAT_64    = 0x400                                            # 0000 0100 0000 0000 64bit float

# any possibly known encoding from the list above.
const MPG123_ENC_ANY = ( MPG123_ENC_SIGNED_16  | MPG123_ENC_UNSIGNED_16
	                   | MPG123_ENC_UNSIGNED_8 | MPG123_ENC_SIGNED_8
	                   | MPG123_ENC_ULAW_8     | MPG123_ENC_ALAW_8
	                   | MPG123_ENC_SIGNED_32  | MPG123_ENC_UNSIGNED_32
	                   | MPG123_ENC_SIGNED_24  | MPG123_ENC_UNSIGNED_24
	                   | MPG123_ENC_FLOAT_32   | MPG123_ENC_FLOAT_64    )

"""represents the C pointer mpg123_handle*. used by all mpg123 functions"""
const MPG123 = Ptr{Nothing}

const MPG123_DONE       = -12
const MPG123_NEW_FORMAT = -11
const MPG123_NEED_MORE  = -10
const MPG123_ERR        = -1
const MPG123_OK         = 0