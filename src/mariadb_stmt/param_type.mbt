///| MySQL data types encoded by the parameter.
pub(all) enum ParamType {
  Int // 32Bit, Corresponds to Moonbit Int/Bool
  UInt // 32Bit, Corresponds to Moonbit UInt
  Int64 // 64Bit, Corresponds to Moonbit Int64/UInt64
  UInt64 // 64Bit, Corresponds to Moonbit UInt64
  Float // 32Bit, Corresponds to Moonbit Float
  Double // 64Bit, Corresponds to Moonbit Double
  String(UInt) // UInt: Max length for STRING
  Blob(UInt) // UInt: Max length for BLOB
  Bool // 32Bit, Corresponds to Moonbit Bool
}
