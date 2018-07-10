require "spec_helper"
require './batch_item_processor'

describe 'Processing items' do

  it 'should return not processed items' do
    bit = BatchItemProcessor.new

    bit.items_processed.should eq([])
  end

  it 'should process items' do
    bit = BatchItemProcessor.new
    bit.process_items([1, 2]) {}

    bit.items_processed.should eq([1, 2])
  end

  it 'should process two packs of items' do
    bit = BatchItemProcessor.new
    bit.process_items([1, 2]) {}
    bit.process_items([3, 4]) {}

    bit.items_processed.should eq([1, 2, 3, 4])
  end
  
  it 'should not process the same item twice' do
    bit = BatchItemProcessor.new
    bit.process_items([1, 2, 2, 3]) {}
    
    bit.items_processed.should eq([1, 2, 3])
  end

  it 'should not process the same item twice when in different arrays' do
    bit = BatchItemProcessor.new
    bit.process_items([4]) {}
    bit.process_items([3, 4]) {}
    bit.process_items([5, 6]) {}

    bit.items_processed.should eq([4, 3, 5, 6])
  end

  it 'should execute do/end block' do
    bit = BatchItemProcessor.new
    items = []
    bit.process_items([1, 2]) do |item|
      items << item
    end

    items.should eq([1, 2])
  end

  it 'should only execute block for item processing' do
    bit = BatchItemProcessor.new
    items = []
    bit.process_items([1, 2]) do |item|
      items << item
    end
    bit.process_items([2, 4]) do |item|
      items << item
    end

    items.should eq([1, 2, 4])
  end
end

describe 'Should Process' do
  it 'should filter item processing' do
    bit = BatchItemProcessor.new
    bit.should_process do |item|
      (item % 2) == 0
    end
    bit.process_items([1, 2, 3, 4]) {}

    bit.items_processed.should eq([2, 4])
  end
end

describe 'Identify' do

  it 'should identify a hash using keys value' do
    data = [
      { 'id' => 1, 'value' => '1' }, # 0
      { 'id' => 2, 'value' => '2' }, # 1
      { 'id' => 2, 'value' => '3' }  # 2
    ]

    bit = BatchItemProcessor.new
    bit.identify('id')
    bit.process_items(data) {}

    bit.items_processed.should eq([data[0], data[1]])
  end

  it 'should identify across groups' do
    data_1 = [{ 'id' => 1, 'value' => '1' }]
    data_2 = [{ 'id' => 1, 'value' => '2' }]

    bit = BatchItemProcessor.new
    bit.identify('id')
    bit.process_items(data_1) {}
    bit.process_items(data_2) {}

    bit.items_processed.should eq(data_1)
  end

  it 'should identify a hash using symbol' do
    data = [
      { :id => 1, 'value' => '1' }, # 0
      { :id => 2, 'value' => '2' }, # 1
      { :id => 2, 'value' => '3' }  # 2
    ]

    bit = BatchItemProcessor.new
    bit.identify(:id)
    bit.process_items(data) {}

    bit.items_processed.should eq([data[0], data[1]])
  end

  it 'should identify object using symbol' do
    class Example
      attr_reader :name
      def initialize(name)
        @name = name
      end
    end

    data = [
      Example.new('John'),
      Example.new('Arthur'),
      Example.new('John')
    ]

    bit = BatchItemProcessor.new
    bit.identify(:name)
    bit.process_items(data) {}

    bit.items_processed.should eq([data[0], data[1]])
  end
end

describe 'Reset' do

  it 'should do nothing when nothing was processed' do
    bit = BatchItemProcessor.new
    bit.reset

    bit.items_processed.should eq([])
  end

  it 'should reset processed items' do
    bit = BatchItemProcessor.new
    bit.process_items([1, 2]) {}
    bit.reset

    bit.items_processed.should eq([])
  end

  it 'should allow item reprocess' do
    bit = BatchItemProcessor.new
    items = []
    bit.process_items([1, 2]) do |item|
      items << item
    end
    bit.reset
    bit.process_items([2, 4]) do |item|
      items << item
    end

    items.should eq([1, 2, 2, 4])
  end
end
