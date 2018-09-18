# Class that fetches tail of a file
class PuppetX::Coi::Jboss::Tail
  BUFFER_S = 512

  # Constructor
  # @param file [File] a file to get tail from
  def initialize(file)
    @file = file
  end

  # Returns exactly n last lines of File
  #
  # @param n [Integer] number of last lines to read
  # @return [Array] collected lines as array
  def get(n)
    @file.seek(0, IO::SEEK_END)
    offset = calc_offset(n)
    @file.seek(offset)
    @file.read
  end

  private

  def calc_offset(n)
    state = State.new(@file, n)

    while state.notfound?
      to_read = calc_to_read(state.offset)
      @file.seek(state.offset - to_read)
      data = @file.read(to_read)
      search(state, data)
    end
    state.offset
  end

  def search(state, data)
    data.reverse.each_char do |c|
      if state.line_count > state.n
        state.offset += 1
        break
      end
      state.offset -= 1
      state.line_count += 1 if c == "\n"
    end
  end

  def calc_to_read(offset)
    if (offset - BUFFER_S) < 0
      offset
    else
      BUFFER_S
    end
  end

  # A state of a tail
  class State
    attr_reader :line_count, :offset, :n
    attr_writer :line_count, :offset

    def initialize(file, n)
      @line_count = 0
      @offset = file.pos # we start at the end
      @n = n
    end

    def notfound?
      @line_count <= @n && @offset > 0
    end
  end
end
