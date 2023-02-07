require "mruby_gem_scaffolding/version"

module MrubyGemScaffolding
  module Utility
    class << self
      # from thor gem
      def snake_case(str)
        return str.downcase if str =~ /^[A-Z_]+$/
        str.gsub(/\B[A-Z]/, '_\&').squeeze("_") =~ /_*(.*)/
        Regexp.last_match(-1).downcase
      end

      # from thor gem
      def camel_case(str)
        return str if str !~ /_/ && str =~ /[A-Z]+.*/
        str.split("_").map(&:capitalize).join
      end
    end
  end

  class << self
    def empty_project
      {
        "README.md" => '',
        "mrbgem.rake" => '',
        "include" => {},
        "mrblib" => {},
        "src" => {},
        "tools" => {},
        "test" => {},
        "LICENSE" => '',
      }
    end

    def generate(user_name:, project_name:)
      result = empty_project

      result["README.md"] =
        <<MULTILINE
# #{Utility.camel_case(project_name)}
An mruby gem created by #{user_name} using mruby_gem_scaffolding.
MULTILINE

      result["mrbgem.rake"] =
        <<MULTILINE
MRuby::Gem::Specification.new('#{Utility.snake_case(project_name)}') do |spec|
  spec.license = 'MIT'
  spec.author  = '#{user_name}'
end
MULTILINE

      result["src"]["main.c"] =
        <<MULTILINE
#include <mruby.h>
#include <stdio.h>

// defining the function to be later bound to a ruby method
static mrb_value
hello_world(mrb_state *mrb, mrb_value self)
{
    printf("Hello World");

    return mrb_nil_value(); // return null
}

// gem initializer
void
mrb_#{Utility.snake_case(project_name)}_gem_init(mrb_state* mrb) {
    struct RClass *#{Utility.snake_case(project_name)}_class = mrb_define_module(mrb, "#{Utility.camel_case(project_name)}");
    mrb_define_class_method(
      mrb,                    // Mruby VM state
      #{Utility.snake_case(project_name)}_class,  // Class we bind method to
      "say_hello",            // Name of method
      hello_world,        // Function we are binding as a method
      MRB_ARGS_NONE()         // How many arguments are optional/required
    );
}

// gem finalizer
void
mrb_#{Utility.snake_case(project_name)}_gem_final(mrb_state* mrb) {

}
MULTILINE

      result["LICENSE"] =
        <<MULTILINE
The MIT License (MIT)

Copyright (c) #{Time.now.year} #{user_name}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

MULTILINE

      return result
    end

    def write(dir, hash_data)
      Dir.mkdir dir unless File.exists? dir
      hash_data.each do |key, value|
        if value.is_a? Hash
          write("#{dir}/#{key}", value)
        else
          File.open("#{dir}/#{key}", 'w') { |file| file.write(value) }
        end
      end
    end
  end

end
