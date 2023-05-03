meta:
  id: jpeg
  title: JPEG image file
  imports:
    - exif
  endian: be
seq:
  - id: segments
    type: segment
    repeat: eos
types:
  segment:
    seq:
      - id: magic
        contents: [0xff]
      - id: marker
        type: u1
        enum: marker_enum
      - id: length
        type: u2
        if: marker != marker_enum::soi and marker != marker_enum::eoi
      - id: data
        size: length - 2
        if: marker != marker_enum::soi and marker != marker_enum::eoi
        type:
          switch-on: marker
          cases:
            'marker_enum::app0': segment_app0
            'marker_enum::app1': segment_app1
            'marker_enum::sof0': segment_sof0
            'marker_enum::sos': segment_sos
      - id: image_data
        size-eos: true
        if: marker == marker_enum::sos
    enums:
      marker_enum:
        0x01: tem
        0xc0: sof0
        0xc1: sof1
        0xc2: sof2
        0xc3: sof3
        0xc4: dht
        0xc5: sof5
        0xc6: sof6
        0xc7: sof7
        0xd8: soi
        0xd9: eoi
        0xda: sos
        0xdb: dqt
        0xdc: dnl
        0xdd: dri
        0xde: dhp
        0xe0: app0
        0xe1: app1
        0xe2: app2
        0xe3: app3
        0xe4: app4
        0xe5: app5
        0xe6: app6
        0xe7: app7
        0xe8: app8
        0xe9: app9
        0xea: app10
        0xeb: app11
        0xec: app12
        0xed: app13
        0xee: app14
        0xef: app15
        0xfe: com
  segment_app0:
    seq:
      - id: magic
        type: str
        encoding: ASCII
        size: 5
      - id: version_major
        type: u1
      - id: version_minor
        type: u1
      - id: density_units
        type: u1
        enum: density_unit
      - id: density_x
        type: u2
      - id: density_y
        type: u2
      - id: thumbnail_x
        type: u1
      - id: thumbnail_y
        type: u1
      - id: thumbnail
        size: thumbnail_x * thumbnail_y * 3
    enums:
      density_unit:
        0: no_units
        1: pixels_per_inch
        2: pixels_per_cm
  segment_app1:
    seq:
      - id: magic
        type: strz
        encoding: ASCII
      - id: body
        type:
          switch-on: magic
          cases:
            '"Exif"': exif_in_jpeg
  segment_sof0:
    seq:
      - id: bits_per_sample
        type: u1
      - id: image_height
        type: u2
      - id: image_width
        type: u2
      - id: num_components
        type: u1
      - id: components
        type: component
        repeat: expr
        repeat-expr: num_components
    types:
      component:
        seq:
          - id: id
            type: u1
            enum: component_id
            doc: Component selector
          - id: sampling_factors
            type: u1
          - id: quantization_table_id
            type: u1
        instances:
          sampling_x:
            value: (sampling_factors & 0xf0) >> 4
          sampling_y:
            value: sampling_factors & 0xf
  segment_sos:
    seq:
      - id: num_components
        type: u1
      - id: components
        type: component
        repeat: expr
        repeat-expr: num_components
      - id: start_spectral_selection
        type: u1
      - id: end_spectral
        type: u1
      - id: appr_bit_pos
        type: u1
    types:
      component:
        seq:
          - id: id
            type: u1
            enum: component_id
          - id: huffman_table
            type: u1
  exif_in_jpeg:
    seq:
      - id: extra_zero
        contents: [0]
      - id: data
        size-eos: true
        type: exif
enums:
  component_id:
    1: y
    2: cb
    3: cr
    4: i
    5: q
