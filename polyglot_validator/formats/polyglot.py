"""Custom polyglot opaque type for Kaitai Struct."""

import kaitaistruct


from collections import deque
from kaitaistruct import KaitaiStruct, KaitaiStream, BytesIO, SEEK_CUR


class Polyglot(KaitaiStruct):
    def __init__(self, _io, magic, _parent=None, _root=None):
        self._io = _io
        self._parent = _parent
        self._root = _root if _root else self
        self.magic = magic
        self._read()

    def _read(self):
        found = False
        self.data = []

        magic_bytes = deque(self.magic)

        current_bytes = deque()

        for i in range(len(magic_bytes)):
            current_bytes.append(self.read_byte())

        while not found:
            if current_bytes == magic_bytes:
                self._io._io.seek(-len(magic_bytes), SEEK_CUR)
                found = True

            else:
                self.data.append(current_bytes.popleft())
                current_bytes.append(self.read_byte())

    def read_byte(self):
        byte = self._io.read_bytes(1)
        
        if type(byte) == bytes:
            return byte
        else:
            return byte.to_byte(1, "big")
