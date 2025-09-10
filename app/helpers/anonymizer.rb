module Anonymizer
  ADJECTIVES = [
    'Agile', 'Bright', 'Clever', 'Creative', 'Curious', 'Eager', 'Focused',
    'Honest', 'Insightful', 'Kind', 'Quiet', 'Swift', 'Vivid', 'Wise'
  ].freeze

  NOUNS = [
    'Alpaca', 'Badger', 'Cheetah', 'Dolphin', 'Eagle', 'Falcon', 'Gecko',
    'Heron', 'Ibex', 'Jellyfish', 'Koala', 'Llama', 'Meerkat', 'Narwhal'
  ].freeze

  def self.generate_name
    "#{ADJECTIVES.sample} #{NOUNS.sample}"
  end
end