# This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild

import kaitaistruct
from kaitaistruct import KaitaiStruct, KaitaiStream, BytesIO


if getattr(kaitaistruct, 'API_VERSION', (0, 9)) < (0, 9):
    raise Exception("Incompatible Kaitai Struct Python API: 0.9 or later is required, but you have %s" % (kaitaistruct.__version__))

from formats import polyglot
class Zip(KaitaiStruct):
    def __init__(self, _io, _parent=None, _root=None):
        self._io = _io
        self._parent = _parent
        self._root = _root if _root else self
        self._read()

    def _read(self):
        self.top = polyglot.Polyglot(self._io, [b"\x50", b"\x4B", b"\x03",
                                                b"\x04"])
        self.sections = []
        i = 0
        while not self._io.is_eof():
            self.sections.append(Zip.PkSection(self._io, self, self._root))
            i += 1


    class LocalFile(KaitaiStruct):
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.header = Zip.LocalFileHeader(self._io, self, self._root)
            self.body = self._io.read_bytes(self.header.len_body_compressed)


    class DataDescriptor(KaitaiStruct):
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.crc32 = self._io.read_u4le()
            self.len_body_compressed = self._io.read_u4le()
            self.len_body_uncompressed = self._io.read_u4le()


    class CentralDirEntry(KaitaiStruct):
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.version_made_by = self._io.read_u2le()
            self.version_needed_to_extract = self._io.read_u2le()
            self.flags = self._io.read_u2le()
            self.compression_method = self._io.read_u2le()
            self.file_mod_time = self._io.read_u4le()
            self.crc32 = self._io.read_u4le()
            self.len_body_compressed = self._io.read_u4le()
            self.len_body_uncompressed = self._io.read_u4le()
            self.len_file_name = self._io.read_u2le()
            self.len_extra = self._io.read_u2le()
            self.len_comment = self._io.read_u2le()
            self.disk_number_start = self._io.read_u2le()
            self.int_file_attr = self._io.read_u2le()
            self.ext_file_attr = self._io.read_u4le()
            self.ofs_local_header = self._io.read_s4le()
            self.file_name = (self._io.read_bytes(self.len_file_name)).decode(u"UTF-8")
            self.extra = self._io.read_bytes(self.len_extra)
            self.comment = self._io.read_bytes(self.len_comment)

        @property
        def local_header(self):
            if hasattr(self, '_m_local_header'):
                return self._m_local_header

            _pos = self._io.pos()
            self._io.seek(self.ofs_local_header)
            self._m_local_header = Zip.PkSection(self._io, self, self._root)
            self._io.seek(_pos)
            return getattr(self, '_m_local_header', None)


    class PkSection(KaitaiStruct):
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.magic = self._io.read_bytes(2)
            if not self.magic == b"\x50\x4B":
                raise kaitaistruct.ValidationNotEqualError(b"\x50\x4B", self.magic, self._io, u"/types/pk_section/seq/0")
            self.section_type = self._io.read_u2le()
            _on = self.section_type
            if _on == 513:
                self.body = Zip.CentralDirEntry(self._io, self, self._root)
            elif _on == 1027:
                self.body = Zip.LocalFile(self._io, self, self._root)
            elif _on == 1541:
                self.body = Zip.EndOfCentralDir(self._io, self, self._root)
            elif _on == 2055:
                self.body = Zip.DataDescriptor(self._io, self, self._root)


    class LocalFileHeader(KaitaiStruct):
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.version = self._io.read_u2le()
            self.flags = self._io.read_u2le()
            self.compression_method = self._io.read_u2le()
            self.file_mod_time = self._io.read_u4le()
            self.crc32 = self._io.read_u4le()
            self.len_body_compressed = self._io.read_u4le()
            self.len_body_uncompressed = self._io.read_u4le()
            self.len_file_name = self._io.read_u2le()
            self.len_extra = self._io.read_u2le()
            self.file_name = (self._io.read_bytes(self.len_file_name)).decode(u"UTF-8")
            self.extra = self._io.read_bytes(self.len_extra)


    class EndOfCentralDir(KaitaiStruct):
        def __init__(self, _io, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root if _root else self
            self._read()

        def _read(self):
            self.disk_of_end_of_central_dir = self._io.read_u2le()
            self.disk_of_central_dir = self._io.read_u2le()
            self.num_central_dir_entries_on_disk = self._io.read_u2le()
            self.num_central_dir_entries_total = self._io.read_u2le()
            self.len_central_dir = self._io.read_u4le()
            self.ofs_central_dir = self._io.read_u4le()
            self.len_comment = self._io.read_u2le()
            self.comment = self._io.read_bytes(self.len_comment)



