require 'cinch'
require 'rspec'
require './helpers'

describe 'Magic Plugin' do
  
  before(:all) do 
    @plugin = Magic.new(fake_bot)
    @card = { :name => 'Acidic Slime',
              :info => '',
              :text => '',
              :link => ''  } 
  end

  describe 'Data Handling' do
    
    it 'should return a block of html data as a string when searching for a valid term' do
      @plugin.get_card_data(@card[:name]).
        class.should == String
    end

    it 'should not return a blank string when searching for a valid term' do
      @plugin.get_card_data(@card[:name]).
        should_not == ''
    end

    it 'should not return nil when searching for a valid term' do
      @plugin.get_card_data(@card[:name]).
        should_not be_nil 
    end

    it 'should return nil when searching for an invalid term' do
      @plugin.get_card_data(rand_string).
        should be_nil 
    end

    describe 'Invalid ' do
      it 'should return an error string when querying for text for invalid data' do 
        @plugin.get_card_text(rand_string).
          should == 'Error finding this card\'s description.'
      end

      it 'should return an error string when querying for text for invalid data' do 
        @plugin.get_card_text(rand_string).
          should == 'Error finding this card\'s description.'
      end
      
      it 'should return an error string when querying for text for invalid data' do 
        @plugin.get_card_text(rand_string).
          should == 'Error finding this card\'s description.'
      end

      it 'should return an error string when querying for text for invalid data' do 
        @plugin.get_card_text(rand_string).
          should == 'Error finding this card\'s description.'
      end
    end 
  end

  describe 'Channel Messages' do

  it "should return an error on a bad card name" do
    @plugin.get_card(rand_string).
      should == '[Magic] Card not found!'
  end

  end
  

end
