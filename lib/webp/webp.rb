require "webp/options"
require "webp/c"

module WebP
  class << self
    
    def decoder_version
      pointer = FFI::MemoryPointer.new(:char, 10)
      C.decoder_version(pointer)
      pointer.null? ? nil : pointer.read_string()
    end
    
    def encoder_version
      pointer = FFI::MemoryPointer.new(:char, 10)
      C.encoder_version(pointer)
      pointer.null? ? nil : pointer.read_string()
    end
    
    # get webp image size
    def webp_size(data)
      return nil if data.nil?
      pointers = get_pointers_for_webp_size(data)
      if 0 == C.webp_get_info(pointers[:data], pointers[:data_size], pointers[:width], pointers[:height])
        [(pointers[:width].null? ? nil : pointers[:width].read_int), (pointers[:height].null? ? nil : pointers[:height].read_int)]
      else
        raise InvalidImageFormatError, "invalid WebP image data"
      end
    end
    
    # encode
    def encode(input_file, output_file, options = {})
      unless 0 == (encode_res = C.webp_encode(input_file, output_file, init_options_object(options).encode_pointer))
        raise EncoderError, ENCODER_ERRORS[encode_res - 1]
      end
      true
    end
    
    # decode
    def decode(input_file, output_file, options = {})
      unless 0 == (decode_res = C.webp_decode(input_file, output_file, init_options_object(options).decode_pointer))
        raise DecoderError, DECODER_ERRORS[decode_res - 1]
      end
      true
    end
    
    private
    
    def get_pointers_for_webp_size(data)
      pointers = Hash.new
      pointers[:data_size] = data.respond_to?(:bytesize) ? data.bytesize : data.size
      pointers[:width], pointers[:height] = FFI::MemoryPointer.new(:int, 2), FFI::MemoryPointer.new(:int, 2)
      pointers[:data] = FFI::MemoryPointer.new(:char, pointers[:data_size]).put_bytes(0, data)
      pointers
    end
    
    def init_options_object(options)
      Options.new options
    end
    
  end
end