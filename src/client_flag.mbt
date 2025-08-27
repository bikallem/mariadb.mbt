///|
/// see mariadb_com.h
struct ClientFlag(UInt64)

///|
pub let client_found_rows : ClientFlag = ClientFlag(2)

///|
pub let client_no_schema : ClientFlag = ClientFlag(16)

///|
pub let client_compress : ClientFlag = ClientFlag(32)

///|
pub let client_ignore_space : ClientFlag = ClientFlag(256)

///|
pub let client_local_files : ClientFlag = ClientFlag(128)

///|
pub let client_multi_statements : ClientFlag = ClientFlag(1 << 16)

///|
pub let client_multi_results : ClientFlag = ClientFlag(1 << 17)

///|
pub impl BitOr for ClientFlag with lor(self : ClientFlag, other : ClientFlag) -> ClientFlag {
  ClientFlag(self.0 | other.0)
}
