require 'nokogiri'
require 'time'

module XMapper
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Initialize class variables
    base.instance_variable_set("@root", base.to_s)
    base.instance_variable_set("@namespaces", {})
    base.instance_variable_set("@children_list", [])
  end

  module ClassMethods
    attr_reader :children_list

    # Define the root document name for the class
    def root(root)
      @root = root
    end

    # Define the XMLNS for building and parsing documents.
    def namespaces(namespaces)
      @namespaces = namespaces
    end

    # Define an attribute to be embedded on the root tag.
    def attribute(name, opts = {})
      attr_accessor name
      @children_list << { :name => name, :type => :attr }.merge(opts)
    end

    # Define a textual content body for the tag.
    def body(name, opts = {})
      attr_accessor name
      @children_list << { :name => name, :type => :body }.merge(opts)
    end

    # Define a new textual property.
    def text(name, opts = {})
      attr_accessor name
      @children_list << { :name => name, :type => :text }.merge(opts)
    end

    # Define a new date property.
    def datetime(name, opts = {})
      attr_accessor name
      @children_list << { :name => name, :type => :datetime }.merge(opts)
    end

    # Define a new children with its own hierarchy inside a block.
    def child(name, opts = {}, &block)
      attr_accessor name
      model = build_class(name, @namespaces, self, opts[:path], &block) if block_given?
      @children_list << { :name => name, :model => model }.merge(opts)
    end

    # Define a new property for a model that will appear many times.
    def many(name, opts = {}, &block)
      attr_accessor name
      model = build_class(name, @namespaces, self, opts[:path], &block) if block_given?
      @children_list << { :name => name, :type => :list, :model => model, :default => [] }.merge(opts)
    end

    def xhash(name, opts = {}, &block)
      attr_accessor name
      model = build_class(name, @namespaces, self, opts[:path], &block) if block_given?
      @children_list << { :name => name, :type => :hash, :model => model, :default => {} }.merge(opts)
    end

    # Parse a XML document or a Nokogiri XML document
    def parse(document)
      if document.is_a? String
        document = Nokogiri::XML::Document.parse(document)
        document.remove_namespaces! unless @namespaces.length > 0
        document = document.xpath("#{ 'xmlns:' if @namespaces.include? 'xmlns' and !@root.to_s.include? ':' }#{ @root }", @namespaces)
      end

      object = self.new
      @children_list.each do |tag|
        path = tag[:path] || "#{'@' if tag[:type] == :attr }#{ 'xmlns:' if @namespaces.include? 'xmlns' and tag[:type] != :attr and tag[:type] != :body }#{ tag[:type] == :body ? 'text()' : tag[:name] }"
        nodes = document.xpath(path, @namespaces)
        value = nodes.map { |node| process_one(tag, node) }
        value = Hash[value] if tag[:type] == :hash
        value = value.first unless tag[:type] == :list or tag[:type] == :hash
        object.instance_variable_set("@#{tag[:name]}".to_sym, value)
      end
      object
    end

    private

    def process_one(tag, node)
      value = tag[:model] ? tag[:model].parse(node) : node.text

      if tag[:type] == :hash
        [ value.instance_variable_get("@#{tag[:key]}"), value ]
      elsif tag[:type] == :datetime
        Time.parse(value)
      elsif tag[:encoding] == :base64
        value.tr("-_", "+/").unpack("m0").first
      else
        value
      end
    end

    # Create a new XMapper class.
    def build_class(name, namespaces = {}, parent = Object, path = nil, &block)
      model = parent.const_set(name.to_s.capitalize, Class.new)
      model.send(:include, XMapper)
      model.instance_variable_set("@namespaces", namespaces)
      model.instance_variable_set("@root", "#{path || name}")
      model.class_eval(&block)
      model
    end
  end

  module InstanceMethods
    # Instantiate a XML model, using hash parameters as values
    def initialize(values = {})
      self.class.children_list.each do |tag|
        v = values[tag[:name]]
        v = tag[:model].new(v) if tag[:model] and tag[:type] != :list and tag[:type] != :hash and v
        v = Hash[v.map { |k,w| [k, tag[:model].new({ tag[:key] => k }.merge(w))] }] if tag[:model] and tag[:type] == :hash and v
        v = [v].flatten.map { |w| tag[:model].new(w) } if tag[:model] and tag[:type] == :list and v
        instance_variable_set("@#{tag[:name]}".to_sym, v || tag[:default])
      end
    end

    # Render the current document to XML.
    def to_xml
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| build_root(xml) }.to_xml
    end

    protected

    # Build the current tag
    def build_root(xml)
      root = self.class.instance_variable_get("@root").to_s.gsub('xmlns:', '')
      ns = self.class.instance_variable_get("@namespaces")

      xml.send(root, ns, build_attributes) { build_children(xml) }
    end

    private

    # Build the children recursively
    def build_children(xml)
      self.class.children_list.each do |tag|
        value = instance_variable_get("@#{tag[:name]}".to_sym)

        next if value.nil? or (value.is_a? String and value.empty?)

        tagname = (tag[:path] || tag[:name].to_s).gsub('xmlns:', '')
        tagname = :'id_' if tagname.to_s == "id"
        value = [value].pack("m0").tr("+/", "-_").gsub("\n", "") if tag[:encoding] == :base64

        case tag[:type]
          when :hash then value.each { |k,v| v.instance_variable_set("@#{tag[:key]}", k); v.build_root(xml) }
          when :list then value.each { |val| val.build_root(xml) }
          when :body then xml << value
          when :attr then nil
          when :datetime then xml.send(tagname, value.iso8601)
          else tag[:model] ? value.build_root(xml) : xml.send(tagname, value)
        end
      end
    end

    # Build the attributes of this tag
    def build_attributes
      attributes = self.class.children_list.select{ |child| child[:type] == :attr }
      Hash[ attributes.map { |attribute| [ (attribute[:path] || attribute[:name]).to_s.gsub('@', ''), instance_variable_get("@#{attribute[:name]}".to_sym) || attribute[:default] ] }.select{ |attribute| attribute.last } ]
    end
  end
end
