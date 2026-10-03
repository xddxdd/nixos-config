# fastpit corpus — Cap'n Proto schema.
#
# This is the storage format of data/corpus.bin. It is a standard Cap'n Proto
# message (segment table + segments), read zero-copy from an mmap or from the
# bytes embedded in the server.
#
# The message carries only what generation needs: words, tags, pools, the POS
# sentence templates and the generation parameters. It deliberately stores no
# HTML/page template — that is an asset, loaded from the asset directory.
#
# It is functionally self-contained: the server hardcodes no tag name or
# numeric range, so a different conforming file changes the generated site
# with no recompilation. Adding fields is backwards compatible; a reader
# ignores fields it does not know.

@0xd8a1b2c3d4e5f607;

struct Corpus {
  # b"FASTPIT\0" little-endian == 0x0054495054534146.
  magic        @0  :UInt64;
  version      @1  :UInt32;   # format version, currently 4

  # --- words: one UTF-8 blob plus a UInt32 offset table ----------------
  # word i is wordBlob[wordOffsets[i] .. wordOffsets[i+1]]. The word count is
  # wordOffsets.len() - 1.
  wordBlob     @2  :Data;
  wordOffsets  @3  :List(UInt32);  # wordCount + 1, monotonic
  universeLen  @4  :UInt32;        # words [0, universeLen) are the universe, sorted

  # --- tags ------------------------------------------------------------
  tagStrings   @5  :List(UInt32);  # tagCount word ids, one tag name each

  # --- pools, indexed by tag id ---------------------------------------
  # A tag's content pool is contentItems[contentOff[i] .. contentOff[i+1]];
  # likewise for functionOff. Zero-length pools are equal consecutive offsets.
  contentOff   @6  :List(UInt32);  # tagCount + 1
  functionOff  @7  :List(UInt32);  # tagCount + 1
  punctString  @8  :List(UInt32);  # tagCount; word id, or 0xFFFFFFFF for "none"
  contentItems @9  :List(UInt32);  # word ids
  functionItems@10 :List(UInt32);  # word ids

  # --- templates -------------------------------------------------------
  templateOff  @11 :List(UInt32);  # templateCount + 1
  templateTags @12 :List(UInt16);  # tag ids

  # --- generation parameters ------------------------------------------
  numberTag    @13 :UInt32;   # tag id for the numeric slot, or 0xFFFFFFFF
  numberMin    @14 :Int64;
  numberMax    @15 :Int64;
  flags        @16 :UInt32;   # bit0 a/an fix, bit1 capitalize first letter
  attach       @17 :List(UInt8);  # tagCount; 0 space, 1 left, 2 right, 3 both
}
