module Applyance
  module Lib
    module Strings
      def to_slug(str)
        value = str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s
        value.gsub!(/[']+/, '')
        value.gsub!(/\W+/, ' ')
        value.strip!
        value.downcase!
        value.gsub!(' ', '-')
        value
      end
    end
  end
end
