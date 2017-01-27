require 'rubygems'

require File.dirname(__FILE__) + '/../lib/xmapper'

class Atom
  include XMapper

  root :feed
  namespaces 'xmlns' => 'http://www.w3.org/2005/Atom',
             'xmlns:thr' => 'http://purl.org/syndication/thread/1.0',
             'xmlns:activity' => 'http://activitystrea.ms/spec/1.0/',
             'xmlns:georss' => 'http://www.georss.org/georss',
             'xmlns:media' => 'http://search.yahoo.com/mrss/',
             'xmlns:poco' => 'http://portablecontacts.net/spec/1.0'
 
  text :id
  child :title do
    attribute :type, :default => 'text'
    body :value
  end
  child :subtitle do
    attribute :type, :default => 'text'
    body :value
  end
  child :generator do
    attribute :uri
    attribute :version
    body :value
  end
  text :icon
  text :logo
  text :rights
  many :category do
    attribute :term
    attribute :label
    attribute :scheme
  end
  datetime :updated
  xhash :link, :key => :rel do
    attribute :rel
    attribute :type
    attribute :hreflang
    attribute :href
  end

  child :author do
    text :name
    text :uri
    text :email
    text :object_type, :path => 'activity:object-type', :default => 'person'
    text :poco_id, :path => 'poco:id'
    text :poco_display_name, :path => 'poco:displayName'
    text :poco_name, :path => 'poco:name'
    text :poco_nickname, :path => 'poco:nickname'
    text :poco_published, :path => 'poco:published'
    text :poco_updated, :path => 'poco:updated'
    text :poco_birthday, :path => 'poco:birthday'
    text :poco_anniversary, :path => 'poco:anniversary'
    text :poco_gender, :path => 'poco:gender'
    text :poco_note, :path => 'poco:note'
    text :poco_preferred_username, :path => 'poco:preferredUsername'
    text :poco_utc_offset, :path => 'poco:utcOffset'
    text :poco_connected, :path => 'poco:connected'
  end
 
   many :entry do
    text :id
    text :title
    text :rights
    text :summary
    datetime :updated
 
    text :point, :path => 'georss:point'
    text :line, :path => 'georss:line'
    text :polygon, :path => 'georss:polygon'
    text :box, :path => 'georss:boxs'
    text :circle, :path => 'georss:circle'
    text :elev, :path => 'georss:elev'
    text :floor, :path => 'georss:floor'
    text :radius, :path => 'georss:radius'
    text :featureTypeTag, :path => 'georss:featureTypeTag'
    text :relationshipTag, :path => 'georss:relationshipTag'
    text :featureName, :path => 'georss:featureName'
 
    child :author, :model => Atom::Author
    many :contributor do
      text :name
      text :uri
      text :email
    end
 
    child :content do
      attribute :type, :default => 'text'
      attribute :src
      attribute :lang, :path => 'xml:lang'
      attribute :base, :path => 'xml:base'
      body :value
    end
    child :in_reply_to, :path => 'in-reply-to' do
      attribute :ref
      attribute :type
      attribute :href
      attribute :source
    end
    child :object, :path => 'activity:object' do
      text :id
      text :title
      text :object_type, :path => 'activity:object-type'
      xhash :link, :model => Atom::Link, :key => :rel
    end
    child :target, :path => 'activity:target' do
      text :id
      text :title
      text :object_type, :path => 'activity:object-type'
      xhash :link, :model => Atom::Link, :key => :rel
    end

    child :source do
      text :id
      child :title do
        attribute :type, :default => 'text'
        body :value
      end
      child :subtitle do
        attribute :type, :default => 'text'
        body :value
      end
      child :generator do
        attribute :uri
        attribute :version
        body :value
      end
      text :icon
      text :logo
      text :rights
      many :category do
        attribute :term
        attribute :label
        attribute :scheme
      end
      datetime :updated
      xhash :link, :model => Atom::Link, :key => :rel
      child :author, :model => Atom::Author
    end

    child :total, :path => 'thr:total'
    xhash :link, :model => Atom::Link, :key => :rel
  end
end

class RSS
  include XMapper

  root :rss

  child :channel do
    text :title
    text :description
    text :author
    datetime :lastBuildDate
    datetime :pubDate

    many :link do
      attribute :rel
      attribute :href
      body :value
    end

    many :item do
      text :title
      text :link
      text :description
      text :author
      text :category
      text :comments
      text :enclosure
      text :guid
      datetime :pubDate
      text :source
    end
  end
end

class XRD
  include XMapper

  root :XRD
  namespaces 'xmlns' => 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

  text :subject, :path => 'xmlns:Subject'
  text :Alias
  xhash :Link, :key => :rel do
    attribute :rel
    attribute :href
    attribute :type
    child :Property do
      attribute :type
      body :value
    end
  end
end

$example_atom = <<ATOM
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">

  <title>Example Feed</title>
  <link href="http://example.org/"/>
  <updated>2003-12-13T18:30:02Z</updated>
  <author>
    <name>John Doe</name>
  </author>
  <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>

  <entry>
    <title>Atom-Powered Robots Run Amok</title>
    <link href="http://example.org/2003/12/13/atom03"/>
    <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
    <updated>2003-12-13T18:30:02Z</updated>
    <summary>Some text.</summary>
  </entry>

</feed>
ATOM

