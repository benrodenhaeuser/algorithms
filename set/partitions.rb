# generate all partitions of a set.

require 'set'
require 'benchmark'

# ---------------------------------------------------------------------------
# k-combinations and powerset
# ---------------------------------------------------------------------------

def powerset(set)
  powerset = [].to_set
  (0..set.size).each { |k| powerset += combinations(set, k) }
  powerset
end

def combinations(set, k)
  if k == 0
    [[].to_set].to_set
  elsif k == 1
    set.map { |elem| [elem].to_set }.to_set
  elsif set.size >= k
    elem = set.to_a.first
    combinations(set.select { |other| elem != other }, k - 1).map { |combo| [elem].to_set + combo }.to_set +
    combinations(set.select { |other| elem != other }, k)
  else
    [].to_set
  end
end

# ---------------------------------------------------------------------------
# displaying sets of sets
# ---------------------------------------------------------------------------

def display_string(set)
  string = "{"

  if !set.to_a.first.is_a?(Set)
    string << set.to_a.map(&:to_s).join(", ")
  else
    string << set.to_a.map do |elem|
      display_string(elem)
    end.join(", ")
  end
  string << "}"
end

# ---------------------------------------------------------------------------
# solution 1: using the powerset (without top and bottom)
# ---------------------------------------------------------------------------

# we make use of an auxiliary method non_empty_proper_subsets, which gives the powerset minus the top and bottom elements. this auxiliary method is defined in terms of another auxiliary method which gives the k-combinations of a set, i.e., the subsets of cardinality k.

def partitions1(set)
  if set.size == 0
    [set].to_set # { {} }
  elsif set.size == 1
    [[set].to_set].to_set # { { set } }
  else
    partitions = [].to_set
    non_empty_proper_subsets(set).each do |subset|
      partitions1(set - subset).each do |partition|
        partitions << ([subset].to_set + partition)
      end
    end
    partitions << [set].to_set
  end
end

def non_empty_proper_subsets(set)
  powerset(set) - [set, [].to_set].to_set
end

# ---------------------------------------------------------------------------
# solution 2: using the refinement order on partitions
# ---------------------------------------------------------------------------

def partitions2(set, partition = finest(set), partitions = [finest(set)].to_set)
  combinations(partition, 2).each do |set_of_two|
    stored_partition = partition
    combo = set_of_two.to_a.first + set_of_two.to_a.last
    partition = (partition - set_of_two) << combo
    partitions << partition
    partitions2(set, partition, partitions)
    partition = stored_partition
  end
  partitions
end

# note that if partition == coarsest(set), the set of 2-combinations of partition elements will be 0 (no way to draw two elements from a singleton set!). this ensures that the recursion terminates, it's like an implicit base case.

def finest(set)
  set.map { |elem| [elem].to_set }.to_set
end

# not used
def coarsest(set)
  [set].to_set
end

# ---------------------------------------------------------------------------
# solution 3: add memoization to solution 2
# ---------------------------------------------------------------------------

# since we already carry around the partitions computed so far as a method parameter, memoization is not much of a change.

def partitions3(set, partition = finest(set), partitions = [finest(set)].to_set)
  combinations(partition, 2).each do |set_of_two|
    stored_partition = partition
    combo = set_of_two.to_a.first + set_of_two.to_a.last
    partition = (partition - set_of_two) << combo
    if partitions.add?(partition) # NEW
      partitions << partition
      partitions3(set, partition, partitions)
    end
    partition = stored_partition
  end
  partitions
end

# ---------------------------------------------------------------------------
# tests
# ---------------------------------------------------------------------------

# tests for solution 1 (based on powerset)

# set = [].to_set
# p display_string(partitions1(set))
# # "{{}}"
#
# set = [1].to_set
# p display_string(partitions1(set))
# # "{{{1}}}"
#
# set = [1, 2].to_set
# p display_string(partitions1(set))
# # "{{{1}, {2}}, {{1, 2}}}"
#
# set = [1, 2, 3].to_set
# p display_string(partitions1(set))
# # "{{{1}, {2}, {3}}, {{1}, {2, 3}}, {{2}, {1, 3}}, {{3}, {1, 2}}, {{1, 2, 3}}}"

# tests for solution 2 (based on refinement order)

# set = [].to_set
# p partitions2(set) == partitions1(set) # true
#
# set = [1].to_set
# p partitions2(set) == partitions1(set) # true
#
# set = [1, 2].to_set
# p partitions2(set) == partitions1(set) # true
#
# set = [1, 2, 3].to_set
# p partitions2(set) == partitions1(set) # true


# tests for solution 3 (based on refinement order)

# set = [].to_set
# p partitions3(set) == partitions1(set) # true
#
# set = [1].to_set
# p partitions3(set) == partitions1(set) # true
#
# set = [1, 2].to_set
# p partitions3(set) == partitions1(set) # true
#
# set = [1, 2, 3].to_set
# p partitions3(set) == partitions1(set) # true


# ---------------------------------------------------------------------------
# benchmarks
# ---------------------------------------------------------------------------

# how long do the two solutions take to solve a 7-element set?
# what is the number of recursive method calls?

# set = (1..7).to_a.to_set
# puts Benchmark.realtime { partitions1(set) } # 3.933948999736458
# puts Benchmark.realtime { partitions2(set) } # 11.537049000151455
# puts Benchmark.realtime { partitions3(set) } # 0.28797500021755695

# number of calls:
# partitions1: 47293
# partition2: 135787
# partition3: 877

# So using memoized values leads to a dramatic speed increase, and corresponding decrease in the number of method calls.
