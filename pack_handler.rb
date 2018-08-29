class PackHandler

  def initialize
    @processed_objects = []
  end

  def proc_items(array)
    return false unless array.instance_of?(Array)
    process_with_block(array) if process_with

    array.each do |element|
      next if already_processed?(element)
      processed_objects << element
      yield element
    end
  end

  def should_proc(&block)
    @process_with = block
  end

  def procd_items
    processed_objects
  end

  def identify(identifier)
    return false if identifier.nil? || identifier.empty?
    @identifier = identifier
  end

  def reset
    @identifier, @process_with = nil
    @processed_objects = []
  end

  private

  attr_accessor :processed_objects, :process_with, :identifier

  def process_with_block(array)
    array.select! { |element| process_with.call(element) }
  rescue
    raise ArgumentError.new('Invalid params')
  end

  def already_processed?(obj)
    identifier ? identifier_processed?(obj) : processed_objects.include?(obj)
  end

  def identifier_processed?(obj)
    return true if processed_objects.include?(obj)
    objects_for_check = processed_objects.select { |item| item.instance_of?(obj.class) }
    obj.instance_of?(Hash) ? hash_object_processed?(objects_for_check, obj) : object_processed?(objects_for_check, obj)
  end

  def hash_object_processed?(objects_for_check, obj)
    return false unless obj.has_key?(identifier)
    objects_for_check.any? { |hash| hash[identifier] == obj[identifier] }
  end

  def object_processed?(objects_for_check, obj)
    return false unless obj.class.method_defined?(identifier)
    objects_for_check.any? { |item| item.send(identifier) == obj.send(identifier) }
  end
end
