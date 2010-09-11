# encoding: UTF-8

require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::google = 'Google'

class JapaneseGeocodingTest < BaseGeocoderTest #:nodoc: all
  GOOGLE_FULL=<<-EOF.strip
  <?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>〒105-0011 東京都港区 芝公園4-2-8</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>〒105-0011 東京都港区 芝公園4-2-8</address><AddressDetails Accuracy="8" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>JP</CountryNameCode><AdministrativeArea><AdministrativeAreaName>東京</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>東京都港区</SubAdministrativeAreaName><Locality><LocalityName>東京都港区</LocalityName><Thoroughfare><ThoroughfareName>芝公園4-2-8</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>105-0011</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><Point><coordinates>139.751599,35.658068,0</coordinates></Point></Placemark></Response></kml>
  EOF

  GOOGLE_CITY=<<-EOF.strip
  <?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Response><name>東京都港区</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>東京都港区、東京都</address><AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>JP</CountryNameCode><AdministrativeArea><AdministrativeAreaName>東京</AdministrativeAreaName><Locality><LocalityName>東京都港区</LocalityName></Locality></AdministrativeArea></Country></AddressDetails><Point><coordinates>139.751587,35.658063,0</coordinates></Point></Placemark></Response></kml>
  EOF
  
  def setup
    super
    @address = '東京都港区、東京都'
    @full_address = '〒105-0011 東京都港区 芝公園4-2-8'
    @full_address_short_zip = '〒105-0011 東京都港区 芝公園4-2-8'

    @latlng = Geokit::LatLng.new(35.658063, 139.751587)
    @success = Geokit::GeoLoc.new({:city=>"東京都港区", :state=>"東京", :country_code=>"JP", :lat=>@latlng.lat, :lng=>@latlng.lng})
    @success.success = true
    
    @google_full_hash = {:street_address=>"芝公園4-2-8", :city=>"東京都港区", :state=>"東京", :zip=>"105-0011", :country_code=>"JP"}
    @google_city_hash = {:city=>"東京都港区", :state=>"東京"}

    @google_full_loc = Geokit::GeoLoc.new(@google_full_hash)
    @google_city_loc = Geokit::GeoLoc.new(@google_city_hash)
  end
  
  def test_google_full_address
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal "東京", res.state
    assert_equal "東京都港区", res.city 
    assert_equal "35.658068,139.751599", res.ll # slightly dif from yahoo
    assert !res.is_us?
    assert_equal "〒105-0011 東京都港区 芝公園4-2-8", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end
  
  def test_google_full_address_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal "東京", res.state
    assert_equal "東京都港区", res.city 
    assert_equal "35.658068,139.751599", res.ll # slightly dif from yahoo
    assert !res.is_us?
    assert_equal "〒105-0011 東京都港区 芝公園4-2-8", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end  
  
  def test_google_full_address_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal 8, res.accuracy
  end

  def test_google_city
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal "東京", res.state
    assert_equal "東京都港区", res.city
    assert_equal "35.658063,139.751587", res.ll
    assert !res.is_us?
    assert_equal "東京都港区、東京都", res.full_address
    assert_nil res.street_address
    assert_equal "google", res.provider
  end  
  
  def test_google_city_accuracy
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal 4, res.accuracy
  end
  
  def test_google_city_with_geo_loc
    response = MockSuccess.new
    response.expects(:body).returns(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&output=xml&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc)
    assert_equal "東京", res.state
    assert_equal "東京都港区", res.city
    assert_equal "35.658063,139.751587", res.ll
    assert !res.is_us?
    assert_equal "東京都港区、東京都", res.full_address
    assert_nil res.street_address
    assert_equal "google", res.provider
  end  
end