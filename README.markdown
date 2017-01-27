XMapper
=======

XMapper is a Ruby gem that maps XML to objects and objects to XML using Nokogiri, using a very nice block-syntax to define XML hierarchies.

# Installation

    gem install xmapper

# Usage

First, require the gem:

    require 'xmapper'

Then you declare your mapping class. Here's an example using RSS. In this example you can see how blocks are used to define hierarchy, using the `many` and `child` methods.

    class RSS
      include XMapper

      root :rss
      child :channel do
        text :title
        text :author
        many :item do
          text :title
          text :link
          text :description
        end
      end
    end

You can generate XMLs using a struct-like syntax:

    rss = RSS.new(:channel => { :title => 'My blog', :author => 'John', :item => [ { :title => 'First Post', :description => 'This is the first post' } ] })
    puts rss.to_xml

    <?xml version="1.0" encoding="UTF-8"?>
    <rss>
      <channel>
        <title>My blog</title>
        <author>John</author>
        <item>
          <title>First Post</title>
          <description>This is the first post</description>
        </item>
      </channel>
    </rss>

And you also can parse existing XML:

    parsed_rss = RSS.parse('<rss><channel><title>My Blog</title></channel></rss>')
    parsed_rss.channel.title
    => 'My Blog'

Items declared with 'many' are accessed trough an array:

    parsed_rss = RSS.parse('<rss><channel><title>My Blog</title><item><title>First Post</title></item></channel></rss>')
    parsed_rss.item.first.title
    => "First post"

There's also support for namespaces, ISO dates (with the datetime declaration), attributes (they're referent to the parent block) and "body", which is useful when tags can have both attributes and textual content. They're accessed normally:

    class Atom
      include XMapper

      root :feed
      namespaces 'xmlns' => 'http://www.w3.org/2005/Atom',
                 'xmlns:activity' => 'http://activitystrea.ms/spec/1.0/'

      text :id
      datetime :updated

      child :title do
        attribute :type, :default => 'text'
        body :value
      end
    end

The xhash declaration is useful when you want to refer 

    class Atom
      include XMapper

      root :feed

      ...

      xhash :link, :key => :rel do
        attribute :rel
        attribute :type
        attribute :hreflang
        attribute :href
      end
    end

Here's how you instantiate it:

    atom = Atom.new(:link => { 'self' => { :href => 'http://example.com/atom' } })

And here's how you access it:

    atom_two = Atom.parse(atom.xml)
    atom_two.link['self'].href
    => 'http://example.com/atom'