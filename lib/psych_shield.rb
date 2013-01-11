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
		res = @@allowed_objects.include?(o.class.to_s)
		@@callback.call(o.class.to_s, res) if @@callback
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

	alias_method :shielded_revive_hash, :revive_hash
	def revive_hash hash, o
		unless PsychShield.allowed?(hash)
			return PsychShield::DeniedObject.new
		end
		shielded_revive_hash(hash,o)
	end

	alias_method :shielded_init_with, :init_with
	def init_with o, h, node
		unless PsychShield.allowed?(o)
			return PsychShield::DeniedObject.new
		end
		shielded_init_with(o,h,node)
	end

end
end
end
