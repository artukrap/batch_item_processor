class BatchItemProcessor
  attr_reader :items_processed

  def initialize
    @id = nil
    @items_processed = []

    @proc_items = proc do |item|
      true
    end
  end
  
  def identify(id)
    @id = id
  end

  def reset
    @items_processed = []
  end

  def should_process(&do_block)
    @proc_items = do_block
  end

  def process_items(items)
    items = prepare_data(items).each do |item|
      yield item
    end

    @items_processed.concat(items)
  end

  private

    def prepare_data(items)
      items
        .find_all do |item|
          not_processed?(item) and check_process?(item)
        end
        .uniq do |item|
          identity(item)
        end
    end
    
    def check_process?(item)
      @proc_items.call(item)
    end
    
    def not_processed?(item)
      not_processed = 
        @items_processed
        .detect do |curr_item|
          identity(curr_item) == identity(item)
        end

      return not_processed === nil
    end

    def identity(item)
      return item if @id === nil
      return item[@id] if item.is_a?(Hash)
      item.send(@id)
    end
end