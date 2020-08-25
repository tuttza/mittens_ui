module MittensUi

  class DSLParser
    attr_reader :src_file

    def initialize(src_file)
      @src_file = src_file
    end

    def parse
      src_file_content = File.read(@src_file)
      instance_eval(src_file_content)
    end

  end

end