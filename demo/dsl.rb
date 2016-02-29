# define :ASub, :A, b_value, e_value do
define :ASub, :A, :b_value, :e_value do
  b b_value
  c 'bar'
  d (expand :D do
    e e_value
    f 'quux'
  end)
end
# define :ASub2, :ASub, :c_value do
#   b_value 'foo'
#   e_value 'baz'
# end
define :DSub, :D, :f_value do
  e 'baz'
  f f_value
end
a (expand :A do
  b 'foo'
  c 'bar'
  d (expand :D do
    e 'baz'
    f 'quux'
  end)
end)

a (expand :ASub do
  b_value 'foo'
  e_value 'baz'
end)

a (expand :A do
  b 'foo'
  c 'bar'
  d (expand :DSub do
    f_value 'quux'
  end)
end)

a (expand :ASub do
  b_value 'foo'
  c 'chris'
  e_value 'baz'
  d (expand :DSub do
    f_value 'quuz'
  end)
end)

# a (expand :ASub2 do
#
# end)
