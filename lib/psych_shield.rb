#
# PsychShield provides a filter around the Psych class
# that can prevent exploitation of YAML.load calls.
#

require 'yaml'

unless YAML.name == "Psych"
	raise RuntimeError, "psych-shield only works with the Psych parser"
end

class PsychShield

	# Generally regarded as safe for YAML loads
	@@allowed_objects = %W{
		Hash Array String Range
		Numeric Fixnum Integer Bignum Float Rational Complex
		Time DateTime
		NilClass TrueClass FalseClass
	}

	@@callback = nil

	def self.add(name)
		@@allowed_objects << name
	end

	def self.remove(name)
		@@allowed_objects.delete(name)
	end

	def self.clear
		@@allowed_objects = []
	end

	def self.allowed?(o)
		res = @@allowed_objects.include?(o.to_s)
		@@callback.call(o.to_s, res) if @@callback
		res
	end

	def self.callback=(cb)
		@@callback = cb
	end

	class DeniedObject < Hash
	end

end

module Psych
module Visitors
class ToRuby

	alias_method :shielded_resolve_class, :resolve_class
	def resolve_class klass
		return unless PsychShield.allowed?(klass)
		shielded_resolve_class(klass)
	end

end
end
end