$example_rss = <<RSS
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns="http://my.netscape.com/rdf/simple/0.9/">

<channel>
<atom:link rel="hub" href="http://tumblr.superfeedr.com/" xmlns:atom="http://www.w3.org/2005/Atom"/>
<title>RSS Example</title>
<description>This is an example of an RSS feed</description>
<lastBuildDate>Mon, 28 Aug 2006 11:12:55 -0400 </lastBuildDate>
<pubDate>Tue, 29 Aug 2006 09:00:00 -0400</pubDate>

<item>
<title>Item Example</title>
<description>This is an example of an Item</description>
<link>http://www.domain.com/link.htm</link>
<guid isPermaLink="false"> 1102345</guid>
<pubDate>Tue, 29 Aug 2006 09:00:00 -0400</pubDate>
</item>

</channel>
</rss>
RSS

$example_xrd = <<XRD
<?xml version="1.0" encoding="utf-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>acct:shf@snet1.shf</Subject>
  <Alias>http://snet1.shf/index.php/user/1</Alias>
  <Alias>http://snet1.shf/index.php/shf</Alias>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="http://snet1.shf/index.php/shf"></Link>
  <Link rel="http://gmpg.org/xfn/11" type="text/html" href="http://snet1.shf/index.php/shf"></Link>
  <Link rel="describedby" type="application/rdf+xml" href="http://snet1.shf/shf/foaf"></Link>
  <Link rel="http://apinamespace.org/atom" type="application/atomsvc+xml" href="http://snet1.shf/api/statusnet/app/service/shf.xml">
    <Property type="http://apinamespace.org/atom/username">shf</Property>
  </Link>
  <Link rel="http://apinamespace.org/twitter" href="http://snet1.shf/api/">
    <Property type="http://apinamespace.org/twitter/username">shf</Property>
  </Link>
  <Link rel="http://specs.openid.net/auth/2.0/provider" href="http://snet1.shf/index.php/shf"></Link>
  <Link rel="http://schemas.google.com/g/2010#updates-from" href="http://snet1.shf/api/statuses/user_timeline/1.atom" type="application/atom+xml"></Link>
  <Link rel="salmon" href="http://snet1.shf/main/salmon/user/1"></Link>
  <Link rel="http://salmon-protocol.org/ns/salmon-replies" href="http://snet1.shf/main/salmon/user/1"></Link>
  <Link rel="http://salmon-protocol.org/ns/salmon-mention" href="http://snet1.shf/main/salmon/user/1"></Link>
  <Link rel="magic-public-key" href="data:application/magic-public-key,RSA.gACPp7lovVrzsGeRjnnpuXKwpmLGfixZx-ZWbQxb7M1SGfzJ8XtAfemKAgsARjKoR985RycPZDjncATaFP_LRbAx3u5lAN0NqQ2TzDU4NSvxCChpCAaYYv5RqVXjApu50DErjl2wEVXkYtkI5ES1jD5jIjg1yPnfakgfO6yW_30=.AQAB"></Link>
  <Link rel="http://ostatus.org/schema/1.0/subscribe" template="http://snet1.shf/main/ostatussub?profile={uri}"></Link>
</XRD>
XRD

describe XMapper do
  describe 'Atom Feed' do
    it "should create an Atom feed" do
      $atom1 = Atom.new(:id => 'http://no.com/index.atom', :title => { :value => 'Example Feed' }, :updated => Time.now, :entry => [ { :id => 'http://no.com/post-01', :title => 'test', :updated => Time.now, :content => { :value => 'lalalalala' }, :contributor => { :name => 'Myself' }, :total => 10 } ], :author => { :name => 'John' }, :link => { :self => { :href => 'http://no.com/index.atom' } })
      $atom1.to_xml.include?('<name>John</name>').should == true
    end

    it "should parse the previously created feed" do
      $atom2 = Atom.parse($atom1.to_xml)
      $atom1.to_xml.should == $atom2.to_xml
    end

    it "should parse the example feed" do
      @atom3 = Atom.parse($example_atom)
      @atom3.title.value.should == 'Example Feed'
      @atom3.author.name.should == 'John Doe'
      @atom3.entry.first.title.should == 'Atom-Powered Robots Run Amok'
    end
  end

  describe 'RSS' do
    it "should create an RSS Feed" do
      $rss = RSS.new(:channel => { :title => 'my channel', :item => [ { :title => 'First Post' } ] })
      $rss.to_xml.include?('<title>my channel</title>').should == true
    end

    it "should parse the previously created RSS" do
      rss2 = RSS.parse($rss.to_xml)
      $rss.to_xml.should == rss2.to_xml
    end

    it "should parse the example RSS" do
      rss3 = RSS.parse($example_rss)
      rss3.channel.title.should == 'RSS Example'
      rss3.channel.item.first.title.should == 'Item Example'
      rss3.channel.link.select { |v| v.rel == 'hub'}.first.href.should == 'http://tumblr.superfeedr.com/'
    end
  end

  describe 'XRD' do
    it "should parse an example XRD" do
      xrd3 = XRD.parse($example_xrd)
      xrd3.subject.should == 'acct:shf@snet1.shf'
      xrd3.Alias.should == 'http://snet1.shf/index.php/user/1'
      xrd3.Link['magic-public-key'].nil?.should == false
    end
  end
end
