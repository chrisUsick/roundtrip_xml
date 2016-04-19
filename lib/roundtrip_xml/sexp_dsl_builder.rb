# require 'rubygems'
require 'ruby2ruby'
require 'ruby_parser'
require 'pp'
require 'sexp_processor'

class SexpDslBuilder
  def exp
    arr = [
      [:block,
       [:defn,
       :b,
       [:args],
       [:scope, [:block, [:call, nil, :a, [:arglist]]]]]
       ]
    ]
    s = Sexp.from_array arr
    pp s
    ruby2ruby.process(s)
  end
end
s(:block,
  s(:defn,
    :a,
    s(:args),
    s(:scope, s(:block, s(:call, nil, :puts, s(:arglist, s(:str, "A")))))),
  s(:defn, :b, s(:args), s(:scope, s(:block, s(:call, nil, :a, s(:arglist))))))
