class Hexpress
  extend Forwardable
  def_delegators :to_regexp, :=~, :===, :==, :match

  CHARACTERS = [:word, :digit, :space]
  attr_reader :hexen

  def initialize(*hexen, &block)
    @hexen = hexen
    instance_exec(&block) if block_given?
  end

  # Matches \w
  def word
    add(Character.new(:word))
  end

  # Matches \d
  def digit
    add(Character.new(:digit))
  end

  # Matches \s
  def space
    add(Character.new(:space))
  end

  # Matches .
  def any
    add(Character.new(:any))
  end

  # Matches (?:.)*
  def anything
    many(Character.new(:any), 0)
  end

  # Matches (?:.)+
  def something
    many(Character.new(:any), 1)
  end

  # Matches \t
  def tab
    add(Character.new(:tab))
  end

  # Matches (?:(?:\n)|(?:\r\n))
  def line
    either(Character.new('(?:\n)'), Character.new('(?:\r\n)'))
  end

  CHARACTERS.each do |character|
    define_method(character) do
      add(Character.new(character))
    end

    define_method("non#{character}") do
      add(Character.new(character, true))
    end

    define_method("#{character}s") do
      many(Character.new(character))
    end

    define_method("non#{character}s") do
      many(Character.new(character, true))
    end
  end

  # This method returns the regular hexpression form of this object.
  def to_regexp
    Regexp.new(to_s)
  end
  alias_method :to_r, :to_regexp

  # This method returns the string version of the regexp.
  def to_s
    @expressions.map(&:to_s).join
  end

  # Takes an expression and returns the combination of the two expressions
  # in a new Hexpress object.
  def +(expression)
    Hexpress.new(*expressions + expression.expressions)
  end

  private

  # This method takes an hex and adds it to the hexen queue
  # while returning the main object.
  def add(hex)
    tap { @expressions << hex }
  end

  def add_value(hex, value, &block)
    add(hex.new(block_given? ? Hexpress.new.instance_exec(&block) : value))
  end

  def add_nested(hex, &block)
    add(hex.new(&block))
  end
end

require_relative "hexpress/character"
require_relative "hexpress/version"
require_relative "hexpress/value"
require_relative "hexpress/suffix"
require_relative "hexpress/prefix"
require_relative "hexpress/wrapped"
require_relative "hexpress/noncapture"
require_relative "hexpress/many"

if defined?(Rails)
  require_relative "hexpress/main"
end
