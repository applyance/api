module Applyance
  module Lib
    module Strings

      # Returns a slug
      def to_slug(str, delim = '-')
        value = str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s
        value.gsub!(/[']+/, '')
        value.gsub!(/\W+/, ' ')
        value.strip!
        value.downcase!
        value.gsub!(' ', delim)
        value
      end

    end
  end
end
