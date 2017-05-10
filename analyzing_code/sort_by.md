# Exploring `sort_by`

My goal was to get clearer about how `sort_by` works internally. Or rather, how it must work, because I have no direct way to check. My initial hunch was that `sort_by` seems fairly closely related to the `map` method.

Start with an example: Let's sort the following array by the *numerical values* of its elements:

```ruby
arr = ['0', '10', '3']
```

This can be achieved using `sort_by`:

```ruby
arr.sort_by do |string|
  string.to_i
end
# => ['0', '3', '10']
```

Or more briefly:

```ruby
arr.sort_by(&:to_i)
# => ['0', '3', '10']
```

Now the question is how does `sort_by` do its magic? There is a hint in the Ruby Docs: ["The current implementation of `sort_by` generates an array of tuples containing the original collection element and the mapped value"](http://ruby-doc.org/core-2.4.1/Enumerable.html#method-i-sort_by).

Based on this, I think what `sort_by` must be doing is something like this:

1. Map the given array to an array of pairs (using the block that was passed).
2. Sort the array of pairs by the second component of each pair (relying on `<=>`).
3. Map each pair to its first component.

The result of step 3 is your sorted array.

After some Googling, I found that this is actually a pretty well-known technique, called [Schwartzian transform](https://en.wikipedia.org/wiki/Schwartzian_transform), so I think I am actually pretty close here.

But however close it may be, one way to demonstrate that this is viable simply as a mental model is to reimplement `sort_by` based on the algorithm just sketched.

First, we observe that we can actually mimick the above three steps in Ruby code fairly closely. This is where the `map` method comes into play. For our running example, observe that the sorted array can be obtained as follows:

```ruby
arr.map { |elem| [elem, elem.to_i] } # step (1)
  .sort { |pair1, pair2| pair1.last <=> pair2.last } # step (2)
  .map { |pair| pair.first } # step (3)
# => ['0', '3', '10']
```

Note that we have replaced the invocation of `sort_by` with calls to `map`, `sort` and `<=>`. This is obviously a lot more cumbersome than using `sort_by` itself, but it's the crucial step towards our reimplementation.

Ruby-internally, it seems rather unlikely that `sort_by` relies on the `sort` method. Presumably, *both* `sort` and `sort_by` rely on something like quicksort, implemented in C. But that is just a guess.

Generalizing the above approach to our example, here is an implementation of a method `my_sort_by` that takes a collection as an argument, and a block:

```ruby
def my_sort_by(collection)
  collection.map { |elem| [elem, yield(elem)] }
    .sort { |pair1, pair2| pair1.last <=> pair2.last }
    .map { |pair| pair.first }
end
```

Invoked with our running example:

```ruby
my_sort_by(arr) { |elem| elem.to_i } # => ['0', '3', '10']
```

Or, using the shorthand notation from above:

```ruby
my_sort_by(arr, &:to_i) # => ['0', '3', '10']
```

To get close to the original `sort_by`, one step is missing: we should implement `my_sort_by` as an `Enumerable` method:

```ruby
module Enumerable
  def my_sort_by
    self.map { |elem| [elem, yield(elem)] }
      .sort { |pair1, pair2| pair1.last <=> pair2.last }
      .map { |pair| pair.first }
  end
end
```

Now we can call `my_sort_by` *on* a collection like this:

```ruby
arr.my_sort_by { |elem| elem.to_i } # => ['0', '3', '10']
```

Or like this:

```ruby
arr.my_sort_by(&:to_i) # => ['0', '3', '10']
```

So we have reinvented the wheel. Nice!