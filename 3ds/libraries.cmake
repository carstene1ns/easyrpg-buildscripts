
set(ICU_VER 59.2)
string(REPLACE "." "-" _ICU_VER ${ICU_VER})
set(ICU_URL https://github.com/unicode-org/icu/releases/download/release-${_ICU_VER}/icu4c-${_ICU_VER}-src.tgz)
set(ICU_PATCHES_3DS icu59-3ds.patch)
