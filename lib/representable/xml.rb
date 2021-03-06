require 'representable'
require 'representable/bindings/xml_bindings'
require 'nokogiri'

module Representable
  module XML
    def self.included(base)
      base.class_eval do
        include Representable
        extend ClassMethods
        self.representation_wrap = true # let representable compute it.
      end
    end


    module ClassMethods
      def remove_namespaces!
        representable_attrs.options[:remove_namespaces] = true
      end

      # Creates a new Ruby object from XML using mapping information declared in the class.
      #
      # Accepts a block yielding the currently iterated Definition. If the block returns false
      # the property is skipped.
      #
      # Example:
      #   band.from_xml("<band><name>Nofx</name></band>")
      def from_xml(*args, &block)
        create_represented(*args, &block).from_xml(*args)
      end

      def from_node(*args, &block)
        create_represented(*args, &block).from_node(*args)
      end

    private
      def representer_engine
        Representable::XML
      end
    end

    def from_xml(doc, *args)
      node = parse_xml(doc, *args)

      from_node(node, *args)
    end

    def from_node(node, options={})
      update_properties_from(node, options, PropertyBinding)
    end

    # Returns a Nokogiri::XML object representing this object.
    def to_node(options={})
      root_tag = options[:wrap] || representation_wrap

      create_representation_with(Nokogiri::XML::Node.new(root_tag.to_s, Nokogiri::XML::Document.new), options, PropertyBinding)
    end

    def to_xml(*args)
      to_node(*args).to_s
    end

  private
    def remove_namespaces?
      # TODO: make local Config easily extendable so you get Config#remove_ns? etc.
      representable_attrs.options[:remove_namespaces]
    end

    def parse_xml(doc, *args)
      node = Nokogiri::XML(doc)

      node.remove_namespaces! if remove_namespaces?
      node.root
    end
  end
end
