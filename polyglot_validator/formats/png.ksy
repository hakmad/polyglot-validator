meta:
  id: png
  title: PNG image file 
  endian: be
seq:
  - id: magic
    contents: [137, 80, 78, 71, 13, 10, 26, 10]
  - id: ihdr_len
    type: u4
    valid: 13
  - id: ihdr_type
    contents: "IHDR"
  - id: ihdr
    type: ihdr_chunk
  - id: ihdr_crc
    size: 4
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.type == "IEND" or _io.eof
types:
  chunk:
    seq:
      - id: len
        type: u4
      - id: type
        type: str
        size: 4
        encoding: UTF-8
      - id: body
        size: len
        type:
          switch-on: type
          cases:
            '"PLTE"': plte_chunk

            '"cHRM"': chrm_chunk
            '"gAMA"': gama_chunk
            '"sRGB"': srgb_chunk
            '"bKGD"': bkgd_chunk
            '"pHYs"': phys_chunk
            '"tIME"': time_chunk
            '"iTXt"': international_text_chunk
            '"tEXt"': text_chunk
            '"zTXt"': compressed_text_chunk

            '"acTL"': animation_control_chunk
            '"fcTL"': frame_control_chunk
            '"fdAT"': frame_data_chunk
      - id: crc
        size: 4
  ihdr_chunk:
    seq:
      - id: width
        type: u4
      - id: height
        type: u4
      - id: bit_depth
        type: u1
      - id: color_type
        type: u1
        enum: color_type
      - id: compression_method
        type: u1
      - id: filter_method
        type: u1
      - id: interlace_method
        type: u1
  plte_chunk:
    seq:
      - id: entries
        type: rgb
        repeat: eos
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
  chrm_chunk:
    seq:
      - id: white_point
        type: point
      - id: red
        type: point
      - id: green
        type: point
      - id: blue
        type: point
  point:
    seq:
      - id: x_int
        type: u4
      - id: y_int
        type: u4
    instances:
      x:
        value: x_int / 100000.0
      y:
        value: y_int / 100000.0
  gama_chunk:
    seq:
      - id: gamma_int
        type: u4
    instances:
      gamma_ratio:
        value: 100000.0 / gamma_int
  srgb_chunk:
    seq:
      - id: render_intent
        type: u1
        enum: intent
    enums:
      intent:
        0: perceptual
        1: relative_colorimetric
        2: saturation
        3: absolute_colorimetric
  bkgd_chunk:
    seq:
      - id: bkgd
        type:
          switch-on: _root.ihdr.color_type
          cases:
            color_type::greyscale: bkgd_greyscale
            color_type::greyscale_alpha: bkgd_greyscale
            color_type::truecolor: bkgd_truecolor
            color_type::truecolor_alpha: bkgd_truecolor
            color_type::indexed: bkgd_indexed
  bkgd_greyscale:
    seq:
      - id: value
        type: u2
  bkgd_truecolor:
    seq:
      - id: red
        type: u2
      - id: green
        type: u2
      - id: blue
        type: u2
  bkgd_indexed:
    seq:
      - id: palette_index
        type: u1
  phys_chunk:
    seq:
      - id: pixels_per_unit_x
        type: u4
        doc: |
          Number of pixels per physical unit (typically, 1 meter) by X
          axis.
      - id: pixels_per_unit_y
        type: u4
        doc: |
          Number of pixels per physical unit (typically, 1 meter) by Y
          axis.
      - id: unit
        type: u1
        enum: phys_unit
  time_chunk:
    doc-ref: https://www.w3.org/TR/png/#11tIME
    seq:
      - id: year
        type: u2
      - id: month
        type: u1
      - id: day
        type: u1
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
  international_text_chunk:
    seq:
      - id: keyword
        type: strz
        encoding: UTF-8
        doc: Indicates purpose of the following text data.
      - id: compression_flag
        type: u1
      - id: compression_method
        type: u1
        enum: compression_methods
      - id: language_tag
        type: strz
        encoding: ASCII
      - id: translated_keyword
        type: strz
        encoding: UTF-8
      - id: text
        type: str
        encoding: UTF-8
        size-eos: true
  text_chunk:
    seq:
      - id: keyword
        type: strz
        encoding: iso8859-1
        doc: Indicates purpose of the following text data.
      - id: text
        type: str
        size-eos: true
        encoding: iso8859-1
  compressed_text_chunk:
    seq:
      - id: keyword
        type: strz
        encoding: UTF-8
        doc: Indicates purpose of the following text data.
      - id: compression_method
        type: u1
        enum: compression_methods
      - id: text_datastream
        process: zlib
        size-eos: true
  animation_control_chunk:
    seq:
      - id: num_frames
        type: u4
      - id: num_plays
        type: u4
  frame_control_chunk:
    seq:
      - id: sequence_number
        type: u4
        doc: Sequence number of the animation chunk
      - id: width
        type: u4
        valid:
          min: 1
          max: _root.ihdr.width
      - id: height
        type: u4
        valid:
          min: 1
          max: _root.ihdr.height
      - id: x_offset
        type: u4
        valid:
          max: _root.ihdr.width - width
      - id: y_offset
        type: u4
        valid:
          max: _root.ihdr.height - height
      - id: delay_num
        type: u2
      - id: delay_den
        type: u2
      - id: dispose_op
        type: u1
        enum: dispose_op_values
      - id: blend_op
        type: u1
        enum: blend_op_values
    instances:
      delay:
        value: 'delay_num / (delay_den == 0 ? 100.0 : delay_den)'
  frame_data_chunk:
    seq:
      - id: sequence_number
        type: u4
      - id: frame_data
        size-eos: true
enums:
  color_type:
    0: greyscale
    2: truecolor
    3: indexed
    4: greyscale_alpha
    6: truecolor_alpha
  phys_unit:
    0: unknown
    1: meter
  compression_methods:
    0: zlib
  dispose_op_values:
    0:
      id: none
    1:
      id: background
    2:
      id: previous
  blend_op_values:
    0:
      id: source
    1:
      id: over
