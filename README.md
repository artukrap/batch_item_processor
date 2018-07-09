# The Task - BatchItemProcessor

Create a processor class that will take in an array of items and perform an action on each item, but only if the item was not already processed. The idea is that this class will be useful for processing multiple batches of items while ensuring that each item only gets processed once, even if the item is included in multiple batches.

## Setup

### Requirements

* Ruby 2.4.1

Install gems:

> bundle

### Tests

Run tests using `rspec`

## Methods

The processor will support the following methods:
* process_items - will be called with an enumerable as its argument and requires a block. The block passed in is used to process the item, which will only be called if the processor determines that the item should in fact be processed. The item passed into the block will be whatever the item being processed is. So if a hash is being processed, the item will be the hash.
* processed_items - returns an array of processed items.
* identify - The purpose of this method is to allow different object instances that represent the same data to be treated as the same. If called, it will determine which hash key to use as the identifying value (if a hash is provided) or which method to use (if a non-hash item is provided). It accepts a symbol or string argument that determines the hash key/method name to be used to identify an item. If this method is not called then the item/hash instances will be compared to each other directly.
* should_process - The purpose of this method is to configure an optional callback method that will be used to determine if an item should be processed. This optional callback would return true if the item should be processed, otherwise it will return false. When this method is used, the callback passed to it will be used in conjunction with the built-in "has this item already been processed?" logic.
* reset - If called will reset the processed item state, allowing items to be reprocessed again.

## Examples:

```ruby
processor = BatchItemProcessor.new
processor.process_items([1,2,3,4]) do |item|
  # will process 1, 2, 3 and 4
end

processor.process_items([3,4,5,6]) do |item|
  # will process 5 and 6
end

processor.reset #reset the processed items state so that we can do it all over again

processor.process_items([{'id' => 1}, {'id' => 1, 'name' => 'example'}]) do |item|
  # will process both items
end

processor.reset
processor.identify('id')
processor.process_items([{'id' => 1}, {'id' => 1, 'name' => 'example'}, {'id' => 2}]) do |item|
  # will process the first and last item. 
  # the 2nd item will be skipped since identity was called and its id matches the first item.
end

processor.process_items([{'id' => 2}, {'id' => 3}]) do |item|
  # will only process {'id' => 3}. 
  # item will equal the original item ({'id' => 3}), not just the id
end

processor.reset

# now we are going to use the processor to only process items with values that are even. We do not want to process the same value twice
processor.identify(:value)
processor.should_process do |item|
  item[:value] % 2 == 0
end

processor.process_items([{value: 2}, {value: 3}]) do |item|
  # will only process {value: 2},
end

processor.process_items([{value: 2}, {value: 6}]) do |item|
  # will only process {value: 6} since {value: 2} has already been processed
end

# here we show how the processor will behave when identify is used on non-hash items.  
class Example
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

a = Example.new('a')
b = Example.new('b')

processor = BatchItemProcessor.new
processor.identify(:name)
processor.process_items([a, b]) do |item|
  # will process both items
  # item will == one of the example instances, not one of the name values
end

processor.process_items([Example.new('a')]) do |item|
  # will not process anything, an item with the name 'a' has already been processed
end
```
