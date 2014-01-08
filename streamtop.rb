#!/usr/bin/env ruby

require 'optparse'

$ctable = Hash.new(0) # table of string => count

def clearTerm
  print "\e[2J\e[f"
end

def count(s)
  # takes string to count and adds it to global table
  $ctable[s] += 1
end

def sort
  leaders = []
  # walk down count table and fill array with counts and string matched
  $ctable.each do |k,c|
    leaders.push([c, k])
  end
  return leaders.sort.reverse
end

def printTable
  hi_score = 0
  sort[0...$options[:lines]].each do |arr|
    hi_score = hi_score > arr.first ? hi_score : arr.first
    printf("%#{hi_score.to_s.length}s %s\n", arr.first, arr.last)
  end
end

def thread_1
  while $running do
    clearTerm
    printTable
    STDOUT.flush
    sleep $options[:interval]
  end
  clearTerm
  printTable
end

###
##
$options = {
  :delim => ' ',
  :field => 6,
  :lines => 20,
  :interval => 2
}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.separator ""
  opts.separator "Options:"

  opts.on("-d", "--delimiter DELIM", "Delimiter to use (' ')") do |d|
    $options[:delim] = d
  end

  opts.on("-f", "--field FIELD", Integer, "Field to sort/count (1)") do |f|
    $options[:field] = f
  end

  opts.on("-i", "--interval INT", Float, "Delay between display refresh (2)") do |i|
    $options[:interval] = i
  end

  opts.on("-n", "--num_lines LINES", Integer, "Number of lines to display (top 20)") do |n|
    $options[:lines] = n
  end

end.parse!

$running = true
t1 = Thread.new{ thread_1() }
ARGF.each do |line|
  count(line.split($options[:delim])[$options[:field] <= 0 ? 1 : $options[:field]-1])
end
$running = false
t1.join
puts "done."